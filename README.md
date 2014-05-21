Getting and Cleaning Data Course Project
========================================================

This file describes the functionality of the data processing script *run_analysis.R*

Original Instructions
-------------------------
You should create one R script called run_analysis.R that does the following.

* Merges the training and the test sets to create one data set.
* Extracts only the measurements on the mean and standard deviation for each measurement.
* Uses descriptive activity names to name the activities in the data set
* Appropriately labels the data set with descriptive activity names.
* Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Script Functionality
-------------------------

Set the directory for the data (relative to current working directory), and read the label files for the activities and features

```{r}
# data files are in subdirectory
workdir <- "UCI HAR Dataset"

# read activity indeces[,1] and names[,2] (6)
actnames  <- read.table(file.path(workdir, "activity_labels.txt"), head= FALSE, stringsAsFactors= FALSE)
# read feature indices[,1] and names[,2] (561)
featnames <- read.table(file.path(workdir, "features.txt"), header= FALSE, stringsAsFactors= FALSE)
```

Build a filter for the necessary columns, so we can limit the amount of data to import.

```{r}
# prepare filter string for table import for columns with "-mean()" or "-std()" only
# "NULL" flags skipping, required columns are "numeric"
filter <- rep("NULL", nrow(featnames))
filter[grep("-(mean|std)\\(\\)", featnames[,2])]= "numeric"
```

Now read all the data for the test and training data limited to the columns for means and standard deviation and their respective labels.

```{r}
# read activity data for test activities, limiting to required columns (2947x66)
testdata  <- read.table(file.path(workdir, "test", "X_test.txt"), colClasses= filter, header= FALSE)
# read subject IDs[,1] for test activities (2947)
testsubj  <- read.table(file.path(workdir, "test", "subject_test.txt"), header= FALSE)
# read activity type[,1] for test activities (2947)
testact   <- read.table(file.path(workdir, "test", "y_test.txt"), header= FALSE)

# read activity data for training activities, limiting to required columns (7352x66)
traindata <- read.table(file.path(workdir, "train", "X_train.txt"),  colClasses= filter, header= FALSE)
# read subject IDs[,1] for training activities (7352)
trainsubj <- read.table(file.path(workdir, "train", "subject_train.txt"), header= FALSE)
# read activity type[,1] for training activities (7352)
trainact  <- read.table(file.path(workdir, "train", "y_train.txt"), header= FALSE)
```

Merge to a common data set.

```{r}
# merge data sets and prepend subject and type (using their names) columns
data <- cbind(c(trainsubj[,1], testsubj[,1]), 
              actnames[c(trainact[,1], testact[,1]),2], 
              rbind(traindata, testdata))
```

Generate user (and R) friendly labels.

```{r}
# set column names, lower case replacing "-" by R's preferred "." and dropping other non-letters
colnames(data) <- c("subject", 
                    "activity", 
                    gsub("[^a-z\\.]", "", gsub("-", ".", tolower(featnames[grep("-(mean|std)\\(\\)", featnames[,2]), 2]))))
# set row names as "activity.#" using row number
rownames(data) <- sub("(.*)", "activity.\\1", 1:nrow(data))
```

Write out the merged and cleaned data set (just for reference).

```{r}
# write as CSV with row names (columns names are automatic) and without quoting
write.csv(data, file.path(workdir, "clean.csv"), row.names= T, quote= F)
```

Aggregate the data to generate averages per subject per activity.

```{r}
# build average per subject per activity
means <- aggregate(data[,3:ncol(data)], by= list(data$subject, data$activity), FUN= mean)
```

Build nice labels.

```{r}
# add column names for the categories
colnames(means)[c(1, 2)] <- c("subject", "activity")
# add row names as "means.#"
rownames(means) <- sub("(.*)", "mean.\\1", 1:nrow(means))
```

Write out the data as CSV file (uploaded to grading system as .TXT due to limitations in file naming).

```{r}
# write as CSV with row names (columns names are automatic) and without quoting
write.csv(means, file.path(workdir, "means.csv"), row.names= T, quote= F)
```
