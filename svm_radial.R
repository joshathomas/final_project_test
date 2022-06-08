# {Support vector machine (radial basis function)] tuning ----

# Load package(s) ----
library(tidyverse)
library(tidymodels)
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

svm_rbf_kernlab_spec <-
  svm_rbf(cost = tune(), rbf_sigma = tune()) %>%
  set_engine('kernlab') %>%
  set_mode('classification')


# set-up tuning grid ----

svm_rbf_params <- hardhat::extract_parameter_set_dials(svm_rbf_kernlab_spec)

# define tuning grid 

svm_rbf_grid <- grid_regular(svm_rbf_params, levels = 5)

# workflow ----

svm_rbf_wflow <- workflow() %>% 
  add_model(svm_rbf_kernlab_spec) %>% 
  add_recipe(svm_recipe)

# Tuning/fitting ----

svm_rbf_tuned <- svm_rbf_wflow %>% 
  tune_grid(resamples = heart_folds,
            grid = svm_rbf_grid, 
            metrics = heart_metrics(),
            control = keep_pred)



# Write out results & workflow

save(svm_rbf_tuned,
     file = "results/svm_rbf_tuned.rds")
