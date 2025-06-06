import time
import numpy as np
from for006parser import DatcomCase


class Aerodata:
    def __init__(self, aerodata, state_vecs, state_fin_info) -> None:
        self.aerodata = aerodata
        self.state_vecs = state_vecs
        self.state_fin_info = state_fin_info

    def addFromDatcomCases(self, cases: list):
        for c in cases:
            self.addFromDatcomCase(c)

    def addFromDatcomCase(self, case: DatcomCase):
        case_state = self.getCaseState(case)

        for mach, data in case.data.items():
            for i, alpha in enumerate(case.alphas):
                state = (alpha, mach) + case_state

                # Indices of the state in the n-dim aerodata tensors
                state_index = self.getStateIndex(state)

                # For each tensor
                for name, vals in data.items():
                    if name not in self.aerodata:
                        continue
                    self.aerodata[name][state_index] = vals[i]

    def initAerodata(self, name: str):
        state_size = tuple([len(v) for v in self.state_vecs])
        self.aerodata[name] = np.zeros(state_size, dtype=np.float32)

    def getFlatSize(self):
        aerodata_size = tuple([len(x) for x in self.state_vecs])
        return np.prod(aerodata_size)

    def getCaseState(self, case: DatcomCase):
        """Returns a tuple of constant state variables within a case:
        (beta, altitude, [delta1, delta2...])

        Must be prependended with (alpha, mach) to obtain the full
        aerodynamic state
        """
        state = (case.beta, case.altitude)

        # Which fin deflections are used as a state?
        for set, fin in self.state_fin_info:
            state += (case.deflect[set - 1][fin - 1],)

        return state

    def getStateIndex(self, state):
        index = [self.state_vecs[i].index(s) for i, s in enumerate(state)]
        return tuple(index)

    def getStateFromFlatIndex(self, flat_index: int):
        index = self.getIndex(flat_index)
        state = [s[index[i]] for i, s in enumerate(self.state_vecs)]
        return state

    def getDataFromFlatIndex(self, index: int):
        aerodata_size = tuple([len(x) for x in self.state_vecs])
        i = np.unravel_index(index, aerodata_size)
        out = {}
        for k, v in self.aerodata.items():
            out[k] = v[i]
        return out

    def getIndex(self, flat_index: int):
        aerodata_size = tuple([len(x) for x in self.state_vecs])
        return np.unravel_index(flat_index, aerodata_size)
