# Grouped Survival data analysis


The primary goal of Survival data analysis is to determine the distributional shape of the time to the occurrence of a certain event of interest 
and compare the survival experience among groups of the studied subjects.
Depending of the area of application the event of interest can be marriage (social-demographic applications),
death (clinical  applications) or failure of system (engineering applications).

One frequent problem, though, is that not all studied subjects experience the event; some will never experience 
the event, others may experience it after the study period ends. This problem is well known as "censoring". 
censored survival data include therefore, the observed survival time, a censorig indicator, and some relevant 
independent variables.

This is a package for descritizing the survival time into several time intervals to create grouped survival data 
from standard (right) censored survival data. Also the package implements some models for grouped survival data. 

Grouped survival data can be modelled using generalized linear models such the Poisson model which are currently supported by the package. 




