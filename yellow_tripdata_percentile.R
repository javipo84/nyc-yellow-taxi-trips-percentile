library(data.table)

if(length(commandArgs(trailingOnly=TRUE)) > 0)
  args = commandArgs(trailingOnly=TRUE)

if (length(args) == 0)
  stop("At least one argument must be supplied (input file).csv", call.=FALSE)

#Data Ingestion
data.trips <- fread(args[1], blank.lines.skip = TRUE)

#Calculation
data.percentile_trips <- data.trips[data.trips$trip_distance>quantile(data.trips$trip_distance, probs = c(0.9))[1],]

#Data Output
if(length(args) == 2)
  fwrite(data.percentile_trips[order(data.percentile_trips$trip_distance),], args[2])