"""Generate local analysis figures from locally supplied processed inputs.

The script uses grayscale styles and exports both raster PNG and vector PDF
files. It never changes the input tables.
"""

from __future__ import annotations

from hashlib import sha256
from pathlib import Path
import warnings

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats


SCRIPT_PATH = Path(__file__).resolve()
ANALYSIS_ROOT = SCRIPT_PATH.parent
DATA_ROOT = ANALYSIS_ROOT / "data" / "ccs"

SUBJECT_CURVES_FILE = DATA_ROOT / "effective_bos_subject_curves.csv"
SUBJECT_METRICS_FILE = DATA_ROOT / "effective_bos_subject_metrics.csv"
BODY_STATE_FILE = DATA_ROOT / "body_state_subject_curves.csv"
AP_GROUP_FILE = DATA_ROOT / "ap_mechanism_group_curves.csv"
CONTRIBUTION_GROUP_FILE = DATA_ROOT / "component_contribution_group_curves.csv"
CONTRIBUTION_SUBJECT_FILE = DATA_ROOT / "component_contribution_subject_curves.csv"
INCREMENT_GROUP_FILE = DATA_ROOT / "component_sensitivity_group_curves.csv"
INCREMENT_SUBJECT_FILE = DATA_ROOT / "component_sensitivity_subject_curves.csv"

OUTPUT_ROOT = ANALYSIS_ROOT / "results"
FIGURES = OUTPUT_ROOT / "figures"
QA_FILE = OUTPUT_ROOT / "figure_qa.csv"
MANIFEST_FILE = OUTPUT_ROOT / "manifest.csv"

PHASE = np.linspace(0.0, 100.0, 101)
ALPHA = 0.05

# Typography is intentionally large for legibility after figure resizing.
FONT_TITLE = 19.0
FONT_LABEL = 19.0
FONT_TICK = 17.0
FONT_LEGEND = 16.5
LINE_WIDTH = 2.8
REFERENCE_WIDTH = 1.6

GROUP_STYLE = {
    "Control": {
        "short": "Control",
        "label": "Healthy controls",
        "color": "#111111",
        "linestyle": "-",
    },
    "Patient": {
        "short": "Stroke",
        "label": "Stroke survivors",
        "color": "#666666",
        "linestyle": "--",
    },
}

METHOD_STYLE = {
    "reference": {"color": "#111111", "linestyle": "-"},
    "extended": {"color": "#6B6B6B", "linestyle": "--"},
}

# In the two six-curve panels, group membership is encoded by grayscale and
# component identity by line style. This avoids relying on three similar gray
# levels to distinguish components while retaining black-and-white output.
SUPPORT_STYLE = {
    "seat_ap_contribution_m": {"label": "Seat-derived", "linestyle": "-."},
    "foot_ap_contribution_m": {"label": "Plantar", "linestyle": "--"},
    "net_ap_contribution_m": {"label": "Net", "linestyle": "-"},
}

COMPONENT_STYLE = {
    "displacement": {"label": "Displacement", "linestyle": "-"},
    "velocity": {"label": "Velocity", "linestyle": "--"},
    "angular_momentum": {"label": "Angular momentum", "linestyle": "-."},
}

FIGURE_STEMS = (
    "Figure_1_EffectiveBoS",
    "Figure_2_VDIXCoM",
    "Figure_3_StabilityProfiles",
    "Figure_4_APSupport",
    "Figure_5_Components",
)

plt.rcParams.update(
    {
        "font.family": "serif",
        "font.serif": ["Times New Roman", "DejaVu Serif"],
        "mathtext.fontset": "stix",
        "font.size": FONT_TICK,
        "axes.titlesize": FONT_TITLE,
        "axes.labelsize": FONT_LABEL,
        "xtick.labelsize": FONT_TICK,
        "ytick.labelsize": FONT_TICK,
        "legend.fontsize": FONT_LEGEND,
        "axes.linewidth": 1.2,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "xtick.direction": "out",
        "ytick.direction": "out",
        "figure.facecolor": "white",
        "savefig.facecolor": "white",
        "pdf.fonttype": 42,
        "ps.fonttype": 42,
    }
)


def require_inputs() -> None:
    required = [
        SUBJECT_CURVES_FILE,
        SUBJECT_METRICS_FILE,
        BODY_STATE_FILE,
        AP_GROUP_FILE,
        CONTRIBUTION_GROUP_FILE,
        CONTRIBUTION_SUBJECT_FILE,
        INCREMENT_GROUP_FILE,
        INCREMENT_SUBJECT_FILE,
    ]
    missing = [str(path) for path in required if not path.exists()]
    if missing:
        raise FileNotFoundError("Required figure inputs are missing:\n" + "\n".join(missing))


def mean_ci(matrix: np.ndarray) -> tuple[np.ndarray, np.ndarray, np.ndarray]:
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", category=RuntimeWarning)
        mean = np.nanmean(matrix, axis=0)
        sd = np.nanstd(matrix, axis=0, ddof=1)
    n = np.sum(np.isfinite(matrix), axis=0)
    critical = stats.t.ppf(1.0 - ALPHA / 2.0, np.maximum(n - 1, 1))
    half_width = np.divide(
        critical * sd,
        np.sqrt(n),
        out=np.full_like(sd, np.nan),
        where=n > 1,
    )
    return mean, mean - half_width, mean + half_width


def plot_long_subject_signal(
    ax: plt.Axes,
    curves: pd.DataFrame,
    signal: str,
    group: str,
    *,
    scale: float,
    color: str,
    linestyle: str,
    label: str,
    linewidth: float = LINE_WIDTH,
) -> None:
    selected = curves[curves["group"].eq(group) & curves["signal"].eq(signal)]
    matrix = (
        selected.pivot(index="subject_key", columns="phase_percent", values="value")
        .reindex(columns=PHASE)
        .to_numpy(float)
    )
    mean, low, high = mean_ci(matrix)
    ax.plot(
        PHASE,
        scale * mean,
        color=color,
        linestyle=linestyle,
        linewidth=linewidth,
        label=label,
        zorder=3,
    )
    ax.fill_between(
        PHASE,
        scale * low,
        scale * high,
        color=color,
        alpha=0.12,
        linewidth=0,
        zorder=1,
    )


def plot_wide_subject_signal(
    ax: plt.Axes,
    curves: pd.DataFrame,
    signal: str,
    group: str,
    *,
    scale: float,
    color: str,
    linestyle: str,
    label: str,
    linewidth: float = LINE_WIDTH,
) -> None:
    selected = curves[curves["group"].eq(group)]
    matrix = (
        selected.pivot(index="subject_key", columns="phase_percent", values=signal)
        .reindex(columns=PHASE)
        .to_numpy(float)
    )
    mean, low, high = mean_ci(matrix)
    ax.plot(
        PHASE,
        scale * mean,
        color=color,
        linestyle=linestyle,
        linewidth=linewidth,
        label=label,
        zorder=3,
    )
    ax.fill_between(
        PHASE,
        scale * low,
        scale * high,
        color=color,
        alpha=0.12,
        linewidth=0,
        zorder=1,
    )


def format_axis(
    ax: plt.Axes,
    title: str,
    ylabel: str,
    *,
    xlabel: str = "Normalized STS cycle (%)",
    xlim: tuple[float, float] = (0.0, 100.0),
) -> None:
    ax.set_title(title, loc="left", fontweight="normal", pad=11)
    ax.set_xlabel(xlabel, labelpad=8)
    ax.set_ylabel(ylabel, labelpad=8)
    ax.set_xlim(*xlim)
    ax.tick_params(axis="both", labelsize=FONT_TICK, width=1.1, length=5.5)
    ax.grid(color="#D9D9D9", linewidth=0.75, alpha=0.55)
    ax.spines["left"].set_linewidth(1.2)
    ax.spines["bottom"].set_linewidth(1.2)


def south_legend(
    ax: plt.Axes,
    *,
    ncol: int,
    y: float = -0.30,
    fontsize: float = FONT_LEGEND,
) -> None:
    ax.legend(
        loc="upper center",
        bbox_to_anchor=(0.5, y),
        ncol=ncol,
        frameon=False,
        fontsize=fontsize,
        handlelength=2.5,
        handletextpad=0.65,
        columnspacing=1.1,
        borderaxespad=0.0,
    )


def add_seat_off_line(ax: plt.Axes, phase: float, *, style: dict[str, str] | None = None) -> None:
    if style is None:
        color = "#555555"
        linestyle = ":"
    else:
        color = style["color"]
        linestyle = style["linestyle"]
    ax.axvline(
        phase,
        color=color,
        linestyle=linestyle,
        linewidth=REFERENCE_WIDTH,
        alpha=0.75,
        zorder=2,
    )


def save_figure(fig: plt.Figure, stem: str) -> None:
    FIGURES.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIGURES / f"{stem}.png", dpi=300, bbox_inches="tight", pad_inches=0.08)
    fig.savefig(FIGURES / f"{stem}.pdf", bbox_inches="tight", pad_inches=0.08)
    plt.close(fig)


def figure_1(curves: pd.DataFrame, metrics: pd.DataFrame) -> None:
    control_seat_off = float(metrics.loc[metrics["group"].eq("Control"), "seat_off_phase_percent"].mean())
    fig, axes = plt.subplots(1, 2, figsize=(10.8, 5.9))

    plot_long_subject_signal(
        axes[0], curves, "bos_centroid_relative_y_m", "Control",
        scale=100.0, color=METHOD_STYLE["extended"]["color"],
        linestyle=METHOD_STYLE["extended"]["linestyle"], label="Effective-BoS centroid",
    )
    axes[0].axhline(
        0.0, color=METHOD_STYLE["reference"]["color"],
        linestyle=METHOD_STYLE["reference"]["linestyle"],
        linewidth=LINE_WIDTH, label="Plantar-BoS centroid", zorder=3,
    )
    format_axis(axes[0], "(a) AP centroid relative to plantar BoS", "Relative AP position (cm)")
    add_seat_off_line(axes[0], control_seat_off)
    handles, labels = axes[0].get_legend_handles_labels()
    axes[0].legend(
        [handles[1], handles[0]], [labels[1], labels[0]],
        loc="upper center", bbox_to_anchor=(0.5, -0.30), ncol=1,
        frameon=False, fontsize=FONT_LEGEND, handlelength=2.5,
        borderaxespad=0.0,
    )

    plot_long_subject_signal(
        axes[1], curves, "mos", "Control", scale=100.0,
        color=METHOD_STYLE["reference"]["color"],
        linestyle=METHOD_STYLE["reference"]["linestyle"], label="MoS",
    )
    plot_long_subject_signal(
        axes[1], curves, "mos_effective_bos", "Control", scale=100.0,
        color=METHOD_STYLE["extended"]["color"],
        linestyle=METHOD_STYLE["extended"]["linestyle"],
        label=r"$MoS_{\mathrm{effectiveBoS}}$",
    )
    axes[1].axhline(0.0, color="#777777", linestyle=":", linewidth=REFERENCE_WIDTH)
    format_axis(axes[1], "(b) Stability margins with the same XcoM", "Margin (cm)")
    add_seat_off_line(axes[1], control_seat_off)
    south_legend(axes[1], ncol=1)

    fig.subplots_adjust(left=0.09, right=0.985, top=0.90, bottom=0.32, wspace=0.29)
    save_figure(fig, FIGURE_STEMS[0])


def figure_2(body_state: pd.DataFrame, metrics: pd.DataFrame) -> None:
    control_seat_off = float(metrics.loc[metrics["group"].eq("Control"), "seat_off_phase_percent"].mean())
    fig, axes = plt.subplots(1, 3, figsize=(13.0, 5.8))

    plot_wide_subject_signal(
        axes[0], body_state, "xcom", "Control", scale=100.0,
        color=METHOD_STYLE["reference"]["color"],
        linestyle=METHOD_STYLE["reference"]["linestyle"], label="XcoM",
    )
    plot_wide_subject_signal(
        axes[0], body_state, "vdi_xcom", "Control", scale=100.0,
        color=METHOD_STYLE["extended"]["color"],
        linestyle=METHOD_STYLE["extended"]["linestyle"], label="VDI-XcoM",
    )
    format_axis(axes[0], "(a) Body-state trajectories", "AP position (cm)")
    add_seat_off_line(axes[0], control_seat_off)
    south_legend(axes[0], ncol=1)

    plot_wide_subject_signal(
        axes[1], body_state, "mos_effective_bos", "Control", scale=100.0,
        color=METHOD_STYLE["reference"]["color"],
        linestyle=METHOD_STYLE["reference"]["linestyle"],
        label=r"$MoS_{\mathrm{effectiveBoS}}$",
    )
    plot_wide_subject_signal(
        axes[1], body_state, "mmos", "Control", scale=100.0,
        color=METHOD_STYLE["extended"]["color"],
        linestyle=METHOD_STYLE["extended"]["linestyle"], label="MMoS",
    )
    axes[1].axhline(0.0, color="#777777", linestyle=":", linewidth=REFERENCE_WIDTH)
    format_axis(axes[1], "(b) Effective-BoS margins", "Margin (cm)")
    add_seat_off_line(axes[1], control_seat_off)
    south_legend(axes[1], ncol=1)

    plot_wide_subject_signal(
        axes[2], body_state, "vdi_minus_xcom", "Control", scale=1000.0,
        color="#111111", linestyle="-", label="VDI-XcoM − XcoM",
    )
    axes[2].axhline(0.0, color="#777777", linestyle=":", linewidth=REFERENCE_WIDTH)
    format_axis(axes[2], "(c) VDI-XcoM − XcoM", "AP difference (mm)")
    add_seat_off_line(axes[2], control_seat_off)
    south_legend(axes[2], ncol=1)

    fig.subplots_adjust(left=0.065, right=0.992, top=0.90, bottom=0.33, wspace=0.31)
    save_figure(fig, FIGURE_STEMS[1])


def figure_4_support_mechanism(ap_curves: pd.DataFrame) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(11.8, 6.4))

    for group, style in GROUP_STYLE.items():
        data = ap_curves[
            ap_curves["group"].eq(group)
            & ap_curves["signal"].eq("effective_ap_span_m")
            & ap_curves["phase_percent"].le(95.0)
        ].sort_values("phase_percent")
        x = data["phase_percent"].to_numpy(float)
        mean = 100.0 * data["mean"].to_numpy(float)
        low = 100.0 * data["ci_low"].to_numpy(float)
        high = 100.0 * data["ci_high"].to_numpy(float)
        axes[0].plot(
            x, mean, color=style["color"], linestyle="-",
            linewidth=LINE_WIDTH, label=style["label"], zorder=3,
        )
        axes[0].fill_between(x, low, high, color=style["color"], alpha=0.12, linewidth=0)
    format_axis(
        axes[0], "(a) Effective-BoS AP span", "AP span (cm)",
        xlabel="Normalized pre-seat-off phase (%)", xlim=(0.0, 95.0),
    )
    south_legend(axes[0], ncol=1, y=-0.27)

    # Grayscale identifies group, whereas line style identifies the three
    # support contributions. Each group-by-component combination is named.
    for group, style in GROUP_STYLE.items():
        for signal, component in SUPPORT_STYLE.items():
            data = ap_curves[
                ap_curves["group"].eq(group)
                & ap_curves["signal"].eq(signal)
                & ap_curves["phase_percent"].le(95.0)
            ].sort_values("phase_percent")
            axes[1].plot(
                data["phase_percent"].to_numpy(float),
                100.0 * data["mean"].to_numpy(float),
                color=style["color"],
                linestyle=component["linestyle"],
                linewidth=LINE_WIDTH,
                label=f"{style['short']}: {component['label']}",
                zorder=3,
            )
    format_axis(
        axes[1], "(b) Load-weighted AP support contributions", "AP contribution (cm)",
        xlabel="Normalized pre-seat-off phase (%)", xlim=(0.0, 95.0),
    )
    south_legend(axes[1], ncol=2, y=-0.27, fontsize=15.0)

    fig.subplots_adjust(left=0.085, right=0.985, top=0.91, bottom=0.36, wspace=0.27)
    save_figure(fig, FIGURE_STEMS[3])


def figure_3_stability_profiles(curves: pd.DataFrame, metrics: pd.DataFrame) -> None:
    specifications = [
        ("mos", "(a) Traditional MoS\nClassical XcoM + plantar BoS"),
        ("mos_effective_bos", r"(b) $MoS_{\mathrm{effectiveBoS}}$" + "\nClassical XcoM + effective BoS"),
        ("mmos", "(c) MMoS\nVDI-XcoM + effective BoS"),
    ]
    seat_off = {
        group: float(metrics.loc[metrics["group"].eq(group), "seat_off_phase_percent"].mean())
        for group in GROUP_STYLE
    }
    fig, axes = plt.subplots(1, 3, figsize=(13.0, 5.9), sharey=True)
    for ax, (signal, title) in zip(axes, specifications):
        for group, style in GROUP_STYLE.items():
            plot_long_subject_signal(
                ax, curves, signal, group, scale=100.0,
                color=style["color"], linestyle=style["linestyle"],
                label=style["label"],
            )
            add_seat_off_line(ax, seat_off[group], style=style)
        ax.axhline(0.0, color="#777777", linestyle="--", linewidth=REFERENCE_WIDTH)
        format_axis(ax, title, "Margin (cm)")
        ax.tick_params(labelleft=True)
        south_legend(ax, ncol=1, y=-0.29)

    # A shared scale prevents visual exaggeration of one metric relative to another.
    axes[0].set_ylim(-18.5, 11.5)
    fig.subplots_adjust(left=0.065, right=0.992, top=0.88, bottom=0.34, wspace=0.25)
    save_figure(fig, FIGURE_STEMS[2])


def figure_5(
    contribution: pd.DataFrame,
    contribution_subject: pd.DataFrame,
    increments: pd.DataFrame,
    increment_subject: pd.DataFrame,
) -> None:
    contribution_seat_off = (
        contribution_subject[["group", "subject_key", "seat_off_phase_percent"]]
        .drop_duplicates(["group", "subject_key"])
        .groupby("group")["seat_off_phase_percent"]
        .mean()
        .to_dict()
    )
    increment_seat_off = (
        increment_subject[["group", "subject_key", "seat_off_phase_percent"]]
        .drop_duplicates(["group", "subject_key"])
        .groupby("group")["seat_off_phase_percent"]
        .mean()
        .to_dict()
    )

    fig, axes = plt.subplots(1, 3, figsize=(13.2, 6.5))

    # Panel A merges the former group-specific panels. Grayscale identifies
    # group and line style identifies component; all combinations are named.
    for group, group_style in GROUP_STYLE.items():
        for component_name, component_style in COMPONENT_STYLE.items():
            data = contribution[
                contribution["group"].eq(group)
                & contribution["component"].eq(component_name)
            ].sort_values("phase_percent")
            x = data["phase_percent"].to_numpy(float)
            mean = data["mean_percent"].to_numpy(float)
            low = data["ci_low_percent"].to_numpy(float)
            high = data["ci_high_percent"].to_numpy(float)
            axes[0].plot(
                x, mean, color=group_style["color"],
                linestyle=component_style["linestyle"], linewidth=LINE_WIDTH,
                label=f"{group_style['short']}: {component_style['label']}", zorder=3,
            )
            axes[0].fill_between(
                x, low, high, color=group_style["color"], alpha=0.045,
                linewidth=0, zorder=1,
            )
    for group, style in GROUP_STYLE.items():
        add_seat_off_line(axes[0], contribution_seat_off[group], style=style)
    format_axis(axes[0], "(a) Component contributions", "Relative contribution (%)")
    axes[0].set_ylim(0.0, 105.0)
    south_legend(axes[0], ncol=2, y=-0.28, fontsize=13.5)

    increment_panels = [
        ("velocity_increment", "(b) Velocity increment"),
        ("angular_increment", "(c) Angular-momentum increment"),
    ]
    for ax, (signal, title) in zip(axes[1:], increment_panels):
        for group, style in GROUP_STYLE.items():
            data = increments[
                increments["group"].eq(group) & increments["signal"].eq(signal)
            ].sort_values("phase_percent")
            x = data["phase_percent"].to_numpy(float)
            mean = data["mean_m"].to_numpy(float)
            low = data["ci_low_m"].to_numpy(float)
            high = data["ci_high_m"].to_numpy(float)
            ax.plot(
                x, mean, color=style["color"], linestyle="-",
                linewidth=LINE_WIDTH, label=style["label"], zorder=3,
            )
            ax.fill_between(x, low, high, color=style["color"], alpha=0.11, linewidth=0)
            add_seat_off_line(ax, increment_seat_off[group], style=style)
        ax.axhline(0.0, color="#777777", linestyle="--", linewidth=REFERENCE_WIDTH)
        format_axis(ax, title, "Signed-distance increment (m)")
        south_legend(ax, ncol=1, y=-0.28)

    fig.subplots_adjust(left=0.065, right=0.992, top=0.91, bottom=0.41, wspace=0.42)
    save_figure(fig, FIGURE_STEMS[4])


def file_sha256(path: Path) -> str:
    digest = sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def write_qa(
    curves: pd.DataFrame,
    metrics: pd.DataFrame,
    body_state: pd.DataFrame,
    contribution: pd.DataFrame,
) -> None:
    checks: list[dict[str, object]] = []
    sources = {
        "subject_curves": curves,
        "subject_metrics": metrics,
        "body_state": body_state,
    }
    expected = curves.groupby("group")["subject_key"].nunique().to_dict()
    if not expected or any(int(count) <= 0 for count in expected.values()):
        raise RuntimeError("Subject-curve input must contain at least one subject per group.")
    for source_name, frame in sources.items():
        counts = frame.groupby("group")["subject_key"].nunique().to_dict()
        for group, expected_count in expected.items():
            observed = int(counts.get(group, 0))
            checks.append(
                {
                    "check": f"{source_name}_{group}_subjects",
                    "observed": observed,
                    "expected": expected_count,
                    "passed": observed == expected_count,
                }
            )
    component_counts = contribution.groupby("group")["n_subjects"].min().to_dict()
    for group, expected_count in expected.items():
        observed = int(component_counts.get(group, 0))
        checks.append(
            {
                "check": f"component_curves_{group}_subjects",
                "observed": observed,
                "expected": expected_count,
                "passed": observed == expected_count,
            }
        )
    for stem in FIGURE_STEMS:
        for suffix in ("png", "pdf"):
            path = FIGURES / f"{stem}.{suffix}"
            checks.append(
                {
                    "check": f"{stem}_{suffix}",
                    "observed": int(path.exists()),
                    "expected": 1,
                    "passed": path.exists(),
                }
            )
    qa = pd.DataFrame(checks)
    qa.to_csv(QA_FILE, index=False)
    if not qa["passed"].all():
        raise RuntimeError("Figure QA failed:\n" + qa.loc[~qa["passed"]].to_string(index=False))


def write_manifest() -> None:
    rows = []
    for path in sorted(OUTPUT_ROOT.rglob("*")):
        if path.is_file() and path != MANIFEST_FILE:
            rows.append(
                {
                    "relative_path": path.relative_to(OUTPUT_ROOT).as_posix(),
                    "bytes": path.stat().st_size,
                    "sha256": file_sha256(path),
                }
            )
    pd.DataFrame(rows).to_csv(MANIFEST_FILE, index=False)


def write_readme() -> None:
    text = """# Generated analysis figures

This folder is created from local processed inputs.

- PNG files are exported at 300 dpi.
- PDF files retain vector graphics.
- Generated files remain local and are excluded from version control.
"""
    (OUTPUT_ROOT / "README.md").write_text(text, encoding="utf-8")


def main() -> None:
    require_inputs()
    OUTPUT_ROOT.mkdir(parents=True, exist_ok=True)
    FIGURES.mkdir(parents=True, exist_ok=True)

    # Clear only generated figure exports before rebuilding the local set.
    for pattern in ("Figure_*.png", "Figure_*.pdf"):
        for path in FIGURES.glob(pattern):
            path.unlink()

    curves = pd.read_csv(SUBJECT_CURVES_FILE)
    metrics = pd.read_csv(SUBJECT_METRICS_FILE)
    body_state = pd.read_csv(BODY_STATE_FILE)
    ap_curves = pd.read_csv(AP_GROUP_FILE)
    contribution = pd.read_csv(CONTRIBUTION_GROUP_FILE)
    contribution_subject = pd.read_csv(CONTRIBUTION_SUBJECT_FILE)
    increments = pd.read_csv(INCREMENT_GROUP_FILE)
    increment_subject = pd.read_csv(INCREMENT_SUBJECT_FILE)

    figure_1(curves, metrics)
    figure_2(body_state, metrics)
    figure_3_stability_profiles(curves, metrics)
    figure_4_support_mechanism(ap_curves)
    figure_5(contribution, contribution_subject, increments, increment_subject)
    write_readme()
    write_qa(curves, metrics, body_state, contribution)
    write_manifest()

    print(f"Saved local analysis figures to: {FIGURES}")
    print(f"QA checks passed: {pd.read_csv(QA_FILE)['passed'].sum()}/{len(pd.read_csv(QA_FILE))}")


if __name__ == "__main__":
    main()
