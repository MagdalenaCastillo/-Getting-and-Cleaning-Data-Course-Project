#load required package
library(dplyr)

#create individual dataframes from the text files
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("feature_id", "feature"))
activites <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_id", "activity"))
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR DataSet/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "label")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

#merge the training data with the test data
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)
merged_data <- cbind(subject_data, Y, X)

#extract only the measurements on the mean and standard deviation for each measurement
x_test <- x_test %>% select(contains("mean"), contains("std"))
x_train <- x_train %>% select(contains("mean"), contains("std"))

#use the descriptive activity names from the activites dataframe to name the activities in the data set
merged_data <- merged_data %>% mutate(label = activites[merged_data$label, 2])

#appropriately label the data set with descriptive variable names
names(merged_data)[2] = "activity"
names(merged_data)<-gsub("Acc", "Accelerometer", names(merged_data))
names(merged_data)<-gsub("Gyro", "Gyroscope", names(merged_data))
names(merged_data)<-gsub("BodyBody", "Body", names(merged_data))
names(merged_data)<-gsub("^t", "Time", names(merged_data))
names(merged_data)<-gsub("-mean()", "Mean", names(merged_data))
names(merged_data)<-gsub("-std()", "STD", names(merged_data))
names(merged_data)<-gsub("-freq()", "Frequency", names(merged_data))

#create a second, independent tidy data set with the average of each variable for each activity and each subject
final_data <- merged_data %>% group_by(subject, activity) %>% summarise_all(mean)

write.table(final_data, "final_data.txt", row.names = FALSE)
