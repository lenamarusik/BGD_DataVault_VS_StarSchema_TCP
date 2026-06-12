"""
Benchmark BI query execution times: Data Vault vs Star Schema.

Usage:
    python benchmark.py [--runs N] [--cold]

Options:
    --runs N   Number of timed repetitions per query (default: 5)
    --cold     Drop DuckDB buffer cache between runs (measures cold reads)
"""

import argparse
import pathlib
import statistics
import time

import duckdb

DB_PATH = pathlib.Path(__file__).parent / "datavault_vs_star.duckdb"
COMPILED = pathlib.Path(__file__).parent / "target/compiled/datavault_vs_star/models"

QUERY_PAIRS = [
    (
        "clients_by_revenue",
        COMPILED / "data_vault/bi/dv_clients_by_revenue.sql",
        COMPILED / "star_schema/bi/star_clients_by_revenue.sql",
    ),
    (
        "monthly_revenue_per_product",
        COMPILED / "data_vault/bi/dv_monthly_revenue_per_product.sql",
        COMPILED / "star_schema/bi/star_monthly_revenue_per_product.sql",
    ),
    (
        "promotion_effectiveness",
        COMPILED / "data_vault/bi/dv_promotion_effectiveness.sql",
        COMPILED / "star_schema/bi/star_promotion_effectiveness.sql",
    ),
    (
        "sales_per_store",
        COMPILED / "data_vault/bi/dv_sales_per_store.sql",
        COMPILED / "star_schema/bi/star_sales_per_store.sql",
    ),
    (
        "seasonality",
        COMPILED / "data_vault/bi/dv_seasonality.sql",
        COMPILED / "star_schema/bi/star_seasonality.sql",
    ),
]


def time_query(con: duckdb.DuckDBPyConnection, sql: str, runs: int) -> list[float]:
    times = []
    for _ in range(runs):
        # ensure cold cache
        con.execute("CHECKPOINT")
        t0 = time.perf_counter()
        con.execute(sql).fetchall()
        times.append(time.perf_counter() - t0)
    return times


def fmt_ms(seconds: float) -> str:
    return f"{seconds * 1000:7.1f}ms"


def winner_marker(dv_avg: float, star_avg: float) -> str:
    if dv_avg < star_avg * 0.95:
        return "DV faster"
    if star_avg < dv_avg * 0.95:
        return "Star faster"
    return "comparable"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--runs", type=int, default=5, help="Timed repetitions per query")
    args = parser.parse_args()

    con = duckdb.connect(str(DB_PATH))

    print(f"Database       : {DB_PATH}\n")

    col_q  = 30
    col_v  = 10
    header = f"{'Query':<{col_q}}  {'DV avg':>{col_v}}  {'DV min':>{col_v}}  {'Star avg':>{col_v}}  {'Star min':>{col_v}}  {'Result'}"
    print(header)
    print("-" * len(header))

    dv_totals: list[float] = []
    star_totals: list[float] = []

    for name, dv_path, star_path in QUERY_PAIRS:
        dv_sql   = dv_path.read_text()
        star_sql = star_path.read_text()

        dv_times   = time_query(con, dv_sql,   args.runs)
        star_times = time_query(con, star_sql, args.runs)

        dv_avg   = statistics.mean(dv_times)
        star_avg = statistics.mean(star_times)
        dv_totals.append(dv_avg)
        star_totals.append(star_avg)

        marker = winner_marker(dv_avg, star_avg)
        print(
            f"{name:<{col_q}}"
            f"  {fmt_ms(dv_avg):>{col_v}}"
            f"  {fmt_ms(min(dv_times)):>{col_v}}"
            f"  {fmt_ms(star_avg):>{col_v}}"
            f"  {fmt_ms(min(star_times)):>{col_v}}"
            f"  {marker}"
        )

    print("-" * len(header))
    total_dv   = sum(dv_totals)
    total_star = sum(star_totals)
    print(
        f"{'TOTAL (sum of avgs)':<{col_q}}"
        f"  {fmt_ms(total_dv):>{col_v}}"
        f"  {'':>{col_v}}"
        f"  {fmt_ms(total_star):>{col_v}}"
        f"  {'':>{col_v}}"
        f"  {winner_marker(total_dv, total_star)}"
    )
    print()


if __name__ == "__main__":
    main()
