"""Generate local tables and figures from locally supplied analysis inputs."""

from build_tables import main as build_tables
from plot_figures import main as plot_figures


def main() -> None:
    build_tables()
    plot_figures()
    print("Local analysis outputs generated.")


if __name__ == "__main__":
    main()
