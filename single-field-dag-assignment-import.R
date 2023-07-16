############################ DESCRIPTION #############################
# This code is used to merge two fields into a single one to assign 
# data access groups in REDCap. Purpose/utility is discussed further 
# in the "multi-field" comments. Fields are initially exported from
# a REDCap report, then imported back into REDCap.
###### Notes on REDCapR usage 
# redcap_report is used in this code to lighten burden on R/local 
# machine. Same goes for write_oneshot. Reasoning is discussed further
# in "multi-field" and "unique-identified" code.
#####################################################################


#####################################################
# Prep environment
#####################################################
# Clear everything in the R environment.
rm(list = ls())

if(!("REDCapR" %in% installed.packages()[,"Package"])) install.packages("REDCapR")
library(REDCapR)
#####################################################
# Set up the REDCap API connection
#####################################################
# Connect to the REDCap API
# uri: URL for the REDCap API.
uri <- "YOUR API"
# token: REDCap user API token
token <- "YOUR TOKEN"

# Export report - logic is built to only include records with DAG assigned where fields are != NA
  # This is done to avoid the need to put an additional strain on the local machine, which leads to slower proc times

df <- redcap_report(
  uri,
  token,
  report_id = 111111,
  raw_or_label = "raw",
  raw_or_label_headers = "raw",
  export_checkbox_label = FALSE,
  col_types = NULL,
  guess_type = TRUE,
  guess_max = 1000L,
  verbose = TRUE,
  config_options = NULL
)$data



df$redcap_data_access_group <- paste0(df$provider, "-", df$refferer)

#create replacement list, matching joint value to respective DAG name

replacements <- list(
  "1-1"="dagname_subgroup1_1",
  "1-2"="dagname_subgroup1_2",
  "1-3"="dagname_subgroup1_3",
  "2-1"="dagname_subgroup2_1",
  "2-2"="dagname_subgroup2_3",
  "2-3"="dagname_subgroup2_3",
  "3-1"="dagname_subgroup3_1",
  "3-2"="dagname_subgroup3_2",
  "3-3"="dagname_subgroup3_2"
)

#Replace base of DAG list

for (key in names(replacements)) {
  # Find the rows in the data frame where the name matches the key
  rows_to_replace <- which(df$redcap_data_access_group == key)
  
  # Replace the name in those rows with the corresponding value from the replacements list
  df$redcap_data_access_group[rows_to_replace] <- replacements[[key]]
}

redcap_write_oneshot(
  df,
  uri,
  token,
  overwrite_with_blanks = FALSE,
  convert_logical_to_integer = FALSE,
  verbose = TRUE,
  config_options = NULL
)