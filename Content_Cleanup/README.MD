# Data Preparation
The code here will build the data and allow a report similar to the basic one shown below to be created. The execution order is as:

1. pull_Reports
2. pull_modelStudio_projects
3. create_full_inventory

There are depenencies between the code so they must be run in the above order. The output table "cleanup.Content_Inventory" can be loaded into memory to create the report. As you can see in the screenshot below, we are able to view all the content created by each user. Additionally, we can see the data sources that support each artifact they have created.  

![Example Cleanup Report](/cleanup_report.png "cleanup image")

# Recycle Content
In addition to simply being able to view the content created by each user, you can expand access to this report to the individual users to allow them to "clean up" their content. We've all done it... created "Delete Me," "Test," or "...v2" files that just seem to hang around forever. Well, when enough users and time go by, this can cause issues when searching for actual meaningful content that has been created.

I've created a job to assist in the deletion of content by the users. I designed this job to require two steps prior to the actually permanent deletion of content. Instead of deleting the content immediately, the job simply moves the selected content to the users Recycling Bin. 

![Move To Recycle Bin](/Move-to-Recycle.png "recycleBin image")

After the user has moved all the desired content to their Recycling Bin, they can go to SAS Drive and either permanently delete the content or restore individual items back to the location if they did not intend to delete that content.

![Move To Recycle Bin](/Move-to-Recycle.png "recycleBin image")
