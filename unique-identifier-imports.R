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

#Export report - shows all records, restricted to event/fields of concern ( customrecordlabelfield, firstname, lastname)

df <- redcap_report(
  redcap_uri = uri,
  token,
  report_id = 11111,
  raw_or_label = "raw",
  raw_or_label_headers = "raw",
  verbose = TRUE,
  config_options = NULL)$data

# Subset blank necessary field used in identifier

df <- df[!is.na(df$firstname),]

#change NA to blank

df[is.na(df)] <- ""

# Merge 

df$customrecordlabelfield <- paste0(df$firstname," ",df$lastname)

#import dags
redcap_write_oneshot(
  df,
  uri,
  token,
  overwrite_with_blanks = FALSE,
  convert_logical_to_integer = FALSE,
  verbose = TRUE,
  config_options = NULL)