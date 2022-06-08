# {Mars} tuning-----------------------------------------------------------------


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

#No interctions with random forest

#Define Model-------------------------------------------------------------------

mars_earth_spec <-
  mars(prod_degree = tune()) %>%
  set_engine('earth') %>%
  set_mode('classification')


# Workflow----------------------------------------------------------------------

mars_earth_wflow <- 
  workflow() %>% 
  add_recipe(heart_data_recipe) %>% 
  add_model(mars_earth_spec)

# Tuning/fitting ---------------------------------------------------------------

tic("Mars")

#Tune grid----------------------------------------------------------------------

mars_earth_tuned <- mars_earth_wflow %>% 
  tune_grid(resamples = heart_data_resamples, control = keep_pred, metrics = heart_data_metrics)

#Check results 

# autoplot(mars_earth_tuned, metric = "f_means")

#select best

mars_earth_best <- select_best(mars_earth_tuned, metric = "f_meas")


# save runtime info
toc(log = TRUE)

time_log <- tic.log(format = FALSE)

mars_earth_tictoc <- tibble(
  model = time_log[[1]]$msg, 
  start_time = time_log[[1]]$tic,
  end_time = time_log[[1]]$toc,
  runtime = end_time - start_time
)


# End parallel processing 

stopCluster(cl)

# Save results & workflow

save(mars_earth_tuned, mars_earth_tictoc, file = "model_info/mars_earth_no_interact.rda")

