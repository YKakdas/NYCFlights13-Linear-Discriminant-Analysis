## -------------------------------------------------------------------------------------------------------------------------
#install.packages("nycflights13") #Data Sets
#install.packages("parsnip")


## -------------------------------------------------------------------------------------------------------------------------
library(nycflights13) # data set
library(parsnip) # library for LDA


## -------------------------------------------------------------------------------------------------------------------------
flights_filtered <- flights %>%
  mutate(delay = factor(arr_delay > 0, c(TRUE, FALSE),
                        c("Delayed", "On time"))) %>% # Add new column whether the flight delayed or arrived on time
  filter(!is.na(delay)) %>% # Remove NA
  select(delay, hour, minute, dep_delay, carrier, distance) # Select subset of features


## -------------------------------------------------------------------------------------------------------------------------
# Split the data set into training and testing sets
set.seed(1234)
flights_split <- initial_split(flights_filtered)
flights_train <- training(flights_split)
flights_test <- testing(flights_split)


## -------------------------------------------------------------------------------------------------------------------------
lda_spec <- discrim_linear() %>%
  set_mode("classification") %>%
  set_engine("MASS")


## -------------------------------------------------------------------------------------------------------------------------
# Fit model using training data to see how much distance and departure delay features affect the delay
lda_fit <- lda_spec %>%
  fit(delay ~ dep_delay + distance, data = flights_train)


## -------------------------------------------------------------------------------------------------------------------------
# Use model to predict the test data
data <- augment(lda_fit, new_data = flights_test)

# Create confusion matrix from results
confusion_matrix <- conf_mat(data, truth = delay, estimate = .pred_class)

# Print confusion matrix
confusion_matrix

# Calculate the accuracy of the model
accuracy(data, truth = delay, estimate = .pred_class)

# Plot confusion matrix
confusion_matrix %>% autoplot("heatmap")

