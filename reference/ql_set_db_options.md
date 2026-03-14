# Set options for the local database and enables caching

Set options for the local database and enables caching

## Usage

``` r
ql_set_db_options(db_filename = NULL, db_type = "DuckDB", db_folder = ".")
```

## Arguments

- db_filename:

  Defaults NULL. Internally, defaults to a combination of
  `quackingllama`, followed by the name of the model used. Name given to
  the local database file. Useful for differentiating among different
  approaches or projects when storing multiple database files in the
  same folder.

- db_type:

  Defaults to `DuckDB`.

- db_folder:

  Defaults to `.`, i.e., to the current working directory.

## Value

Nothing, used for its side effects.

## See also

Other database:
[`ql_disable_db()`](https://giocomai.github.io/quackingllama/reference/ql_disable_db.md),
[`ql_enable_db()`](https://giocomai.github.io/quackingllama/reference/ql_enable_db.md)

## Examples

``` r
ql_set_db_options(db_filename = "testing_ground")
```
