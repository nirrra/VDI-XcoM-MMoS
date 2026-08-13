## VDI-XcoM & MMoS Validation (GVS + CCS)

This repository provides MATLAB algorithms and Python analysis code for
VDI-XcoM, the effective base of support (BoS), and the modified margin of
stability (MMoS) during sit-to-stand.

The project is organized by two complementary studies:

- **`GVS/`**: Gold-standard validation algorithms.
- **`CCS/`**: Clinical comparison algorithms.

### What’s included

- MATLAB implementations of the kinematic, kinetic, BoS, VDI-XcoM, and MMoS
  calculations.
- A Python workflow for generating local analysis tables and figures from
  authorized local inputs.
- Repository-relative paths and a layout suitable for independent analysis.

---

## Repository layout (key files)

- **`GVS/codes/algorithms/`**: Validation-study preprocessing and VDI-XcoM
  calculation functions.
- **`CCS/algorithms/algorithm_pelvis/`**: Pelvis-aware kinematic and kinetic
  functions used by the effective-BoS calculation.
- **`CCS/algorithms/algorithm_VDI_XcoM/`**: BoS, VDI-XcoM, and signed-margin
  functions.
- **`analysis/build_tables.py`**: Builds local analysis tables.
- **`analysis/plot_figures.py`**: Builds local analysis figures, including
  vector-PDF exports.
- **`analysis/run_all.py`**: Runs the Python analysis workflow.

---

## Data download

Input datasets are not bundled with this repository. Download the study data
from the following links and place the files in the corresponding study
directories before running an analysis:

- **CCS data**: <https://share.weiyun.com/EFtY8Crr>
- **GVS data**: <https://share.weiyun.com/wTSKfAVp>

Locally authorized processed inputs for the Python workflow should be placed
in `analysis/data/`. Input data and generated outputs are excluded from version
control.

---

## Data layout and setup

Keep the directory structure unchanged. The analysis workflow reads local
processed inputs from `analysis/data/` and writes generated artifacts to
`analysis/results/`. Both paths are intentionally excluded from version
control.

```text
VDI-XcoM-MMoS/
  README.md
  GVS/
    codes/
      algorithms/
  CCS/
    algorithms/
      algorithm_pelvis/
      algorithm_VDI_XcoM/
  analysis/
    build_tables.py
    plot_figures.py
    run_all.py
    requirements.txt
    data/
    results/
```

Notes:

- `GVS` contains the validation-study algorithm library.
- `CCS` contains the clinical-comparison algorithm library.
- `analysis/data/README.md` explains the local-data boundary.

---

## Requirements

- MATLAB for the algorithm libraries.
- Python 3.10 or later for the local analysis workflow.
- Python packages listed in `analysis/requirements.txt`.

---

## Running the code

### 1) MATLAB algorithms

Open MATLAB and add the required study algorithm directory and its subfolders
to the path. The functions can then be called from a local analysis script with
locally authorized data.

### 2) Python analysis workflow

From the repository root, install the Python requirements and run:

```bash
python -m pip install -r analysis/requirements.txt
python analysis/run_all.py
```

The workflow reports missing local inputs by name.

---

## Outputs

Python outputs are written only to `analysis/results/`. These generated files,
as well as all local input data, are excluded from version control.
