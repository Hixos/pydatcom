import re
from collections import OrderedDict


class DatcomParserError(Exception):
    def __init__(self, message):
        self.message = message


class DatcomCase:
    flightcond_pattern = r"\s{{2,}}{var}\s+=\s+(?P<val>[\d.+-E]+)"

    flightcond_re = {
        "MACH NO": re.compile(flightcond_pattern.format(var="MACH NO")),
        "ALTITUDE": re.compile(flightcond_pattern.format(var="ALTITUDE")),
        "SIDESLIP": re.compile(flightcond_pattern.format(var="SIDESLIP")),
    }

    fin_hinge_re = re.compile(r"FIN SET (?P<finnum>\d+) PANEL HINGE MOMENTS")
    number_line_re = re.compile(
        r"(?P<num>-?\d+(?:.\d+)?(?:[eE][-+]?\d+)?|\*+)"
    )

    def __init__(self):
        self.alphas = []

        # {MACH: {"CL": [...], "FIN1.PANL1": [...], ...}, ...}
        self.data = OrderedDict()

        self.altitude = None
        self.beta = None
        self.deflect = None

    def parsePage(self, page: str):
        mach = self.parseFlightCond(page, "MACH NO")
        alt = self.parseFlightCond(page, "ALTITUDE")
        beta = self.parseFlightCond(page, "SIDESLIP")
        hinge_match = self.fin_hinge_re.search(page)

        # Add dict for current mach number in data
        if self.data.get(mach, None) is None:
            self.data[mach] = {}

        # Check if altitude & sideslip in this page is consistend with the case
        if self.altitude is not None and self.altitude != alt:
            raise DatcomParserError(
                "Altitude is not consistent within the case"
            )
        else:
            self.altitude = alt

        if self.beta is not None and self.beta != beta:
            raise DatcomParserError(
                "Sideslip is not consistent within the case"
            )
        else:
            self.beta = beta

        # If page contains panel deflections info...
        if "PANEL DEFLECTION ANGLES" in page:
            self.deflect = self.parseDeflections(page)

        coeffs = self.parseCoefficients(page)

        # If coeffs contains hinge moments
        if hinge_match is not None:
            fin_num = hinge_match.group("finnum")
            coeffs_temp = {}
            # Update key names to remove space and add the finset number
            for k, v in coeffs.items():
                if k == "ALPHA":
                    coeffs_temp[k] = v
                else:
                    coeffs_temp[
                        "FIN" + str(fin_num) + "." + k.replace(" ", "")
                    ] = v
            coeffs = coeffs_temp

        # Check if alphas are consintent
        if len(self.alphas) == 0:
            self.alphas = coeffs["ALPHA"]
        else:
            if self.alphas != coeffs["ALPHA"]:
                raise DatcomParserError(
                    "Alpha values not consistent within the case"
                )

        del coeffs["ALPHA"]
        self.data[mach].update(coeffs)

    def parseFlightCond(self, page: str, name: str):
        match = self.flightcond_re[name].search(page)
        if match is not None:
            return float(match.group("val"))
        else:
            raise DatcomParserError("Could not find value for {}".format(name))

    def parseDeflections(self, page: str):
        state = "findheader"
        lines = page.splitlines()

        deflect = []
        for line in lines:
            # Find line containing column names
            if state == "findheader":
                if line.strip().startswith("SET"):
                    state = "parsedeflect"
            # Parse lines containing data
            elif state == "parsedeflect":
                vals = [float(x) for x in line.split(" ") if x]
                deflect.append(vals[1:])

        return deflect

    def parseCoefficients(self, page: str):
        state = "findheader"
        lines = page.splitlines()

        parse_started = False

        cols = []
        coeffs = {}

        for line in lines:
            # Find line containing column names
            if state == "findheader":
                if "ALPHA" in line:
                    # Parse column names
                    # Split by two spaces to avoid splitting column names
                    # containing a single space
                    cols = [x.strip() for x in line.split("  ") if x]
                    state = "parsecoeffs"
                    parse_started = False

            # Parse lines containing data
            elif state == "parsecoeffs":
                if line.strip() == "":
                    # Empty line: skip it
                    if parse_started:
                        # Empty line after data: stop parsing
                        state = "findheader"
                    continue

                parse_started = True
                m = self.number_line_re.findall(line)
                if len([x for x in m if "*" in x]) > 0:
                    print("Found invalid value, substituting 0...")
                    print(line)
                    print(page)

                vals = [float(x) if "*" not in x else 0 for x in m if x]

                for i, v in enumerate(vals):
                    colname = cols[i]
                    if not coeffs.get(colname, None):
                        coeffs[colname] = []
                    if colname == "ALPHA":
                        # Only add to alpha if not already present
                        if v not in coeffs[colname]:
                            coeffs[colname].append(v)
                    else:
                        coeffs[colname].append(v)

        return coeffs


case_re = re.compile(r"\s{2,}CASE\s+(?P<val>\d+)")


def containsData(page: str):
    return (
        page != ""
        and "INPUT DATA CARDS" not in page
        and "CASE INPUTS" not in page
    )


def getCaseNumber(page: str):
    case_match = case_re.search(page)
    if case_match:
        return int(case_match.group("val"))
    else:
        raise DatcomParserError("No case number found in the page")


def readDatcomOutput(output: str):
    if not output.rstrip().endswith("*** END OF JOB ***"):
        raise DatcomParserError("for006.dat terminated prematurely")

    cases = []
    case_num = 0

    pages = output.split("1         ***** ")
    for page in pages:
        if containsData(page):
            n = getCaseNumber(page)

            if n != case_num:
                d = DatcomCase()
                cases.append(d)
                case_num = n

            d.parsePage(page)

    return cases


# For debugging purposes
if __name__ == "__main__":
    with open("for006.dat") as datcom:
        s = datcom.read()
        cases = readDatcomOutput(s)
        print("end")
