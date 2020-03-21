#' @name unjoin
#' @export
unjoin_ <- function(data, unjoin_cols = character(), key_col = ".idx0") UseMethod("unjoin_")
#' @name unjoin
#' @param unjoin_cols character list of unjoin column names for `unjoin_` backwards compatibility
#' @export
unjoin_.data.frame <- function(data,  unjoin_cols = character(), key_col = ".idx0") {
  group_cols <- setdiff(names(data), unjoin_cols)
  unjoin_impl(tibble::as_tibble(data), group_cols, unjoin_cols, key_col = key_col)
}
#' @name unjoin
#' @export
unjoin_.unjoin <- function(data,  unjoin_cols = character(), key_col = ".idx0") {
  in_name <- setdiff(names(data), "data")
  uj <-  unjoin_(data[["data"]], unjoin_cols, key_col = key_col)

  data[[key_col]] <- uj[[key_col]]
  data[["data"]] <- uj[["data"]]
  structure(data[c(in_name, key_col, "data")], class = "unjoin")
}

#' @importFrom stats setNames
#' @importFrom tibble as_tibble
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

  dat <- list()
  dat[[key_col]] <- out
  dat[["data"]] <- data
  class(dat) <- "unjoin"
  dat
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
#'  @name unjoin
#'  @export
#' unjoin_ <- function(data, ..., key_col = ".idx0") {
#'   dots <- compat_lazy_dots(list(), rlang::caller_env(), ...)
#'   unjoin(data, !!! dots)
#' # }
#'
#' ## https://raw.githubusercontent.com/tidyverse/rlang/master/R/compat-lazyeval.R
#' # nocov start - compat-lazyeval (last updated: rlang 0.1.9000)
#'
#' # This file serves as a reference for compatibility functions for lazyeval.
#' # Please find the most recent version in rlang's repository.
#'
#'
#' warn_underscored <- function() {
#'   return(NULL)
#'   warn(paste(
#'     "The underscored versions are deprecated in favour of",
#'     "tidy evaluation idioms. Please see the documentation",
#'     "for `quo()` in rlang"
#'   ))
#' }
#' warn_text_se <- function() {
#'   return(NULL)
#'   warn("Text parsing is deprecated, please supply an expression or formula")
#' }
#'
#' compat_lazy <- function(lazy, env = rlang::caller_env(), warn = TRUE) {
#'   if (warn) warn_underscored()
#'
#'   if (missing(lazy)) {
#'     return(rlang::quo())
#'   }
#'
#'   rlang::coerce_type(lazy, "a quosure",
#'               formula = rlang::as_quosure(lazy, env),
#'               symbol = ,
#'               language = rlang::new_quosure(lazy, env),
#'               string = ,
#'               character = {
#'                 if (warn) warn_text_se()
#'                 rlang::parse_quosure(lazy[[1]], env)
#'               },
#'               logical = ,
#'               integer = ,
#'               double = {
#'                 if (length(lazy) > 1) {
#'                   warn("Truncating vector to length 1")
#'                   lazy <- lazy[[1]]
#'                 }
#'                 new_quosure(lazy, env)
#'               },
#'               list =
#'                 rlang::coerce_class(lazy, "a quosure",
#'                              lazy = new_quosure(lazy$expr, lazy$env)
#'                 )
#'   )
#' }
#'
#' compat_lazy_dots <- function(dots, env, ..., .named = FALSE) {
#'   if (missing(dots)) {
#'     dots <- list()
#'   }
#'   if (inherits(dots, c("lazy", "formula"))) {
#'     dots <- list(dots)
#'   } else {
#'     dots <- unclass(dots)
#'   }
#'   dots <- c(dots, list(...))
#'
#'   warn <- TRUE
#'   for (i in seq_along(dots)) {
#'     dots[[i]] <- compat_lazy(dots[[i]], env, warn)
#'     warn <- FALSE
#'   }
#'
#'   named <- rlang::have_name(dots)
#'   if (.named && any(!named)) {
#'     nms <- map_chr(dots[!named], f_text)
#'     names(dots)[!named] <- nms
#'   }
#'
#'   names(dots) <- rlang::names2(dots)
#'   dots
#' }
#'
#' compat_as_lazy <- function(quo) {
#'   structure(class = "lazy", list(
#'     expr = rlang::f_rhs(quo),
#'     env = rlang::f_env(quo)
#'   ))
#' }
#' compat_as_lazy_dots <- function(...) {
#'   structure(class = "lazy_dots", map(rlang::quos(...), compat_as_lazy))
#' }
#'
#'
#' # nocov end
