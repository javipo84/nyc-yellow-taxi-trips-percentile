# NYC Yellow Taxi Trips Percentile

NYC Yellow Taxi Trips Percentile is a R script that return all the trips **over 0.9 percentile** in distance traveled for any of the CSV files you can find in [NYC "Yellow Taxi" Trips Data](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page). This website contains trip data from 2009 to present, this information is available in CSV files for each month and year and this is the [Data Dictionary](https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf). Some of the information provided for each trip is Passengers count, Trip distance (milles), Pick up date, Drop off date or Total amount.

## Approach & Performance

**¿Why R?** 

Because R is a platform-independent or cross-platform language, and also has these two features:

- Open Source.
- Effective data handling and storage.
- A great collection of tools for data analysis.

Other languages like Python or others also allow it, but this time I wanted to develop this funcionality using R.

**Approach**

The three stages of the solution are as follows:

1. **Ingestion:** This is the most critical phase, consuming **80%** of the total script execution time. <ins>The data is loaded directly into memory for faster calculation processing</ins>, either from a local file or available via url. If it is a url, a temporary download will be performed but the file will not be persisted, it is not the purpose of this script to create a download history. For this in-memory loading to be optimal, it is necessary to use a package such as [data.table](https://www.rdocumentation.org/packages/data.table/versions/1.14.2), specially prepared for larger datasets. This technique can cause problems if there is not enough memory available on the machine to contain all this information, but after checking that the maximum file size of the website is **2.6GB**, we can say that it is an acceptable value for this technique. However, it is certainly something to pay attention to in case the data source changes. Other techniques discarded in this first version were the following:


   - *<ins>Partial memory loading:</ins>* This option requires the source file to be persisted on disk and only the *trip_distance* column to be loaded in memory, as it is the only one needed to calculate the percentile, thus reducing the size of the object to be loaded and improving speed. Subsequently, to extract from the file all the information of the trips that meet the percentile, we could use a library such as [sqldf](https://www.rdocumentation.org/packages/sqldf/versions/0.4-11), which is able to perform a query on a .csv file hosted on disk. In some tests, I did not achieve a performance improvement by applying this technique, the reading of the file on disk to extract this query turned out to be much more expensive, so I discarded it.
   
   - *<ins>Data loading into a database system</ins> Another option would be to ingest the input file into an information system, for example any database. The process would be very similar to that of the previous point, except that on this occasion, once the percentile calculation has been made, we would have to consult this system so that it would return all the trips that are above this percentile. This query would be faster, as it is not done directly from a flat file on disk, but in architectures specially designed for this type of queries. I rejected it because it requires the use of other structures and eliminates the flexibility of the script's calculation by making it dependent on other systems.

 
2. **Calculation:** This stage only takes **3%-5%** of the total process time. Once the data is loaded into memory, the calculation of the 0.9 percentile is performed using the column **trip_distance**, that contains the elapsed trip distance in miles reported by the taximeter. This stage is more optimized because the data is already loaded into memory, but if the size of the files were to increase considerably, penalising this calculation, the solution would be to extract a random sample of the file and obtain the percentile from it, instead of the complete file. This technique, obtains very good results, but the solution would become non-deterministic. 
3. **Output**: <ins>The output we will be stored in a dataframe called **data.percentile_trips**</ins> with the same original [Data Dictionary](https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf), but where we will only have those trips over the calculated percentile. Working in the R environment we can take the data directly from this dataframe. Also as we will see in *Usage*, if we have specified a value for the Output File parameter, the result will also be stored to this file, but be careful, if the output file already exists, it will be overwritten. In both cases, the output will be sorted in ascending order by the **trip_distance** column.
<ins>This step could consume up to **15%** of total time in case the output needs to be written down in disk. If it is not necessary to write the output in CSV file, this stage will not consume any time.</ins>


![Performance chart](https://github.com/javipo84/nyc-yellow-taxi-trips-percentile/blob/main/src/Performance_chart.png)

*For these simulations, the download time of the source file has not been taken into account in case it was via url.*

## Requeriments

1. Obviously, you will need to install [R](https://cran.r-project.org/) on your system. 
2. You will also need to install the [data.table](https://www.rdocumentation.org/packages/data.table/versions/1.14.2) and [curl](https://www.rdocumentation.org/packages/curl/versions/4.3.2/topics/curl) packages in your R environment, for this you just need to run the code below in your R console from an IDE connected to this R environment. 

```r
install.packages("data.table")
install.packages("curl")
```

## Usage
Whether you use R from the console or from an IDE like [RStudio](https://www.rstudio.com/), **the most important thing is that prior to the execution of any script, you properly configure your workspace, setting the root of this repository in your local workspace or run the Rscript command also located in the root directory of the repo in your local workspace**. Otherwise, some relative paths may not work properly and therefore you may not be able to run this script correctly.

Once this is done, you will need to run the [yellow_tripdata_percentile.R](yellow_tripdata_percentile.R) file, , which has two input parameters:
- **Input File** (Required): Specifies the path and name of the input CSV file. You can specify a local path or a url, siempre que sea un fichero que cumpla con el [Data Dictionary](https://www1.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf).
- **Output File** (Optional): Indicate the path and name of the output CSV file. 

Examples: 

```r
#Calculates the percentile on the file contained in a url and does not generate an output file
Rscript yellow_tripdata_percentile.R https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv output_2021_01.csv
```
```r
#Calculates the percentile on the file contained in a url and generates output file
Rscript yellow_tripdata_percentile.R https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2021-01.csv output_2021_01.csv output_2021_01.csv
```

```r
#Calculates the percentile on the file contained in a local path and generates output file
#The file data/yellow_tripdata_2021-01_test.csv is available in this repo
Rscript yellow_tripdata_percentile.R data/yellow_tripdata_2021-01_test.csv output_2021_01.csv
```

## Test
The test to validate the [yellow_tripdata_percentile.R](yellow_tripdata_percentile.R) script is very simple. The [yellow_tripdata_percentile_test.R](yellow_tripdata_percentile_test.R) script is also available in the repository, for now it is the only test developed. This script is executed without parameters and uses as input file [yellow_tripdata_2021-01_test.csv](data/yellow_tripdata_2021-01_test.csv), which contains a random sample of 100,000 trips for the month of January 2021. This run results in the output file *output_yellow_tripdata_calculated_test.csv* which is compared with the file [output_yellow_tripdata_expected_test.csv](data/output_yellow_tripdata_expected_test.csv). 

```r
#Ejecución del test
Rscript yellow_tripdata_percentile_test.R
```
If the test is OK, you will receive the message *"Test passed"*, otherwise, the execution will have suffered some error or the calculated data is not exactly the same as expected.

## Roadmap
- **Data schema optimisation:** While the file is loaded into memory, there is a data conversion happening automatically from raw data from the CSV file to the required one (int, char, date, ...).  We could improve the performance by paying attention to get *colClasses* parameter so the data schema is optimal for the data structure we are loading.

- **Better testing coverage:**
In addition to the “happy path” test performed, further tests should be developed:
  - Empty file as input.
  - High number of corrupt rows as input - low number is acceptable (<0.1% - agree with acceptance criteria/requirements).
  - Data dictionary not respected.
  - Wrong input format file.
  - Low number of elements - expected file.
  - Find more other edge cases.

- **Continuous Integration:**
Once we got a good testing coverage, CI becomes super relevant.
This way, we validate the core functionality will be always respected, no matter how many changes are performed over the original code.
I would suggest, every time a new pull request is sent, the battery of tests is triggered and only performs the merge action, if all tests are green. Otherwise, a report would be created for the developers to analyse.


- **Cleaning Data:**
There are some rows which contain corrupt data. E.g. number of passengers is zero, or pick up date happens after drop off date, etc. 
The impact is really low, around 0.001% of the total, but still, these are incongruences that would be ideal to be eliminated first.

- **Percentile parameter:**
At the moment, the 0.9 percentile parameter is hardcoded within the script. 
Getting this as an input param would be recommended, so the script becomes more generic.

- **Error handling:**
At the moment, basic error handling has been implemented. The script just requires to have at least one input parameter
Other errors to take into consideration could be:
  - Error while loading the file into memory (e.g. lack of memory space, input file not exist, etc).
  - High number of corrupt rows within the table (e.g. >70% of corrupt rows).
  - Missing columns.
  - Not able to write the outcome file into disk.


- **Package:**
Instead of building this feature as a script, it would be better to run it as a library or package. This way, it would be more convenient for the user.

- **Breaks method:**
This script uses Quantiles method break, but there are other similar approaches like [Jenks natural breaks](https://en.wikipedia.org/wiki/Jenks_natural_breaks_optimization). This break method could be an input parameter for our script. 


## Contributing
Pull requests are welcome. 
Please make sure to update tests as appropriate.



