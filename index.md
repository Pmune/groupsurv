---
title: "Grouping Survival time"
author: "Parfait Munezero"
output: rmarkdown::html_vignette
description: >
  This is package provides functions for grouping and summarizing (right censored) Survival times. 
fig_caption: yes
vignette: >
  \VignetteIndexEntry{Grouping Survival time}
  \VignetteEngine{knitr::rmarkdown}
  \VignetteEncoding{UTF-8}
---

```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

## Overview


The aim of `groupsurv`  is to compute the exposure time and the event status in some user-specified time intervals that partition the survival time. The exposure time in a given interval can be the length of the interval (if the event or censoring is occurs after the interval), or the difference between the observed survival time and the lower limit of the interval (if event or censoring occurs inside the interval). The event status in the interval is $1$ if the event occurs in the interval and is $0$ otherwise. If a set of independent variables is provided, the two quantities are computed for each variable's category.

`groupsurv` requires that the data include a column of the observed survival time the censoring indicator ($1$ if event, $0$ if censored), and some relevant independent variables. The current version supports only categorical independent variables. 

The key functions implemented in `groupsurv` are:

 * `group_surv_time` : The main function for grouping survival time. It requires the raw survival data, column indices of the survival time, censoring indicator, and covariate to be included in the grouped data.
 
 * `grouped_summary`: Provides a summary of the grouped data.
 
 * `compute_interval_data`: Computes the exposures and event status within a given time period (interval) for all observations.
 
 
## Installation

`groupsurv` is hosted on  Github; therefore, to install it you need to install and load the `devtools` package. Then install `groupsurv` using devetools. 

```{r, message=FALSE}
# uncomment if you don't have devtools installed

#install.packages("devtools")
library(devtools)
devtools::install_github("Pmune/groupsurv") # install groupsurv from github
library(groupsurv)
```


# Example

## Data simulation.

For illustrative purpose, let's simulate the survival time from the exponential distribution with rate $1.2$ and the censoring indicators from a Bernoulli distribution with probability of success $0.7$. This means that the censored observations are roughly $30%$. In addition to this, let's simulate some binary covariates.


```{r}
set.seed(500)
sample_size <- 500 # number of observations  
# simulate the censoring indicator
status <- rbinom(sample_size, 1, .7) # censoreed obs aprox 30%
# simulate some binary covariates
x1 <- rbinom(sample_size, 1, .2)
x2 <- rbinom(sample_size, 1, .5)
x3 <- rbinom(sample_size, 1, .6)
# simulate survival time from the exponential distribution
surv_time <- rexp(sample_size,1.2) 

simul_data <- data.frame(time=surv_time,status=status,x1=x1,x2=x2,x3=x3)


```

The simulated data looks as follows: 
```{r, echo=FALSE}
knitr::kable(head(simul_data, 10), align = 'c', caption='Simulated data',label = 'table_1')
```

and the simulated survival time summary is as follows:
```{r, echo=FALSE}
summary(simul_data$time)
```

## Partioning the survival time.

To group the survival time, we need to partition the survival time into consecutive and disjoint time intervals. For the sake of example, let's partition the it based on the above quantiles; that is four intervals: 

  * interval $1$: $[0.00, 0.31)$.
  * interval $2$: $[0.31, 0.67)$.
  * interval $3$: $[0.67, 1.28)$.
  * interval $4$: $[1.28, \infty)$.

To do this, we need to define a vector containing only the intervals limits where the last interval's upper limit is set to the observed highest survival time.

```{r, echo=TRUE}
intervals = c(0.00, 0.31, 0.67, 1.28, round(max(simul_data$time),2)) # create the time intervals
```


## Grouping the survival time


The next step is to call the function `group_surv_time`. We need to pass to the function either the column names or indices of the survival time, censoring indicator and all covariates to be included. 

In the following example we pass the column indices. In our case the survival time column is the first column, the second column contains the censoring indicator, and we are going to include all independent variables $x_1$, $x_2$, and $x_3$. 


```{r}
#  passing column indices
grouped_data <- group_surv_time(surv_data = simul_data,
                                time_intervals = intervals,
                                time_ind = 1,
                                cens_ind = 2,
                                X_vec = c(3,4,5))

# One can also use column names to pass arguments to the function.
grouped_data <- group_surv_time(surv_data = simul_data,
                                time_intervals = intervals,
                                time_ind = "time",
                                cens_ind = "status",
                                X_vec = c("x1","x2","x3"))

```


The output is a data frame containing the exposure time and number of events for each time interval and independent variable's categories. The time interval categories are displayed in the column labeled `group`. The categories $1$, $2$, $3$, and $4$ refer to the first, second, third and forth interval of the defined survival time partition. 

```{r, echo=FALSE}

knitr::kable(grouped_data, align = 'c', caption='Grouped data',label = 'table_1')
```


## Summarizing the survival time

We can, also, compute the overall summary of the grouped data using the function `grouped_summary`. This function requires the grouped data and the time intervals.

```{r}
data_summary <- grouped_summary(grouped_data,intervals)

```

The output is a table of interval-specific total exposures and number of events as well as the overall total exposure and number of events. 
```{r, echo=FALSE}
knitr::kable(data_summary, align = 'c', caption='Summary of the grouped data',label = 'table_1') 
```



The overall total quantities are, respectively, equivalent to the sum of the original `survival time` and the `status` in the raw data.  

