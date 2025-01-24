ql_create_schema <- function(fields) {
  fields <- list(
    type = "object",
    properties = list(
      `name` = list(type = "string"),
      `description` = list(type = "string")
    ),
    required = c("name", "description")
  )

  schema_v <- yyjsonr::write_json_str(
    x = fields,
    opts = yyjsonr::opts_write_json(auto_unbox = FALSE)
  )

  schema_v
}
