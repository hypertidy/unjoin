
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/hypertidy/unjoin.svg?branch=master)](https://travis-ci.org/hypertidy/unjoin) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/hypertidy/unjoin?branch=master&svg=true)](https://ci.appveyor.com/project/hypertidy/unjoin) [![Coverage Status](https://img.shields.io/codecov/c/github/hypertidy/unjoin/master.svg)](https://codecov.io/github/hypertidy/unjoin?branch=master)

unjoin
======

The goal of unjoin is to provide `unjoin` for data frames. This is exactly part of what `tidyr::nest` does, but with two differences:

-   the split data frames are not nested, they are split and returned as two whole tibbles `main` and `data`
-   there is an explicit key column added to identify the de-duplicated rows in `main` with the rows in `data`.

Installation
------------

Install unjoin from CRAN:

``` r
install.packages("unjoin")
```

You can install the development unjoin from github with:

``` r
# install.packages("devtools")
devtools::install_github("hypertidy/unjoin")
```

Example
-------

This is a basic example which shows you how to unjoin a data frame.

``` r
library(unjoin)

unjoin(iris)
#> $.idx0
#> # A tibble: 1 x 1
#>   .idx0
#>   <int>
#> 1     1
#> 
#> $data
#> # A tibble: 150 x 6
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species .idx0
#>           <dbl>       <dbl>        <dbl>       <dbl>  <fctr> <int>
#>  1          5.1         3.5          1.4         0.2  setosa     1
#>  2          4.9         3.0          1.4         0.2  setosa     1
#>  3          4.7         3.2          1.3         0.2  setosa     1
#>  4          4.6         3.1          1.5         0.2  setosa     1
#>  5          5.0         3.6          1.4         0.2  setosa     1
#>  6          5.4         3.9          1.7         0.4  setosa     1
#>  7          4.6         3.4          1.4         0.3  setosa     1
#>  8          5.0         3.4          1.5         0.2  setosa     1
#>  9          4.4         2.9          1.4         0.2  setosa     1
#> 10          4.9         3.1          1.5         0.1  setosa     1
#> # ... with 140 more rows
#> 
#> attr(,"class")
#> [1] "unjoin"

library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
iris %>% unjoin(Species)
#> $.idx0
#> # A tibble: 3 x 2
#>      Species .idx0
#>       <fctr> <int>
#> 1     setosa     1
#> 2 versicolor     2
#> 3  virginica     3
#> 
#> $data
#> # A tibble: 150 x 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width .idx0
#>           <dbl>       <dbl>        <dbl>       <dbl> <int>
#>  1          5.1         3.5          1.4         0.2     1
#>  2          4.9         3.0          1.4         0.2     1
#>  3          4.7         3.2          1.3         0.2     1
#>  4          4.6         3.1          1.5         0.2     1
#>  5          5.0         3.6          1.4         0.2     1
#>  6          5.4         3.9          1.7         0.4     1
#>  7          4.6         3.4          1.4         0.3     1
#>  8          5.0         3.4          1.5         0.2     1
#>  9          4.4         2.9          1.4         0.2     1
#> 10          4.9         3.1          1.5         0.1     1
#> # ... with 140 more rows
#> 
#> attr(,"class")
#> [1] "unjoin"

iris %>% unjoin(Species, Petal.Width)
#> $.idx0
#> # A tibble: 27 x 3
#>       Species Petal.Width .idx0
#>        <fctr>       <dbl> <int>
#>  1     setosa         0.2     2
#>  2     setosa         0.4     4
#>  3     setosa         0.3     3
#>  4     setosa         0.1     1
#>  5     setosa         0.5     5
#>  6     setosa         0.6     6
#>  7 versicolor         1.4    11
#>  8 versicolor         1.5    12
#>  9 versicolor         1.3    10
#> 10 versicolor         1.6    13
#> # ... with 17 more rows
#> 
#> $data
#> # A tibble: 150 x 4
#>    Sepal.Length Sepal.Width Petal.Length .idx0
#>           <dbl>       <dbl>        <dbl> <int>
#>  1          5.1         3.5          1.4     2
#>  2          4.9         3.0          1.4     2
#>  3          4.7         3.2          1.3     2
#>  4          4.6         3.1          1.5     2
#>  5          5.0         3.6          1.4     2
#>  6          5.4         3.9          1.7     4
#>  7          4.6         3.4          1.4     3
#>  8          5.0         3.4          1.5     2
#>  9          4.4         2.9          1.4     2
#> 10          4.9         3.1          1.5     1
#> # ... with 140 more rows
#> 
#> attr(,"class")
#> [1] "unjoin"
```

This is used to build topological data structures, with a kind of inside-out version of a nested data frame. Whether it's of broader use is unclear.

There is a record here of some of the thinking that led to unjoin: <https://github.com/r-gris/babelfish>

The function `unjoin` replaces the method here: <http://rpubs.com/cyclemumner/iout_nest>

``` r
(d2 <- iris %>% unjoin(Species, Petal.Width))
#> $.idx0
#> # A tibble: 27 x 3
#>       Species Petal.Width .idx0
#>        <fctr>       <dbl> <int>
#>  1     setosa         0.2     2
#>  2     setosa         0.4     4
#>  3     setosa         0.3     3
#>  4     setosa         0.1     1
#>  5     setosa         0.5     5
#>  6     setosa         0.6     6
#>  7 versicolor         1.4    11
#>  8 versicolor         1.5    12
#>  9 versicolor         1.3    10
#> 10 versicolor         1.6    13
#> # ... with 17 more rows
#> 
#> $data
#> # A tibble: 150 x 4
#>    Sepal.Length Sepal.Width Petal.Length .idx0
#>           <dbl>       <dbl>        <dbl> <int>
#>  1          5.1         3.5          1.4     2
#>  2          4.9         3.0          1.4     2
#>  3          4.7         3.2          1.3     2
#>  4          4.6         3.1          1.5     2
#>  5          5.0         3.6          1.4     2
#>  6          5.4         3.9          1.7     4
#>  7          4.6         3.4          1.4     3
#>  8          5.0         3.4          1.5     2
#>  9          4.4         2.9          1.4     2
#> 10          4.9         3.1          1.5     1
#> # ... with 140 more rows
#> 
#> attr(,"class")
#> [1] "unjoin"
```

We can chain unjoins together, but make sure not to repeat a `key_col` in one of these.

``` r
unjoin(iris, Species, key_col = "vertex") %>% unjoin(Petal.Width, vertex,  key_col = "branch")
#> $vertex
#> # A tibble: 3 x 2
#>      Species vertex
#>       <fctr>  <int>
#> 1     setosa      1
#> 2 versicolor      2
#> 3  virginica      3
#> 
#> $branch
#> # A tibble: 27 x 3
#>    Petal.Width vertex branch
#>          <dbl>  <int>  <int>
#>  1         0.2      1      2
#>  2         0.4      1      4
#>  3         0.3      1      3
#>  4         0.1      1      1
#>  5         0.5      1      5
#>  6         0.6      1      6
#>  7         1.4      2     11
#>  8         1.5      2     13
#>  9         1.3      2     10
#> 10         1.6      2     15
#> # ... with 17 more rows
#> 
#> $data
#> # A tibble: 150 x 4
#>    Sepal.Length Sepal.Width Petal.Length branch
#>           <dbl>       <dbl>        <dbl>  <int>
#>  1          5.1         3.5          1.4      2
#>  2          4.9         3.0          1.4      2
#>  3          4.7         3.2          1.3      2
#>  4          4.6         3.1          1.5      2
#>  5          5.0         3.6          1.4      2
#>  6          5.4         3.9          1.7      4
#>  7          4.6         3.4          1.4      3
#>  8          5.0         3.4          1.5      2
#>  9          4.4         2.9          1.4      2
#> 10          4.9         3.1          1.5      1
#> # ... with 140 more rows
#> 
#> attr(,"class")
#> [1] "unjoin"
```

Also, there's no escape hatch here, you can't "unjoin" your way to normal nirvana, each unjoin needs to carry the last unjoin-key with it, and you just end up with the big link table with no attributes. It needs some kind of group-semantic to cut the chain.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
