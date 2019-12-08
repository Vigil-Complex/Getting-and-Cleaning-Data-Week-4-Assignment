library(tidyverse)
library(readxl)
library(data.table)

#Importing Activity_Label and Features Datasets
features <- fread("./UCI HAR Dataset/features.txt", header = FALSE, stringsAsFactors = FALSE)
activities <- fread("./UCI HAR Dataset/activity_labels.txt", header = FALSE)

#Import Test Data Sets
x_test <- fread("./UCI HAR Dataset/test/X_test.txt")
y_test <- fread("./UCI HAR Dataset/test/y_test.txt")
sub_test <- fread("./UCI HAR Dataset/test/subject_test.txt")

#Import Train Data Sets
x_train <- fread("./UCI HAR Dataset/train/X_train.txt")
y_train <- fread("./UCI HAR Dataset/train/y_train.txt")
sub_train <- fread("./UCI HAR Dataset/train/subject_train.txt")

# 1) Merge datasets and remove duplicated variables
Test <- cbind(sub_test,y_test,x_test)
Train <- cbind(sub_train,y_train,x_train)
All <- rbind(Train,Test)
colnames(All) <- c("subject","activity",features$V2)
All <- as.data.frame(All)
Cleaned <- subset(All, select=which(!duplicated(names(All))))

# 2) Extracts only the mean and standard deviation
final <- All[,c(grep("subject|activity|*mean*|*std*",colnames(All)))]
index <- grep ("*Freq*",colnames(final))
final <- select(final, -index)


# 3)Use descriptive activity names to name the activities in the dataset
colnames(activities) <- c("activity","type")
final <- merge(final,activities,by="activity",all.x = TRUE)
final <- final[,c(1,2,69,3:68)]

# 4)Appropriately labels the data set with descriptive variable names
varname <- colnames(final)

varname = gsub("\\()","",varname)
varname = gsub("-std","_Standard_Deviation",varname)
varname = gsub("-mean","_Mean",varname)
varname = gsub("^(t)","Time_",varname)
varname = gsub("^(f)","Frequency_",varname)
varname <- gsub("Acc","Acceleration",varname)
varname = gsub("([Gg]ravity)","Gravity_",varname)
varname = gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body_",varname)
varname = gsub("[Gg]yro","Gyro",varname)
varname = gsub("Mag","_Magnitude",varname)
varname = gsub("Jerk","_Jerk",varname)
varname[1] <- "Activity"
varname[2] <- "Subject"
varname[3] <- "Type"

colnames(final) <- varname

# 5) From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

tidydata <- final %>% group_by(Activity, Subject, Type) %>% summarize_each(funs(mean))
write.table(tidydata, file = "./UCI HAR Dataset/tidydata.txt", row.names = FALSE, col.names = TRUE)

