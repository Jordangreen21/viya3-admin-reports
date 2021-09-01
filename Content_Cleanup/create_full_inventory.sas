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

/* Pull all reports that have been created. */
filename rptFile temp encoding='UTF-8';
proc http method = "GET" oauth_bearer=sas_services OUT = rptFile
     URL = "&BASE_URI/reports/reports?limit=9999";
	HEADERS "Accept" = "application/vnd.sas.collection+json"
			"Accept-Item" = "application/vnd.sas.summary+json";
run;
libname rptFile json;

data ds_rpts (keep=rptID id name createdBy creationTimeStamp modifiedTimeStamp type  
			  rename=(modifiedTimeStamp=lastModifiedDate creationTimeStamp=createdDate));
	length rptID $ 100 id $ 100 rptPath $ 100;
	set rptFile.items;
	rptID = '/reports/reports/'||id;
run;

%macro VA_Report_Path(reportURI);

	/* Create folder path for the report. */
	filename fldFile temp encoding='UTF-8';
	%let locURI = &reportURI;
	proc http method="GET" oauth_bearer=sas_services out=fldFile

		url = "&BASE_URI/folders/ancestors?childUri=/reports/reports/&reportURI";
     	headers "Accept" = "application/vnd.sas.content.folder.ancestor+json";
	run;
	libname fldFile json;
	
	/* Generate the path from the returned folders above */
	proc sql noprint;
		select name into :fldname separated by '/'
		from fldFile.ancestors 
		order by ordinal_ancestors desc;
	quit;

	data tmpsave;
		length cc $ 36;
		set ds_rpts;
		cc = "&locURI";
		if trim(id) = trim(cc) then 
			rptPath=resolve('&fullpath.&fldname.');
		drop cc;
	run;
	
	data reportContent;
		set tmpsave;
		type='Report';
	run;

%mend;

%macro VA_Report_Data(reportURI);
	/* Pull Report Content. */
	filename rcontent temp;
	proc http 
		 oauth_bearer=sas_services	 
		 method="GET"
	     url= "&BASE_URI/reports/reports/&reportUri/content"
		 	out=rcontent;
			headers "Accept"="application/vnd.sas.report.content+json";
	run;
	libname rcontent json;

	%if %sysfunc(exist(rcontent.datasources_casresource)) %then %do;
			%put "Exist";
			/* Create reporting dataset */
			data listdatasources;
				length id $ 100 table $ 32 library $ 32;
				set rcontent.datasources_casresource;

					id = "&reportUri";
					keep id table library;
			run;
		
			/* Merge reporting dataset to the reportList dataset */
			data reportData;
				length table $ 32 library $ 32;
				merge reportData(in=T1) listdatasources(in=T2);
					if T1;
					by ID;
			run;
		%end;
		%else %do;
			%put "DNE";
		/* Merge reporting dataset to the reportList dataset. */
			data reportData;
				length table $ 32 library $ 32;
				set reportData;
				dataLabel = catx('.', library, table);
			run;
		%end;

%mend;

proc sort data=ds_rpts out=reportData;
	by ID;
run;

/* Execute macros on each reportURI. */
data _null_;
	set ds_rpts;
	call execute('%VA_Report_Path('||id||')');
	call execute('%VA_Report_Data('||id||')');
run;

data Content;
	length tableName $ 96 type $ 24;
	set reportData(rename=(table=Tablename)) cleanup.modelstudiocontent;

run;

data cleanup.Content_Inventory;
	set content;
	length uri $ 100;
	uri = coalescec(rptID, projectID);
run;
