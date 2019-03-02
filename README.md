
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dance

<!-- badges: start -->

<!-- badges: end -->

Dancing 💃 with the stats, aka `tibble()` dancing 🕺.

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(dance)
library(tidyselect)

g <- dplyr::group_by(iris, Species)
```

### waltz(), polka(), tango()

These are in the neighborhood of `dplyr::summarise()`.

`waltz()` takes a grouped tibble and a list of formulas and returns a
tibble with: as many columns as supplied formulas, one row per group. It
does not prepend the grouping variables (see `tango` for that).

``` r
g %>% 
  waltz(
    Sepal.Length = ~mean(Sepal.Length), 
    Sepal.Width  = ~mean(Sepal.Width)
  )
#> # A tibble: 3 x 2
#>   Sepal.Length Sepal.Width
#>          <dbl>       <dbl>
#> 1         5.01        3.43
#> 2         5.94        2.77
#> 3         6.59        2.97
```

`polka()` deals with peeling off one layer of grouping:

``` r
g %>% 
  polka()
#> # A tibble: 3 x 1
#>   Species   
#>   <fct>     
#> 1 setosa    
#> 2 versicolor
#> 3 virginica
```

`tango()` binds the results of `polka()` and `waltz()` so is the closest
to `dplyr::summarise()`

``` r
g %>% 
  tango(
    Sepal.Length = ~mean(Sepal.Length), 
    Sepal.Width  = ~mean(Sepal.Width)
  )
#> # A tibble: 3 x 3
#>   Species    Sepal.Length Sepal.Width
#>   <fct>             <dbl>       <dbl>
#> 1 setosa             5.01        3.43
#> 2 versicolor         5.94        2.77
#> 3 virginica          6.59        2.97
```

### swing, twist, rumba, zumba

There is no `waltz_at()`, `tango_at()`, etc … but instead we can use
either the same function on a set of columns or a set of functions on
the same column.

For this, we need to learn new dance moves:

`swing()` and `twist()` are for applying the same function to a set of
columns:

``` r
g %>% 
  tango(swing(mean, starts_with("Petal")))
#> # A tibble: 3 x 3
#>   Species    Petal.Length Petal.Width
#>   <fct>             <dbl>       <dbl>
#> 1 setosa             1.46       0.246
#> 2 versicolor         4.26       1.33 
#> 3 virginica          5.55       2.03

g %>% 
  tango(twist(mean, starts_with("Petal")))
#> # A tibble: 3 x 2
#>   Species    data$Petal.Length $Petal.Width
#>   <fct>                  <dbl>        <dbl>
#> 1 setosa                  1.46        0.246
#> 2 versicolor              4.26        1.33 
#> 3 virginica               5.55        2.03
```

They differ in the type of column is created and how to name them:

  - `swing()` makes as many new columns as are selected by the tidy
    selection, and the columns are named using a `.name` glue pattern,
    this way we might `swing()` several times.

<!-- end list -->

``` r
g %>% 
  tango(
    swing(mean, starts_with("Petal"), .name = "mean_{var}"), 
    swing(median, starts_with("Petal"), .name = "median_{var}"), 
  )
#> # A tibble: 3 x 5
#>   Species mean_Petal.Leng… mean_Petal.Width median_Petal.Le…
#>   <fct>              <dbl>            <dbl>            <dbl>
#> 1 setosa              1.46            0.246             1.5 
#> 2 versic…             4.26            1.33              4.35
#> 3 virgin…             5.55            2.03              5.55
#> # … with 1 more variable: median_Petal.Width <dbl>
```

  - `twist()` instead creates a single data frame column, and `.name`
    control its name:

<!-- end list -->

``` r
g %>% 
  tango(
    twist(mean, starts_with("Petal"), .name = "mean"), 
    twist(median, starts_with("Petal"), .name = "median"), 
  )
#> # A tibble: 3 x 3
#>   Species    mean$Petal.Length $Petal.Width median$Petal.Leng… $Petal.Width
#>   <fct>                  <dbl>        <dbl>              <dbl>        <dbl>
#> 1 setosa                  1.46        0.246               1.5           0.2
#> 2 versicolor              4.26        1.33                4.35          1.3
#> 3 virginica               5.55        2.03                5.55          2
```

The first arguments of `swing()` and `twist()` are either a function or
a formula that uses `.` as a placeholder. Subsequent arguments are
tidyselect selections.

You can combine `swing()` and `twist()` in the same `tango()` or
`waltz()`:

``` r
g %>% 
  tango(
    swing(mean, starts_with("Petal"), .name = "mean_{var}"), 
    twist(median, contains("."), .name = "median")
  )
#> # A tibble: 3 x 4
#>   Species mean_Petal.Leng… mean_Petal.Width median$Sepal.Le… $Sepal.Width
#>   <fct>              <dbl>            <dbl>            <dbl>        <dbl>
#> 1 setosa              1.46            0.246              5            3.4
#> 2 versic…             4.26            1.33               5.9          2.8
#> 3 virgin…             5.55            2.03               6.5          3  
#> # … with 2 more variables: $Petal.Length <dbl>, $Petal.Width <dbl>
```
