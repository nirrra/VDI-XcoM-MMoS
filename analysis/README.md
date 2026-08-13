# Analysis workflow

This directory contains the Python workflow for local table and figure
generation. It is designed to operate on locally authorized processed inputs.

## Setup

```bash
python -m pip install -r analysis/requirements.txt
```

## Run

```bash
python analysis/run_all.py
```

The workflow reads inputs from `analysis/data/` and writes outputs to
`analysis/results/`. Both locations are excluded from version control.

## Components

- `build_tables.py`: tabular summaries.
- `plot_figures.py`: static PNG and vector-PDF figures.
- `run_all.py`: runs both steps.

If an input is absent, the script reports the required local filename.
