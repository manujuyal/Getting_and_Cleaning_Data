---
title: "ReadMe"  
date: "Saturday, May 16, 2015"  
---  

#README
This repo is for the course project for Getting and Cleaning Data Course. Below is the description of the other files uploaded for this course.

**1. run_analysis.R**: This R Script is for creating a Tidy Dataset from the files in UCI HAR Dataset. The instruction and steps to create the Tidy Dataset is provided in the CodeBook.md. This R Script creates tidydata.txt file in the working directory. Please use the following script to generate tidydata.txt file in the working directory.

```{r}
source("run_analysis.R")
```

**2. tidydata.txt:** The tidy data set is created using run_analysis.R script. The data dictionary for the tidy data is provided in CodeBook.md in the repo. Please use read.table("TidyData.txt",sep="") command to view the data.

**3. CodeBook.md:** This file describes the variables of the tidy dataset and provides step-by-step instructions and explanation of how the tidy dataset was created.


