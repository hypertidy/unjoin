#' unjoin
#'
#' Split a table in two and remove repeated values.
#'
#' The data frame on input is treated as "data", the new data frame is treated
#' as the normalized key. This means that the split-off and de-duplicated table has the name given via
#' the `key_col` argument (defaults to ".idx0") and shares this name with the common key.
#'
#' It's not yet clear if this flexibility around naming is a good idea, but it enables a simple scheme for chaining
#' unjoins, though you'd better not use the same `key_col` again.
#'
#' This is a subset of the tasks done by \code{\link[tidyr]{nest}}.
#' @param data A data frame.
#' @param ... Specification of columns to unjoin by.  For full details, see the `dplyr::select`` documentation.
#' @param key_col The name of the new column to key the two output data frames.
#' @seealso `dplyr::inner_join` for the inverse operation.
#' @seealso `tidyr::nest` for the complementary operation resulting in one nested data frame
#' @name unjoin
#' @importFrom dplyr %>% distinct group_by select ungroup
#' @importFrom tibble as_tibble
#' @importFrom rlang syms
#' @importFrom stats setNames
#' @export
#' @examples
#' library(dplyr)
#' data("Seatbelts", package= "datasets")
#' x <- unjoin(as.data.frame(Seatbelts), front, law)
#' y <- inner_join(x$.idx0, x$data) %>% select(-.idx0)
#' all.equal(y[colnames(Seatbelts)], as.data.frame(Seatbelts))
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
#' unjoin(iris, Petal.Width) %>% unjoin(Species, key_col = ".idx1")
unjoin <- function(data, ..., key_col = "idx0") UseMethod("unjoin")
#' @name unjoin
#' @export
unjoin.data.frame <- function(data, ..., key_col = ".idx0") {
  data <- ungroup(data) %>% as_tibble()
  if (!(utils::packageVersion("dplyr") > "0.5.0")) {
    unjoin_cols <- unname(dplyr::select_vars(colnames(data), ...))
    out <-  unjoin_(data, unjoin_cols, key_col = key_col)
    return(out)
  }
  main <- select(data, ...)
  data <- select(data, !!!rlang::syms(setdiff(names(data), names(main))))
  # return(list(out, data))
  idx <- dplyr::group_indices(group_by(main, !!!rlang::syms(names(main))))
  main[[key_col]] <- idx
  main <- distinct(main)
  data[[key_col]] <- idx
  structure(setNames(list(main,data), c(key_col, "data")), class = "unjoin")
}
#' @name unjoin
#' @export
unjoin.unjoin <- function(data, ..., key_col = ".idx0") {
  in_name <- setdiff(names(data), "data")
  ## assume we get the output of unjoin (should be classed)
  if (!(utils::packageVersion("dplyr") > "0.5.0")) {
    unjoin_cols <- unname(dplyr::select_vars(colnames(data[["data"]]), ...))
    uj <-  unjoin_(data[["data"]], unjoin_cols, key_col = key_col)

  } else {
    uj <- unjoin(data[["data"]], ..., key_col = key_col)

  }

  data[[key_col]] <- uj[[key_col]]
  data[["data"]] <- uj[["data"]]
  structure(data[c(in_name, key_col, "data")], class = "unjoin")
}
