# Grouped Survival data analysis

`groupsurv` package provides functions for grouping and summarizing Survival data. It requires Survival data which include the observed survival time, a censoring indicator(`1` if event, `0` if censored), and some relevant independent variables. The current version supports only categorical independent variables.


## Installation.

This package is hosted on my Github. Therefore, to install it you need to install and load the `devtools` package, then install `groupsurv` using devetools.

```{r}
#install.packages("devtools")
library(devtools)
devtools::install_github("Pmune/groupsurv") # install groupsurv from github
library(groupsurv)
```

## Implemented functions.

The key functions implemented in `groupsurv` are:
 
 * `group_surv_time` : the main function for grouping survival time. Requires the                raw survival data, column indices of the survival time, censoring                  indicator, and covariate to be included in the grouped data.
 
 * `grouped_summary`: provides a summary of the grouped data.
 * `compute_interval_data`: computes the exposures and event status within a given time period (interval) for all observations.
 
 For more details see the `vignette`.
