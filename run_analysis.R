##Intsall and load dplyr package
if("dplyr" %in% rownames(installed.packages()) == FALSE) 
{
  install.packages("dplyr")
};

library(dplyr) 

## Download data files
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

## Read test data
test.subject <- read.table(paste(datDir, "/test/subject_test.txt", sep=""),col.names = "Subject")
test.X <- read.table(paste(datDir, "/test/X_test.txt", sep=""))
test.Y <- read.table(paste(datDir, "/test/Y_test.txt", sep=""), col.names = "Activity")

## Read training data
training.subject <- read.table(paste(datDir, "/train/subject_train.txt", sep=""),col.names = "Subject")
training.X <- read.table(paste(datDir, "/train/X_train.txt", sep=""))
training.Y <- read.table(paste(datDir, "/train/Y_train.txt", sep=""), col.names = "Activity")

## Step 1: 1.Merges the training and the test sets to create one data set
test.data <- dplyr::bind_cols(test.subject, test.Y, test.X)
training.data <- dplyr::bind_cols(training.subject, training.Y, training.X)
base.data <- dplyr::bind_rows(test.data, training.data)

#### Step 2: Extracts only the measurements on the mean and standard deviation for each measurement ####
## Read features or measures
measures <- read.table(paste(datDir, "/features.txt",sep = ""), col.name=c("Id", "MeasureName"))
## Get the indices of the rows with mean and standard deviation measurements
mean_stddev_measure_indices <- grep(pattern = "[Mm]ean\\()|[Ss]td\\()", measures$MeasureName)
## Filter the base table with mean and standard deviation measures for all the activities for all the subjects
subject_activity_mean_stddev.data <- base.data[, c(1, 2, mean_stddev_measure_indices+2)]

#### Step 3: Use descriptive activity names to name the activities in the data set ####
subject_activity_mean_stddev.data$Activity <- as.character(subject_activity_mean_stddev.data$Activity)
## Read activities labels
activity_labels <- read.table(paste(datDir, "/activity_labels.txt",sep = ""), col.name=c("Id", "Activity"))
## Take the activities name from activity_labels and replace the value for Activity id 
for(i in 1:nrow(activity_labels))
{ 
  ## Replace the id for activity with descriptive activity name
  subject_activity_mean_stddev.data$Activity <- gsub(activity_labels[i,"Id"], activity_labels[i,"Activity"], subject_activity_mean_stddev.data$Activity)
}

#### Step 4: Appropriately labels the data set with descriptive variable names ####
## Get the names of all mean and standard deviation measures
mean_stddev_measure_names <- grep("[Mm]ean\\()|[Ss]td\\()", measures$MeasureName, value=TRUE)
mean_stddev_measure_names <- c("Subject", "Activity", mean_stddev_measure_names)
names(subject_activity_mean_stddev.data) = mean_stddev_measure_names

#### Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject ####
## create tidy dataset
tidy_dataset <- subject_activity_mean_stddev.data %>% dplyr::group_by(Subject, Activity)%>%dplyr::summarise_each(funs(mean))
## Save the tidy dataset
write.table(tidy_dataset, "./tidydata.txt", row.name=FALSE)
