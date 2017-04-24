#' data(iris)
#' library(dplyr)
#'
#' iris %>% ujoin(Species, Petal.Length) ##%>% ujoin(Sepal.Width, key_col = ".idx1")
ujoin <- function(data, ..., key_col = "idx0") UseMethod("ujoin")
ujoin.data.frame <- function(data, ..., key_col = ".idx0") {
  data <- ungroup(data)
  unjoin_cols <- rlang::quos(...)
  ## thanks to Jim Hester for this
  group_cols <- unlist(lapply(unjoin_cols, rlang::quo_name))
  idx <- group_indices(data, !!!unjoin_cols)
  out <- dplyr::distinct(select(data, !!!unjoin_cols))
  out[[key_col]] <- unique(idx)
  ## dopey munge of quos here, how to do properly?
  data <- data[group_cols]
  data[[key_col]] <- idx

  structure(setNames(list(out,data), c(key_col, "data")), class = "unjoin")
}
ujoin.unjoin <- function(data, ..., key_col = ".idx0") {
  in_name <- setdiff(names(data), "data")
  ## assume we get the output of unjoin (should be classed)
  uj <- unjoin(data[["data"]], ..., key_col = key_col)
  data[[key_col]] <- uj[[key_col]]
  data[["data"]] <- uj[["data"]]
  structure(data[c(in_name, key_col, "data")], class = "unjoin")
}
