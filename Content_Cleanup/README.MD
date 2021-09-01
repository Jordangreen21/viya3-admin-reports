# DIY
The code here will build the data and allow a report similar to the basic one shown below to be created. The execution order is as:

1. pull_Reports
2. pull_modelStudio_projects
3. create_full_inventory

There are depenencies between the code so they must be run in the above order. The output table "cleanup.Content_Inventory" can be loaded into memory to create the report. My basic example report is 

![Example Cleanup Report](/cleanup_report.png "cleanup image")
