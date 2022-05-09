The foodproject is in a few parts within /Code/


/Writing/*_writeup.rmd is the most informative file, containing the important code and the written analysis.
/Code/Clean_*.R are two single-function files that generate the clean code assembled from the .json scrapes

/Code/Scrape_*.py is the only non-R file, it does the scraping itself

Other scripts are working and config files that don't largely impact the project. 

In /Data/ are a few things, FDBRaw is the raw scrape of FlavorDB. See Clean_* for a succinct breakdown
FoodMols_* are the datasets actually used in analysis.
_Long and _Wide are the same data, but transformed by pivot_longer() and pivot_wider() appropriatley.
_Labels and _NoDrop were mostly for convenience. 
_CompSummary contains important information for each compound
_Sparse is functionally deprecated
The .RDS files are specific results that have long calculation times so they were manually stored to be called in knitting


The key results for future reference are the PCA_FoodScores.csv and Cluster_FoodMemberships.csv
