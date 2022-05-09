#from Nate Hattersly, 2022

# installs the librarian package if you don't have it
if (!("librarian" %in% rownames(utils::installed.packages()))) {
  utils::install.packages("librarian")
}

# put all of the packages that you import here
librarian::shelf( 
  cran_repo = "https://cran.microsoft.com/", # Dallas, TX
  ask = FALSE,
  stats, # https://stackoverflow.com/questions/26935095/r-dplyr-filter-not-masking-base-filter#answer-26935536
  here,
  kableExtra,
  rlang,
  ggthemes,
  tidyverse,
  janitor,
  magrittr,
  mosaic,
  glue,
  lubridate,
  haven,
  snakecase,
  sandwich,
  lmtest,
  gganimate,
  gapminder,
  stargazer,
  snakecase,
  foreach,
  # Here down is project specific
  rjson,
  RColorBrewer,
  cluster,
  LICORS,
  slam,
  tictoc
)

# tell here where we are so we can use it elsewhere
here::i_am("Code/include.R")

#Extensions---------
#To check loaded packages use (.packages())
theme_set(theme_minimal())
source(here("Code/Library_Food.R"))

