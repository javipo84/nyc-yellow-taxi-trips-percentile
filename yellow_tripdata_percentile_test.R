#R script test calculation percentile 0.9 Yellow Taxi Trips

input_file <- "data//yellow_tripdata_2021-01_test.csv"
output_file <- "data//output_yellow_tripdata_calculated_test.csv"
expected_outcome <- "data//output_yellow_tripdata_expected_test.csv"
test_script <- "yellow_tripdata_percentile.R"

args <- c(input_file,output_file)
source(test_script)
data.test_calculated <- fread(output_file, blank.lines.skip = TRUE)
data.test_expected <- fread(expected_outcome, blank.lines.skip = TRUE)

if(nrow(data.test_expected) == nrow(data.test_calculated)){
  print("Test passed")
}