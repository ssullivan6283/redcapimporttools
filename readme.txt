Created on: 07/16/2023

------------------------------------------------------------
BEFORE READING/USING: 
------------------------------------------------------------

I highly recommend you review the full documentation for REDCapR (found here: https://ouhscbbmc.github.io/REDCapR/index.html). I am not familiar with package design, and every comment I make on the utility of this package is mostly anecdotal. Please only use this code if you have a general understanding of what the package is doing to avoid potential data overwriting/loss.

I have avoided integrating additional packages to allow for improved speed - I run this code at regular intervals through Windows Task Scheduler on a local machine that is not very powerful.

------------------------------------------------------------
GENERAL OVERVIEW:
------------------------------------------------------------

This code is intended to manage "rolling" imports into REDCap via the API. I have identified a handful of scenarios where this may be useful, each of which is exemplified in the respective code. Different functions from REDCapR have been used to both demonstrate their utility, and deal with system burden/Curl timeouts.

I have also included the .bat code used in conjunction with Task Scheduler. The .bat file is quite remedial, as my familiarity is limited. 

------------------------------------------------------------
DESCRIPTION - multi-field-dag-assignment-big-import:
------------------------------------------------------------

Utility:

Code is used to boot multiple fields into the data_access_group (DAG) field that is used to manage viewing rights within REDCap. This feature may be used on larger REDCap projects, such as a multi-site data collection project, where you wish to restrict viewing rights for individuals per site based on the client's DAG. At this time, REDCap does not offer a auto-DAG assignment feature based on field values, which leads to the need for manual assignment. This can be burdensome on DAG restricted and unrestricted users, as individuals have to spend the time/wait for DAGs to be assigned before viewing the record on the back-end UI of REDCap. 

The goal here is to speed up this process dramatically. The other unique piece of this code (in comparison to the "single-field" variant in this repo) is that we are looking at multiple "secondary" fields to determine the DAG. Your project set-up may have been built with several subfields branching off the primary grouping field. While best practice would be to keep values in these fields unique and merge into a single field on export, this may not be the case (as I ran into when writing this code).

REDCapR Usage:

redcap_read/readcap_write seems particularly useful when working with a large number of records. I noticed timeouts from the "_oneshot" variants when working with roughly 1,000 records, and switched this code over to the current formatting. The data export does take more time, but the batch process has prevent Curl timeouts since its implementation. Batch size can/should be experimented with to fit your needs.

------------------------------------------------------------
DESCRIPTION - unique-identifier-imports_07-16-2023:
------------------------------------------------------------

Utility: 

This code is used to boot two fields into a secondary unique identifier field. This came at the request of folks looking to assign client name to the custom record label AND a secondary unique field, while also avoiding errors if an external party submitted a duplicate client from the survey view.

REDCapR Usage:

redcap_report is used here is to avoid system burden as redcap_read can take quite some time to pull on smaller data sets, and we are able to skip filtering within R itself. Similarly, we use redcap_write_oneshot, as this code runs at an interval of every fifteen minutes. At a light volume of exported records, it is rare for oneshots You will be notified if you are trying to import a duplicate package. I will document the exact error message the next time I encounter it, but it is quite readable.


------------------------------------------------------------
DESCRIPTION - single-field-dag-assignment-import_07-16-2023:
------------------------------------------------------------

Utility:

This is codes purpose is a bit of a hybrid between the unique record label/multi-field DAG code above. Ultimately, the goal here is to merge two fields (as opposed to one primary and multiple sub-fields mentioned in multi-field description) to identify and generate the correct DAG. This example code is only built out for 9 DAGs, but I have it currently assigning for 54 different DAGs (due to a large number of potential permutations), and it runs smoothly.


REDCapR usage:

The use of redcap_report/redcap_write_oneshot are summarized in the other two "REDCapR Usage" sections.


------------------------------------------------------------

If you encounter any issues using this yourself, or if you have any questions, please feel free to reach out to me directly via email (seanpsullivan6283@gmail.com) or message me here. This is my first time really working with GitHub, so forgive me if I am missing any ettique or standardized formatting.