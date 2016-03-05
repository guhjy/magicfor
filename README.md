# Magic for()
Koji MAKIYAMA(@hoxo_m)  


```r
x <- 1:100
for(i in 1:3) {
  y <- x[i] * 2
  print(y)
}
```

```
## [1] 2
## [1] 4
## [1] 6
```


```r
library(magicfor)

magic_for()

x <- 1:100
for(i in 1:3) {
  y <- x[i] * 2
  print(y)
}

result <- magic_result()
result$y
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

x <- 1:100
for(i in 1:3) {
  y <- x[i] * 2
  print(y)
  z <- x[i] ** 2
  print(z)
}

result <- magic_result_as_dataframe()
result
```

```
##   i y z
## 1 1 2 1
## 2 2 4 4
## 3 3 6 9
```

