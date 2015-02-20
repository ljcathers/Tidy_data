#Readme for Tidy_data
This contains my work and final results for the course project for the Coursera Getting and Cleaning Data course.

Break down of the script for run_analaysis.R, that produces a tidy dataset with the mean of each variable for each activity and each subject.

The Goals of this script are as follows:
You should create one R script called run_analysis.R that does the following. 
 1- Merges the training and the test sets to create one data set.
 2- Extracts only the measurements on the mean and standard deviation for each measurement. 
 3- Uses descriptive activity names to name the activities in the data set
 4- Appropriately labels the data set with descriptive variable names. 
 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

About the data files
 'features.txt': List of all features.
 'activity_labels.txt': Links the class labels with their activity name.
 'X': data set.
 'y': labels.

Install data.table package for R
    >install.packages("data.table")
set the working directory
    >setwd("~/Documents/Coursera_Data_Science/03_Cleaning_data/UCI HAR Dataset")

Load test data sets
    >X_test <- read.table("./test/X_test.txt", header = FALSE)
    >y_test <- read.table("./test/y_test.txt", header = FALSE)
    >subject_test <- read.table("./test/subject_test.txt", header = FALSE)

Load training data sets
    >X_train <- read.table("./train/X_train.txt", header = FALSE)
    >y_train <- read.table("./train/y_train.txt", header = FALSE)
    >subject_train <- read.table("./train/subject_train.txt", header = FALSE)

Step 1- Merges the training and the test sets to create one data set for each type; data (X), labels (y), and subjects.
merge the two feature data files (X) 
    >X_data <- rbind(X_test, X_train)
merge the two activity labels files (y)
    >y_labels <- rbind(y_test, y_train)
merge the two subject files 
    >subject_all <- rbind(subject_test, subject_train)

Read in feature names file
    >features <- read.table("./features.txt",header=FALSE)

Provide descriptive names for the columns
    >names(subject_all)<-c("subject")
    >names(y_labels)<- c("activity")
    >names(X_data)<- features$V2

Merge all datasets into one dataset called all_data
    >y_subj<- cbind(subject_all, y_labels)
    >all_data<- cbind(y_subj, X_data)

Review all_data (names)
    * decided not to include >head(all_data)
    >names(all_data)

Step 2- Extracts only the measurements on the mean and standard deviation for each measurement. 
    >mean_std <- features[grep("(mean|std)\\(", features[,2]),]
    >myMeasurements <- all_data[,mean_std[,1]]

Review dimensions and column headers for the extracted measurements data in myMeasurements
    >dim(myMeasurements)
    >names(myMeasurements)

Step 3- Uses descriptive activity names to name the activities in the data set
Read in the table containing activity names
    >activity_names <- read.table("./activity_labels.txt", header = FALSE)
View the list of activity names
    >activity_names

Use the activity labels (i.e. "walking") to replace the activity code in the 'activity' column
    >myMeasurements$activity <- factor(myMeasurements$activity,
                    levels = c(1,2,3,4,5,6),
                    labels = c("WALKING", "WALKING_UPSTAIRS", "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))

Print a range of rows for column 2, "Activity", to view the activity labels
      >print(myMeasurements[100:120, 1:4])

Step4- Appropriately labels the data set with descriptive variable names. 
The abbreviations are replaced with descriptive variable names (i.e. "t" is replaced with "time")
    >names(myMeasurements)<-gsub("^t", "time", names(myMeasurements))
    >names(myMeasurements)<-gsub("^f", "frequency", names(myMeasurements))
    >names(myMeasurements)<-gsub("Acc", "Accelerometer", names(myMeasurements))
    >names(myMeasurements)<-gsub("Gyro", "Gyroscope", names(myMeasurements))
    >names(myMeasurements)<-gsub("Mag", "Magnitude", names(myMeasurements))
    >names(myMeasurements)<-gsub("BodyBody", "Body", names(myMeasurements))

Review the newly renamed headings
                    *head(myMeasurements) # This is too long for the console to load.
    >names(myMeasurements)
    >print(myMeasurements[100:120, 1:4])

Rename the file "data"
    >data<- myMeasurements

Step 5- From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    >library(reshape2) # load the reshape package
    >data2 <- arrange(data,subject, activity) #arrange the data in order by subject, then activity
    >dataMelt <- melt(data2, id.vars=c("subject", "activity")

Review the melted table.
    >head(dataMelt, n=3)

Calculate the Means
    >library(dplyr) #load the dplyr package
    >groupedData <- group_by(dataMelt, subject, activity, variable)
    >tidy_dataMean<- summarise(groupedData, mean=mean(value))

Review the final tidy dataset (data_mean)
    >head(tidy_dataMean)

Upload file using write.table() using row.name=FALSE
    >write.table(tidy_dataMean, file = "./tidy_data.txt",row.name=FALSE)

To read the file back into R use the following code
    >data <- read.table("./tidy_data.txt", header = TRUE)
    >View(data)
#SOURCE: David Hood (Coursera TA), "David's Course Project FAQ", https://class.coursera.org/getdata-011/forum/thread?thread_id=69


About the data:

==================================================================
Human Activity Recognition Using Smartphones Dataset
Version 1.0
==================================================================
Jorge L. Reyes-Ortiz, Davide Anguita, Alessandro Ghio, Luca Oneto.
Smartlab - Non Linear Complex Systems Laboratory
DITEN - Universit‡ degli Studi di Genova.
Via Opera Pia 11A, I-16145, Genoa, Italy.
activityrecognition@smartlab.ws
www.smartlab.ws
==================================================================

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:
======================================

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:
=========================================

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

Notes: 
======
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

For more information about this dataset contact: activityrecognition@smartlab.ws

License:
========
Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.
