# Risk Control Using a Bayesian Joint Quantile Time Series Model For Asset Returns
I backtest the performance of an index concept where the index portfolio changes its weight in an underlying market portfolio in order to achieve a target level of risk, given by a target forecast quantile level (using a BJQTS model) as opposed to a target forecast volatility level.

## Highlights for achieved so far and still developing:

### Achieved so far:
- Backtest has been carried out over each of last 10 years, with replication through changing exposure to a liquid ETF of the S&P 500, the SPY (not a futures contract), and no accounting for management fees
- Over almost all annual windows over the preceding 10 year, the standard index concept exhibits a more favourable Sharpe ratio than a baseline buy-and hold
- During some select periods of market stress, forecasts from the model allow the strategy to reduce market exposure ahead of a drawdown in the market and re-enter the market just as it is recovering. During the COVID-19 pandemic, drawdowns were less than half of those experienced by buy-and hold.
- During other periods, drawdowns may have been lower than the market, but time to re-enter the market resulted in materially weaker returns
### To develop:
- Conduct more rigorous backtests to validate long-term performance:
    - Analyse strategy performance in different regimes and tailor the strategy to adjust for each:
        - Identify structurally different regimes using features that are fundamental predictors of those regimes
        - Assign different windows of time in the return series history to each regime as per whether the features would suggest that indeed is the regime at that time
        - Conduct regime-specific backtests as opposed to a handful of market stress scenarios (compare strategy performance in areas statistically identified to belong to different states/regimes)
    - Join regime-specific performances (distribution of returns conditional on being in each state/regime) together:
        - Estimating the transition matrix first, by seeing how often we switch from each regime to the other in historical data
        - Estimat the long run probabilities of each state/regime by finding which steady state probabilities are rationalised by the transition matrix
        - Multiply the expected returns conditional on being in each regime by each regime's long-run probability
    - Adapt the model or strategy to achieve stronger expected long-run performance by optimising its out-of-sample performance in each regime
    - Finally run over completely unsees testing data (separate to the validation data used for making out-of-sample performance better)
      
- Extend to the intraday arena
    - Model adjustments:
        - Adjust for intraday seasonality/diurnality (Market open and close)
        - Adjust for wider hierearchy (market structure [long-run volatility, or volatility of volatility, regime, long, medium and short-term dynamics)
      - Strategy adjustments
          - Change mechanism of gaining market exposure to be through futures
          - Account for holding costs (net funding)
          - Account for transaction costs (brokerage fees and slippage)


## DISCLAIMER:

The model used to forecast the quantiles of conditional returns is a Bayesian Joint Quantile Time Series (BJQTS) model form the paper "A Bayesian Joint Quantile Time Series Model for Asset Returns" by Daniel Halm, which is available on Taylor and Francis Online [here](https://www.tandfonline.com/doi/abs/10.1080/07350015.2020.1766470).

I have used Open AI's Chat GPT 3.5, GPT 4-0 and GPT 5, as well as github co-pilot (underlying LLM is Claude) to assist with syntax and structuring across various coding aspects of this project. 

###  🗂️ Directory Structure
```plaintext
.
├── README.md
├── credentials.json (used to acess data)
├── data
│   └── csv and excel files from CRSP
├── docs (webpages)
│   ├── figures
│       ├── contains figures and images
│   └── index.html (Project overview web page)
├── notebooks
│   ├── NB01_Backtest_Interday.ipynb (Original main notebook with visuals)
│   ├── NB01_Backtest_Interday_working.ipynb (Additional, inter-day analysis building off of original, main notebook)
│   └── NB01_Backtest_Intraday.ipynb (Work in progress for applying into the intra-day space)
├── src
│   ├── stats_utils (custom Python package)
│   └── scripts (runnable Python scripts)
└── requirements.txt (set of packages to install onto the virtual environment)

```
### 📚 How to get this to work

If you want to replicate the analysis in this project, you will need to:

1. Clone this repository to your computer
    ```bash
    git clone git@github.com:danielhalm1407/Rental_Market_Demand_and_Cost_Inference.git
    ```
2. Add it to your VS Code workspace
3. Set up your conda environment on conda's 3.11 version of python:

    ```bash
    conda create -n venv-stats python=3.11 ipython
    conda activate venv-stats
    ```
4. Make sure `pip` is installed inside that environment:

    ```bash
    conda install pip
    ```

5. Now use that pip to install the packages:

    ```bash
    python -m pip install -r requirements.txt
    ```
