#' Split a table in two and remove repeated values.
#'
#' This is a subset of the tasks done by \code{\link[tidyr]{nest}}.
#' @seealso `dplyr::inner_join` for the inverse operation.
#' @seealso `tidyr::nest` for the complementary operation resulting in one data frame
#' @inheritParams unjoin_
#' @name unjoin
#' @param ... Specification of columns to nest. Use bare variable names.
#'   Select all variables between x and z with \code{x:z}, exclude y with
#'   \code{-y}. For more options, see the \link[dplyr]{select} documentation.
#' @export
#' @examples
#' library(dplyr)
#' data("Seatbelts", package= "datasets")
#' x <- unjoin(as.data.frame(Seatbelts), front, rear, kms)
#' all.equal(inner_join(x$main, x$data) %>% select(-.idx0), as.data.frame(Seatbelts))
#'
#' iris %>% unjoin(-Species)
#' chickwts %>% unjoin(weight)
#'
#' if (require("gapminder")) {
#'   gapminder %>%
#'     group_by(country, continent) %>%
#'     unjoin()
#'
#'   gapminder %>%
#'     unjoin(-country, -continent)
#'   unjoin(gapminder)
#' }
#' unjoin(iris, Petal.Width)
unjoin <- function(data, ..., key_col = ".idx0") {
  unjoin_cols <- unname(dplyr::select_vars(colnames(data), ...))
  unjoin_(data, unjoin_cols, key_col = key_col)
}

#' Standard-evaluation version of 'unjoin'.
#'
#' This is a S3 generic.
#'
#' @param data A data frame.
#' @param unjoin_cols Character vector of columns to nest.
#' @param key_col The name of the new column to key the two output data frames.
#' @keywords internal
#' @export
#' @name unjoin_
unjoin_ <- function(data, unjoin_cols = character(), key_col = ".idx0") {
  UseMethod("unjoin_")
}

#' @export
unjoin_.data.frame <- function(data,  unjoin_cols = character(), key_col = ".idx0") {
  group_cols <- setdiff(names(data), unjoin_cols)
  unjoin_impl(dplyr::as_data_frame(data), group_cols, unjoin_cols, key_col = key_col)
}

#' #' @export
#' unjoin_.tbl_df <- function(data,  nest_cols = character()) {
#'   as_data_frame(NextMethod())
#' }

## grouping is as-yet undecided
## I think it should be used to define higher groupings so that
## d %>% group_by(a) %>% unjoin(x, y, z)
## gives a set of paths defined by groupings in a
#' #' @export
#' unjoin_.grouped_df <- function(data,  nest_cols = character()) {
#'   if (length(nest_cols) == 0) {
#'     nest_cols <- names(data)
#'   }
#'
#'   group_cols <- vapply(dplyr::groups(data), as.character, character(1))
#'   #print(group_cols)
#'   unjoin_impl(data,  group_cols, nest_cols)
#' }

#' @importFrom stats setNames
#' @importFrom dplyr as_data_frame distinct_ group_indices ungroup select_ select_vars
#' @importFrom tibble data_frame as_tibble
unjoin_impl <- function(data, group_cols, unjoin_cols, key_col = ".idx0") {
  stopifnot(length(key_col) == 1L)
  data <- dplyr::ungroup(data)
  unjoin_cols <- setdiff(unjoin_cols, group_cols)
  idx <- dplyr::group_indices_(data, .dots = unjoin_cols)
  ## I think using distinct will be a lurking problem for floating point comparisons
  ## but I can't explore this enough right now
  ## see here: https://github.com/r-gris/rangl/issues/7
  out <- dplyr::distinct_(dplyr::select_(data, .dots = unjoin_cols))
  if (ncol(out) < 1L) out <- tibble::as_tibble(stats::setNames(list(1), key_col))
  out[[key_col]] <- unique(idx)
#  out <- dplyr::select_(data, .dots = unjoin_cols)

  data <- data[group_cols]
  data[[key_col]] <- idx

  list(main = out, data = data)
}



#tidyr:::col_name
col_name <- function(x, default = stop("Please supply column name", call. = FALSE)) {
  if (is.character(x)) return(x)
  if (identical(x, quote(expr = ))) return(default)
  if (is.name(x)) return(as.character(x))
  if (is.null(x)) return(x)

  stop("Invalid column specification", call. = FALSE)
}

#globalVariables(".")
