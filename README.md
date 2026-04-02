## VDI-XcoM & MMoS Validation (GVS + CCS)

This repository provides the **MATLAB code and experiment data** used to support the manuscript **`manuscript.md`**.

The project is organized by the two studies described in the manuscript:
- **`GVS/`**: Gold-standard validation study.
- **`CCS/`**: Clinical comparison study.

### What’s included
- **Experiment-specific code** for the `GVS` and `CCS` analyses.
- **Bundled experiment data folders** arranged under each study directory.
- **Figure / table output locations** matching the current project structure.
- A repository layout that follows the two-stage study design used in the manuscript.

---

## Repository layout (key files)
- **`GVS/codes/com_cmp_single.m`**: Single-trial visualization / sanity-check script for the gold-standard validation study.
- **`GVS/codes/com_cmp_all.m`**: Full GVS analysis script for aggregated results.
- **`GVS/data/dataSTS2/`**: Main bundled dataset folder used by the GVS workflow.
- **`CCS/CompareControlPatient_VDI_XcoM.m`**: Main script for the clinical comparison study.
- **`CCS/data/`**: Patient-group data and processed segment cache for CCS.
- **`CCS/data_control/`**: Control-group data and processed segment cache for CCS.
- **`CCS/predicted_tangential_mat/`**: Predicted tangential-force files used by the CCS pipeline.

---

## Data download
If you need to re-download the experiment data, use the following links:

- **CCS data**: `https://share.weiyun.com/EFtY8Crr`
- **GVS data**: `https://share.weiyun.com/wTSKfAVp`

After download, please place the files back into the folder structure shown below.

---

## Data layout and setup
The repository is already arranged according to the current manuscript workflow. Please keep the folder structure unchanged.

```text
VDI-XcoM-MMoS/
  README.md
  GVS/
    codes/
      com_cmp_single.m
      com_cmp_all.m
      algorithms/
      ...
    data/
      dataSTS2/
        floorFileSTS2.txt
        KinectMat/
        GRF2Mat/
        Analysis2Mat/
        Analysis4Mat/
        ...
  CCS/
    CompareControlPatient_VDI_XcoM.m
    algorithms/
    data/
      floorFile/
      footscan/
      kinect/
      sts_segs_patient.mat
    data_control/
      floorFile/
      footscan/
      kinect/
      sts_segs_control.mat
    predicted_tangential_mat/
      patient/
      control/
    outputs/
      experiment_b_lite/
        figures/
        tables/
```

Notes:
- `GVS` corresponds to the **gold-standard validation study**.
- `CCS` corresponds to the **clinical comparison study**.

---

## Requirements
- **MATLAB**
- Standard MATLAB functionality required by the provided scripts for signal processing, visualization, tables, and statistics
- No separate installation step is required if the repository structure is kept as-is

---

## Running the code
### 1) GVS: single-trial test
Open MATLAB, set the current folder to:
- **`GVS/codes/`**

Then run:
- **`com_cmp_single.m`**

This script is intended for **single-trial inspection and visualization** in the gold-standard validation study.

### 2) GVS: full analysis
From the same folder:
- **`GVS/codes/`**

Run:
- **`com_cmp_all.m`**

This script performs the **full GVS analysis** and generates the main aggregated results for the validation experiment.

### 3) CCS: group comparison analysis
Open MATLAB, set the current folder to:
- **`CCS/`**

Then run:
- **`CompareControlPatient_VDI_XcoM.m`**

This script performs the **clinical comparison study** analysis between the control and patient groups.

---

## Outputs
After running the scripts, outputs are written to the experiment-specific folders:

- **GVS outputs**: `GVS/outputs/experiment_a/` (created when needed by the full analysis script)
- **CCS outputs**: `CCS/outputs/experiment_b_lite/`
- **CCS figures**: `CCS/outputs/experiment_b_lite/figures/`
- **CCS tables**: `CCS/outputs/experiment_b_lite/tables/`

Additional intermediate figures may also be created under other `outputs/` subfolders inside each experiment directory.
