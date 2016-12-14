# magicfor: Magic Functions to Obtain Results from for Loops in R
Koji MAKIYAMA(@hoxo_m)  

## 1. Overview

`for()` is one of the most popular functions in R.
It is very useful to create loops, for example:


```r
for (i in 1:3) {
   print(i * 2)
}
```

```
## [1] 2
## [1] 4
## [1] 6
```


```r
squared <- vector("numeric", 3)
for (i in 1:3) {
  squared[i] <- i * 2
}
squared
```

```
## [1] 2 4 6
```


```r
data.frame(i = 1:3, squared = squared)
```

```
##   i squared
## 1 1       2
## 2 2       4
## 3 3       6
```


```r
library(magicfor)

magic_for(print)
for (i in 1:3) {
  print(i * 2)
}
magic_result_as_dataframe()
```

```
##   i i.2
## 1 1   2
## 2 2   4
## 3 3   6
```

When we use for loops in R, we need to ready some variables for the results.


```r
result <- numeric(3)
for(i in 1:3) {
  x <- i * 2
  result[i] <- x
}
result
```

```
## [1] 2 4 6
```

Before the (final) code, you may dash off the following code using `print()`.


```r
for(i in 1:3) {
  x <- i * 2
  print(x)
}
```

```
## [1] 2
## [1] 4
## [1] 6
```

After you glanced at that the code goes well, you might start to modify the code to final.

The `magic_for()` function is very useful in such situations.


```r
library(magicfor)

magic_for()

for(i in 1:3) {
  x <- i * 2
  print(x)
}
```

```
## [1] 2
## [1] 4
## [1] 6
```

```r
result <- magic_result()
result$x
```

```
## NULL
```


```r
magic_for()

for(i in 1:3) {
  x <- i * 2
  print(x)
  y <- i * 3
  print(y)
}
```

```
## [1] 2
## [1] 3
## [1] 4
## [1] 6
## [1] 6
## [1] 9
```

```r
result <- magic_result_as_dataframe()
result
```

```
##   i
## 1 1
## 2 2
## 3 3
```

