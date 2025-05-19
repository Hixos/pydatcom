import json
import re
from configreader import DatcomConfig
from aerodata import Aerodata
from scipy import io
import numpy as np
import h5py


def listToCSV(list_: list):
    line = ",".join([str(x) for x in list_]) + "\n"
    return line


def sanitizeKey(key: str):
    return re.sub(r"[^0-9a-zA-Z]+", "", key)


def sanitizeDictKeys(d: dict):
    out = {}
    for k, v in d.items():
        sanitized = sanitizeKey(k)
        if sanitized in out:
            raise KeyError("Duplicate key '" + sanitized + "'")

        if isinstance(v, dict):
            out[sanitized] = sanitizeDictKeys(v)
        else:
            out[sanitized] = v
    return out


def saveCSV(file_prefix, config: DatcomConfig, aero_data: Aerodata):
    """Outputs aerodynamic coefficient in a csv file, and state vectors
    in a json file.
    """

    with open(file_prefix + "_states.json", "w") as fstates:
        fstates.write(json.dumps(config.states, indent=4))

    state_names = list(config.states.keys())
    data_names = sorted(aero_data.aerodata.keys())

    header = listToCSV(state_names + data_names)

    with open(file_prefix + "_coeffs.csv", "w") as fcsv:
        fcsv.write(header)
        for i in range(0, aero_data.getFlatSize()):
            state_list = aero_data.getStateFromFlatIndex(i)
            data_dict = aero_data.getDataFromFlatIndex(i)
            data_list = [data_dict[k] for k in data_names]
            values = state_list + data_list
            fcsv.write(listToCSV(values))


def saveMAT(file_prefix, config: DatcomConfig, aero_data: Aerodata):
    mat_dict = {}
    mat_dict["states"] = config.states
    mat_dict["coeffs"] = aero_data.aerodata
    io.savemat(file_prefix + ".mat", mdict=sanitizeDictKeys(mat_dict))


def saveNPZ(file_prefix, config: DatcomConfig, aero_data: Aerodata):
    np.savez(file_prefix + "_coeffs", **sanitizeDictKeys(aero_data.aerodata))
    np.savez(file_prefix + "_states", **sanitizeDictKeys(config.states))


def saveHDF(file_prefix, config: DatcomConfig, aero_data: dict[str, np.ndarray]):
    with h5py.File(file_prefix + "_coeffs.h5", "w") as hf_coeffs:
        for key in aero_data.keys():
            hf_coeffs.create_dataset(
                key.replace("/", ""), data=aero_data[key], dtype=np.float32
            )

        for key in config.states.keys():
            hf_coeffs.create_dataset(key, data=config.states[key], dtype=np.float32)

        hf_coeffs.close()
