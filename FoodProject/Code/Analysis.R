######################
# Author: Robert Petit
# Desc: Carrying out the initial analysis. 
# The algorithms and graphs in this are selectively recreated in the .Rmd associated with writing
######################

# https://stats.stackexchange.com/questions/81396/clustering-algorithms-that-operate-on-sparse-data-matricies


FoodMols_Sparse = readMM(here("Data/FoodMol_Sparse.mtx"))
Cluster_FoodMols = kmeans(FoodMols_Sparse, 5, iter.max=10, nstart=1)
#clusGap(x=FoodMols_Sparse, FUNcluster=kmeans, K.max=50, B=100, nstart=50)
