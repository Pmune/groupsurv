#' Group survival data
#'
#' This function groups censored survival data.
#' It assumes that the raw data includes a column of observed survival time, censoring indicator,
#' and some additional categorical covariates. The current version does not support contineous covariates.
#'
#' @param surv_data Raw data in the foarm of a data frame.
#' @param time_intervals A vector of time points partitioning the survival time. They define the survival time groups.
#' @param time_ind Column index of the survival time in the data.
#' @param cens_ind Column index of the censoring indicator in the data.
#' @param x_vec A vector of column indexes that specify covariates to be used.
#' @return A data frame containing the grouped survival data. In addition to the selected covariates,
#' the output data frame three columns: exposure (for the exposure times), events (for the number of events),
#' and group (representing the survival time interval category).
#' @export

group_surv_time<-function(surv_data,time_intervals,time_ind,cens_ind,X_vec)
{
  grouped_data<-c()
  for(i in 2:length(time_intervals))

  {
    interval_data<-compute_interval_data(surv_data,time_intervals[i-1],time_intervals[i],time_ind,cens_ind, X_vec)
    L<-dim(interval_data)[1]
    X_mat<-as.data.frame(unique(interval_data[,X_vec]))
    for(j in 1:dim(X_mat)[1])
    {
      # difference between a given variable combination with the whole dataset
      diff<-as.matrix(interval_data[,X_vec])==
        matrix(rep(X_mat[j,],each=L),ncol=length(X_mat[j,]))
      diff<-ifelse(diff==TRUE,1,0)
      exposure<-sum(interval_data[which(apply(diff,1,prod)==1),"time"])
      events<-sum(interval_data[which(apply(diff,1,prod)==1),"status"])
      grouped_data<-rbind(grouped_data,cbind(exposure=exposure,events=events,group=i-1,X_mat[j,]))
    }

  }

  colnames(grouped_data)<-c("Exposure","Events","Group",colnames(surv_data[X_vec]))
  rownames(grouped_data) <- c()

  return(as.data.frame(grouped_data))
}


#' Extract interval-specific data
#'
#' Extract data for observations  which experience or are censored within a specified time interval.
#' @param lower_limit The lower limit of the time interval
#' @param upper_limit The upper limit of the time interval
#' @param surv_data The raw data in the foarm of a data frame.
#' @param time_ind Column index of the survival time in the data.
#' @param cens_ind Column index of the censoring indicator in the data.
#' @param x_vec A vector of column indexes that specify covariates to be used.
#' @return The interval-specific data in the foarm of a data frame.
#' @export

compute_interval_data<-function(surv_data,lower_limit,upper_limit,time_ind,cens_ind, x_vec)
{
  # filter individuals who experienced the event or were censored before the interval [lower_limit,upper_limit)
  int_data<-surv_data[which(surv_data[,time_ind]>=lower_limit),]
  # compute the new survival time
  surv_time<-apply(cbind(int_data[,time_ind]-lower_limit,rep((upper_limit-lower_limit),
                                                   nrow(int_data))),1,min)
  # compute the interval censoring index
  # as a reminder: an obs is censored if it survive beyond the interval or was censored within the interval.
  # if an obs is censored the index is given calue equal to 0, otherwise it is 1.
  index<-int_data[,cens_ind]*ifelse(int_data[,time_ind]<upper_limit,1,0)
  return(data.frame(time=surv_time,status=index,int_data[,x_vec]))
}


#' Compute a summary of the grouped data
#' @param grouped.data A data frame containing the grouped data to be summarized.
#' @param time_intervals A vector of time points partitioning the survival time. They define the survival time groups.
#' @return The data summary.
#' @export

grouped_summary<-function(grouped_data,time_intervals)
{
  grp_names<-c()
  total_sum<-c()
  col_indexes <- c(1,2)
  for (i in 1:(length(time_intervals)-1))
  {

    grp_names<-cbind(grp_names,
                     paste0("[",paste0(time_intervals[i]),
                            paste0(",", paste0(time_intervals[i+1],")"))))
    total_sum<-rbind(total_sum,apply(grouped_data[which(grouped_data$Group==i),
                                                  col_indexes],2,sum))

  }
  grand_totals <- c(Total=apply(total_sum,2,sum))
  total_sum <- rbind(total_sum , grand_totals)
  rownames(total_sum)<-c(grp_names, 'Total')
  return(total_sum)

}

