# Thomas Classification Recipe

# Based on Bank Loan Classification Basic Recipe


# Load Recipes------------------------------------------------------------------

library(tidyverse)
library(tidymodels)

tidymodels_prefer()

# Load data---------------------------------------------------------------------

load("data/processed/initial_split.rda")

#Base Recipe--------------------------------------------------------------------


heart_data_recipe <-recipe(heart_disease ~., data = heart_data_training) %>% 
  step_impute_mean(all_numeric_predictors()) %>% 
  step_impute_mode(all_nominal_predictors()) %>%
  step_YeoJohnson(all_numeric_predictors()) %>%
  step_novel(all_nominal_predictors()) %>% # assigns a unseen factor level to a factor (variable) that already existed, comes up when you fold the data alot, always put this in
  step_dummy(all_nominal_predictors()) %>% #not the supervising variable, because the outcome variable should only be one variable , the computer will do the seperation by itself, its a software specific issue
  step_nzv(all_predictors()) %>%   #stands for near zero variance, we have several variables that are near zero variance that will provide little information
  step_normalize()


#Recipe Check-------------------------------------------------------------------

# heart_data_recipe %>%
#   prep() %>%
#   bake(new_data = NULL) %>%
#   view()

#Set Control Grid---------------------------------------------------------------

#This code allows you to get the metrics of all of our models without saving 
# the workflow individually. 

keep_pred <- control_grid(save_pred = TRUE, save_workflow = TRUE)

#Set Metrics Set----------------------------------------------------------------

heart_data_metrics <- metric_set(
  accuracy, 
  roc_auc, 
  precision,
  sensitivity, 
  f_meas
)

#Save Recipe--------------------------------------------------------------------

save(heart_data_metrics, heart_data_recipe, keep_pred,  file = "recipes/Thomas_base_recipe.rda") 

