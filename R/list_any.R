#' Read multiple files into a list using any given reading function.
#'
#' @inheritParams fs::dir_ls
#' @inheritParams base::grep
#' @param .f A function able to read the desired file format.
#'
#' @return A list.
#'
#' @family general functions to import data
#' @export
#'
#' @examples
#' tor_example()
#'
#' path <- tor_example("csv")
#' dir(path)
#'
#' list_any(path, read.csv)
#'
#' list_any(path, ~read.csv(.x, stringsAsFactors = FALSE))
#'
#' (path_mixed <- tor_example("mixed"))
#' dir(path_mixed)
#'
#' list_any(
#'   path_mixed, ~get(load(.x)),
#'   regexp = "[.]csv$",
#'   invert = TRUE
#' )
#'
#' list_any(
#'   path_mixed, ~get(load(.x)),
#'   "[.]Rdata$",
#'   ignore.case = TRUE
#' )
#' @importFrom rlang %||% abort set_names
list_any <- function(path = ".",
                     .f,
                     regexp = NULL,
                     ignore.case = FALSE,
                     invert = FALSE,
                     ...) {
  files <- fs::dir_ls(
    path,
    regexp = regexp,
    ignore.case = ignore.case,
    invert = invert
  )

  if (length(files) == 0) {
    abort(
      sprintf("Can't find files matching '%s' in:\n '%s'", regexp, path)
    )
  }

  file_names <- fs::path_ext_remove(fs::path_file(files))
  set_names(lapply(files, rlang::as_function(.f), ...), file_names)
}