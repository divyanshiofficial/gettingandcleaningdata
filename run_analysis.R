# Read data
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("index", "feature"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("id", "activity"))

# Training data
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$feature)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity_id")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

# Test data
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$feature)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity_id")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

# Merge data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)

# Combine all into one dataset
merged_data <- cbind(subject_data, y_data, x_data)

# Select columns with mean() and std()
mean_std_columns <- grep("mean\\(\\)|std\\(\\)", features$feature, value = TRUE)
selected_data <- merged_data %>%
  select(subject, activity_id, all_of(mean_std_columns))
selected_data <- merge(selected_data, activities, by.x = "activity_id", by.y = "id")
selected_data <- selected_data %>%
  select(-activity_id) %>%
  rename(activity = activity)
names(selected_data) <- gsub("^t", "Time", names(selected_data))
names(selected_data) <- gsub("^f", "Frequency", names(selected_data))
names(selected_data) <- gsub("Acc", "Accelerometer", names(selected_data))
names(selected_data) <- gsub("Gyro", "Gyroscope", names(selected_data))
names(selected_data) <- gsub("Mag", "Magnitude", names(selected_data))
names(selected_data) <- gsub("BodyBody", "Body", names(selected_data))

tidy_data <- selected_data %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), mean), .groups = "drop")

# Save the tidy dataset
write.table(tidy_data, "tidy_data.txt", row.name = FALSE)
