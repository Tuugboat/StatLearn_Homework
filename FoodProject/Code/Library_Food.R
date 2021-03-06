######################
# Author: Robert Petit
# Desc: Some functions for tidily working with this data
######################

PullMolecules <- function(Name, eID, MolList) {
  # This runs through a list of provided molecules and returns
  # a dataframe in the form (alias, ID, common_name, IndVal)
  # The expected format for lists comes directly from the json scraped from FlavorDB
  # 
  MolList %>%
    select(common_name) %>%
    mutate(alias=Name, ID=eID) %>%
    select(alias, ID, common_name) %>%
    return
} 

# This function needs to be written. 
# We want to loop through every molecule in every food
# in the list and assemble information in the format
# (common_name, flavorprofile) with the end goal of using it in out analysis
# This could probably be moved to a different file.
GetFlavorProfiles <- function(MolList) {
  MolList %>%
    select(common_name, fooddb_flavor_profile) %>%
    return
}
