# {Elastic net} tuning----------------------------------------------------------


#Load Packages------------------------------------------------------------------ 

library(tidymodels)
library(tidyverse)
library(doParallel)
library(tictoc)

#Register Processing------------------------------------------------------------ 

# Create a cluster object and then register: 
cl <- makePSOCKcluster(6)
registerDoParallel(cl)

#Handle conflicts--------------------------------------------------------------- 

tidymodels_prefer()

#Load Required Objects ---------------------------------------------------------

load("data/processed/initial_split.rda")
load("recipes/Thomas_base_recipe.rda")
#set.seed-----------------------------------------------------------------------

set.seed(3013)

#Update Recipe------------------------------------------------------------------

# heart_data_recipe <- heart_data_recipe %>%
#   step_interact(heart_diease ~ all_numeric_predictors()^2)

#no step interact in rand forest

#No interctions with random forest

#Define Model-------------------------------------------------------------------

elastic_net_spec <-
  logistic_reg(penalty = tune(), mixture = tune()) %>%
  set_engine('glmnet')

# Workflow----------------------------------------------------------------------

elastic_net_wflow <- 
  workflow() %>% 
  add_recipe(heart_data_recipe) %>% 
  add_model(elastic_net_spec)

# Tuning/fitting ---------------------------------------------------------------

tic("Elastic Net")

#Tune grid----------------------------------------------------------------------

elastic_net_tuned <- elastic_net_wflow %>% 
  tune_grid(resamples = heart_data_resamples, control = keep_pred, metrics = heart_data_metrics)

#Check results 

# autoplot(elastic_net_tuned, metric = "f_means")

#select best

elastic_net_best <- select_best(elastic_net_tuned, metric = "f_meas")


# save runtime info
toc(log = TRUE)

time_log <- tic.log(format = FALSE)

elastic_net_tictoc <- tibble(
  model = time_log[[1]]$msg, 
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  runtime = end_time - start_time
)


# End parallel processing 

stopCluster(cl)

# Save results & workflow

save(elastic_net_tuned, elastic_net_tictoc, file = "model_info/elastic_net_no_interact.rda")

