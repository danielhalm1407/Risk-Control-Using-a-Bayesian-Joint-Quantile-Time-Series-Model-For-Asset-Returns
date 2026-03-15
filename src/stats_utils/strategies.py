# Imports

# standard library imports
from itertools import product
from pathlib import Path
from typing import Optional

import numpy as np
import pandas as pd
from scipy.io import loadmat


class QuantileForecastsMerger:
    """
    Load S&P 500 returns, clean them, load BJQTS forecast quantiles from MAT,
    and merge both datasets for backtesting.

    Typical usage in a notebook can stay concise:

    merger = QuantileForecastsMerger()
    merged_returns = merger.run()

    After running, intermediate outputs are also available on the instance:
    - merger.raw_returns
    - merger.returns
    - merger.quantile_forecasts_df
    - merger.merged_returns
    """

    def __init__(
        self,
        label_format: str = "%y-%m-%d",
        returns: Optional[pd.DataFrame] = None,
        returns_path: str | Path = "data/intermediate_input/sp500_interday_returns.xlsx",
        mat_path: str | Path = "data/intermediate_input/q_minus_all_BJSAV_5_norm_SP500.mat",
        mat_key: str = "q_minus_all_select",
        date_format: str = "%d-%b-%Y",
        drop_zero: bool = True,
        burn_in: int = 2520,
        label: bool = False,
    ) -> None:
        self.label_format = label_format
        self.raw_returns: Optional[pd.DataFrame] = None
        self.returns = returns
        self.returns_path = returns_path
        self.mat_path = mat_path
        self.mat_key = mat_key
        self.date_format = date_format
        self.drop_zero = drop_zero
        self.burn_in = burn_in
        self.label = label
        self.quantile_forecasts_df: Optional[pd.DataFrame] = None
        self.merged_returns: Optional[pd.DataFrame] = None

    def _resolve_path(self, path_value: str | Path, *, path_label: str) -> Path:
        """
        Resolve a file path robustly across notebook/module execution contexts.

        Resolution order:
        1) Absolute path as provided.
        2) Relative to current working directory.
        3) Relative to project root (derived from this file location).
        """
        p = Path(path_value)
        if p.is_absolute():
            if not p.exists():
                raise FileNotFoundError(f"{path_label} not found: {p}")
            return p

        cwd_candidate = Path.cwd() / p
        if cwd_candidate.exists():
            return cwd_candidate

        project_root = Path(__file__).resolve().parents[2]
        root_candidate = project_root / p
        if root_candidate.exists():
            return root_candidate

        raise FileNotFoundError(
            f"Could not resolve {path_label}. "
            f"Tried: {cwd_candidate} and {root_candidate}"
        )

    def load_returns_from_file(
        self,
        returns_path: Optional[str | Path] = None,
    ) -> pd.DataFrame:
        """
        Load raw returns data from CSV or Excel and store it on the instance.
        """
        resolved_path = self._resolve_path(
            returns_path or self.returns_path,
            path_label="returns file",
        )

        suffix = resolved_path.suffix.lower()
        if suffix == ".csv":
            raw_returns = pd.read_csv(resolved_path)
        elif suffix in {".xls", ".xlsx"}:
            raw_returns = pd.read_excel(resolved_path)
        else:
            raise ValueError(
                f"Unsupported returns file type '{suffix}'. Use CSV or Excel."
            )

        self.raw_returns = raw_returns
        return raw_returns

    def clean_returns(
        self,
        returns: Optional[pd.DataFrame] = None,
    ) -> pd.DataFrame:
        """
        Clean a returns dataframe and store the cleaned result on the instance.
        """
        source_returns = returns
        if source_returns is None:
            source_returns = self.raw_returns if self.raw_returns is not None else self.returns

        if source_returns is None:
            raise ValueError(
                "No returns DataFrame available. Load one from file or pass `returns`."
            )

        cleaned_returns = source_returns.copy()
        cleaned_returns.columns = ["time", "return"]
        cleaned_returns["time"] = pd.to_datetime(
            cleaned_returns["time"],
            format=self.date_format,
            errors="coerce",
        )

        if self.drop_zero:
            cleaned_returns = cleaned_returns[cleaned_returns["return"] != 0]

        cleaned_returns = cleaned_returns[cleaned_returns["return"].notna()]

        if self.burn_in:
            cleaned_returns = cleaned_returns.iloc[self.burn_in :].reset_index(drop=True)

        if self.label:
            cleaned_returns["time_label"] = cleaned_returns["time"].dt.strftime(
                self.label_format
            )

        self.returns = cleaned_returns
        return cleaned_returns

    def load_quantile_forecasts_from_mat(
        self,
        mat_path: Optional[str | Path] = None,
        mat_key: Optional[str] = None,
    ) -> pd.DataFrame:
        """
        Load quantile forecasts from a MATLAB .mat file and return a DataFrame.
        """
        resolved_path = self._resolve_path(
            mat_path or self.mat_path,
            path_label="MAT file",
        )
        data = loadmat(resolved_path)

        resolved_key = mat_key or self.mat_key

        if resolved_key not in data:
            available = sorted(k for k in data.keys() if not k.startswith("__"))
            raise KeyError(
                f"Key '{resolved_key}' not found in MAT file. "
                f"Available keys: {available}"
            )

        quantile_forecasts = np.asarray(data[resolved_key])
        if quantile_forecasts.ndim != 2:
            raise ValueError(
                f"Expected a 2D array for '{resolved_key}', got shape {quantile_forecasts.shape}."
            )

        self.quantile_forecasts_df = pd.DataFrame(
            quantile_forecasts,
            columns=[f"q_{i + 1}" for i in range(quantile_forecasts.shape[1])],
        )
        return self.quantile_forecasts_df

    def merge_returns_with_quantiles(
        self,
        returns: Optional[pd.DataFrame] = None,
        quantile_forecasts_df: Optional[pd.DataFrame] = None,
        *,
        mat_path: Optional[str | Path] = None,
        mat_key: Optional[str] = None,
    ) -> pd.DataFrame:
        """
        Merge returns with quantile forecasts on index.

        If quantile_forecasts_df is not provided, forecasts are loaded from MAT.
        """
        resolved_returns = returns if returns is not None else self.returns
        if resolved_returns is None:
            raise ValueError(
                "No returns DataFrame provided. Pass `returns` or set it on QuantileForecastsMerger(...)"
            )

        if quantile_forecasts_df is None:
            quantile_forecasts_df = self.load_quantile_forecasts_from_mat(
                mat_path=mat_path,
                mat_key=mat_key,
            )

        self.merged_returns = resolved_returns.merge(
            quantile_forecasts_df,
            left_index=True,
            right_index=True,
        )
        return self.merged_returns

    def run(
        self,
        returns: Optional[pd.DataFrame] = None,
        quantile_forecasts_df: Optional[pd.DataFrame] = None,
        *,
        clean_loaded_returns: bool = True,
    ) -> pd.DataFrame:
        """
        End-to-end pipeline for backtest inputs.

        If `returns` is supplied, it is treated as already prepared returns data.
        Otherwise returns are loaded from `returns_path`, optionally cleaned, and
        then merged with the quantile forecasts loaded from `mat_path`.
        """
        if returns is not None:
            self.returns = returns
        elif self.returns is None:
            loaded_returns = self.load_returns_from_file()
            if clean_loaded_returns:
                self.clean_returns(loaded_returns)
            else:
                self.returns = loaded_returns.copy()

        return self.merge_returns_with_quantiles(
            returns=self.returns,
            quantile_forecasts_df=quantile_forecasts_df,
        )


class IntradayIndexLevelsCleaner:
    """
    Load and clean intraday S&P index levels into a single tidy dataframe.

    The default pipeline mirrors the notebook/script workflow:
    1) Read the raw Excel file.
    2) Promote row 6 to header and drop metadata rows.
    3) Standardize column names.
    4) Parse the effective date column to datetime and drop invalid rows.
    5) Keep only the date and S&P columns, renaming levels with a _level suffix.
    6) Coerce level columns to numeric.
    """

    def __init__(
        self,
        input_path: str | Path = "data/input/intraday_indices_levels.xlsx",
        header_row_idx: int = 5,
        date_column: str = "effective_date_",
        sp_column_token: str = "sp",
    ) -> None:
        self.input_path = input_path
        self.header_row_idx = header_row_idx
        self.date_column = date_column
        self.sp_column_token = sp_column_token

        self.raw_intraday_index_levels: Optional[pd.DataFrame] = None
        self.cleaned_intraday_index_levels: Optional[pd.DataFrame] = None

    def _resolve_path(self, path_value: str | Path, *, path_label: str) -> Path:
        """
        Resolve a path robustly across notebook/module execution contexts.
        """
        p = Path(path_value)
        if p.is_absolute():
            if not p.exists():
                raise FileNotFoundError(f"{path_label} not found: {p}")
            return p

        cwd_candidate = Path.cwd() / p
        if cwd_candidate.exists():
            return cwd_candidate

        project_root = Path(__file__).resolve().parents[2]
        root_candidate = project_root / p
        if root_candidate.exists():
            return root_candidate

        raise FileNotFoundError(
            f"Could not resolve {path_label}. "
            f"Tried: {cwd_candidate} and {root_candidate}"
        )

    def load(self, input_path: Optional[str | Path] = None) -> pd.DataFrame:
        """
        Load the raw intraday index level file from Excel.
        """
        resolved_path = self._resolve_path(
            input_path or self.input_path,
            path_label="intraday index levels file",
        )
        self.raw_intraday_index_levels = pd.read_excel(resolved_path)
        return self.raw_intraday_index_levels

    def clean(self, intraday_index_levels: Optional[pd.DataFrame] = None) -> pd.DataFrame:
        """
        Apply the full cleaning pipeline and return tidy index levels.
        """
        source_df = intraday_index_levels
        if source_df is None:
            source_df = self.raw_intraday_index_levels

        if source_df is None:
            raise ValueError(
                "No intraday index levels dataframe available. "
                "Load from file or pass `intraday_index_levels`."
            )

        out = source_df.copy()

        if self.header_row_idx >= len(out):
            raise ValueError(
                f"header_row_idx={self.header_row_idx} is out of bounds for dataframe with {len(out)} rows."
            )

        # Promote the configured row to header and remove pre-header metadata rows.
        out.columns = out.iloc[self.header_row_idx]
        out = out.drop(index=list(range(self.header_row_idx + 1))).reset_index(drop=True)

        out.columns = [str(col).lower().replace(" ", "_") for col in out.columns]
        out.columns = [col.replace("&", "") for col in out.columns]
        out.columns = [col.replace("(", "") for col in out.columns]
        out.columns = [col.replace(")", "") for col in out.columns]

        if self.date_column not in out.columns:
            raise KeyError(
                f"Date column '{self.date_column}' not found after normalization. "
                f"Available columns: {list(out.columns)}"
            )

        out[self.date_column] = pd.to_datetime(
            out[self.date_column],
            errors="coerce",
        )
        out = out.dropna(subset=[self.date_column])

        sp_columns = [col for col in out.columns if self.sp_column_token in col]

        renamed_columns = {self.date_column: "time"}
        renamed_columns.update({col: f"{col}_level" for col in sp_columns})
        out = out[[self.date_column] + sp_columns].rename(columns=renamed_columns)

        level_columns = [col for col in out.columns if "level" in col]
        for col in level_columns:
            out[col] = pd.to_numeric(out[col], errors="coerce")

        self.cleaned_intraday_index_levels = out
        return out

    def run(
        self,
        intraday_index_levels: Optional[pd.DataFrame] = None,
        *,
        input_path: Optional[str | Path] = None,
    ) -> pd.DataFrame:
        """
        Execute load (if needed) + clean in one call.
        """
        if intraday_index_levels is not None:
            self.raw_intraday_index_levels = intraday_index_levels.copy()
        elif self.raw_intraday_index_levels is None:
            self.load(input_path=input_path)

        return self.clean(self.raw_intraday_index_levels)

    

class QuantileRiskControlStrategy:
    # add a mapping of quantile numbers to quantile levels
    # 8 to 1 map to 0.0556, 0.1111, 0.1667, 0.2222, 0.2778, 0.3333, 0.3889, 0.4444 respectively
    quantile_level_map = {
        1: 0.4444,
        2: 0.3889,
        3: 0.3333,
        4: 0.2778,
        5: 0.2222,
        6: 0.1667,
        7: 0.1111,
        8: 0.0556,
    }

    # Set maximum drawdown/quantile target
    def __init__(self, r: float = 0.0063, spec: int = 2, q_level: int = 8) -> None:
        self.r = r
        self.spec = spec
        self.q_level = q_level

    # Note that the target probability level will be given by the quantile forecast that we compare this to, in this case q_8

    # define a function calc_targ_weight that calculates the target weight in the market index based on the quantile forecast
    # this takes as input a the forecast quantile we are comparing and the maximum drawdown/quantile target
    def calc_targ_weight(self, q_forecast: float) -> float:
        """
        Calculate the target weight in the market index based on the quantile forecast.

        Args:
            q_forecast (float): The forecasted quantile value.

        Returns:
            float: The target weight in the market index.
        """
        if self.spec == 1:
            # For the first specification, the weight is set to 1 when the quantile forecast is above the target
            if q_forecast >= -self.r:
                w_targ = 1
            else:
                # If the quantile forecast is below the target, we set the weight to 0
                w_targ = 0
            return w_targ

        # For the second specification, the weight changes linearly with the quantile forecast
        if q_forecast == 0:
            return 1

        w_targ = max(min(1, (-self.r / q_forecast)), 0)
        return w_targ

    # A function that calculates the target weights and actual weights for each period
    # based on the quantile forecasts and the maximum drawdown/quantile target
    def calc_strat_returns(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Calculate target weights and actual weights based on quantile forecasts.

        Args:
            df (pd.DataFrame): DataFrame containing quantile forecasts and returns.

        Returns:
            pd.DataFrame: DataFrame with added target and actual weights.
        """
        out = df.copy()  # Prevent modifying the original DataFrame
        # Calculate target weights based on the quantile forecast for q_8
        out["target_weight"] = out[f"q_{self.q_level}"].apply(self.calc_targ_weight)

        # Create an actual_weight column that is the target weight column shifted by one row
        # this is to reflect a 1-day trading delay
        out["actual_weight"] = out["target_weight"].shift(1)

        # Now calculate the actual, risk control returns based on the actual weight
        return_col = [col for col in out.columns if "return" in col and "risk_control_return" not in col]
        out["risk_control_return"] = out[return_col[0]] * out["actual_weight"]

        return out

    def run(self, df: pd.DataFrame) -> pd.DataFrame:
        return self.calc_strat_returns(df)


class QuantileRiskControlGrid:
    """
    Run a grid of risk-control strategies and append each strategy's results
    as additional columns to the input dataframe.
    """

    def __init__(self, r_list: list[float], q_level_list: list[int], spec_list: list[int]) -> None:
        self.r_list = r_list
        self.q_level_list = q_level_list
        self.spec_list = spec_list

    def _strategy_suffix(self, r: float, q_level: int, spec: int) -> str:
        # format r in terms as a percentage
        r_label = f"{r*100:.2f}%"
        return f"q_{q_level}_target_at_{r_label}_spec_{spec}"

    def run(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        For each (r, q_level, spec) in the Cartesian product of parameter lists,
        calculate target weight, actual weight, and risk-control return and append
        these as new columns.
        """
        out = df.copy()

        for r, q_level, spec in product(self.r_list, self.q_level_list, self.spec_list):
            strategy = QuantileRiskControlStrategy(r=r, spec=spec, q_level=q_level)
            strat_df = strategy.run(df)
            suffix = self._strategy_suffix(r=r, q_level=q_level, spec=spec)

            # Add strategy-specific columns for target and actual weights and returns.
            out[f"target_weight__{suffix}"] = strat_df["target_weight"]
            out[f"actual_weight__{suffix}"] = strat_df["actual_weight"]
            out[f"risk_control_return__{suffix}"] = strat_df["risk_control_return"]

        return out



