
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tor

The goal of **tor** (*to-R*) is to make importing data into R
ridiculously easy. It helps you to import multiple files from a single
directory into R in a simple, intuitive way. For example, `load_csv()`
with no argument loads all “\*.csv” files in your working directory into
the global environment, making them directly available for analysis.

## Installation

Install **tor** from CRAN with:

``` r
install.packages("tor")
```

Or install the development version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("maurolepore/tor")
```

## Example

``` r
library(tor)
```

All functions list whatever they read, and default to reading from the
working directory.

### `list_*()`: Import multiple files from a directory into a list

``` r
dir()
#>  [1] "_pkgdown.yml"     "cran-comments.md" "csv1.csv"        
#>  [4] "csv2.csv"         "DESCRIPTION"      "docs"            
#>  [7] "inst"             "LICENSE.md"       "man"             
#> [10] "NAMESPACE"        "NEWS.md"          "R"               
#> [13] "README.md"        "README.Rmd"       "tests"           
#> [16] "tmp.R"            "tor.Rproj"        "vignettes"

list_csv()
#> Parsed with column specification:
#> cols(
#>   x = col_double()
#> )
#> Parsed with column specification:
#> cols(
#>   y = col_character()
#> )
#> $csv1
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1     1
#> 2     2
#> 
#> $csv2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

Often you will specify a `path` to read from.

``` r
# Helpes create paths to examples
tor_example()
#> [1] "csv"   "mixed" "rdata" "rds"   "tsv"

(path_rds <- tor_example("rds"))
#> [1] "C:/Users/LeporeM/Documents/R/R-3.5.2/library/tor/extdata/rds"
dir(path_rds)
#> [1] "rds1.rds" "rds2.rds"

list_rds(path_rds)
#> $rds1
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1     1
#> 2     2
#> 
#> $rds2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

You may read all files with a particular extension.

``` r
path_mixed <- tor_example("mixed")
dir(path_mixed)
#> [1] "csv.csv"           "lower_rdata.rdata" "rda.rda"          
#> [4] "upper_rdata.RData"

list_rdata(path_mixed)
#> $lower_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b    
#> 
#> $rda
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b    
#> 
#> $upper_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

Or you may read specific files matching a pattern.

``` r
list_rdata(path_mixed, regexp = "[.]RData", ignore.case = FALSE)
#> $upper_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

`list_any()` is the most flexible function. You supply the function to
read with.

``` r
(path_csv <- tor_example("csv"))
#> [1] "C:/Users/LeporeM/Documents/R/R-3.5.2/library/tor/extdata/csv"
dir(path_csv)
#> [1] "csv1.csv" "csv2.csv"

list_any(path_csv, read.csv)
#> $csv1
#> # A tibble: 2 x 1
#>       x
#>   <int>
#> 1     1
#> 2     2
#> 
#> $csv2
#> # A tibble: 2 x 1
#>   y    
#>   <fct>
#> 1 a    
#> 2 b
```

It understands lambda functions and formulas (powered by
[**rlang**](https://rlang.r-lib.org/)).

``` r
# Use the pipe (%>%)
library(magrittr)

(path_rdata <- tor_example("rdata"))
#> [1] "C:/Users/LeporeM/Documents/R/R-3.5.2/library/tor/extdata/rdata"
dir(path_rdata)
#> [1] "rdata1.rdata" "rdata2.rdata"

path_rdata %>% 
  list_any(function(x) get(load(x)))
#> $rdata1
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1     1
#> 2     2
#> 
#> $rdata2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b

# Same
path_rdata %>% 
  list_any(~get(load(.x)))
#> $rdata1
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1     1
#> 2     2
#> 
#> $rdata2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

Pass additional arguments via `...` or inside the lambda function.

``` r
path_csv %>% 
  list_any(readr::read_csv, skip = 1)
#> Parsed with column specification:
#> cols(
#>   `1` = col_double()
#> )
#> Parsed with column specification:
#> cols(
#>   a = col_character()
#> )
#> $csv1
#> # A tibble: 1 x 1
#>     `1`
#>   <dbl>
#> 1     2
#> 
#> $csv2
#> # A tibble: 1 x 1
#>   a    
#>   <chr>
#> 1 b

path_csv %>% 
  list_any(~read.csv(., stringsAsFactors = FALSE))
#> $csv1
#> # A tibble: 2 x 1
#>       x
#>   <int>
#> 1     1
#> 2     2
#> 
#> $csv2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

It also provides the arguments `regexp`, `ignore.case`, and `invert` to
pick specific files in a directory (powered by
[**fs**](https://fs.r-lib.org/)).

``` r
path_mixed <- tor_example("mixed")
dir(path_mixed)
#> [1] "csv.csv"           "lower_rdata.rdata" "rda.rda"          
#> [4] "upper_rdata.RData"

path_mixed %>% 
  list_any(~get(load(.)), "[.]Rdata$", ignore.case = TRUE)
#> $lower_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b    
#> 
#> $upper_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b

path_mixed %>% 
  list_any(~get(load(.)), regexp = "[.]csv$", invert = TRUE)
#> $lower_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b    
#> 
#> $rda
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b    
#> 
#> $upper_rdata
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

### `load_*()`: Load multiple files from a directory into an environment

All functions default to loading from the working directory.

``` r
# The working directory contains .csv files
dir()
#>  [1] "_pkgdown.yml"     "cran-comments.md" "csv1.csv"        
#>  [4] "csv2.csv"         "DESCRIPTION"      "docs"            
#>  [7] "inst"             "LICENSE.md"       "man"             
#> [10] "NAMESPACE"        "NEWS.md"          "R"               
#> [13] "README.md"        "README.Rmd"       "tests"           
#> [16] "tmp.R"            "tor.Rproj"        "vignettes"

load_csv()
#> Parsed with column specification:
#> cols(
#>   x = col_double()
#> )
#> Parsed with column specification:
#> cols(
#>   y = col_character()
#> )

# Each file is now available as a dataframe in the global environment
csv1
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1     1
#> 2     2
csv2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

You may load from a `path`.

``` r
rm(list = ls())
ls()
#> character(0)

(path_mixed <- tor_example("mixed"))
#> [1] "C:/Users/LeporeM/Documents/R/R-3.5.2/library/tor/extdata/mixed"
dir(path_mixed)
#> [1] "csv.csv"           "lower_rdata.rdata" "rda.rda"          
#> [4] "upper_rdata.RData"

load_rdata(path_mixed)

ls()
#> [1] "lower_rdata" "path_mixed"  "rda"         "upper_rdata"
rda
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

For more flexibility use `load_any()` with a function able to read one
file of the format you want to import.

``` r
dir()
#>  [1] "_pkgdown.yml"     "cran-comments.md" "csv1.csv"        
#>  [4] "csv2.csv"         "DESCRIPTION"      "docs"            
#>  [7] "inst"             "LICENSE.md"       "man"             
#> [10] "NAMESPACE"        "NEWS.md"          "R"               
#> [13] "README.md"        "README.Rmd"       "tests"           
#> [16] "tmp.R"            "tor.Rproj"        "vignettes"

load_any(".", .f = readr::read_csv, regexp = "[.]csv$")
#> Parsed with column specification:
#> cols(
#>   x = col_double()
#> )
#> Parsed with column specification:
#> cols(
#>   y = col_character()
#> )

# The data is now available in the global environment
csv1
#> # A tibble: 2 x 1
#>       x
#>   <dbl>
#> 1     1
#> 2     2
csv2
#> # A tibble: 2 x 1
#>   y    
#>   <chr>
#> 1 a    
#> 2 b
```

# Related projects

There are great packages to read and write data, for example
[**rio**](https://CRAN.R-project.org/package=rio) and
[**io**](https://CRAN.R-project.org/package=io). **tor** does less than
the alternatives, but it is much smaller and more flexible.
