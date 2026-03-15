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
import pandas as pd
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
class ColourGroupConfig:
    cols: Sequence[str]
    colour: Optional[str] = None
    opacity: Optional[float] = None
    start: Optional[str] = None
    end: Optional[str] = None
    name: str = "gradient"


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
    opacity_map: Mapping[str, float] = None  # filled in by normalize_config
    colour_groups: Optional[Sequence[Any]] = None
    auto_colour_map: bool = True
    colour_start: str = "cyan"
    colour_end: str = "purple"
    default_opacity: float = 1.0

    

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


def _normalise_colour_group(group: Any, idx: int, cols_of_interest: Optional[Sequence[str]]) -> ColourGroupConfig:
    """Accept dicts or ColourGroupConfig instances for grouped colour definitions."""
    if isinstance(group, ColourGroupConfig):
        spec = group
    elif isinstance(group, dict):
        cols = group.get("cols", group.get("columns"))
        spec = ColourGroupConfig(
            cols=cols,
            colour=group.get("colour", group.get("color")),
            opacity=group.get("opacity", group.get("alpha")),
            start=group.get("start"),
            end=group.get("end"),
            name=group.get("name", f"group_{idx}"),
        )
    else:
        raise ValueError("colour_groups items must be ColourGroupConfig objects or dicts")

    if spec.cols is None or len(spec.cols) == 0:
        raise ValueError("Each colour group must define a non-empty 'cols' list")

    if cols_of_interest is not None:
        missing = [c for c in spec.cols if c not in cols_of_interest]
        if missing:
            raise ValueError(f"These colour-group columns are missing from cols_of_interest: {missing}")

    if spec.colour is None and spec.start is None and spec.end is None:
        raise ValueError("Each colour group must define either 'colour' or a 'start'/'end' gradient")

    return spec


def _build_group_colour_map(cfg: LevelAppConfig) -> Mapping[str, str]:
    """Build colours for any explicitly configured groups."""
    if not cfg.colour_groups:
        return {}

    colour_map = {}
    for idx, raw_group in enumerate(cfg.colour_groups):
        group = _normalise_colour_group(raw_group, idx, cfg.cols_of_interest)

        if group.colour is not None:
            colour_map.update({col: group.colour for col in group.cols})
            continue

        start = cfg.colour_start if group.start is None else group.start
        end = start if group.end is None else group.end
        colour_map.update(
            GradientColourMap(group.cols, start=start, end=end, name=group.name).run()
        )

    return colour_map


def _build_group_opacity_map(cfg: LevelAppConfig) -> Mapping[str, float]:
    """Build opacity values for any explicitly configured groups."""
    if not cfg.colour_groups:
        return {}

    opacity_map = {}
    for idx, raw_group in enumerate(cfg.colour_groups):
        group = _normalise_colour_group(raw_group, idx, cfg.cols_of_interest)
        if group.opacity is not None:
            opacity_map.update({col: float(group.opacity) for col in group.cols})
    return opacity_map


def _build_colour_map(cfg: LevelAppConfig) -> Mapping[str, str]:
    """Resolve colours using defaults/auto generation, then group overrides, then explicit overrides."""
    if cfg.auto_colour_map and cfg.cols_of_interest:
        colour_map = GradientColourMap(
            cfg.cols_of_interest,
            start=cfg.colour_start,
            end=cfg.colour_end,
            name="auto_gradient",
        ).run()
    else:
        colour_map = {c: DEFAULT_COLOUR_MAP[c] for c in (cfg.cols_of_interest or []) if c in DEFAULT_COLOUR_MAP}

    colour_map.update(_build_group_colour_map(cfg))

    if cfg.colour_map is not None:
        colour_map.update(cfg.colour_map)

    return colour_map


def _build_opacity_map(cfg: LevelAppConfig) -> Mapping[str, float]:
    """Resolve opacities using default, then group overrides, then explicit overrides."""
    opacity_map = {
        col: float(cfg.default_opacity)
        for col in (cfg.cols_of_interest or [])
    }

    opacity_map.update(_build_group_opacity_map(cfg))

    if cfg.opacity_map is not None:
        opacity_map.update({k: float(v) for k, v in cfg.opacity_map.items()})

    return opacity_map


def _filter_df_by_time_window(df, time_window=None):
    """Filter dataframe by either slider-style integer range or explicit datetime window."""
    if time_window is None:
        return df.copy()

    if isinstance(time_window, (list, tuple)) and len(time_window) == 2:
        left, right = time_window
        if isinstance(left, (int, np.integer)) and isinstance(right, (int, np.integer)):
            return df.iloc[left:right + 1].copy()

        start = pd.to_datetime(left)
        end = pd.to_datetime(right)
        return df[(df["time"] >= start) & (df["time"] <= end)].copy()

    raise ValueError("time_window must be None or a 2-item tuple/list of integer indices or datetime-like bounds")





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

    colour_map = _build_colour_map(cfg)
    opacity_map = _build_opacity_map(cfg)
    # return new config with updated maps
    # the **{ **... } syntax unpacks the original config's fields
        # where the first ** unpacks the dict,
        # and the second ** allows us to override specific fields
    # note that the __dict__ attribute of a dataclass instance gives a dict of its fields
    return LevelAppConfig(**{**cfg.__dict__, "label_map": label_map, "colour_map": colour_map, "opacity_map": opacity_map})


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
    filtered_df = _filter_df_by_time_window(df, time_range)

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
                opacity=cfg.opacity_map.get(col, cfg.default_opacity),
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
    cols_of_interest=None,
    cfg: Optional[LevelAppConfig] = None,
    label_map=None,
    colour_map=None,
    opacity_map=None,
    colour_groups=None,
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
    default_opacity=1.0,
    time_window=None,
):
    # Backward compatibility:
    # - old style: make_level_figure(df, cols_of_interest=..., ...)
    # - new style: make_level_figure(df, cfg=my_cfg, time_window=(...))
    # - shorthand : make_level_figure(df, my_cfg, time_window=(...))
    if isinstance(cols_of_interest, LevelAppConfig):
        if cfg is not None:
            raise ValueError("Pass config only once: either cfg=... or second positional config")
        cfg = cols_of_interest
    
    # in the rare case where user has not already defined a configuration, or wishes to 
    # override just a few parameters without defining a full config, allow passing those few parameters directly and build the config internally
    if cfg is None:
        if cols_of_interest is None:
            raise ValueError("Provide either cols_of_interest or cfg=LevelAppConfig(...)")

        resolved_colour_map = colour_map if colour_map is not None else color_map

        cfg = LevelAppConfig(
            cols_of_interest=cols_of_interest,
            reindex=reindex,
            label_map=label_map,
            colour_map=resolved_colour_map,
            opacity_map=opacity_map,
            colour_groups=colour_groups,
            auto_label_map=auto_label_map,
            auto_colour_map=auto_colour_map,
            colour_start=colour_start,
            colour_end=colour_end,
            default_opacity=default_opacity,
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
    return _build_level_figure(df, cfg, time_range=time_window)
