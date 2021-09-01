/*  */
/* Use this code to pull all content created by users in your SAS Viya 3.x Environment. */
/* {Update to physical path on OS} */
/*  */

/* Data store for permanent data created by this code. You must modify this path to one that */
/* exists on your filesystem. */
libname cleanup '/opt/Data/Data_jrg/content_cleanup';

/* System variables. */
%let BASE_URI=%sysfunc(getoption(SERVICESBASEURL));
%let fullpath=/SAS Content/;
option nonotes;

/* Get a list of model studio projects. */
filename rptFile temp encoding='UTF-8';
proc http method= "GET" oauth_bearer=sas_services out=rptFile
     url = "&BASE_URI/analyticsGateway/projects?limit=9999";
	headers "Accept" = "application/vnd.sas.collection+json";
run;
libname rptFile json;

/* Clean up data. */
data ds_projects (keep=projectID id name createdBy creationTimeStamp modifiedTimeStamp 
			  dataLabel library tableName projectType 
			  rename=(modifiedTimeStamp= lastModifiedDate creationTimeStamp=createdDate projectType=type));
	length projectID $ 70 library $ 24 tableName $ 96;
	set rptFile.items;
	projectID = '/analyticsGateway/projects/'||id;
	library = scan(datalabel, 1, '.');
	tableName = scan(dataLabel, 2, '.');
run;

data cleanup.modelStudioContent;
	set ds_projects;
run;
