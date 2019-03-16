
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dance <img src="man/figures/logo.png" align="right" />

<!-- badges: start -->

[![Travis build
status](https://travis-ci.org/romainfrancois/dance.svg?branch=master)](https://travis-ci.org/romainfrancois/dance)
<!-- badges: end -->

![](https://media.giphy.com/media/GFBME4lzPVwxW/giphy.gif)

Dancing 💃 with the stats, aka `tibble()` dancing 🕺. `dance` is a sort of
reinvention of `dplyr` classic verbs, with a more modern stack
underneath, i.e. it leverages a lot from `vctrs` and `rlang`.

# Installation

You can install the development version from GitHub.

``` r
# install.packages("pak")
pak::pkg_install("romainfrancois/dance")
```

# Usage

We’ll illustrate tibble dancing with `iris` grouped by `Species`.

``` r
library(dance)
g <- iris %>% group_by(Species)
```

### waltz(), polka(), tango(), charleston()

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

`charleston()` is like `tango` but it packs the new columns in a tibble:

``` r
g %>% 
  charleston(
    Sepal.Length = ~mean(Sepal.Length), 
    Sepal.Width  = ~mean(Sepal.Width)
  )
#> # A tibble: 3 x 2
#>   Species    data$Sepal.Length $Sepal.Width
#>   <fct>                  <dbl>        <dbl>
#> 1 setosa                  5.01         3.43
#> 2 versicolor              5.94         2.77
#> 3 virginica               6.59         2.97
```

### swing, twist

There is no `waltz_at()`, `tango_at()`, etc … but instead we can use
either the same function on a set of columns or a set of functions on
the same column.

For this, we need to learn new dance moves:

`swing()` and `twist()` are for applying the same function to a set of
columns:

``` r
library(tidyselect)

g %>% 
  tango(swing(mean, starts_with("Petal")))
#> # A tibble: 3 x 3
#>   Species    Petal.Length Petal.Width
#>   <fct>             <dbl>       <dbl>
#> 1 setosa             1.46       0.246
#> 2 versicolor         4.26       1.33 
#> 3 virginica          5.55       2.03

g %>% 
  tango(data = twist(mean, starts_with("Petal")))
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

  - `twist()` instead creates a single data frame column.

<!-- end list -->

``` r
g %>% 
  tango(
    mean   = twist(mean, starts_with("Petal")), 
    median = twist(median, starts_with("Petal")), 
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
    median = twist(median, contains("."))
  )
#> # A tibble: 3 x 4
#>   Species mean_Petal.Leng… mean_Petal.Width median$Sepal.Le… $Sepal.Width
#>   <fct>              <dbl>            <dbl>            <dbl>        <dbl>
#> 1 setosa              1.46            0.246              5            3.4
#> 2 versic…             4.26            1.33               5.9          2.8
#> 3 virgin…             5.55            2.03               6.5          3  
#> # … with 2 more variables: $Petal.Length <dbl>, $Petal.Width <dbl>
```

### rumba, zumba

Similarly `rumba()` can be used to apply several functions to a single
column. `rumba()` creates single columns and `zumba()` packs them into a
data frame column.

``` r
g %>% 
  tango(
    rumba(Sepal.Width, mean = mean, median = median, .name = "Sepal_{fun}"), 
    Petal = zumba(Petal.Width, mean = mean, median = median)
  )
#> # A tibble: 3 x 4
#>   Species    Sepal_mean Sepal_median Petal$mean $median
#>   <fct>           <dbl>        <dbl>      <dbl>   <dbl>
#> 1 setosa           3.43          3.4      0.246     0.2
#> 2 versicolor       2.77          2.8      1.33      1.3
#> 3 virginica        2.97          3        2.03      2
```

### salsa, chacha, samba, madison

Now we enter the realms of `dplyr::mutate()` with:

  - `salsa()` : to create new columns
  - `chacha()`: to reorganize a grouped tibble so that data for each
    group is contiguous
  - `samba()` : `chacha()` + `salsa()`

<!-- end list -->

``` r
g %>% 
  salsa(
    Sepal = ~Sepal.Length * Sepal.Width, 
    Petal = ~Petal.Length * Petal.Width
  )
#> # A tibble: 150 x 2
#>    Sepal Petal
#>    <dbl> <dbl>
#>  1  17.8 0.280
#>  2  14.7 0.280
#>  3  15.0 0.26 
#>  4  14.3 0.3  
#>  5  18   0.280
#>  6  21.1 0.68 
#>  7  15.6 0.42 
#>  8  17   0.3  
#>  9  12.8 0.280
#> 10  15.2 0.15 
#> # … with 140 more rows
```

You can `swing()`, `twist()`, `rumba()` and `zumba()` here too, and if
you want the original data, you can use `samba()` instead of `salsa()`:

``` r
g %>% 
  samba(centered = twist(~ . - mean(.), everything(), -Species))
#> # A tibble: 150 x 6
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # … with 140 more rows, and 4 more variables: centered$Sepal.Length <dbl>,
#> #   $Sepal.Width <dbl>, $Petal.Length <dbl>, $Petal.Width <dbl>
```

`madison()` packs the columns `salsa()` would have created

``` r
g %>% 
  madison(swing(~ . - mean(.), starts_with("Sepal")))
#> # A tibble: 150 x 6
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # … with 140 more rows, and 2 more variables: data$Sepal.Length <dbl>,
#> #   $Sepal.Width <dbl>
```

### bolero and mambo

`bolero()` is similar to `dplyr::filter()`. The formulas may be made by
`mambo()` if you want to apply the same predicate to a tidyselection of
columns:

``` r
g %>% 
  bolero(~Sepal.Width > 4)
#> # A tibble: 3 x 5
#> # Groups:   Species [3]
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.7         4.4          1.5         0.4 setosa 
#> 2          5.2         4.1          1.5         0.1 setosa 
#> 3          5.5         4.2          1.4         0.2 setosa

g %>% 
  bolero(mambo(~. > 4, starts_with("Sepal")))
#> # A tibble: 3 x 5
#> # Groups:   Species [3]
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.7         4.4          1.5         0.4 setosa 
#> 2          5.2         4.1          1.5         0.1 setosa 
#> 3          5.5         4.2          1.4         0.2 setosa

g %>% 
  bolero(mambo(~. > 4, starts_with("Sepal"), .op = or))
#> # A tibble: 150 x 5
#> # Groups:   Species [3]
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1          5.1         3.5          1.4         0.2 setosa 
#>  2          4.9         3            1.4         0.2 setosa 
#>  3          4.7         3.2          1.3         0.2 setosa 
#>  4          4.6         3.1          1.5         0.2 setosa 
#>  5          5           3.6          1.4         0.2 setosa 
#>  6          5.4         3.9          1.7         0.4 setosa 
#>  7          4.6         3.4          1.4         0.3 setosa 
#>  8          5           3.4          1.5         0.2 setosa 
#>  9          4.4         2.9          1.4         0.2 setosa 
#> 10          4.9         3.1          1.5         0.1 setosa 
#> # … with 140 more rows
```
