# A Script to create a Dash app for visualizing level time series data

import numpy as np
from dash import Dash, html, dcc, Input, Output
import plotly.graph_objects as go

def make_level_app(
    df, # input dataframe with 'time' and series columns
    reindex = True, # whether to reindex the levels to 100 at the start of the selected range
    cols_of_interest = None, # columns (series) to plot
    label_map = { # default labels
    'spx_level_yf': 'S&P 500 Index<br>Level YF',
    'es_level_yf': 'ES Futures<br>Settlement YF',
    'spx_level': 'S&P 500 Index<br>Level CIQ',
    'spx_period_return': 'S&P 500 Index<br>Return CIQ',
    'spy_period_return': 'S&P 500 ETF<br>Return CIQ',
    },
    colour_map = { # default colors
    'spx_level_yf': 'purple',
    'es_level_yf': 'blue',
    'spx_level': 'cyan'
    },
    title="Comparison of Levels",
    figure_title="Levels Reindexed to 100",
    graph_id="level-plot",
    slider_id="time-range-slider",
    num_marks=20,
    fig_height=800,          # height control
    port=8050
):
    app = Dash(__name__)

    mark_positions = np.linspace(0, len(df) - 1, num_marks, dtype=int)

    app.layout = html.Div([
        html.H3(title),
        # leave spacing before the range slider
        html.Br(), html.Br(), html.Br(), html.Br(),

        dcc.RangeSlider(
            id=slider_id,
            min=0,
            max=len(df) - 1,
            marks={
                int(pos): {
                    "label": df["time"].iloc[pos].strftime("%y-%m-%d %H:%M"),
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

        dcc.Graph(id=graph_id, style={"height": f"{fig_height}px"})
    ])

    @app.callback(
        Output(graph_id, "figure"),
        Input(slider_id, "value")
    )
    def update_plot(time_range):
        start_idx, end_idx = time_range
        filtered_df = df.iloc[start_idx:end_idx + 1].copy()

        tick_positions = np.linspace(0, len(filtered_df) - 1, 20, dtype=int)

        fig = go.Figure()

        # plot each data series iteratively
        for col in cols_of_interest:

            var_data = filtered_df[col]
            first_value = var_data.iloc[0]
            # normalize if required
            if reindex:
                normalized = (var_data / first_value) * 100
                y_axis_title_value = "Level (Base 100)"
            else:
                normalized = var_data
                y_axis_title_value = "Level"

            fig.add_trace(go.Scatter(
                x=filtered_df.index,
                y=normalized,
                mode="lines",
                name=label_map.get(col, col),
                line=dict(width=2, color=colour_map.get(col))
            ))
        # mark vertical lines at market close times (15:50)
        close_times = filtered_df[
            (filtered_df["time"].dt.hour == 15) &
            (filtered_df["time"].dt.minute == 50)
        ]
        for idx, row in close_times.iterrows():
            fig.add_vline(
                x=idx,
                line=dict(color="grey", dash="dash", width=1),
                opacity=0.5
            )

        # add extra layout details
        fig.update_layout(
            title=figure_title,
            xaxis_title="Time",
            yaxis_title=y_axis_title_value,
            hovermode="x unified",
            height=fig_height,  # adjust the figure height
            xaxis=dict(
                tickmode="array",
                tickvals=[filtered_df.index[i] for i in tick_positions],
                ticktext=[filtered_df["time"].iloc[i].strftime("%y-%m-%d %H:%M") for i in tick_positions],
                tickangle=-90
            )
        )
        return fig

    return app
