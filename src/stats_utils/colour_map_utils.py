import numpy as np
import matplotlib.colors as mcolors


class GradientColourMap:
    """
    Create a dict mapping column names -> hex colours using a linear gradient.

    Usage:
        gen = GradientColourMap(cols, start="cyan", end="purple")
        gen.run()
        colour_map = gen.colour_map
    """

    def __init__(self, cols, start="cyan", end="purple", name="gradient"):
        self.cols = list(cols)
        self.start = start
        self.end = end
        self.name = name

        # filled by run()
        self.colour_map = None

    def run(self):
        n = len(self.cols)
        if n == 0:
            self.colour_map = {}
            return self.colour_map

        cmap = mcolors.LinearSegmentedColormap.from_list(self.name, [self.start, self.end])
        positions = np.linspace(0, 1, n)
        colours = [mcolors.to_hex(cmap(p)) for p in positions]

        self.colour_map = dict(zip(self.cols, colours))
        return self.colour_map

# dummy run if we run the file directly
if __name__ == "__main__":
    cols = ["spx_level", "spx_level_yf", "es_level_yf"]
    gen = GradientColourMap(cols)
    print(gen.run())