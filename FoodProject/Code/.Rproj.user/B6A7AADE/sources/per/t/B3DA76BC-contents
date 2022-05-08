######################
# Author: Robert Petit
# Desc: Carrying out the initial analysis. 
# The algorithms and graphs in this are selectively recreated in the .Rmd associated with writing
######################

FoodMols = read.csv(here("Data/FoodMols_Wide.csv")) %>% select(-X)
FoodMols_NoLab = FoodMols %>% select(-c(X, alias, ID)) %>% scale(center=T, scale=F)

FoodMols_Labs = FoodMols %>% select(alias, ID)

# Calc and write the gap stat. This should only be done once, analysis should happen on FoodMols_GapStat.RDS
clusGap(x=FoodMols_NoLab, FUNcluster=kmeans, K.max=50, B=100, nstart=50) %>%
  saveRDS(here("Data/FoodMols_GapStat.RDS"))
