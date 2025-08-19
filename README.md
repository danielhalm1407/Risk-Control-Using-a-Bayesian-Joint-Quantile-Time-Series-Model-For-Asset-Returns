# Risk-Control-Using-a-Bayesian-Joint-Quantile-Time-Series-Model-For-Asset-Returns
I back-test the performance of an index concept where the index portfolio changes its weight in an underlying market portfolio in order to achieve a target level of risk, given by a target forecast quantile level (using a BJQTS model) as opposed to a target forecast volatility level.

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
│   └── NB01_Backtest.ipynb
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
