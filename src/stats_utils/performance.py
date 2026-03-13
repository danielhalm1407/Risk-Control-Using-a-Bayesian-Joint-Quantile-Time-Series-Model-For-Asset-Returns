# performance.py


# Import modules needed for the py file to work
from ast import List
import numpy as np
import pandas as pd


class PerformanceSummary:
    """
    Compute performance summary statistics for multiple return series.

    Usage:
        ps = PerformanceSummary(df, ret_cols, kind="log")
        summary = ps.run()
    """

    def __init__(
        self,
        df: pd.DataFrame,
        ret_cols,
        kind: str = "simple",
        annualise: List = ["resampled","windows"], # which returns to annualise
        resample_freq: str = "YE", # controls frequency of the resampled periods
        periods_per_year: float = 252.0, # default 252 for interday data,
        *, 
        # the * makes the following arguments keyword-only, 
        # which means they must be specified by name
        include_vol: bool = False,
        include_drawdown: bool = False
        
    ):
        """
        Initialize with DataFrame, return columns, and return type.
        Done to make attributes retrievable later and clearly associated with the instance.
        """
        # stop if returns argument is invalid
        if kind not in ("simple", "log"):
            raise ValueError("kind must be 'simple' or 'log3'")
        
        self.df = df # dataframe input
        self.x = None  # prepared dataframe (filled in _prepare_returns)
        self.R = None # returns dataframe (filled in _prepare_returns)
        # list of return columns to analyze (can be just one)
        self.ret_cols = ret_cols if isinstance(ret_cols, list) else [ret_cols]
        self.kind = kind
        self.annualise = annualise
        self.resample_freq = resample_freq
        self.periods_per_year = periods_per_year
        self.include_vol = include_vol
        self.include_drawdown = include_drawdown
        
        # filled during run()
        self.summary = None

    def _prepare_returns(self) -> pd.DataFrame:
        """
        Prepare the returns DataFrame for analysis.
        Convert the 'time' column to datetime, sort by time, and set it as the index.
        Return only the specified return columns as floats.
        """
        # create an attribute self.x to hold the prepared DataFrame
        self.x = self.df.copy() # make a copy to avoid modifying original
        self.x["time"] = pd.to_datetime(self.x["time"])
        self.x = self.x.sort_values("time").set_index("time")
        # return only the return columns as float type,
        # now indexed by time thanks to the above code
        return self.x[self.ret_cols].astype(float)

    def _total_return(self, frame: pd.DataFrame, annualise: bool = False) -> pd.Series:
        """Calculate total return  over the given DataFrame frame."""
        # using log returns 
        if self.kind == "log":
            total_return = np.exp(frame.sum()) - 1
        # using simple returns
        else:
            total_return = (1 + frame).prod() - 1
        if annualise:
            # annualise the return
            elapsed_years = (frame.index[-1] - frame.index[0]).days / 365.25
            return (1 + total_return) ** (1 / elapsed_years) - 1
        else:
            return total_return

    def _total_return_resampled(self, resampler, annualise: bool = False) -> pd.DataFrame:
        """
        Compute total returns for each resample bin, returning a DataFrame
        indexed by bin end timestamps, columns=strategies.
        """
        if self.kind == "log":
            tr = np.exp(resampler.sum()) - 1
        else:
            tr = (1 + resampler).prod() - 1

        if not annualise:
            return tr

        # Annualise each bin using that bin's actual elapsed years
        # Bin start/end per row:
        # tr is a DataFrame whose INDEX is the resample bin label (e.g., each quarter-end),
        # and whose COLUMNS are your strategies. Each ROW corresponds to one resample window.
        # Example: index = [2024-03-31, 2024-06-30, ...] for quarterly.

        # Convert each bin label into a Period (e.g., "2024Q1"), then get the start timestamp
        # of that period. This gives a vector of start dates, one per row/bin.
        start = tr.index.to_period(self.resample_freq).start_time

        # Same idea: get the end timestamp of each period/bin, one per row/bin.
        end = tr.index.to_period(self.resample_freq).end_time

        # Compute elapsed time per bin in years.
        # (end - start) is a TimedeltaIndex; .days gives integer day counts per row/bin.
        elapsed_years = (end - start).days / 365.25

        # broadcast elapsed_years across columns
        # We want an annualisation exponent per row/bin: exponent = 1 / elapsed_years.
        # Make it a Series indexed by the same index as tr so pandas can ALIGN by row.
        ann_factor = 1 / pd.Series(elapsed_years, index=tr.index)

        # Annualise each cell in tr using the exponent for its ROW/bin:
        # - (1 + tr) makes gross returns (e.g., 1.05 instead of 0.05)
        # - .pow(ann_factor, axis=0) raises each ROW to the power for that row.
        #
        # IMPORTANT: axis=0 means "align ann_factor on the index (rows)".
        # So for each row i (each resample window):
        #   for every strategy column j:
        #       result[i, j] = (1 + tr[i, j]) ** ann_factor[i]
        #
        # This is the "iterating over windows" part, but it happens in vectorised form
        # across all rows at once (no Python for-loop).
        #
        # Finally, subtract 1 to go back to simple returns.
        return (1 + tr).pow(ann_factor, axis=0) - 1

        
    def _equity_curve(self, frame: pd.DataFrame) -> pd.DataFrame:
        """Equity curve starting at 1.0 for each column."""
        if self.kind == "log":
            return np.exp(frame.cumsum())
        else:
            return (1 + frame).cumprod()
        
    def _annualised_vol(self, frame: pd.DataFrame) -> pd.Series:
        """Annualised volatility per column."""
        # the ddof=0 gives population std dev, ddof=1 gives sample std dev
        if self.kind == "log":
            r = frame
        else:
            r = np.log1p(frame)  # log(1+r)
        return r.std(ddof=0) * np.sqrt(self.periods_per_year)

    def _max_drawdown(self, frame: pd.DataFrame) -> pd.Series:
        """Max drawdown (most negative) per column over the window."""
        # start with equity curve
        eq = self._equity_curve(frame)
        # then calculate the drawdown: the largest % drop in equity from a prior peak
        dd = eq / eq.cummax() - 1.0
        return dd.min()
    
    def _add_extra_stats(self, row: dict, frame: pd.DataFrame, pre_annualised: bool = True) -> dict:
        """Add extra statistics like volatility and drawdown to the stats Series."""
        # add extra stats if requested by user
        if self.include_vol:
            # find the value of annualised volatility
            vol = self._annualised_vol(frame)
            
            # store as e.g. "spx_vol", "es_vol" etc.
            row.update({f"{c}_volatility": float(vol[c]) for c in self.ret_cols})
            # might as well add the sharpe ratio while we're at it
            # taking advantage of the fact that annualised return for a given col
            # is stored in row[c], since we called _total_return earlier
            sharpe = {}
            for c in self.ret_cols:
                if pre_annualised:
                    annualised_return = row[c]
                else:
                    # annualise the return if not already done (as is usually the case for YTD)
                    elapsed_years = (frame.index[-1] - frame.index[0]).days / 365.25
                    annualised_return = (1 + row[c]) ** (1 / elapsed_years) - 1
                sharpe[c] = annualised_return / vol[c] if vol[c] != 0 else np.nan
            row.update({f"{c}_sharpe": float(sharpe[c]) for c in self.ret_cols})
        if self.include_drawdown:
            # find the value of max drawdown
            mdd = self._max_drawdown(frame) 
            # add to the row as e.g. "spx_max_drawdown", "es_max_drawdown" etc.
            row.update({f"{c}_max_drawdown": float(mdd[c]) for c in self.ret_cols})
        return row

    def run(self) -> pd.DataFrame:
        """
        Compute performance summary statistics by calling on the above functions
        """
        # prepare returns DataFrame by calling _prepare_returns
        # which sets up the time index and selects return columns
        self.R = self._prepare_returns()

        # 1) resample period (usually yearly) totals
            # usually resamples by year end, since .resample("Y") uses Dec 31 
            # as year end by default and groups rows into calendar year buckets
        # check whether to annualise the resampled returns
        annualised_value = "resampled" in self.annualise
        resampled = self._total_return_resampled(
            self.R.resample(self.resample_freq),
            annualise=("resampled" in self.annualise),
        )

        # build output DataFrame
        out = resampled.reset_index()
        # add a label for the resampling period: 
        #   (if yearly, take the year)
        #   (if quarterly, take year-Qn etc.)
        if "Q" in self.resample_freq:
            out["period"] = out["time"].dt.to_period("Q").astype(str)
        else:
            out["period"] = out["time"].dt.year.astype(str) # add a label for the period
        
        # add start and end dates for the window
        out["start_date"] = out["time"].dt.year.astype(str) + "-01-01"
        out["end_date"]   = out["time"].dt.year.astype(str) + "-12-31"

        # add extra stats if requested: but iterative so slower
        if self.include_vol or self.include_drawdown:
            # convert the out dataframe into list of dicts, one per year
            out_rows = out.to_dict(orient="records")
            out_rows_new = []
            for row in out_rows:
                # set the frame to be the slice of R corresponding to this year
                frame = self.R.loc[row["start_date"]:row["end_date"]]
                row = self._add_extra_stats(row, frame, pre_annualised=annualised_value)
                out_rows_new.append(row)

            extra_df = pd.DataFrame(out_rows_new)
            # replace original out dataframe
            out = extra_df



        # sort in descending order of year
        out = out.sort_values("period", ascending=False)
        out = out.drop(columns=["time"]) # drop the time column as no longer needed

        # 2) YTD
        last_date = self.R.index.max()
        # set the frame to be from Jan 1 of last year to last date
        frame = self.R.loc[f"{last_date.year}-01-01":last_date]

        # check whether to annualise YTD
        annualised_value = "YTD" in self.annualise
        
        # calculate returns, pre-annualised if chosen
        ytd = self._total_return(frame, annualise=annualised_value)      


        ytd_row = {
            "period": "YTD",
            "start_date": f"{last_date.year}-01-01",
            "end_date": str(last_date.date()),
            # the ** operator unpacks the series into a dict, because it detects that 
            # the indices of the series (returns series we were comparing against) 
            # correspond to the keys expected in the dict
            **ytd.to_dict() 
        }

        # add extra stats if requested
        ytd_row = self._add_extra_stats(ytd_row, frame, pre_annualised=annualised_value)
        ytd_df = pd.DataFrame([ytd_row])

        # 3) rolling multi-year windows
        window_rows = []
        for window in (1, 3, 5, 10):
            # compute start date for the rolling window to be the last date for which
            # we have data, minus the window length
            start = last_date - pd.DateOffset(years=window)
            # make sure the start date is not before the first date in the data
            start = max(start, self.R.index.min())

            # compute stats for the slice of the dataframe corresponding to this window
            frame = self.R.loc[start:last_date]

            # check whether to annualise windows
            annualised_value = "windows" in self.annualise

            # calculate returns, annualised if chosen
            stats = self._total_return(frame, annualise=annualised_value)

            row = {
                "period": f"Last {window} Years",
                "start_date": str(start.date()),
                "end_date": str(last_date.date()),
                # the ** operator unpacks the series into a dict, because it detects that 
                # the indices of the series (returns series we were comparing against) 
                # correspond to the keys expected in the dict
                **stats.to_dict() 
            }

            # add extra stats if requested
            row = self._add_extra_stats(row, frame, pre_annualised=annualised_value)

            # append the row to the list of window rows
            window_rows.append(row)

        windows_df = pd.DataFrame(window_rows)

        summary = pd.concat([ytd_df, windows_df, out], ignore_index=True)

        # formatting
        # ensure the numeric cols are stored as floats but rounded to 4 decimal places
        for c in [col for col in summary.columns if col not in ["period", "start_date", "end_date"]]:
            summary[c] = summary[c].astype(float).round(4)

        # format the summary columns neatly in title format without underscores
        summary.columns = [c.replace("_", " ").title() for c in summary.columns]

        self.summary = summary
        return summary


class PerformanceCompare:
    """
    Compare existing summary statistics of different return series to see which is better.
    """

    def __init__(
        self,
        summary_df: pd.DataFrame,
        rank_by: list[str] = ["Total Return","Sharpe"],
        rank_periods: list[str] = ["Last 5 Years","Last 10 Years"],
        *,
        periods_per_year: float = 252.0 # default 252 for interday data,
    ):
        """
        Initialize with summary DataFrame and periods per year.
        """
        self.summary_df = summary_df
        self.rank_by = rank_by
        self.rank_periods = rank_periods

    def _transform_summary_df(self):
        """
        Transform the summary DataFrame into a format suitable for comparison.
        """
        # first, trasform the summary_df into a long format for easier manipulation
        df_long = self.summary_df.melt(
            id_vars=["Period", "Start Date", "End Date"],
            var_name="metric",
            value_name="value"
        )
        # create a column called "strategy_name" that extracts the strategy name 
        # from the Metric column: everything before Period Return comes up in the
        # string in the Metric column
        # basically, find where "Period Return" comes up and take all the text before that

        # Regex explanation:
        # ^                 -> start of string
        # (.*)              -> capture group 1: "everything up to the next part" (greedy, so it will take as much as it can)
        # \s+               -> one or more spaces before the literal phrase
        # Period Return     -> literal text we anchor on
        # (?:\s+.*)?        -> OPTIONAL non-capturing group:
        #                      \s+.* means "a space followed by anything"
        #                      the trailing ? makes the whole group optional, which is what allows
        #                      anything (or nothing) to follow "Period Return"
        # $                 -> end of string
        df_long["strategy_name"] = df_long["metric"].str.extract(
            r"^(.*)\s+Period Return(?:\s+.*)?$"
        )[0] # this 0 makes sure we only xtract the first group captured ( the part before "Period Return")

        # then, add a separate column for the metric type, which is whatever came after
        # period return in the metric column, and if nothing did, this would correspond to
        # total return (annualised, save for YTD)

        # Regex explanation:
        # ^                 -> start of string
        # .*?               -> any characters (non-greedy) up to the first match of the next literal phrase
        # \s+               -> one or more spaces before the literal phrase
        # Period Return     -> literal text we anchor on
        # (.*)              -> capture group 1: everything after "Period Return" (can be empty)
        # $                 -> end of string
        df_long["metric_type"] = (
            df_long["metric"]
            .str.extract(r"^.*?\s+Period Return(.*)$")[0]
            .str.lstrip()   # remove whitespace only at the start of the string
        )

        # fill the "" (empty string) values in this col with "Total Return"
        # (note: extract returns "" rather than NaN when it matches but captures nothing)
        df_long["metric_type"] = df_long["metric_type"].replace("", "Total Return")

        # drop the start and end date columns as no longer needed

        # transform the datframe again so that each row is a strategy_name, and each column is 
        # a metric during a given period
        df_long = df_long.pivot_table(
            index=["strategy_name"],
            columns=["Period","metric_type"],
            values="value"
        ).reset_index()

        return df_long

    def _flag_frequent_bottom_performers(self,
        df: pd.DataFrame,
        metric: str = "Total Return",
        bottom_frac: float = 0.05,
        min_fraction_periods: float = 0.5,
        out_col: tuple = ("flag", "bottom_5pct_half_periods"),
        ) -> pd.DataFrame:
        """
        Adds a column that flags strategies that fall in the bottom `bottom_frac`
        of performers for at least `min_fraction_periods` of the periods (years)
        for the specified `metric`.

        Returns a copy with the extra column appended.
        """
        out = df.copy()

        # 1) pick (year, metric) columns only
        cols = out.columns
        if not isinstance(cols, pd.MultiIndex):
            raise TypeError("df.columns must be a MultiIndex")

        # Keep columns where level0 is not a strategy_name (will be a metric period)
        period_metric_cols = [c for c in cols if c[0] != "strategy_name"]
        # usually, level0 looks like a time period AND level1 equals metric
        

        X = out[period_metric_cols].astype(float)  # rows=strategy, cols=years

        # 2) bottom-k per year (k = max(1, ceil(frac * n_strategies)))
        n = X.shape[0]
        k = max(1, int(np.ceil(bottom_frac * n)))

        # Rank ascending: rank 1 = worst (smallest return)
        ranks = X.rank(axis=0, method="min", ascending=True)

        bottom_mask = ranks <= k  # True if strategy is in bottom bucket for that year

        # 3) count how often bottom, require at least half the years (or your threshold)
        hits = bottom_mask.sum(axis=1)
        periods = bottom_mask.shape[1]
        threshold = int(np.ceil(min_fraction_periods * periods))

        out[out_col] = (hits >= threshold).astype(int)

        return out

    def run(self) -> pd.DataFrame:
        """
        Compare the performance summaries and determine which return series is better.
        """
        df_transformed = self._transform_summary_df()

        df_flagged = self._flag_frequent_bottom_performers(df_transformed)

        # filter out frequent bottom performers
        df_filtered = df_flagged[df_flagged[("flag", "bottom_5pct_half_periods")] == 0].copy()

              
        # first, initialise a dataframe to hold the rankings, with the same number of rows as the filtered df
        rankings_df = pd.DataFrame(index=df_filtered.index)

        # now,  for each of the metrics and periods specified in self.rank_by and self.rank_periods,
        # create a column where the highest ranked strategy is at the top, followed by the column 
        # used to rank that strategy, also in top to bottom rank order
        for metric in self.rank_by:
            for period in self.rank_periods:
                col = (period, metric)
                if col not in df_filtered.columns:
                    raise ValueError(f"Column {col} not found in DataFrame for ranking.")

                # rank the strategies in descending order (highest value = rank 1)
                df_ranked = df_filtered.sort_values(by=col, ascending=False).reset_index(drop=True)

                # now that it is ranked, take only the strategy_name and the column used for ranking
                df_ranked_subset = df_ranked[[('strategy_name', ''), col]].copy()
                # rename the strategy_name column to indicate the metric and period used for ranking
                # flatten MultiIndex columns -> single strings
                df_ranked_subset.columns = [
                    f"{a} {b}".strip() if b else str(a)   # join levels; drop empty second level
                    for a, b in df_ranked_subset.columns # a and b are usually ('period', 'metric')
                ]

                # now rename using single-level column names
                df_ranked_subset = df_ranked_subset.rename(columns={
                    "strategy_name": f"Ranked by {metric} ({period})",
                    f"{col[0]} {col[1]}".strip(): f"{metric} ({period})",
                })

                # append/concatenate to thee right of the rankings_df
                rankings_df = pd.concat([rankings_df, df_ranked_subset], axis=1)
             


        return rankings_df