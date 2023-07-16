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
uri <- "YOUR API LINK"
# token: REDCap user API token
token <- "YOUR TOKEN"

# Export form with fields to review, and corresponding event

dailydags <- redcap_read(batch_size = 100L,
                         interbatch_delay = 0.5,
                         continue_on_error = FALSE,
                         redcap_uri = uri,
                         token,
                         records = NULL,
                         records_collapsed = "",
                         fields = NULL,
                         fields_collapsed = "",
                         forms = "start_form",
                         forms_collapsed = "",
                         events = "event1_arm_1",
                         events_collapsed = "",
                         raw_or_label = "raw",
                         raw_or_label_headers = "raw",
                         export_checkbox_label = FALSE,
                         export_survey_fields = FALSE,
                         export_data_access_groups = TRUE,
                         filter_logic = "",
                         datetime_range_begin = as.POSIXct(NA),
                         datetime_range_end = as.POSIXct(NA),
                         col_types = NULL,
                         guess_type = TRUE,
                         guess_max = NULL,
                         http_response_encoding = "UTF-8",
                         locale = readr::default_locale(),
                         verbose = TRUE,
                         config_options = NULL,
                         id_position = 1L
)$data

# Subset NAs

dailydags <- dailydags[is.na(dailydags$redcap_data_access_group),]

# Change NA to blank

dailydags[is.na(dailydags)] <- ""


# DAG changed to main field "-" split secondary field values

dailydags$redcap_data_access_group <- paste0(dailydags$fieldmain, "-", 
                                             dailydags$subfield1, 
                                             dailydags$subfield2, 
                                             dailydags$subfield3)
# Drop fields with only "-"

dailydags<-dailydags[!(dailydags$redcap_data_access_group=="-"),]


# Create replacement list, matching joint value to respective DAG name, as assigned automatically by the system

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

for (key in names(replacements)) {
  # Find the rows in the data frame where the name matches the key
  rows_to_replace <- which(dailydags$redcap_data_access_group == key)
  
  # Replace the name in those rows with the corresponding value from the replacements list
  dailydags$redcap_data_access_group[rows_to_replace] <- replacements[[key]]
}

# Subset, drop all columns but record_id, event_name, dag

dailydags <- dailydags[,c(1:5)]

# Import DAGs
redcap_write(
  dailydags,
  batch_size = 1L,
  interbatch_delay = 0.5,
  continue_on_error = FALSE,
  uri,
  token,
  overwrite_with_blanks = FALSE,
  convert_logical_to_integer = FALSE,
  verbose = TRUE,
  config_options = NULL)