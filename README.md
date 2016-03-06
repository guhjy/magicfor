# magicfor - Magic Functions to Obtain Results from for Loops in R
Koji MAKIYAMA(@hoxo_m)  

## Overview

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

result <- magic_result()
result$x
```

```
## [[1]]
## [1] 2
## 
## [[2]]
## [1] 4
## 
## [[3]]
## [1] 6
```


```r
magic_for()

for(i in 1:3) {
  x <- i * 2
  print(x)
  y <- i * 3
  print(y)
}

result <- magic_result_as_dataframe()
result
```

```
##   i x y
## 1 1 2 3
## 2 2 4 6
## 3 3 6 9
```

