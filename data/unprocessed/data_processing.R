# Data Processing 

# Load Packages-----------------------------------------------------------------

library(tidyverse)
library(tidymodels)

tidymodels_prefer()

# Load Unprocessed Data---------------------------------------------------------

heart_data <- read_csv("data/unprocessed/heart_2020_cleaned.csv")

# Clean Data--------------------------------------------------------------------

heart_data <- heart_data %>% 
  janitor::clean_names() %>% 
  mutate(
    heart_disease = factor(heart_disease, levels = c("No" , "Yes")), 
    smoking = factor(smoking, levels = c("Yes" , "No")), 
    alcohol_drinking = factor(alcohol_drinking, levels = c("No", "Yes")), 
    stroke = factor(stroke, levels = c("No" , "Yes")),
    race = factor(race, levels = c("White", "Black", "Asian", "American Indian/Alaskan Native", "Hispanic", "Other")),  
    sex = factor(sex, levels = c("Female","Male")), 
    diabetic = factor(diabetic, levels = c("Yes","Yes (during pregnancy)" , "No", "No, borderline diabetes")),  
    physical_activity = factor(physical_activity, levels = c("Yes","No")), 
    gen_health = factor(gen_health, levels = c("Excellent", "Very Good", "Good", "Poor"), ordered = TRUE), 
    asthma = factor(asthma, levels = c("Yes","No")), 
    kidney_disease = factor(kidney_disease, levels = c("No","Yes")), 
    skin_cancer = factor(skin_cancer, levels = c("Yes","No")), 
    diff_walking = factor(diff_walking, levels = c("No","Yes")), 
    age_category = factor(age_category, levels = c("18-24", "25-29", "30-34", "35-39","40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70-74", "75-79", "80 or older"), ordered = TRUE)
  )

# Initial Split-----------------------------------------------------------------

heart_data_split <- initial_split(data = heart_data, strata = heart_disease, prop = 0.7)

heart_data_training <- training(heart_data_split)

heart_data_testing <- testing(heart_data_split)

# Resamples---------------------------------------------------------------------

heart_data_resamples <- vfold_cv(data = heart_data_training, v = 5, repeats = 3, strata = heart_disease)

# Save Cleaned Data-------------------------------------------------------------

write_csv(x = heart_data, file = "data/processed/heart_data.csv")

# Save Data Split---------------------------------------------------------------

save(heart_data_training, heart_data_testing, heart_data_split, heart_data_resamples, file = "data/processed/initial_split.rda")

