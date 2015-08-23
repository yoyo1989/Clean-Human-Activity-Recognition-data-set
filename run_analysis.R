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

subject_Train=read.table(file.path(pathIn, "train", "subject_train.txt"))
head(subject_Train)
Train_feature=read.table(file.path(pathIn, "train", "X_train.txt"))
head(Train_feature)
names(Train_feature)
Train_label=read.table(file.path(pathIn, "train", "y_train.txt"))
head(Train_label)
names(Train_label)

subject_Test=read.table(file.path(pathIn, "test", "subject_test.txt"))
head(subject_Test)
Test_feature=read.table(file.path(pathIn, "test", "X_test.txt"))
head(Test_feature)
names(Test_feature)
Test_label=read.table(file.path(pathIn, "test", "y_test.txt"))
head(Test_label)
names(Test_label)

subject_total=rbind(subject_Train, subject_Test)
feature_total=rbind(Train_feature,Test_feature)
label_total=rbind(Train_label,Test_label)

setnames(subject_total, "V1", "subject")
setnames(label_total, "V1", "label")
head(subject_total)
head(label_total)
tail(label_total)


features=read.table(file.path(pathIn, "features.txt"))
colnames(features) <- c("No.","feature")
head(features)
meanStdFeatures <- grep("mean|std", features$feature)

features_meanStd=features[meanStdFeatures,]
head(features_meanStd$feature)
tail(features_meanStd)
feature_total_meanStd=feature_total[,meanStdFeatures]
head(feature_total_meanStd)
tail(feature_total_meanStd)

colnames(feature_total_meanStd) <- features_meanStd$feature
data_total=cbind(subject_total,feature_total_meanStd,label_total)
head(data_total)

activity=read.table(file.path(pathIn, "activity_labels.txt"))
head(activity)
colnames(activity) <- c("label","activity")
head(activity)

data_total_describe=merge(data_total,activity,by="label")
head(data_total_describe)
tail(data_total_describe)

col_names=names(data_total_describe)
col_feature=col_names[3:81]
head(col_feature)
tail(col_feature)

data_total_melt=melt(data_total_describe,id=c("subject","activity"),measure.vars=col_feature)
head(data_total_melt)
tail(data_total_melt)

data_tidy=dcast(data_total_melt,subject+activity~variable,mean)
head(data_tidy)

write.table(data_tidy,file="AveVar.txt",row.name=FALSE)
