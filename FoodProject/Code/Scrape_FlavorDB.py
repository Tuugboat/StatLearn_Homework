######################
# Author: Robert Petit
# Desc: Scraping the json downloads from flavordb for later use
######################

# !!!!!!!!IMPORTANT!!!!!!!!!!!
# SOME OF THESE SAVED FILES ARE ERRORS
# About 40 of different indexes are omitted on flavordb so a handful of files
# Output are actually the html for their request denied page saved as a json. 
# I account for this in Clean_FlavorDB.R because it was a little smoother than doing it here

#This one is quite simple since flavorDB provides the JSON files
# in their own url in the format https://cosylab.iiitd.edu.in/flavordb/entities_json?id=972
# Where id=X is a number in range [0,972] so all we need to do is iterate through the numbers and save
# the files in a location.

import requests
from time import sleep

IDMAX = 972
BaseUrl = "https://cosylab.iiitd.edu.in/flavordb/entities_json?id="
for i in range(1, IDMAX+1):
    
    #Parameters for each loop
    FDBUrl = BaseUrl+str(i)
    FileName = "id"+str(i)+".json"
    # Progress updates
    print("Fetching "+str(i)+" as "+FileName+" from "+FDBUrl)
    
    #Actually grabs the thing
    r=requests.get(FDBUrl)

    # Write it straight to a file on request. Easy as possible
    file = open("../Data/FDBRaw/"+FileName, "w")
    file.write(r.text)
    file.close()
    sleep(1) # We add a sleep just so we don't overload the servers. It's less than a thousand requests, but still polite
