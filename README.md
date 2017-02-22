
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/mdsumner/unjoin.svg?branch=master)](https://travis-ci.org/mdsumner/unjoin) \# unjoin

The goal of unjoin is to provide `unjoin` for data frames. This is used to build topological data structures, with a kind of inside-out version of a nested data frame. Whether it's of broader use is an open question.

Installation
------------

You can install unjoin from github with:

``` r
# install.packages("devtools")
devtools::install_github("mdsumner/unjoin")
```

Example
-------

This is a basic example which shows you how to unjoin a data frame.

``` r
library(unjoin)

unjoin(iris)
#> $main
#> # A tibble: 1 × 1
#>   .idx0
#>   <int>
#> 1     1
#> 
#> $data
#> # A tibble: 150 × 6
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species .idx0
#>           <dbl>       <dbl>        <dbl>       <dbl>  <fctr> <int>
#> 1           5.1         3.5          1.4         0.2  setosa     1
#> 2           4.9         3.0          1.4         0.2  setosa     1
#> 3           4.7         3.2          1.3         0.2  setosa     1
#> 4           4.6         3.1          1.5         0.2  setosa     1
#> 5           5.0         3.6          1.4         0.2  setosa     1
#> 6           5.4         3.9          1.7         0.4  setosa     1
#> 7           4.6         3.4          1.4         0.3  setosa     1
#> 8           5.0         3.4          1.5         0.2  setosa     1
#> 9           4.4         2.9          1.4         0.2  setosa     1
#> 10          4.9         3.1          1.5         0.1  setosa     1
#> # ... with 140 more rows

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
#> $main
#> # A tibble: 3 × 2
#>      Species .idx0
#>       <fctr> <int>
#> 1     setosa     1
#> 2 versicolor     2
#> 3  virginica     3
#> 
#> $data
#> # A tibble: 150 × 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width .idx0
#>           <dbl>       <dbl>        <dbl>       <dbl> <int>
#> 1           5.1         3.5          1.4         0.2     1
#> 2           4.9         3.0          1.4         0.2     1
#> 3           4.7         3.2          1.3         0.2     1
#> 4           4.6         3.1          1.5         0.2     1
#> 5           5.0         3.6          1.4         0.2     1
#> 6           5.4         3.9          1.7         0.4     1
#> 7           4.6         3.4          1.4         0.3     1
#> 8           5.0         3.4          1.5         0.2     1
#> 9           4.4         2.9          1.4         0.2     1
#> 10          4.9         3.1          1.5         0.1     1
#> # ... with 140 more rows

iris %>% unjoin(Species, Petal.Width)
#> $main
#> # A tibble: 27 × 3
#>       Species Petal.Width .idx0
#>        <fctr>       <dbl> <int>
#> 1      setosa         0.2     2
#> 2      setosa         0.4     4
#> 3      setosa         0.3     3
#> 4      setosa         0.1     1
#> 5      setosa         0.5     5
#> 6      setosa         0.6     6
#> 7  versicolor         1.4    11
#> 8  versicolor         1.5    12
#> 9  versicolor         1.3    10
#> 10 versicolor         1.6    13
#> # ... with 17 more rows
#> 
#> $data
#> # A tibble: 150 × 4
#>    Sepal.Length Sepal.Width Petal.Length .idx0
#>           <dbl>       <dbl>        <dbl> <int>
#> 1           5.1         3.5          1.4     2
#> 2           4.9         3.0          1.4     2
#> 3           4.7         3.2          1.3     2
#> 4           4.6         3.1          1.5     2
#> 5           5.0         3.6          1.4     2
#> 6           5.4         3.9          1.7     4
#> 7           4.6         3.4          1.4     3
#> 8           5.0         3.4          1.5     2
#> 9           4.4         2.9          1.4     2
#> 10          4.9         3.1          1.5     1
#> # ... with 140 more rows
```
