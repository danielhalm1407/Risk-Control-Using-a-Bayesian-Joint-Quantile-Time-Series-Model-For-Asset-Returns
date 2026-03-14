# dash_timeseries_app.py

# imports

from __future__ import annotations
from dataclasses import dataclass
try:
    from dash import Dash, html, dcc, Input, Output
except ImportError:  # Allow standalone Plotly figure use without Dash installed.
    Dash = None
    html = None
    dcc = None
    Input = None
    Output = None


import plotly.graph_objects as go

import matplotlib.colors as mcolors
import numpy as np
from typing import Mapping, Sequence, Optional, Any




DEFAULT_LABEL_MAP = {
    "spx_level_yf": "S&P 500 Index<br>Level YF",
    "spx_period_return_yf": "S&P 500 Index<br>Return YF",
    "es_level_yf": "ES Futures<br>Settlement YF",
    "es_period_return_yf": "ES Futures<br>Return YF",
    "spx_level": "S&P 500 Index<br>Level CIQ",
    "spx_period_return": "S&P 500 Index<br>Return CIQ",
    "spy_period_return": "SPY ETF<br>Return CIQ",
}

DEFAULT_COLOUR_MAP = {
    "spx_level_yf": "purple",
    "es_level_yf": "blue",
    "spx_level": "cyan",
}


@dataclass(frozen=True)
class LevelAppConfig:
    reindex: bool = True
    cols_of_interest: Optional[Sequence[str]] = None

    # allow user to input pre-made label map, generate automatically, or 
    # stick with defaults (if enters none)
    label_map: Mapping[str, str] = None  # filled in by normalize_config
    auto_label_map: bool = True
    
    # allow user to input pre-made colour map, generate automatically, or 
    # stick with defaults (if enters none)
    colour_map: Mapping[str, str] = None  # filled in by normalize_config
    auto_colour_map: bool = True
    colour_start: str = "cyan"
    colour_end: str = "purple"

    

    # default UI settings
    title: str = "Comparison of Levels"
    figure_title: str = "Levels Reindexed to 100"
    graph_id: str = "level-plot"
    slider_id: str = "time-range-slider"
    num_marks: int = 20
    fig_height: int = 800
    port: int = 8050
    close_hour: int = 15
    close_minute: int = 50

    # plotting switches
    show_legend: bool = True
    x_tick_label_mode: str = "full"  # supported: full, year_month
    x_tick_label_format: Optional[str] = None  # optional explicit strftime format


def _format_time_label(ts, cfg: LevelAppConfig) -> str:
    """Format datetime labels for axis ticks and slider marks."""
    if cfg.x_tick_label_format:
        return ts.strftime(cfg.x_tick_label_format)

    if cfg.x_tick_label_mode == "year_month":
        return ts.strftime("%Y-%m")

    # default "full"
    return ts.strftime("%y-%m-%d %H:%M")

class AutoLabelMap:
    """
    Create a dict mapping column names -> labels
    """

    def __init__(self, cols, start="cyan", end="purple", name="gradient"):
        self.cols = list(cols)

        # filled by run()
        self.label_map = None

    def run(self):
        # for each column of interest, create a label by replacing underscores 
        # with spaces, titleizing words, and putting a line break at most every 16 
        # characters, if not, right at the last space before 16 chars
        label_map = {}
        for col in self.cols:
            words = col.replace("_", " ").title().split(" ")
            label = ""
            current_line = ""
            for word in words:
                if len(current_line) + len(word) + 1 <= 16:
                    if current_line:
                        current_line += " " + word
                    else:
                        current_line = word
                else:
                    if label:
                        label += "<br>" + current_line
                    else:
                        label = current_line
                    current_line = word
            if current_line:
                if label:
                    label += "<br>" + current_line
                else:
                    label = current_line
            label_map[col] = label
        
        self.label_map = label_map
        return self.label_map

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





def _normalize_config(cfg: LevelAppConfig) -> LevelAppConfig:
    # Avoid mutable defaults and allow user override while keeping sane defaults
    # take user input label map if provided
    if cfg.label_map is not None:
        label_map = cfg.label_map
    # if no label_map is explicitly provided...
    else:
        # if user want it to be auto-generated, do so
        if cfg.auto_label_map and cfg.cols_of_interest:
            label_map = AutoLabelMap(
                cfg.cols_of_interest
            ).run()
        # else, stick with defaults
        else:
            label_map = DEFAULT_LABEL_MAP

    # take user input colour map if provided
    if cfg.colour_map is not None:
        colour_map = cfg.colour_map
    # if no colour_map is explicitly provided...
    else:
        # if user want it to be auto-generated, do so
        if cfg.auto_colour_map and cfg.cols_of_interest:
            colour_map = GradientColourMap(
                cfg.cols_of_interest,
                start=cfg.colour_start,
                end=cfg.colour_end,
                name="auto_gradient",
            ).run()
        # else, stick with defaults
        else:
            colour_map = DEFAULT_COLOUR_MAP
    # return new config with updated maps
    # the **{ **... } syntax unpacks the original config's fields
        # where the first ** unpacks the dict,
        # and the second ** allows us to override specific fields
    # note that the __dict__ attribute of a dataclass instance gives a dict of its fields
    return LevelAppConfig(**{**cfg.__dict__, "label_map": label_map, "colour_map": colour_map})


def _validate_inputs(df, cfg: LevelAppConfig) -> None:
    if "time" not in df.columns:
        raise ValueError("df must contain a 'time' column.")
    if not np.issubdtype(df["time"].dtype, np.datetime64):
        # Works for pandas datetime64; if timezone-aware, dtype may differ slightly.
        # A more permissive check would be: pandas.api.types.is_datetime64_any_dtype
        raise ValueError("df['time'] must be datetime-like (convert via pd.to_datetime).")

    if len(df) < 2:
        raise ValueError("df must have at least 2 rows for slider/plotting.")

    if cfg.cols_of_interest is None or len(cfg.cols_of_interest) == 0:
        raise ValueError("cols_of_interest must be provided (non-empty).")

    missing = [c for c in cfg.cols_of_interest if c not in df.columns]
    if missing:
        raise ValueError(f"These cols_of_interest are missing from df: {missing}")


def _build_level_figure(df, cfg: LevelAppConfig, time_range=None):
    if time_range is None:
        filtered_df = df.copy()
    else:
        start_idx, end_idx = time_range
        filtered_df = df.iloc[start_idx:end_idx + 1].copy()

    if len(filtered_df) == 0:
        return go.Figure()

    num_ticks = min(20, len(filtered_df))
    tick_positions = np.linspace(0, len(filtered_df) - 1, num_ticks, dtype=int)

    fig = go.Figure()
    y_axis_title_value = "Level"

    for col in cfg.cols_of_interest:
        series = filtered_df[col]
        first_value = series.iloc[0]

        if cfg.reindex:
            y = (series / first_value) * 100
            y_axis_title_value = "Level (Base 100)"
        else:
            y = series

        fig.add_trace(
            go.Scatter(
                x=filtered_df.index,
                y=y,
                mode="lines",
                name=cfg.label_map.get(col, col),
                line=dict(width=2, color=cfg.colour_map.get(col)),
            )
        )

    close_times = filtered_df[
        (filtered_df["time"].dt.hour == cfg.close_hour) &
        (filtered_df["time"].dt.minute == cfg.close_minute)
    ]
    for idx in close_times.index:
        fig.add_vline(x=idx, line=dict(color="grey", dash="dash", width=1), opacity=0.5)

    fig.update_layout(
        title=cfg.figure_title,
        xaxis_title="Time",
        yaxis_title=y_axis_title_value,
        showlegend=cfg.show_legend,
        hovermode="x unified",
        height=cfg.fig_height,
        xaxis=dict(
            tickmode="array",
            tickvals=[filtered_df.index[i] for i in tick_positions],
            ticktext=[_format_time_label(filtered_df["time"].iloc[i], cfg) for i in tick_positions],
            tickangle=-90,
        ),
    )
    return fig


class LevelDashApp:
    """
    Stateful builder for a Dash app.

    - __init__: store df + config as attributes (self.df, self.cfg, ...)
    - build(): create Dash app, layout, callbacks
    - _update_plot(): callback method that uses attributes
    """

    def __init__(self, df, config: LevelAppConfig):
        self.df = df
        self.cfg = _normalize_config(config)
        self._validate_inputs()

        # These get filled when you build the app
        self.app: Optional[Any] = None


    def _validate_inputs(self) -> None:
        df = self.df
        cfg = self.cfg

        if "time" not in df.columns:
            raise ValueError("df must contain a 'time' column.")
        # If you use pandas, this check can be improved with pandas.api.types
        if not np.issubdtype(df["time"].dtype, np.datetime64):
            raise ValueError("df['time'] must be datetime-like (convert via pd.to_datetime).")
        if len(df) < 2:
            raise ValueError("df must have at least 2 rows.")
        if cfg.cols_of_interest is None or len(cfg.cols_of_interest) == 0:
            raise ValueError("cols_of_interest must be provided (non-empty).")

        missing = [c for c in cfg.cols_of_interest if c not in df.columns]
        if missing:
            raise ValueError(f"These cols_of_interest are missing from df: {missing}")

    def build(self) -> Any:
        """Create the Dash app, attach layout + callbacks, return the Dash app."""
        if Dash is None:
            raise ImportError("dash is required to build the app. Install it to use LevelDashApp.")

        cfg = self.cfg
        df = self.df

        app = Dash(__name__)
        self.app = app

        mark_positions = np.linspace(0, len(df) - 1, cfg.num_marks, dtype=int)

        app.layout = html.Div(
            [
                html.H3(cfg.title),
                html.Br(), html.Br(), html.Br(), html.Br(),
                dcc.RangeSlider(
                    id=cfg.slider_id,
                    min=0,
                    max=len(df) - 1,
                    marks={
                        int(pos): {
                            "label": _format_time_label(df["time"].iloc[pos], cfg),
                            "style": {
                                "transform": "rotate(-90deg)",
                                "transformOrigin": "top left",
                                "whiteSpace": "nowrap",
                                "textAlign": "center",
                                "marginTop": "-20px",
                                "marginLeft": "-8px",
                            },
                        }
                        for pos in mark_positions
                    },
                    value=[0, len(df) - 1],
                    tooltip={"placement": "bottom", "always_visible": True},
                ),
                html.Br(),
                dcc.Graph(id=cfg.graph_id, style={"height": f"{cfg.fig_height}px"}),
            ]
        )

        # Callback defined inside build, but calls a method that uses self.df/self.cfg
        @app.callback(Output(cfg.graph_id, "figure"), Input(cfg.slider_id, "value"))
        def _callback(time_range):
            return self._update_plot(time_range)

        return app

    def _update_plot(self, time_range):
        return _build_level_figure(self.df, self.cfg, time_range=time_range)

    # safely build the app if not already done before running
            
    def run(self, *, debug: bool = False, port: Optional[int] = None, use_reloader: bool = False) -> None:
        if self.app is None:
            self.build()
        self.app.run(
            debug=debug,
            port=(self.cfg.port if port is None else port),
            use_reloader=use_reloader,
        )


# Optional: allow running this file directly as a script for quick manual testing
if __name__ == "__main__":
    # Put a tiny demo here if you want, but DON'T rely on notebook variables.
    # Example: load a CSV, create df, then:
    # cfg = LevelAppConfig(cols_of_interest=[...], reindex=False)
    # app = make_level_app(df, cfg)
    # run_app(app, debug=True, port=8050)
    pass



def make_level_figure(
    df,
    cols_of_interest,
    label_map=None,
    colour_map=None,
    color_map=None,
    reindex=True,
    figure_title="Levels over Selected Period",
    fig_height=800,
    title="Comparison of Levels",
    auto_label_map=True,
    auto_colour_map=True,
    colour_start="cyan",
    colour_end="purple",
    close_hour=15,
    close_minute=50,
    show_legend=True,
    x_tick_label_mode="full",
    x_tick_label_format=None,
):
    resolved_colour_map = colour_map if colour_map is not None else color_map

    cfg = LevelAppConfig(
        cols_of_interest=cols_of_interest,
        reindex=reindex,
        label_map=label_map,
        colour_map=resolved_colour_map,
        auto_label_map=auto_label_map,
        auto_colour_map=auto_colour_map,
        colour_start=colour_start,
        colour_end=colour_end,
        title=title,
        figure_title=figure_title,
        fig_height=fig_height,
        close_hour=close_hour,
        close_minute=close_minute,
        show_legend=show_legend,
        x_tick_label_mode=x_tick_label_mode,
        x_tick_label_format=x_tick_label_format,
    )
    cfg = _normalize_config(cfg)
    _validate_inputs(df, cfg)
    return _build_level_figure(df, cfg)
