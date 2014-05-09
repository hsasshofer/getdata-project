# data files are in subdirectory
workdir <- "UCI HAR Dataset"

# read activity indeces[,1] and names[,2] (6)
actnames  <- read.table(file.path(workdir, "activity_labels.txt"), head= FALSE, stringsAsFactors= FALSE)
# read feature indices[,1] and names[,2] (561)
featnames <- read.table(file.path(workdir, "features.txt"), header= FALSE, stringsAsFactors= FALSE)
# prepare filter string for table import for columns with "-mean()" or "-std()" only
# "NULL" flags skipping, required columns are "numeric"
filter <- rep("NULL", nrow(featnames))
filter[grep("-(mean|std)\\(\\)", featnames[,2])]= "numeric"

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

# merge data sets and prepend subject and type (using their names) columns
data <- cbind(c(trainsubj[,1], testsubj[,1]), 
              actnames[c(trainact[,1], testact[,1]),2], 
              rbind(traindata, testdata))
# set column names, lower case replacing "-" by R's preferred "." and dropping other non-letters
colnames(data) <- c("subject", 
                    "activity", 
                    gsub("[^a-z\\.]", "", gsub("-", ".", tolower(featnames[grep("-(mean|std)\\(\\)", featnames[,2]), 2]))))
# set row names as "activity.#" using row number
rownames(data) <- sub("(.*)", "activity.\\1", 1:nrow(data))
# write as CSV with row names (columns names are automatic) and without quoting
write.csv(data, file.path(workdir, "clean.csv"), row.names= T, quote= F)

# build average per subject per activity
means <- aggregate(data[,3:ncol(data)], by= list(data$subject, data$activity), FUN= mean)
# add column names for the categories
colnames(means)[c(1, 2)] <- c("subject", "activity")
# add row names as "means.#"
rownames(means) <- sub("(.*)", "mean.\\1", 1:nrow(means))
# write as CSV with row names (columns names are automatic) and without quoting
write.csv(means, file.path(workdir, "means.csv"), row.names= T, quote= F)