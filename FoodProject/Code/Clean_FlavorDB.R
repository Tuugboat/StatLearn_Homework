######################
# Author: Robert Petit
# Desc: Assembles the data from the JSON files scraped from FlavorDB
# into the two formats we need for analysis. 
# _Long is the normal long format for summary tables
# _Wide is an indicator for each molecule. It is *massive* by comparison, but is what we need for PCA/Clustering
######################
Sys.glob(here("Data/FDBRaw/id*.json")) %>% foreach(CurFile=., .combine="rbind") %do% {
  try(jsonlite::fromJSON(txt=CurFile), T)
  #There are files in our folder that are html pages for denied requests. We want to drop those
  #So we trycatch fromJSON, which throws an error associated with no valid tag syntax
  #https://stackoverflow.com/questions/12193779/how-to-write-trycatch-in-r
  tryCatch(
    {
      jsonlite::fromJSON(txt=CurFile) %$%
        PullMolecules(entity_alias, entity_id, molecules) # See definition above
    },
    # Give everything that throws and error an easy to drop row
    # It's easier to just return a known value and drop it later than to not return anything
    error=function(cond){
      c(alias="DROP", ID=0, common_name="DROP", IndVal=0)
    }
  )
} %>%
  as.data.frame %>%
  filter(!ID==0) %>% #Drop the IDs designated in foreach
  
  # Last part of cleaning, IDs should be numbers, IndVal should be 0,1 as numbers
  # And the common names cause errors for being syntactically garbage
  # I shudder to imagine the horror for chemists that results from their wild naming schemes
  mutate(ID = as.numeric(ID), IndVal = as.numeric(IndVal), common_name=make.names(common_name, unique=T)) %T>%
  
  # Write the list in the long format. This is better for summarizing the data later
  # Note Tee pipe before this
  write.csv(here("Data/FoodMols_Long.csv")) %>%
  
  # Write the data in the wide format. This is what we need for clustering and PCA
  pivot_wider(names_from=common_name, values_from=IndVal, values_fill = 0) %T>%
  # Note Tee pipe above
  write.csv(here("Data/FoodMols_Wide.csv")) %>%
  
  #Janking the T pipe
  # They don't like to appear in sequence, so we just pass through the start of the last one.
  {.} %T>%
  
  # If you are reading this line, I am so sorry.
  # I swapped LH for RH operation to get pipes to work appropriatley
  # Since I wanted the tee pipe to skip both select and write.
  { write.csv(select(., alias, ID), here("Data/FoodMols_Labels.csv")) } %>%
  
  #Lastly, drop the labels and write as a sparse matrix
  select(-c(alias, ID)) %>%
  as.matrix() %>%
  as("sparseMatrix") %>%
  writeMM(file=here("Data/FoodMol_Sparse.mtx"))
  
# Quick note here on pivot_wider: when run a few iterations ago, diplyr recommended the values_fn=list to suppress some error
# Probably, this error had to do with the absolutely wild naming of columns (fixed by common_name=make.names() above)
# This was causing some HUGE errors for filling values as 0 when they did not exist.

  
