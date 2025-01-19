#!/usr/bin/python3
import argparse
import itertools
import multiprocessing
from os import mkdir, path
from pathlib import Path
import shutil
import subprocess
import sys

import aerodata
from configreader import DatcomConfig
from for005builder import build005
from for006parser import readDatcomOutput
from multiprocessing import Pool, Value
from dataclasses import dataclass
import output

case_counter = None
store_datcom_raw_output = False

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

parser.add_argument("-so", "--save-output", action="store_true")

output_folder = Path("./output")
datcom_folder = Path("./datcom")
datcom_out_dir = Path("./datcom_outputs")

for005_name = "for005.dat"
for006_name = "for006.dat"
datcom_exe = "datcom.exe"

rocket_def_file = "for005rocket.dat"
enable_stdout = False

if enable_stdout:
    stdout = sys.stdout
else:
    stdout = subprocess.DEVNULL


def init_pool(case_counter_arg, config_arg):
    global case_counter
    global config
    case_counter = case_counter_arg
    config = config_arg


def gen_coeffs(args):
    case_i, cases = args

    thread_id = multiprocessing.current_process()
    global case_counter
    global config

    with case_counter.get_lock():
        case_counter.value += len(cases)

    print(
        f"Calculating coefficients... ({case_counter.value}/{config.total_num_cases}) (thread {thread_id.pid})"
    )

    dir = datcom_out_dir / Path(f"thread_{thread_id.pid}")

    if dir.exists():
        shutil.rmtree(dir)
    dir.mkdir(parents=True)

    for005_path = dir / for005_name
    for006_path = dir / for006_name

    build005(for005_path, config.config, cases, config.rocket_def)
    subprocess.run(
        [str(datcom_folder / datcom_exe)],
        stdout=stdout,
        stderr=subprocess.STDOUT,
        cwd=dir,
    )

    with open(for006_path) as for006_file:
        for006 = for006_file.read()

    case_data = readDatcomOutput(for006)

    if store_datcom_raw_output:
        shutil.move(
            for006_path,
            path.join(
                "datcom_outputs", "for006.{:03d}.dat".format(case_i + 1)
            ),
        )
    return case_i, case_data


if __name__ == "__main__":
    args = parser.parse_args()
    config_path = args.config_file
    store_datcom_raw_output = args.save_output

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

    print("Total number of Datcom cases: {}".format(len(case_list)))
    print(
        "Total number of possible aerodynamic states: {}".format(
            total_state_num
        )
    )

    print(
        "Expected npz file size: {:.0f} MB".format(
            total_state_num * 8 / 1024 / 1024 * 24
        )
    )

    # Rocket definition
    with open(rocket_def_file) as rocket_file:
        rocket_def = rocket_file.read()

    aero_data = aerodata.Aerodata(state_vectors, dat_config.fin_states)

    # Split cases into smaller blocks (datcom cannot handle many
    # of them in a singe run)
    case_list_split = splitCases(case_list, dat_config.max_cases_per_file)

    if path.isdir(output_folder):
        shutil.rmtree(output_folder)

    if datcom_out_dir.exists():
        shutil.rmtree(datcom_out_dir)

    mkdir(output_folder)

    case_counter = Value("i", 0)

    case_jobs = list(enumerate(case_list_split))

    config = Config(total_num_cases, dat_config, rocket_def)

    with Pool(
        processes=None, initializer=init_pool, initargs=(case_counter, config)
    ) as p:
        data = p.map(gen_coeffs, case_jobs)
        for i, case in data:
            aero_data.addFromDatcomCases(case)

    print("Saving results...")

    # print("CSV...")
    # output.saveCSV(path.join(output_folder, "for006"), dat_config, aero_data)

    print("Matlab...")
    output.saveMAT(path.join(output_folder, "for006"), dat_config, aero_data)

    # print("NPZs...")
    # output.saveNPZ(path.join(output_folder, "for006"), dat_config, aero_data)

    print("HDF5...")
    output.saveHDF(path.join(output_folder, "for006"), dat_config, aero_data)

    print("Done")
