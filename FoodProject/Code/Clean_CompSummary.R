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
        GetFlavorProfiles(molecules) # See definition above
    },
    # Give everything that throws and error an easy to drop row
    # It's easier to just return a known value and drop it later than to not return anything
    error=function(cond){
      c(common_name=0, fooddb_flavor_profile=0)
    }
  )
} %>%
  filter(!common_name==0) %>%
  group_by(common_name) %>%
  mutate(profile = str_replace_all(fooddb_flavor_profile, "@", ", "), common_name=make.names(common_name)) %>%
  select(common_name, profile) %>%
  write.csv(here("Data/CompSummary.csv"))
