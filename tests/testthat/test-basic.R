context("basic")

test_that("unjoin works", {
  library(dplyr)
  data("Seatbelts", package= "datasets")
  x <- unjoin(as.data.frame(Seatbelts), front, rear, kms)
  all.equal(inner_join(x$main, x$data) %>% select(-.idx0), as.data.frame(Seatbelts))

  iris %>% unjoin(-Species)
  chickwts %>% unjoin(weight)

  if (require("gapminder")) {
    gapminder %>%
      group_by(country, continent) %>%
      unjoin()

    gapminder %>%
      unjoin(-country, -continent)
    unjoin(gapminder)
  }
  x <- unjoin(iris, Petal.Width)
  x %>%  expect_named(c("main", "data"))
  x$data %>% inner_join(x$main) %>% expect_named(c("Sepal.Length", "Sepal.Width", "Petal.Length", "Species", ".idx0",
                                                   "Petal.Width"))
})
