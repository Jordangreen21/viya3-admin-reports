# Data Preparation
The code here will build the data and allow a report similar to the basic one shown below to be created. The execution order is as:

1. pull_Reports
2. pull_modelStudio_projects
3. create_full_inventory

There are depenencies between the code so they must be run in the above order. The output table "cleanup.Content_Inventory" can be loaded into memory to create the report. As you can see in the screenshot below, we are able to view all the content created by each user. Additionally, we can see the data sources that support each artifact they have created.  

![Example Cleanup Report](/cleanup_report.png "cleanup image")

# View Content

TODO

# Export Content

By creating a [URL Link in Visual Analytics](https://go.documentation.sas.com/doc/en/vacdc/8.5/vareportdata/p0qqtmobryw64un1922tyxumhv4a.htm#p17slquu0nhg4an19rvlurtkgk38), an end user or admin can create a JSON export package directly from a report. The URI of the selected content will be passed into the job and a JSON file will be downloaded to the users local PC. This JSON file can be [re-imported into another environment](https://go.documentation.sas.com/doc/en/calcdc/3.5/calpromotion/n0djzpossyj6rrn1vvi1wfvp2qhp.htm#p1h997oay4wsjon1uby6m99zzhsx).  

| Report Example | Parameter Passing |
| ------------- | ------------- |
![Export Content](/export_content.png "Delete")|![Parameter Example](/Export_Parameters.png "Restore")


# Recycle Content
In addition to simply being able to view the content created by each user, you can expand access to this report to the individual users to allow them to "clean up" their content. We've all done it... created "Delete Me," "Test," or "...v2" files that just seem to hang around forever. Well, when enough users and time go by, this can cause issues when searching for actual meaningful content that has been created.

I've created a job to assist in the deletion of content by the users. I designed this job to require two steps prior to the actual permanent deletion of content. Instead of deleting the content immediately, the job simply moves the selected content to the users Recycling Bin. 

![Move To Recycle Bin](/Move-to-Recycle.png "recycleBin image")

After the user has moved all the desired content to their Recycling Bin, they can go to SAS Drive and either permanently delete the content or restore individual items back to the location if they did not intend to delete that content.
| Delete Example | Restore Example |
| ------------- | ------------- |
![Permanently Delete Content](/recycle_content.png "Delete")|![Restore Content](/restore_content.png "Restore")

