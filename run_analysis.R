

#1. Load the Reshape Library
library(reshape2)

filename <- "dataset.zip"
dataDir <- "data"

#2. Download and Unzip the Data
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}


#3. Merge the Train and Test Data

# 3.1. Load train data
x_train <- read.table(paste("UCI HAR Dataset/train/X_train.txt", sep = ""))
y_train <- read.table(paste("UCI HAR Dataset/train/Y_train.txt", sep = ""))
s_train <- read.table(paste("UCI HAR Dataset/train/subject_train.txt", sep = ""))

# 3.2. Load test data
x_test <- read.table(paste("UCI HAR Dataset/test/X_test.txt", sep = ""))
y_test <- read.table(paste("UCI HAR Dataset/test/Y_test.txt", sep = ""))
s_test <- read.table(paste("UCI HAR Dataset/test/subject_test.txt", sep = ""))

# 3.3. Merge the train and test data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)


#4. Load feature information and activity labels
# Load the feature information
feature <- read.table(paste("UCI HAR Dataset/features.txt", sep = ""))

# Load the activity labels
a_label <- read.table(paste("UCI HAR Dataset/activity_labels.txt",sep = ""))
a_label[,2] <- as.character(a_label[,2])

# Extract the data on mean & standard deviation
selFeat <- grep("-(mean|std).*", as.character(feature[,2]))
selFeatNames <- feature[selFeat, 2]
selFeatNames <- gsub("-mean", "Mean", selFeatNames)
selFeatNames <- gsub("-std", "Std", selFeatNames)
selFeatNames <- gsub("[-()]", "", selFeatNames)


#5. Extract the data based on feature names
x_data <- x_data[selFeat]
allData <- cbind(s_data, y_data, x_data)
colnames(allData) <- c("Subject", "Activity", selFeatNames)

#5.1. Convert activities and subjects into factors
allData$Activity <- factor(allData$Activity, levels = a_label[,1], labels = a_label[,2])
allData$Subject <- as.factor(allData$Subject)


#6. Generate tidy data
finalData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(finalData, Subject + Activity ~ variable, mean)

#6.1. Save the tidy data
write.table(tidyData, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)
