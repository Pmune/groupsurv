#' Group survival data
#'
#' This function groups censored survival data.
#' It assumes that the raw data includes a column of observed survival time, censoring indicator,
#' and some additional categorical covariates. The current version does not support contineous covariates.
#'
#' @param surv_data Raw data in the foarm of a data frame.
#' @param time_intervals A vector of time points partitioning the survival time. They define the survival time groups.
#' @param col_indexes A list of column indexes that specify the columns index  of the survival time,
#'  censoring indicator, and covariates used.
#' @return A data frame containing the grouped survival data.
#' @export

group_surv<-function(surv_data,time_intervals,col_indexes)
{
  column_names = c("Exposure","Events","Group",colnames(surv_data)[col_indexes$variables])
  grouped_data<-c()
  for(i in seq_len(length(time_intervals)-1)){
    new_data <- interval_data(lower_limit=time_intervals[i],
                              upper_limit=time_intervals[i+1],
                              surv_data=surv_data,
                              time_index=col_indexes$time,
                              event_index=col_indexes$event
                              )
    variable_unique_labels<-as.data.frame(unique(new_data[,col_indexes$variables]))

    for(j in seq_len(nrow(variable_unique_labels))){
      variable_data <- as.matrix(new_data[,col_indexes$variables]) == matrix(rep(variable_unique_labels[j,],
                                                                          each=nrow(new_data)),
                                                                      ncol=length(variable_unique_labels[j,]
                                                                                  )
                                                                      )

      variable_data <- ifelse(variable_data==TRUE,1,0)
      exposure <- sum(new_data[which(apply(variable_data,1,prod)==1),col_indexes$time])
      number_events <- sum(new_data[which(apply(variable_data,1,prod)==1),col_indexes$event])
      grouped_data <- rbind(grouped_data,cbind(exposure=exposure,events=number_events,
                                             time_group=i-1,variable_unique_labels[j,]))
    }

  }
  colnames(grouped_data) <- column_names
  return(grouped_data)
}

#' Extract interval-specific data
#'
#' Extract data for observations  which experience or are censored within a specified time interval.
#' @param lower_limit The lower limit of the time interval
#' @param upper_limit The upper limit of the time interval
#' @return The interval-specific data in the foarm of a data frame.

interval_data<-function(lower_limit,upper_limit,...){
  # filter individuals who experienced the event or were censored before the interval [LowLim,UPLim)
  interval_data<-surv_data[which(surv_data[,time_index] >= lower_limit),]
  # compute the new survival time
  exposure<-apply(cbind(interval_data[,time_index]-lower_limit,
                        rep((upper_limit-lower_limit),nrow(interval_data))), 1, min)

  # as a reminder: an obseration is censored if it survives beyond the interval or was censored within the interval.
  # if an observation is censored the index is assigned 0, otherwise it is 1.
  event<-interval_data[,event_index]*ifelse(interval_data[,time_index] < upper_limit,1,0)
  return(data.frame(exposure=exposure,event=event,interval_data[,-c(time_index,event_index)]))
  }


#' Compute a summary of the grouped data
#' @param grouped_data A data frame containing the grouped data to be summarized.
#' @param time_intervals A vector of time points partitioning the survival time. They define the survival time groups.
#' @param col_indexes A vector of column indexes for which to display the summary.
#' @return The data summary.
summarize<-function(grouped_data,time_intervals,col_indexes=c(1,2)){
  grp_names<-c()
  total_summary<-c()
  for (i in seq_len(length(time_intervals)-1)){

    grp_names<-cbind(grp_names,
                     paste0("[",paste0(time_intervals[i]),
                            paste0(",", paste0(time_intervals[i+1],"["))))
    total_summary <- rbind(total_summary,apply(grouped_data[which(grouped_data$Group==i),col_indexes],2,sum))

  }
  rownames(total_summary) <- grp_names
  return(total_summary)
}

