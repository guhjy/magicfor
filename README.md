# Magic Functions to Obtain Results from for Loops in R
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

It is very easy.

However, it becomes too much hassle to change such codes to store the result.
You must prepare some containers to store the result with correct length and change `print()` to assignment statements.


```r
result <- vector("numeric", 3) # prepare a container
for (i in 1:3) {
  squared <- i ^ 2
  result[i] <- squared         # change to assignment
}
result
#> [1] 1 4 9
```

Moreover, you may want to store the result as a data frame with the iteration numbers.


```r
result <- data.frame(matrix(nrow = 3, ncol = 2))
colnames(result) <- c("i", "squared")
for (i in 1:3) {
  squared <- i ^ 2
  result[i, 1] <- i
  result[i, 2] <- squared
}
result
#>   i squared
#> 1 1       1
#> 2 2       4
#> 3 3       9
```

What a bother!

In such or more troublesome situations like that you have to store many variables, the code will grow more complex soon.

The **magicfor** package makes to resolve it being kept readability.

Let's just add two lines before the for loop.
First, loads the library. Second, calls `magic_for()`.
Notice that the main for loop is kept intact.


```r
library(magicfor)               # load library
magic_for(print, silent = TRUE) # call magic_for()

for (i in 1:3) {
  squared <- i ^ 2
  print(squared)
}

magic_result_as_dataframe()     # get the result
#>   i squared
#> 1 1       1
#> 2 2       4
#> 3 3       9
```

`magic_for()` takes a function name, and then reconstructs `for()` to remember values passed to the specified function in for loops.
We call the reconstruction "magicalization".
Once you call `magic_for()`, as you just run `for()` as usual, the result will be stored in memory automatically.

Here, we are using `magic_result_as_dataframe()` in order to get the stored values.
It is one of the functions to obtain results from "magicalized for loops", and means to take out the results as a data frame.

Even if the number of observed variables increases, you can do it the same way.


```r
magic_for(silent = TRUE)

for (i in 1:3) {
  squared <- i ^ 2
  cubed <- i ^ 3
  put(squared, cubed)
}

magic_result_as_dataframe()
#>   i squared cubed
#> 1 1       1     1
#> 2 2       4     8
#> 3 3       9    27
```

`put()` is a useful function defined in the package.
It allows to take any number of variables and can display them.

## 2. Installation

You can install the package from GitHub.


```r
install.packages("devtools") # if you have not installed "devtools" package
devtools::install_github("hoxo-m/magicfor")
```

The source code for githubinstall package is available on GitHub at

- https://github.com/hoxo-m/magicfor.

## 3. Details

