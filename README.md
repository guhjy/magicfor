# magicfor: Magic Functions to Obtain Results from for Loops in R
Koji MAKIYAMA (@hoxo_m)  

<!-- README.md is generated from README.Rmd. Please edit that file -->



[![Travis-CI Build Status](https://travis-ci.org/hoxo-m/magicfor.svg?branch=master)](https://travis-ci.org/hoxo-m/magicfor)
[![CRAN Version](http://www.r-pkg.org/badges/version/magicfor)](https://cran.r-project.org/package=magicfor)

## 1. Overview

`for()` is one of the most popular functions in R.
As you know, it is used to create loops.
For example, let's calculate squared values for 1 to 3:


```r
for (i in 1:3) {
  squared <- i ^ 2
  print(squared)
}
#> [1] 1
#> [1] 4
#> [1] 9
```


```r
result <- vector("numeric", 3)
for (i in 1:3) {
  squared <- i ^ 2
  result[i] <- squared
}
result
#> [1] 1 4 9
```


```r
data.frame(i = 1:3, squared = result)
#>   i squared
#> 1 1       1
#> 2 2       4
#> 3 3       9
```


```r
library(magicfor)

magic_for(print)

for (i in 1:3) {
  squared <- i ^ 2
  print(squared)
}
#> print() is magicalized.
#> [1] 1
#> [1] 4
#> [1] 9

magic_result_as_dataframe()
#>   i squared
#> 1 1       1
#> 2 2       4
#> 3 3       9
```

## 2. Installation

You can install the package from GitHub.


```r
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("hoxo-m/magicfor")
```

The source code for githubinstall package is available on GitHub at

- https://github.com/hoxo-m/magicfor.

## 3. Details

When we use for loops in R, we need to ready some variables for the results.


```r
result <- numeric(3)
for(i in 1:3) {
  x <- i * 2
  result[i] <- x
}
#> print() is magicalized.
result
#> [1] 0 0 0
```

Before the (final) code, you may dash off the following code using `print()`.


```r
for(i in 1:3) {
  x <- i * 2
  print(x)
}
#> print() is magicalized.
#> [1] 2
#> [1] 4
#> [1] 6
```

After you glanced at that the code goes well, you might start to modify the code to final.

The `magic_for()` function is very useful in such situations.


```r
library(magicfor)

magic_for(print)

for(i in 1:3) {
  x <- i * 2
  print(x)
}
#> print() is magicalized.
#> [1] 2
#> [1] 4
#> [1] 6

result <- magic_result()
result$x
#> [[1]]
#> [1] 2
#> 
#> [[2]]
#> [1] 4
#> 
#> [[3]]
#> [1] 6
```


```r
magic_for(print)

for(i in 1:3) {
  x <- i * 2
  print(x)
  y <- i * 3
  print(y)
}
#> print() is magicalized.
#> [1] 2
#> [1] 3
#> [1] 4
#> [1] 6
#> [1] 6
#> [1] 9

result <- magic_result_as_dataframe()
result
#>   i x y
#> 1 1 2 3
#> 2 2 4 6
#> 3 3 6 9
```

