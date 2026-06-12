SF=${1:-1}
duckdb datavault_vs_star/datavault_vs_star.duckdb -c "install tpcds; load tpcds; call dsdgen(sf=${SF})"