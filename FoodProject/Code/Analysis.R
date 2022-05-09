######################
# Author: Robert Petit
# Desc: Carrying out the initial analysis. 
# The algorithms and graphs in this are selectively recreated in the .Rmd associated with writing
######################

# !!!!!!!!!!!!!!! ALL RESULTS ARE WRITTEN TO PCA_FoodScores.csv and Cluster_FoodMemberships.csv !!!!!!!!!!!!!!!!!!!!!!!

set.seed(12062016)

SingleCheck <- jsonlite::fromJSON(here("Data/FDBRaw/id972.json"))

FoodMols_Wide <- read.csv(here("Data/FoodMols_Wide.csv")) %>% select(-X)
FoodMols_NoLab <- FoodMols_Wide %>% select(-alias, -ID)
FoodMols_Sparse <- readMM(here("Data/FoodMol_Sparse.mtx"))
FoodMols_Long <- read.csv(here("Data/FoodMols_Long.csv")) %>% select(-X)
FoodMols_Labels <- read.csv(here("Data/FoodMols_Labels.csv")) %>% select(-X)
CompSum <- read.csv(here("Data/CompSummary.csv")) %>% select(-X)

DivColor <- brewer.pal(n=7, name="PRGn")
QualColor5 <- brewer.pal(n=5, name="Set1")



############################ IMPORTANT VISUALIZATIONS ##########################################

# Some overlap statistics
FoodMols_Long %>% group_by(common_name) %>% summarize(n=n()) %>% arrange(desc(n))

NFoods = FoodMols_Wide %>% summarize(n()) %>% pull(1)
NComps = FoodMols_Long %>% group_by(common_name) %>% summarize(total = n()) %>% summarize(n()) %>% pull(1)



ComplexityTable = FoodMols_Long %>%
  group_by(alias) %>%
  summarize(NMols = n())

MeanComplexity = ComplexityTable %>%
  summarize(mNMols = mean(NMols)) %>%
  pull(1)

MedComplexity = ComplexityTable %>%
  summarize(mNMols = median(NMols)) %>%
  pull(1)

# Food complexity histogram
read.csv(here("Data/FoodMols_Long_NoDrop.csv")) %>% select(-X) %>%
  group_by(alias) %>%
  summarize(NMols = n()) %>%
  arrange(desc(NMols)) %>%
  ggplot(mapping=aes(x=NMols)) +
  geom_histogram(bins=50) +
  labs(
    title="Frequencies of Compound Counts",
    y="Occurences",
    x="Number of Compounds"
  )



# Food complexity
ComplexityTable %>%
  arrange(desc(NMols)) %>%
  {rbind(head(., 4), tail(., 4))} %>%
  ggplot(mapping=aes(x=reorder(alias, NMols), y=NMols, fill=alias)) +
  geom_col() +
  geom_label(aes(label=NMols)) +
  scale_fill_brewer(type="qual", palette=2) +
  coord_flip() +
  theme(legend.position="none") +
  labs(title="Number of Compounds Overview",
       x="Top and Bottom 4 Ingredients",
       y="Num. Compounds")



# Molecular appearances
FoodMols_Long %>%
  group_by(common_name) %>%
  summarize(freq = n()/NFoods) %>%
  arrange(desc(freq)) %>%
  head(5) %>%
  ggplot(mapping=aes(x=reorder(common_name, freq), y=freq, fill=common_name)) +
  geom_col() +
  scale_fill_brewer(type="qual", palette=2) +
  coord_flip() +
  theme(legend.position="none") +
  labs(title="Most Common Compounds",
       x="Compound",
       y="Frequency")

# Generates a flavor palette and food list for each compound
FoodMols_Long %>%
  group_by(common_name) %>%
  summarize(freq = n()/NFoods) %>%
  arrange(desc(freq)) %>%
  head(5) %>%
  left_join(CompSum, by="common_name") %>%
  unique%>%
  left_join(FoodMols_Long, by="common_name") %>%
  sample_n(30) %>%
  select(-freq, -ID) %>%
  group_by(common_name, profile) %>%
  summarize(across(everything(), str_c, collapse=", ")) %>%
  kable(col.names = c("Compound", "Flavor Profile", "Sample of Foods"))

MeanFreq = FoodMols_Long %>%
  group_by(common_name) %>%
  summarize(freq = n()/NFoods) %>%
  summarize(mFreq = mean(freq)) %>%
  pull(1)
MedFreq = FoodMols_Long %>%
  group_by(common_name) %>%
  summarize(freq = n()/NFoods) %>%
  summarize(mFreq = median(freq)) %>%
  pull(1)

#Generates a list of foods that contain our top 5 compounds
FoodMols_Long %>%
  group_by(common_name) %>%
  summarize(freq = n()/NFoods) %>%
  arrange(desc(freq)) %>%
  head(5) %>%
  left_join(FoodMols_Long, by="common_name") %>%
  sample_n(30) %>%
  group_by(common_name) %>%
  select(-freq, -ID) %>%
  group_by(common_name) %>%
  summarize(across(everything(), str_c, collapse=", ")) %>%
  kable(col.names = c("Compound", "Sample of Foods"))




  

# Average number of times a molecule appears
FoodMols_Long %>%
  group_by(common_name) %>%
  summarize(freq = n()) %>%
  summarize(MeanFreq = mean(freq)) %>%
  pull(1)

############################ CLUSTERING RESULTS ##########################################

# tic()
# clusGap(x=FoodMols_NoLab, FUNcluster=kmeans, K.max=50, B=100, nstart=50) %>% write_rds(here("Data/ClusGap.RDS"))
# toc()

GapStat = here("Data/ClusGap.RDS") %>% read_rds()
plot(GapStat, main="Gap Statistic, K: [0,50]")

tic()
FoodCluster = kmeanspp(FoodMols_NoLab, k=14)
toc()


kmeans(FoodMols_NoLab, 14, iter.max=25, nstart=1) %>% write_rds(here("Data/ClusterResult.rds"))

Cluster_FoodMols <- read_rds(here("Data/ClusterResult.rds"))


ClustResult <- FoodMols_Labels %>% mutate(CID = Cluster_FoodMols$cluster)

ClustResult %>%
  group_by(CID) %>%
  summarize(ClusterSize = n()) %>%
  t %>%
  as.data.frame %T>%
  { row.names(.) <- c("Cluster Number", "Cluster Size")} %>%
  kable(col.names=NULL)

ClustResult %>%
  left_join(ComplexityTable, by="alias") %>%
  select(alias, CID, NMols) %>%
  group_by(CID) %>%
  slice_max(order_by = NMols, n=5) %>%
  select(-NMols) %>%
  summarize(across(everything(), str_c, collapse=", "))

############################ PCA RESULTS ##########################################

FoodPC = prcomp(FoodMols_NoLab, rank=10)

FoodPC_Loadings_Summarized <- FoodPC$rotation %>% as.data.frame %>%
  rownames_to_column("common_name") %>%
  left_join(CompSum, by="common_name") %>%
  unique %>%
  pivot_longer(cols=starts_with("PC"),  names_to="PCID", values_to = "PCScale") %>%
  group_by(PCID) %>%
  slice_max(order_by = abs(PCScale), n=10) %>%
  mutate(More=PCScale>0) %>%
  ungroup()

LoadDesc <- FoodPC_Loadings_Summarized %>%
  group_by(PCID, More) %>%
  summarize(across(profile, str_c, collapse=", ")) %>%
  mutate(More = ifelse(More, "More", "Less")) %>%
  pivot_wider(names_from = "More", values_from = "profile") %>%
  mutate(across(everything(), ~ replace(., is.na(.), "None")))

# Convoluted transformations to get the flavor profiles
FoodPC$rotation %>% as.data.frame %>%
  
  #Slap common names to a column and join with the compound summaries
  rownames_to_column("common_name") %>%
  left_join(CompSum, by="common_name") %>%
  unique %>%
  
  #Now we are going to pivot longer so that we can get the important compounds 
  pivot_longer(cols=starts_with("PC"),  names_to="PCID", values_to = "PCScale") %>%
  group_by(PCID) %>%
  # We only care about the first 10 components for each
  slice_max(order_by = abs(PCScale), n=5) %>%
  # Boolean for positive values
  mutate(More=PCScale>0) %>%
  ungroup() %>%
  # Now we split into groups by the components AND their sign
  group_by(PCID, More) %>%
  # Collapse the flavor profiles to a string
  summarize(across(common_name, str_c, collapse=", ")) %>%
  # Convert boolean to a string (for readability in the table)
  mutate(More = ifelse(More, "More", "Less")) %>%
  
  # A final pivot wider to return everything to a more/less format
  # Implicitly, the id columns are the PCIDs
  pivot_wider(names_from = "More", values_from = "common_name") %>%
  # Fill in NAs
  mutate(across(everything(), ~ replace(., is.na(.), "None"))) %>%
  t %>%
  kable(col.names=NULL)

# CRITICAL INTERPERETATION
# Convoluted transformations to get the flavor profiles
LoadingPalette = FoodPC$rotation %>% as.data.frame %>%
  
  #Slap common names to a column and join with the compound summaries
  rownames_to_column("common_name") %>%
  left_join(CompSum, by="common_name") %>%
  unique %>%
  
  #Now we are going to pivot longer so that we can get the important compounds 
  pivot_longer(cols=starts_with("PC"),  names_to="PCID", values_to = "PCScale") %>%
  group_by(PCID) %>%
  # We only care about the first 10 components for each
  slice_max(order_by = abs(PCScale), n=10, with_ties=F) %>%
  # Boolean for positive values
  mutate(More=PCScale>0) %>%
  ungroup() %>%
  # Now we split into groups by the components AND their sign
  group_by(PCID, More) %>%
  # Collapse the flavor profiles to a string
  summarize(across(profile, str_c, collapse=", ")) %>%
  ungroup %>% #prep for rowwise()
  
  # Again with the LHS->RHS->LHS swap for piping
  # worse yet, it's inside of a rowwise()
  # Here we convert the profile to a list, grab unique values, then collapse back to a string
  # unlist is what makes unique() work on the vector
  # There are better ways to do this
  rowwise(c(PCID, More)) %>% mutate(profile=str_c(unique(unlist(str_split(profile, ", "))), collapse=", ")) %>%
  ungroup() %>% #Drop rowwise
  
  # Convert Boolean to a string (for readability in the table)
  mutate(More = ifelse(More, "More.Flavor", "Less.Flavor")) %>%
  
  # A final pivot wider to return everything to a more/less format
  # Implicitly, the id columns are the PCIDs
  pivot_wider(names_from = "More", values_from = "profile") %>%
  # Fill in NAs
  mutate(across(everything(), ~ replace(., is.na(.), "None")))

LoadingFood <- FoodMols_Labels %>% cbind(FoodPC$x) %>%
  select(-ID) %>%
  pivot_longer(cols=starts_with("PC"),  names_to="PCID", values_to = "Score") %>%
  group_by(PCID) %>%
  
  # Grab top and bottom 5 of each
  { rbind(slice_max(., order_by = Score, n=5, with_ties=F), slice_min(., order_by = Score, n=5, with_ties=F)) } %>%
  # Boolean for positive values
  mutate(More=Score>0) %>%
  ungroup() %>%
  # Now we split into groups by the components AND their sign
  group_by(PCID, More) %>%
  # Collapse names
  summarize(across(alias, str_c, collapse=", ")) %>%
  # Convert Boolean to a string (for readability in the table)
  mutate(More = ifelse(More, "More.Food", "Less.Food")) %>%
  
  # A final pivot wider to return everything to a more/less format
  # Implicitly, the id columns are the PCIDs
  pivot_wider(names_from = "More", values_from = "alias") %>%
  # Fill in NAs
  mutate(across(everything(), ~ replace(., is.na(.), "None")))

left_join(LoadingPalette, LoadingFood, by="PCID") %>%
  mutate(PCID = str_remove_all(PCID, "PC")) %>%
  mutate(PCID = as.numeric(PCID)) %>%
  arrange(PCID) %>%
  kable(col.names = c("PC", "Less Flavor", "More Flavor", "Low-scored Foods", "High-scored Foods"))

############################ WRITE RESULTS ##########################################
FoodPC_Loadings_Summarized

FoodMols_Labels %>% cbind(FoodPC$x) %>%
  select(-ID) %>% write.csv(here("Data/PCA_FoodScores.csv"))

ClustResult %>%
  left_join(ComplexityTable, by="alias") %>%
  select(alias, CID) %>%
  write.csv(here("Data/Cluster_FoodMemberships.csv"))
  

  
