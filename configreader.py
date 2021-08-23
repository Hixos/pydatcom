import configparser
from collections import OrderedDict
from itertools import product


def parseConfigArray(array: str):
    """Parses a comma-separated array of floats"""
    vals = array.split(",")
    vals = [x.strip() for x in vals]

    floats = [float(x) for x in vals if len(x) > 0]
    return floats


class DatcomConfig:
    def __init__(self, config_file):
        self.states = OrderedDict()
        self.max_cases_per_file = 0

        # Information about which fins are used as aerodynamic state
        # in the form (finset, fin) e.g. [(1,1), (1,2)] -> Fin 1 and
        # 2 of finset 1
        self.fin_states = []

        self.deflect_cases = []

        self.readConfig(config_file)

    def readConfig(self, filename):
        cfgparser = configparser.ConfigParser()
        cfgparser.read(filename)

        self.max_cases_per_file = cfgparser.getint(
            "Options", "MaxCasesPerFile", fallback=0
        )

        # Read fin deflection information
        deflect = [self.readDeflections(cfgparser, i + 1) for i in range(8)]

        # State vectors
        self.states["alpha"] = parseConfigArray(
            cfgparser["FlightConditions"]["Alphas"]
        )
        self.states["mach"] = parseConfigArray(
            cfgparser["FlightConditions"]["Machs"]
        )
        self.states["beta"] = parseConfigArray(
            cfgparser["FlightConditions"]["Betas"]
        )
        self.states["altitude"] = parseConfigArray(
            cfgparser["FlightConditions"]["Altitudes"]
        )

        for i, d in enumerate(deflect):
            if d["mode"] == "Symmetric":
                self.states["fin" + str(i + 1) + ".delta"] = d["deltas"]
                self.fin_states.append((i + 1, 1))
                self.deflect_cases.append(
                    [tuple([x] * d["numfins"]) for x in d["deltas"]]
                )
            elif d["mode"] == "Product":
                for fin in range(1, d["numfins"] + 1):
                    self.states["fin" + str(i + 1) + ".delta" + str(fin)] = d[
                        "deltas"
                    ]
                    self.fin_states.append((i + 1, fin))
                self.deflect_cases.append(
                    list(
                        product(*[d["deltas"] for i in range(0, d["numfins"])])
                    )
                )
            else:
                if len(d["deltas"]) == d["numfins"]:
                    self.deflect_cases.append(
                        [tuple(d["deltas"][0:d["numfins"]])]
                    )
                else:
                    if len(d["deltas"]) > 0:
                        print(
                            "Number of fin deflection must equal number of "
                            "fins in the 'Fixed' case. Using 0 deg for all fins."
                        )
                    self.deflect_cases.append([()])

    def readDeflections(self, config, finset):
        deflect = {}

        sect_name = "FinDeflections" + str(finset)

        deflect["mode"] = config.get(sect_name, "Mode", fallback="Fixed")
        deflect["numfins"] = config.getint(sect_name, "NumFins", fallback=0)
        deflect["deltas"] = parseConfigArray(
            config.get(sect_name, "Deltas", fallback="")
        )

        return deflect
