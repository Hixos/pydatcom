from collections.abc import Iterable
from configreader import DatcomConfig

def formatNumber(v) -> str:
    if isinstance(v, int):
        return "{}.".format(v)
    elif v * 10 - int(v) * 10 > 0:
        return str(round(v, 6))
    else:
        return str(v)


def listToCard(name: str, vals: list):
    card = ""
    row = "  " + name + " = "

    for i, v in enumerate(vals):
        vs = formatNumber(v) + ","
        if len(row) + len(vs) > 79:
            card += row + "\n"
            row = "  " + name + "(" + str(i + 1) + ") = "
        row += vs
    card += row
    return card


def printNameList(f, name, data):
    if len(data) == 0:
        return

    namelist = " $" + name
    for k, v in data.items():
        namelist += "\n"
        if isinstance(v, str):
            namelist += "  " + k + " = " + v + ","
        elif isinstance(v, Iterable):
            namelist += listToCard(k, list(v))
        else:
            namelist += "  " + k + " = " + formatNumber(v) + ","
    namelist += "$\n"
    f.write(namelist)


def printFltCon(f, case, config: DatcomConfig, first: bool):
    namelist = {}
    if first:
        namelist["NALPHA"] = len(config.states["alpha"])
        namelist["ALPHA"] = config.states["alpha"]

        namelist["NMACH"] = len(config.states["mach"])
        namelist["MACH"] = config.states["mach"]

    namelist["BETA"] = case["beta"]
    namelist["ALT"] = (
        str(len(config.states["mach"])) + "*" + formatNumber(case["alt"])
    )
    printNameList(f, "FLTCON", namelist)


def printDeflct(f, case):
    namelist = {}
    for i in range(1, 5):
        if case.get("delta" + str(i), None) is not None:
            namelist["DELTA" + str(i)] = case.get("delta" + str(i))
    printNameList(f, "DEFLCT", namelist)


def printOptions(f, i):
    s = (
        "CASEID CASE"
        + str(i + 1)
        + "\nDERIV RAD\nDIM M\n"
        + "DAMP\n"
    )
    f.write(s)


def build005(file, config, cases, rocket_config):
    with open(file, "w") as f:
        for ic, c in enumerate(cases):
            case_dict = {
                "beta": c[0],
                "alt": c[1],
            }

            for i in range(2, len(c)):
                case_dict["delta" + str(i-1)] = (
                    None if c[i] == () else c[i]
                )

            printOptions(f, ic)
            printFltCon(f, case_dict, config, ic == 0)

            if ic == 0:
                f.write(rocket_config)

            printDeflct(f, case_dict)
            f.write("SAVE\nNEXT CASE\n")
