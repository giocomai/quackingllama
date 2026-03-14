# Enable storing data in a database for the current session

Enable storing data in a database for the current session

## Usage

``` r
ql_enable_db(db_type = "DuckDB")
```

## Arguments

- db_type:

  Defaults to `DuckDB`.

## Value

Nothing, used for its side effects.

## See also

Other database:
[`ql_disable_db()`](https://giocomai.github.io/quackingllama/reference/ql_disable_db.md),
[`ql_set_db_options()`](https://giocomai.github.io/quackingllama/reference/ql_set_db_options.md)

## Examples

``` r
ql_enable_db()
```
