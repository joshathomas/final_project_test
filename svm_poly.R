# {Support vector machine] tuning ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)
library(tictoc)
library(kernlab)
library(doMC)

# parallel processing
registerDoMC(cores = parallel::detectCores(logical = TRUE))

# handle common conflicts
tidymodels_prefer()

# load required objects ----

load("model_info/intial_setup.rda")

# recipe 

svm_recipe <- recipe(heart_disease ~ bmi,
                     data = heart_train) %>%
  step_novel(all_nominal_predictors()) %>% 
  step_normalize(all_numeric_predictors()) %>% 
  step_dummy(all_nominal_predictors(), one_hot = TRUE) %>% 
  step_zv(all_predictors()) %>% 
  step_nzv(all_predictors())

# Define model ----

svm_poly_kernlab_spec <-
  svm_poly(cost = tune(), degree = tune(), scale_factor = tune()) %>%
  set_engine('kernlab') %>%
  set_mode('classification')


# set-up tuning grid ----

svm_poly_params <- hardhat::extract_parameter_set_dials(svm_poly_kernlab_spec)

# define tuning grid

svm_poly_grid <- grid_regular(svm_poly_params, levels = 5)

# workflow ----

svm_poly_wflow <- workflow() %>% 
  add_model(svm_poly_kernlab_spec) %>% 
  add_recipe(svm_recipe)

# Tuning/fitting ----

svm_poly_tuned <- svm_poly_wflow %>% 
  tune_grid(resamples = heart_folds, 
            grid = svm_poly_grid, 
            metrics = heart_metrics,
            control = keep_pred)




# Write out results & workflow

save(svm_poly_tuned, 
     file = "results/svm_poly_tuned.rda")
