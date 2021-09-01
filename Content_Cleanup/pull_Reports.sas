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


/* Macro to pull folder path for input reportURI. */
%macro VA_Report_Path(reportURI);
	filename fldFile temp encoding='UTF-8';
	%let locURI = &reportURI;
	
	proc http method="GET" oauth_bearer=sas_services out=fldFile
	/*  get the folders in which the reportURI is in  */
		url = "&BASE_URI/folders/ancestors?childUri=/reports/reports/&reportURI";
     	headers "Accept" = "application/vnd.sas.content.folder.ancestor+json";
	run;
	libname fldFile json;
	
/* 	generate the path from the returned folders above */
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

/* Execute macro on each reportURI. */
data _null_;
	set ds_rpts;
	call execute('%VA_Report_Path('||id||')');
run;

proc sort data=reportContent out=cleanup.reportContent;
	by ID;
run;
