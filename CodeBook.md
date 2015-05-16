---
title: "CodeBook"
date: "Friday, May 15, 2015"
---
#CodeBook

## Creating Tidy Data
The instruction below explain the process and steps taken to create a tidy dataset from the data files provided in UCI HAR Dataset

### Intsall and Load dplyr package
This code checks whether or not dplyr package is already installed. If not then dplyr is installed. The package is then loaded into the project

```{r}
### Intsall and load dplyr package
if("dplyr" %in% rownames(installed.packages()) == FALSE) 
{
  install.packages("dplyr")
};

library(dplyr) 
```

### Data Download
The first step is to download the necessary data file. The code below first checks whether or not "UCI HAR Dataset" directory exists within the working directory. If the file doesn't exists then it checks whether or not the "getdata-projectfiles-UCI HAR Dataset.zip" file exists. If the zip file also doesn't exists then the code below downloads the zip file from the source location and unzips it in the working directory

```{r}
library(dplyr)

downloadUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destZipFile <- "getdata-projectfiles-UCI HAR Dataset.zip"
dataDir <- "UCI HAR Dataset"

if (!file.exists(dataDir)) {
  if(!file.exists(destZipFile)) {
    download.file(downloadUrl, destZipFile)
  }
  ## Unzip the file
  unzip(destZipFile)
  cat("==The file is downloaded, unzipped and is read to use==")
}
```

###Step 1: Merges the training and the test sets to create one data set
The code below retrieves the data from test and training files an creates seprate datasets for test and training data. It then combines the two datasets and create a single base dataset

```{r}
## Read test data
test.subject <- read.table(paste(datDir, "/test/subject_test.txt", sep=""),col.names = "Subject")
test.X <- read.table(paste(datDir, "/test/X_test.txt", sep=""))
test.Y <- read.table(paste(datDir, "/test/Y_test.txt", sep=""), col.names = "Activity")
## Create test dataset by binding the above data from the test files
test.data <- dplyr::bind_cols(test.subject, test.Y, test.X)

## Read training data
training.subject <- read.table(paste(datDir, "/train/subject_train.txt", sep=""),col.names = "Subject")
training.X <- read.table(paste(datDir, "/train/X_train.txt", sep=""))
training.Y <- read.table(paste(datDir, "/train/Y_train.txt", sep=""), col.names = "Activity")
## Create test dataset by binding the above data from the test files
training.data <- dplyr::bind_cols(training.subject, training.Y, training.X)

## Merge the training and the test sets to create one data set
base.data <- dplyr::bind_rows(test.data, training.data)
```

### Step 2: Extracts only the measurements on the mean and standard deviation for each measurement
The code below retrieves all the measures from the features.txt file. It then retrieves the indices for the measures for mean and standard deviation using regular expression. It then extracts the columns corresponding to the indices of the measure along with Subject and Activity columns

```{r}
## Read features or measures
measures <- read.table(paste(datDir, "/features.txt",sep = ""), col.name=c("Id", "MeasureName"))
## Get the indices of the rows with mean and standard deviation measurements
mean_stddev_measure_indices <- grep(pattern = "[Mm]ean\\()|[Ss]td\\()", measures$MeasureName)
## Filter the base table with mean and standard deviation measures for all the activities for all the subjects
subject_activity_mean_stddev.data <- base.data[, c(1, 2, mean_stddev_measure_indices+2)]
```

### Step 3: Use descriptive activity names to name the activities in the data set
The code below reads the activities name from activity_label files. It then substitutes the activity ids in the Activity column of with the activity name

```{r}
subject_activity_mean_stddev.data$Activity <- as.character(subject_activity_mean_stddev.data$Activity)
## Read activities labels
activity_labels <- read.table(paste(datDir, "/activity_labels.txt",sep = ""), col.name=c("Id", "Activity"))
## Take the activities name from activity_labels and replace the value for Activity id 
for(i in 1:nrow(activity_labels))
{ 
  ## Replace the id for activity with descriptive activity name
  subject_activity_mean_stddev.data$Activity <- gsub(activity_labels[i,"Id"], activity_labels[i,"Activity"], subject_activity_mean_stddev.data$Activity)
}
```

### Step 4: Appropriately labels the data set with descriptive variable names
The code below retrieves the name for the measures for mean and standard deviation using regular expression. It then creates a character vector with column names and then assigns the column names to columns of subject_activity_mean_stddev.data

```{r}
## Get the names of all mean and standard deviation measures
mean_stddev_measure_names <- grep("[Mm]ean\\()|[Ss]td\\()", measures$MeasureName, value=TRUE)
mean_stddev_measure_names <- c("Subject", "Activity", mean_stddev_measure_names)
names(subject_activity_mean_stddev.data) = mean_stddev_measure_names
```

###Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
The code below creates tidy data set with the average of each variable for each activity and subject
```{r}
## create tidy dataset
tidy_dataset <- subject_activity_mean_stddev.data %>% dplyr::group_by(Subject, Activity)%>%dplyr::summarise_each(funs(mean))
## Save the tidy dataset
write.table(tidy_dataset, "./tidydata.txt", row.name=FALSE)
```

## Data Dictionary for Tidy Data
The tidy data has 180 records for 6 Activities for 30 subjects and contains the average of mean and standard deviation values of 68 variables (measures) for each activity for each subject.

The first two variables for subject Subject and Activity while other 66 variables are for average of mean and standard deviation values. The following is the description of the variables

#### Variable Description
"Subject" [int] - 30 subjects on which the measurements were taken

"Activity" [char] - Following six activities are the values of this variable  
    1. WALKING   
    2. WALKING_UPSTAIRS  
    3. WALKING_DOWNSTAIRS  
    4. SITTING  
    5. STANDING  
    6. LAYING  

The following 66 variables correspond to the mean and standard deviation of the measured signals 
"tBodyAcc.mean()-X"           [numeric]   
"tBodyAcc.mean()-Y"           [numeric]  
"tBodyAcc.mean()-Z"           [numeric]  
"tBodyAcc.std()-X"            [numeric]  
"tBodyAcc.std()-Y"            [numeric]  
"tBodyAcc.std()-Z"            [numeric]  
"tGravityAcc.mean()-X"        [numeric]  
"tGravityAcc.mean()-Y"        [numeric]  
"tGravityAcc.mean()-Z"        [numeric]  
"tGravityAcc.std()-X"         [numeric]  
"tGravityAcc.std()-Y"         [numeric]  
"tGravityAcc.std()-Z"         [numeric]  
"tBodyAccJerk.mean()-X"       [numeric]  
"tBodyAccJerk.mean()-Y"       [numeric]  
"tBodyAccJerk.mean()-Z"       [numeric]  
"tBodyAccJerk.std()-X"        [numeric]  
"tBodyAccJerk.std()-Y"        [numeric]  
"tBodyAccJerk.std()-Z"        [numeric]  
"tBodyGyro.mean()-X"          [numeric]  
"tBodyGyro.mean()-Y"          [numeric]  
"tBodyGyro.mean()-Z"          [numeric]  
"tBodyGyro.std()-X"           [numeric]  
"tBodyGyro.std()-Y"           [numeric]  
"tBodyGyro.std()-Z"           [numeric]  
"tBodyGyroJerk.mean()-X"      [numeric]  
"tBodyGyroJerk.mean()-Y"      [numeric]  
"tBodyGyroJerk.mean()-Z"      [numeric]  
"tBodyGyroJerk.std()-X"       [numeric]  
"tBodyGyroJerk.std()-Y"       [numeric]  
"tBodyGyroJerk.std()-Z"       [numeric]  
"tBodyAccMag.mean()"          [numeric]  
"tBodyAccMag.std()"           [numeric]  
"tGravityAccMag.mean()"       [numeric]  
"tGravityAccMag.std()"        [numeric]  
"tBodyAccJerkMag.mean()"      [numeric]  
"tBodyAccJerkMag.std()"       [numeric]  
"tBodyGyroMag.mean()"         [numeric]  
"tBodyGyroMag.std()"          [numeric]  
"tBodyGyroJerkMag.mean()"     [numeric]  
"tBodyGyroJerkMag.std()"      [numeric]  
"fBodyAcc.mean()-X"           [numeric]  
"fBodyAcc.mean()-Y"           [numeric]  
"fBodyAcc.mean()-Z"           [numeric]  
"fBodyAcc.std()-X"            [numeric]  
"fBodyAcc.std()-Y"            [numeric]  
"fBodyAcc.std()-Z"            [numeric]  
"fBodyAccJerk.mean()-X"       [numeric]  
"fBodyAccJerk.mean()-Y"       [numeric]  
"fBodyAccJerk.mean()-Z"       [numeric]  
"fBodyAccJerk.std()-X"        [numeric]  
"fBodyAccJerk.std()-Y"        [numeric]  
"fBodyAccJerk.std()-Z"        [numeric]  
"fBodyGyro.mean()-X"          [numeric]  
"fBodyGyro.mean()-Y"          [numeric]  
"fBodyGyro.mean()-Z"          [numeric]  
"fBodyGyro.std()-X"           [numeric]  
"fBodyGyro.std()-Y"           [numeric]  
"fBodyGyro.std()-Z"           [numeric]  
"fBodyAccMag.mean()"          [numeric]  
"fBodyAccMag.std()"           [numeric]  
"fBodyBodyAccJerkMag.mean()"  [numeric]  
"fBodyBodyAccJerkMag.std()"   [numeric]  
"fBodyBodyGyroMag.mean()"     [numeric]  
"fBodyBodyGyroMag.std()"      [numeric]  
"fBodyBodyGyroJerkMag.mean()" [numeric]  
"fBodyBodyGyroJerkMag.std()"  [numeric]  