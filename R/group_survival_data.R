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

grouping<-function(survData,intervals,T_ind,C_ind,X_vec)
{
  grouped<-c()
  for(i in 2:length(intervals))

  {
    Data.new<-IntervalData(survData,intervals[i-1],intervals[i],T_ind,C_ind)
    L<-dim(Data.new)[1]
    X.mat<-as.data.frame(unique(Data.new[,X_vec]))
    for(j in 1:dim(X.mat)[1])
    {
      # difference between a given variable combination with the whole dataset
      Diff<-as.matrix(Data.new[,X_vec])==
        matrix(rep(X.mat[j,],each=L),ncol=length(X.mat[j,]))

      Diff<-ifelse(Diff==TRUE,1,0)
      Exposure<-sum(Data.new[which(apply(Diff,1,prod)==1),T_ind])
      Events<-sum(Data.new[which(apply(Diff,1,prod)==1),C_ind])
      grouped<-rbind(grouped,cbind(Exposure=Exposure,Events=Events,Group=i-1,X.mat[j,]))
    }

  }

  colnames(grouped)<-c("Exposure","Events","Group",colnames(survData)[X_vec])
  rownames(grouped) <- c()

  return(as.data.frame(grouped))
}


#' Extract interval-specific data
#'
#' Extract data for observations  which experience or are censored within a specified time interval.
#' @param lower_limit The lower limit of the time interval
#' @param upper_limit The upper limit of the time interval
#' @param surv_data The raw data in the foarm of a data frame.
#' @param col_indexes A list of column indexes that specify the columns index  of the survival time,
#'  censoring indicator, and covariates used.
#' @return The interval-specific data in the foarm of a data frame.
#' @export

IntervalData<-function(survData,LowLim,UPLim,T_ind,C_ind)
{
  # filter individuals who experienced the event or were censored before the interval [LowLim,UPLim)
  IntData<-survData[which(survData[,T_ind]>=LowLim),]
  # compute the new survival time
  SurvTime<-apply(cbind(IntData[,T_ind]-LowLim,rep((UPLim-LowLim),
                                                   nrow(IntData))),1,min)
  # compute the interval censoring index
  # as a reminder: an obs is censored if it survive beyond the interval or was censored within the interval.
  # if an obs is censored the index is given calue equal to 0, otherwise it is 1.
  index<-IntData[,C_ind]*ifelse(IntData[,T_ind]<UPLim,1,0)
  return(data.frame(Time=SurvTime,Status=index,IntData[,-c(T_ind,C_ind)]))
}


#' Compute a summary of the grouped data
#' @param grouped.data A data frame containing the grouped data to be summarized.
#' @param intervals A vector of time points partitioning the survival time. They define the survival time groups.
#' @param col.indexes A vector of column indexes for which to display the summary.
#' @return The data summary.
#' @export

grouped_summary<-function(grouped.data,intervals,col.indexes=c(1,2))
{
  grp.names<-c()
  total.sum<-c()
  for (i in 1:(length(intervals)-1))
  {

    grp.names<-cbind(grp.names,
                     paste0("[",paste0(intervals[i]),
                            paste0(",", paste0(intervals[i+1],")"))))
    total.sum<-rbind(total.sum,apply(grouped.data[which(grouped.data$Group==i),
                                                  col.indexes],2,sum))

  }
  grand_totals <- c(Total=apply(total.sum,2,sum))
  total.sum <- rbind(total.sum , grand_totals)
  rownames(total.sum)<-c(grp.names, 'Total')
  #print(c(Total=apply(total.sum,2,sum)))
  return(total.sum)

}

