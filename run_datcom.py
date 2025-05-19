import argparse
from dataclasses import dataclass
import itertools
from multiprocessing import Pool, Value
import multiprocessing
from multiprocessing.shared_memory import SharedMemory
from pathlib import Path
import shutil
import subprocess
from sys import stdout

import aerodata
from configreader import DatcomConfig
import numpy as np

from for005builder import build005
from for006parser import readDatcomOutput
import output

OUTPUT_FOLDER = Path("./output")
DATCOM_FOLDER = Path("./datcom")
DATCOM_OUTPUTS = Path("./datcom_outputs")

COEFFICIENTS = [
    "CA",
    "CAQ",
    "CD",
    "CL",
    "CL/CD",
    "CLL",
    "CLLB",
    "CLLP",
    "CLLR",
    "CLN",
    "CLNB",
    "CLNP",
    "CLNR",
    "CM",
    "CMA",
    "CMAD",
    "CMQ",
    "CN",
    "CNA",
    "CNAD",
    "CNQ",
    "CY",
    "CYB",
    "CYP",
    "CYR",
    "X-C.P.",
]

DATCOM_EXE = "datcom"


@dataclass
class Config:
    total_num_cases: int
    config: DatcomConfig
    rocket_def: str


def splitCases(cases, size):
    split = []
    for i, c in enumerate(cases):
        if i % size == 0:
            split.append([])
        split[-1].append(c)
    return split


def init_worker(
    case_counter_arg, config_arg, shm_names, shape, dat_config, wine_arg
):
    global case_counter
    global config

    global shm_handles
    global aero_data
    global wine
    wine = wine_arg

    case_counter = case_counter_arg
    config = config_arg

    shm_handles = {}
    shm_aero_data = {}
    for c in COEFFICIENTS:
        shm_handles[c] = SharedMemory(name=shm_names[c])
        shm_aero_data[c] = np.ndarray(
            shape, dtype=np.float32, buffer=shm_handles[c].buf
        )

    aero_data = aerodata.Aerodata(
        shm_aero_data, state_vectors, dat_config.fin_states
    )


def worker(args):
    case_i, cases = args

    thread_id = multiprocessing.current_process()
    global case_counter
    global config
    global aero_data
    global wine

    dir = DATCOM_OUTPUTS / Path(f"thread_{thread_id.pid}")

    if dir.exists():
        shutil.rmtree(dir)
    dir.mkdir(parents=True)

    for005_path = dir / "for005.dat"
    for006_path = dir / "for006.dat"

    build005(for005_path, config.config, cases, config.rocket_def)

    cmd = [str((DATCOM_FOLDER / DATCOM_EXE).absolute())]

    if wine:
        cmd = ["wine"] + cmd

    subprocess.run(
        cmd,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        cwd=dir,
    )

    with open(for006_path) as for006_file:
        for006 = for006_file.read()

    case_data = readDatcomOutput(for006)
    aero_data.addFromDatcomCases(case_data)

    with case_counter.get_lock():
        case_counter.value += len(cases)
    print(
        f"Completed ({case_counter.value}/{config.total_num_cases}) (thread {thread_id.pid})"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Generate aerodata tensors from Datcom"
    )
    parser.add_argument(
        "config_file",
        metavar="cfgfile",
        type=str,
        nargs="?",
        default="config.cfg",
        help="Config input file",
    )
    parser.add_argument("-r", "--rocket-def", action="store_true")
    parser.add_argument("-so", "--save-output", action="store_true")
    parser.add_argument("-w", "--wine", action="store_true")
    parser.add_argument("-j", "--num-threads", type=int, default=None)

    args = parser.parse_args()
    config_path = args.config_file
    store_datcom_raw_output = args.save_output
    num_threads = args.num_threads
    wine = args.wine

    # Read config and generate cases
    dat_config = DatcomConfig(config_path)
    case_list = list(
        itertools.product(
            dat_config.states["beta"],
            dat_config.states["altitude"],
            *dat_config.deflect_cases,
        )
    )
    total_num_cases = len(case_list)
    state_vectors = list(dat_config.states.values())
    total_state_num = (
        len(case_list)
        * len(dat_config.states["alpha"])
        * len(dat_config.states["mach"])
    )

    print(f"Num threads: {num_threads}")
    print("Total number of Datcom cases: {}".format(len(case_list)))
    print(
        "Total number of possible aerodynamic states: {}".format(
            total_state_num
        )
    )

    print(
        "Expected output file size: {:.0f} MB".format(
            total_state_num * 4 / 1024 / 1024 * len(COEFFICIENTS)
        )
    )

    shape = tuple([len(v) for v in state_vectors])

    shared_mems: dict[str, SharedMemory] = {}
    shared_mems_names: dict[str, str] = {}
    aerodata_mats = {}

    for c in COEFFICIENTS:
        shared_mems[c] = SharedMemory(create=True, size=np.prod(shape) * 4)
        matrix = np.ndarray(shape, dtype=np.float32, buffer=shared_mems[c].buf)
        matrix[:] = 0
        aerodata_mats[c] = matrix
        shared_mems_names[c] = shared_mems[c].name

        # Rocket definition
    with open("for005rocket.dat") as rocket_file:
        rocket_def = rocket_file.read()

    # Split cases into smaller blocks (datcom cannot handle many
    # of them in a singe run)
    case_list_split = splitCases(case_list, dat_config.max_cases_per_file)

    if OUTPUT_FOLDER.exists():
        shutil.rmtree(OUTPUT_FOLDER)

    if DATCOM_OUTPUTS.exists():
        shutil.rmtree(DATCOM_OUTPUTS)

    OUTPUT_FOLDER.mkdir(parents=True)

    global case_counter
    case_counter = Value("i", 0)

    case_jobs = list(enumerate(case_list_split))
    config = Config(total_num_cases, dat_config, rocket_def)

    with Pool(
        processes=num_threads,
        initializer=init_worker,
        initargs=(
            case_counter,
            config,
            shared_mems_names,
            shape,
            dat_config,
            wine,
        ),
    ) as p:
        p.map(worker, case_jobs)

    print("Saving results...")

    # print("CSV...")
    # output.saveCSV(path.join(output_folder, "for006"), dat_config, aero_data)

    # print("Matlab...")
    # output.saveMAT(path.join(output_folder, "for006"), dat_config, aero_data)

    # print("NPZs...")
    # output.saveNPZ(path.join(output_folder, "for006"), dat_config, aero_data)

    print("HDF5...")

    output.saveHDF(str(OUTPUT_FOLDER / "for006"), dat_config, aerodata_mats)

    print("Done")

    for c in COEFFICIENTS:
        shared_mems[c].close()
        shared_mems[c].unlink()
