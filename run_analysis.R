library(plyr)
library(reshape2)

if (!file.exists("UCI HAR Dataset")) {
        f <- "Dataset.zip"
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(url, destfile = f, method = "curl")
        dateDownloaded <- date()
        unzip(f)
}

pathIn <- file.path("UCI HAR Dataset")
list.files(pathIn, recursive = TRUE)

#read in train data
subject_Train=read.table(file.path(pathIn, "train", "subject_train.txt"))
head(subject_Train)
names(subject_Train)
Train_feature=read.table(file.path(pathIn, "train", "X_train.txt"))
head(Train_feature)
names(Train_feature)
Train_label=read.table(file.path(pathIn, "train", "y_train.txt"))
head(Train_label)
names(Train_label)

#read in test data
subject_Test=read.table(file.path(pathIn, "test", "subject_test.txt"))
head(subject_Test)
Test_feature=read.table(file.path(pathIn, "test", "X_test.txt"))
head(Test_feature)
Test_label=read.table(file.path(pathIn, "test", "y_test.txt"))
head(Test_label)

#merges the training and the test sets to create one data set.
subject_total=rbind(subject_Train, subject_Test)
feature_total=rbind(Train_feature,Test_feature)
label_total=rbind(Train_label,Test_label)
setnames(subject_total, "V1", "subject")
setnames(label_total, "V1", "label")
head(subject_total)
head(label_total)

#read in features
features=read.table(file.path(pathIn, "features.txt"))
colnames(features) <- c("No.","feature")
head(features)

#extracts only the measurements on the mean and standard deviation for each measurement.
meanStdFeatures <- grep("mean|std", features$feature)
features_meanStd=features[meanStdFeatures,]
head(features_meanStd$feature)
feature_total_meanStd=feature_total[,meanStdFeatures]
head(feature_total_meanStd)

#appropriately labels the data set with descriptive variable names.
colnames(feature_total_meanStd) <- features_meanStd$feature
head(feature_total_meanStd)

#read in activity labels
activity=read.table(file.path(pathIn, "activity_labels.txt"))
head(activity)
colnames(activity) <- c("label","activity")
head(activity)

#uses descriptive activity names to name the activities in the data set
data_total=cbind(subject_total,feature_total_meanStd,label_total)
data_total_describe=merge(data_total,activity,by="label")
head(data_total_describe)

##a tidy data set with the average of each variable for each activity and each subject.
#select features
col_names=names(data_total_describe)
col_feature=col_names[3:81]
head(col_feature)
#reshape data
data_total_melt=melt(data_total_describe,id=c("subject","activity"),measure.vars=col_feature)
head(data_total_melt)
data_tidy=dcast(data_total_melt,subject+activity~variable,mean)
head(data_tidy)
#write the tidy data
write.table(data_tidy,file="AveVar.txt",row.name=FALSE)
