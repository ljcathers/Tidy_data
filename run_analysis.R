## You should create one R script called run_analysis.R that does the following. 
# 1- Merges the training and the test sets to create one data set.
# 2- Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3- Uses descriptive activity names to name the activities in the data set
# 4- Appropriately labels the data set with descriptive variable names. 
# 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##Begin Course Project

install.packages("data.table")
setwd("~/Documents/Coursera_Data_Science/03_Cleaning_data/UCI HAR Dataset")

## About the data files
# 'features.txt': List of all features.
# 'activity_labels.txt': Links the class labels with their activity name.
# 'X': data set.
# 'y': labels.

## Load test data sets
X_test <- read.table("./test/X_test.txt", header = FALSE)
y_test <- read.table("./test/y_test.txt", header = FALSE)
subject_test <- read.table("./test/subject_test.txt", header = FALSE)

## Load training data sets
X_train <- read.table("./train/X_train.txt", header = FALSE)
y_train <- read.table("./train/y_train.txt", header = FALSE)
subject_train <- read.table("./train/subject_train.txt", header = FALSE)


## Step 1- Merges the training and the test sets to create one data set for each type; data (X), labels (y), and subjects.
# merge the two feature data files (X) 
X_data <- rbind(X_test, X_train)
# merge the two activity labels files (y)
y_labels <- rbind(y_test, y_train)
# merge the two subject files 
subject_all <- rbind(subject_test, subject_train)

## Read in feature names file
features <- read.table("./features.txt",header=FALSE)

# provide descriptive names for the columns
names(subject_all)<-c("subject")
names(y_labels)<- c("activity")
names(X_data)<- features$V2

# merge all datasets into one dataset called all_data
y_subj<- cbind(subject_all, y_labels)
all_data<- cbind(y_subj, X_data)

#review all_data (names)
# head(all_data)
names(all_data)

## Step 2- Extracts only the measurements on the mean and standard deviation for each measurement. 
mean_std <- features[grep("(mean|std)\\(", features[,2]),]
myMeasurements <- all_data[,mean_std[,1]]

# review dimensions and column headers for the extracted measurements data in myMeasurements
dim(myMeasurements)
names(myMeasurements)

## 3- Uses descriptive activity names to name the activities in the data set
# Read in the table containing activity names
activity_names <- read.table("./activity_labels.txt", header = FALSE)
# View the list of activity names
activity_names

# Use the activity labels (i.e. "walking") to replace the activity code in the 'activity' column
myMeasurements$activity <- factor(myMeasurements$activity,
                    levels = c(1,2,3,4,5,6),
                    labels = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))

# Print a range of rows for column 2, "Activity", to view the activity labels
  # print(myMeasurements[100:120, 1:4])

## 4- Appropriately labels the data set with descriptive variable names. 
# the abbreviations are replaced with descriptive variable names (i.e. "t" is replaced with "time")
names(myMeasurements)<-gsub("^t", "time", names(myMeasurements))
names(myMeasurements)<-gsub("^f", "frequency", names(myMeasurements))
names(myMeasurements)<-gsub("Acc", "Accelerometer", names(myMeasurements))
names(myMeasurements)<-gsub("Gyro", "Gyroscope", names(myMeasurements))
names(myMeasurements)<-gsub("Mag", "Magnitude", names(myMeasurements))
names(myMeasurements)<-gsub("BodyBody", "Body", names(myMeasurements))

# Review the newly renamed headings
# head(myMeasurements) # This is too long for the console to load.
names(myMeasurements)
print(myMeasurements[100:120, 1:4])

#rename the file "data"
data<- myMeasurements

# 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
library(reshape2) # load the reshape package
data2 <- arrange(data,subject, activity) #arrange the data in order by subject, then activity
dataMelt <- melt(data2, id.vars=c("subject", "activity")

# review the melted table.
head(dataMelt, n=3)

#Calculate the Means
library(dplyr) #load the dplyr package
groupedData <- group_by(dataMelt, subject, activity, variable)
tidy_dataMean<- summarise(groupedData, mean=mean(value))

#review the final tidy dataset (data_mean)
head(tidy_dataMean)

##Upload file using write.table() using row.name=FALSE
write.table(tidy_dataMean, file = "./tidy_data.txt",row.name=FALSE)

## To read the file back into R use the following code
data <- read.table("./tidy_data.txt", header = TRUE)
View(data)
  #SOURCE: David Hood (Coursera TA), "David's Course Project FAQ", https://class.coursera.org/getdata-011/forum/thread?thread_id=69
