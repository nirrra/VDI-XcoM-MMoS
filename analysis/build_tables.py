"""Build local analysis tables from locally supplied processed inputs."""

from __future__ import annotations

from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
OUTPUT = ROOT / "results" / "tables"


def save(frame: pd.DataFrame, filename: str) -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    frame.to_csv(OUTPUT / filename, index=False)


def table_1() -> None:
    source = pd.read_csv(DATA / "gvs" / "strategy_descriptives.csv")
    rows = []
    for _, row in source.iterrows():
        rows.append(
            {
                "Metric": f"{row['metric']} ({row['unit']})",
                "MT": f"{row.MT_mean:.2f} ± {row.MT_sd:.2f}" if row.unit != "N" else f"{row.MT_mean:.1f} ± {row.MT_sd:.1f}",
                "ETF": f"{row.ETF_mean:.2f} ± {row.ETF_sd:.2f}" if row.unit != "N" else f"{row.ETF_mean:.1f} ± {row.ETF_sd:.1f}",
                "DVR": f"{row.DVR_mean:.2f} ± {row.DVR_sd:.2f}" if row.unit != "N" else f"{row.DVR_mean:.1f} ± {row.DVR_sd:.1f}",
            }
        )
    save(pd.DataFrame(rows), "gvs_strategy_descriptors.csv")


def table_2() -> None:
    source = pd.read_csv(DATA / "gvs" / "component_subject_strategy_agreement.csv")
    quantity_map = {
        "vdi_xcom_y": "VDI-XcoM AP waveform",
        "bos_ap_length": "Effective-BoS AP span",
        "mmos_waveform": "MMoS waveform",
    }
    selected = source[source["quantity"].isin(quantity_map)].copy()
    summary = (
        selected.groupby(["quantity", "strategy"], as_index=False)[["relative_rmse", "pearson_r"]]
        .mean()
    )
    rows = []
    for quantity, label in quantity_map.items():
        row = {"Quantity": label}
        for strategy in ("MT", "ETF", "DVR"):
            value = summary[(summary.quantity == quantity) & (summary.strategy == strategy)].iloc[0]
            row[f"{strategy} rRMSE (%)"] = round(100 * value.relative_rmse, 1)
            row[f"{strategy} Pearson r"] = round(value.pearson_r, 3)
        rows.append(row)
    save(pd.DataFrame(rows), "gvs_waveform_agreement.csv")


def table_3() -> None:
    group = pd.read_csv(DATA / "ccs" / "group_comparison_effect_size.csv").set_index("metric")
    ancova = pd.read_csv(DATA / "ccs" / "ancova_covariate_adjusted.csv").set_index("metric")
    metrics = ["duration", "seat_off", "trunk_flexion_vertical_max", "max_grf"]
    rows = []
    for metric in metrics:
        g, a = group.loc[metric], ancova.loc[metric]
        rows.append(
            {
                "Metric": g.label,
                "Healthy controls mean": g.control_mean,
                "Healthy controls SD": g.control_sd,
                "Stroke survivors mean": g.patient_mean,
                "Stroke survivors SD": g.patient_sd,
                "Adjusted difference": a.group_beta,
                "95% CI low": a.ci_low,
                "95% CI high": a.ci_high,
                "Hedges g": g.hedges_g,
                "Holm-adjusted p": a.p_holm,
            }
        )
    save(pd.DataFrame(rows), "ccs_conventional_descriptors.csv")


def table_4() -> None:
    source = pd.read_csv(DATA / "ccs" / "reliability_selected.csv")
    selected = source[
        source["group"].eq("Control")
        & source["repeat_definition"].eq("Complete four-trial subset")
        & source["metric"].isin(
            ["main_valley_value", "main_valley_time", "mmos_seatoff", "mmos_negative_auc"]
        )
    ].copy()
    order = ["main_valley_value", "main_valley_time", "mmos_seatoff", "mmos_negative_auc"]
    selected["metric"] = pd.Categorical(selected["metric"], order, ordered=True)
    selected = selected.sort_values("metric")
    save(
        selected[["label", "icc", "sem", "mdc95"]].rename(
            columns={"label": "MMoS feature", "icc": "ICC(A,1)", "sem": "SEM", "mdc95": "MDC95"}
        ),
        "ccs_margin_reliability.csv",
    )


def table_5() -> None:
    source = pd.read_csv(DATA / "ccs" / "three_metrics_group_comparison.csv")
    metrics = [
        "mos_min_preso",
        "mos_effective_bos_min_preso",
        "mmos_min_preso",
        "mmos_negative_auc",
    ]
    selected = source[source["metric"].isin(metrics)].copy()
    selected["metric"] = pd.Categorical(selected["metric"], metrics, ordered=True)
    selected = selected.sort_values("metric")
    save(selected, "ccs_stability_features.csv")


def table_6() -> None:
    source = pd.read_csv(DATA / "ccs" / "component_sensitivity_table6.csv")
    save(source, "ccs_component_features.csv")


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for path in OUTPUT.glob("*.csv"):
        path.unlink()
    table_1()
    table_2()
    table_3()
    table_4()
    table_5()
    table_6()
    print(f"Saved local analysis tables to: {OUTPUT}")


if __name__ == "__main__":
    main()
