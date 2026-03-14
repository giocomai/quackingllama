# Retrieve

Retrieve

## Usage

``` r
ql_get_db_options(options = c("db", "db_type", "db_folder", "db_filename"))
```

## Arguments

- options:

  Available options that

## Value

A list with the selected options.

## Examples

``` r
ql_get_db_options()
#> $db
#> [1] TRUE
#> 
#> $db_type
#> [1] "DuckDB"
#> 
#> $db_folder
#> .
#> 
#> $db_filename
#> [1] ""
#> 

## Retrieve only selected option
ql_get_db_options("db_type")
#> $db_type
#> [1] "DuckDB"
#> 
```
