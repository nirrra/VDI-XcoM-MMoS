## VDI-XcoM & MMoS Validation (Data + Code)

This repository provides the **data and MATLAB code** used to validate the **VDI-XcoM** and **MMoS** metrics proposed in our work.

### What’s included
- **Validation scripts** for single-trial testing and full-dataset statistical analysis.
- **Preprocessing / segmentation / computation pipelines** for CoM, XcoM variants, BoS, MoS/MMoS.
- A fixed **expected dataset directory layout** so the scripts can run without manual path edits.

---

## Repository layout (key files)
- **`codes/com_cmp_single.m`**: Run and visualize **one trial** (quick sanity check).
- **`codes/com_cmp_all.m`**: Run **full-dataset** analysis and statistical summaries.
- **`data/dataSTS2/`**: Dataset root folder expected by the loader.

---

## Data download & setup
### Download
The raw dataset can be downloaded from:
- **Dataset URL**: `https://share.weiyun.com/Z0uyv8hG`

### Unzip location (required)
After extracting the downloaded zip file, please make sure the extracted files match the following structure **relative to the repository root**:

```text
VDI-XcoM-MMoS/
  codes/
    com_cmp_single.m
    com_cmp_all.m
    ...
  data/
    dataSTS2/
      floorFileSTS2.txt
      KinectMat/
        *.mat
      GRF2Mat/
        *.mat
      (other files/folders are allowed)
```

Notes:
- The data loader is implemented in `codes/algorithms/algorithms_preprocessing/ReadAndSortDataKinect2.m`.
- By default it looks for `../data/dataSTS2/` (relative to `codes/`), so the **recommended working directory is `codes/`** when running scripts.

---

## Requirements
- **MATLAB** (tested with typical Signal Processing / Image Processing functionality used by the scripts).
- The repository uses relative paths and does not require extra installation beyond the dataset.

---

## Running the code
### 1) Single trial test
Open MATLAB, set the current folder to `codes/`, then run:
- `com_cmp_single.m`

This script is intended for **testing and visualization on a single trial**.

### 2) Full dataset analysis (recommended)
From the same `codes/` folder, run:
- `com_cmp_all.m`

By default, `com_cmp_all.m` **does not re-generate** the processed dataset. It loads the cached file:
- `codes/com_cmp_all.mat`

#### Re-generate processed data (optional)
In `codes/com_cmp_all.m`, near the top you will find:
- `if false`

Keep it as **`false`** to reuse `com_cmp_all.mat` (fast).

Set it to **`true`** to re-process from the raw dataset and re-create `com_cmp_all.mat` (slow, but fully reproducible from raw data).

---

## Outputs
During execution, figures and intermediate outputs may be saved under:
- `outputs/` (created automatically if missing)

