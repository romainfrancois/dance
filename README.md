
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

# that's a bit like dplyr::summarise 
g %>% 
  waltz(
    Sepal.Length = ~ mean(Sepal.Length), 
    Sepal.Width  = ~ mean(Sepal.Width) 
  )
#> # A tibble: 3 x 3
#>   Species    Sepal.Length Sepal.Width
#>   <fct>             <dbl>       <dbl>
#> 1 setosa             5.01        3.43
#> 2 versicolor         5.94        2.77
#> 3 virginica          6.59        2.97

# however it's using formulas instead of quosures
# and similarly to rap it can empower the lhs of the formula, 
g %>% 
  waltz(
    Sepal.Length = character() ~ mean(Sepal.Length)
  )
#> # A tibble: 3 x 2
#>   Species    Sepal.Length
#>   <fct>      <chr>       
#> 1 setosa     5.006000    
#> 2 versicolor 5.936000    
#> 3 virginica  6.588000

# the rhs of the formula can make tibbles too 
# the only requirement is that the vec_size() 
# of the output has to be 1
g %>% 
  waltz(
    Sepal =  ~ tibble(Sepal.Length = mean(Sepal.Length), Sepal.Width = mean(Sepal.Width))
  )
#> # A tibble: 3 x 2
#>   Species    Sepal$Sepal.Length $Sepal.Width
#>   <fct>                   <dbl>        <dbl>
#> 1 setosa                   5.01         3.43
#> 2 versicolor               5.94         2.77
#> 3 virginica                6.59         2.97
```

### swing

There’s no `waltz_at()` or `waltz_if()` but you can use `swing()` if you
want to use the same function for a bunch of columns:

``` r
g %>% 
  waltz(
    swing(mean, ends_with("th"))
  )
#> # A tibble: 3 x 5
#>   Species    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>   <fct>             <dbl>       <dbl>        <dbl>       <dbl>
#> 1 setosa             5.01        3.43         1.46       0.246
#> 2 versicolor         5.94        2.77         4.26       1.33 
#> 3 virginica          6.59        2.97         5.55       2.03
```

The results are named after the names of the input columns, i.e.

``` r
tidyselect::vars_select(tbl_vars(g), ends_with("th"))
#>   Sepal.Length    Sepal.Width   Petal.Length    Petal.Width 
#> "Sepal.Length"  "Sepal.Width" "Petal.Length"  "Petal.Width"
```

The `.name` gives you a way to control the names by means of a glue
pattern:

``` r
g %>% 
  waltz(
    swing(mean, starts_with("Petal"), .name = "mean_{var}"),
    swing(median, starts_with("Petal"), .name = "median_{var}")
  )
#> # A tibble: 3 x 5
#>   Species mean_Petal.Leng… mean_Petal.Width median_Petal.Le…
#>   <fct>              <dbl>            <dbl>            <dbl>
#> 1 setosa              1.46            0.246             1.5 
#> 2 versic…             4.26            1.33              4.35
#> 3 virgin…             5.55            2.03              5.55
#> # … with 1 more variable: median_Petal.Width <dbl>
```

The first argument of `swing()` is a function, or a formula:

``` r
g %>% 
  waltz(
    swing(~mean(., na.rm = TRUE), starts_with("Petal"), .name = "mean_{var}")
  )
#> # A tibble: 3 x 3
#>   Species    mean_Petal.Length mean_Petal.Width
#>   <fct>                  <dbl>            <dbl>
#> 1 setosa                  1.46            0.246
#> 2 versicolor              4.26            1.33 
#> 3 virginica               5.55            2.03
```
