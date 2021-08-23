from for005builder import build005
from configreader import DatcomConfig
from for006parser import readDatcomOutput
import itertools
import subprocess
import aerodata
from os import path, mkdir
import shutil
import sys
import output


def splitCases(cases, size):
    split = []
    for i, c in enumerate(cases):
        if i % size == 0:
            split.append([])
        split[-1].append(c)
    return split


output_folder = "output"
datcom_folder = "datcom"
config_path = "config.cfg"
for005_path = path.join(datcom_folder, "for005.dat")
rocket_def_file = "for005rocket.dat"
for006_path = path.join(datcom_folder, "for006.dat")
datcom_cmd = "./datcom"
store_datcom_raw_output = False

enable_stdout = False

if enable_stdout:
    stdout = sys.stdout
else:
    stdout = subprocess.DEVNULL

config = DatcomConfig(config_path)

# List of all datcom cases
case_list = list(
    itertools.product(
        config.states["beta"], config.states["altitude"], *config.deflect_cases
    )
)

state_vectors = list(config.states.values())

print("Total number of Datcom cases: {}".format(len(case_list)))
print(
    "Total number of possible aerodynamic states: {}".format(
        len(case_list)
        * len(config.states["alpha"])
        * len(config.states["mach"])
    )
)


# Rocket definition
with open(rocket_def_file) as rocket_file:
    rocket_def = rocket_file.read()

aero_data = aerodata.Aerodata(state_vectors, config.fin_states)

# Split cases into smaller blocks (datcom cannot handle many
# of them in a singe run)
case_list_split = splitCases(case_list, config.max_cases_per_file)

case_counter = 0

if path.isdir("datcom_outputs"):
    shutil.rmtree("datcom_outputs")
mkdir("datcom_outputs")

if path.isdir(output_folder):
    shutil.rmtree(output_folder)

mkdir(output_folder)

for i, cases in enumerate(case_list_split):
    case_counter += len(cases)
    print(
        "Calculating coefficients... ({}/{})".format(
            case_counter, len(case_list)
        )
    )
    build005(for005_path, config, cases, rocket_def)

    # Run datcom
    subprocess.run(
        [datcom_cmd],
        stdout=stdout,
        stderr=subprocess.STDOUT,
        cwd=datcom_folder,
    )

    with open(for006_path) as for006_file:
        for006 = for006_file.read()

    case_data = readDatcomOutput(for006)
    aero_data.addFromDatcomCases(case_data)

    if store_datcom_raw_output:
        shutil.move(
            for006_path,
            path.join("datcom_outputs", "for006.dat.{:03d}".format(i + 1)),
        )

print("Saving results...")

print("CSV...")
output.saveCSV(path.join(output_folder, "for006"), config, aero_data)

print("Matlab...")
output.saveMAT(path.join(output_folder, "for006"), config, aero_data)

print("NPZs...")
output.saveNPZ(path.join(output_folder, "for006"), config, aero_data)

print("Done")
