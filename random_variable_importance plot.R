library(vip)
library(ranger)

tree <- ranger(heart_disease ~ ., data = heart_train) 
vip(tree)

#bar plot importance index on x and y 
