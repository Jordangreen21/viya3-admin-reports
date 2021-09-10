/* System variables. */
%let BASE_URI=%sysfunc(getoption(SERVICESBASEurl));
%let fullpath=/SAS Content/;
option nonotes;

/* Data store for permanent data created by this code. You must modify this path to one that */
/* exists on your filesystem. */
libname cleanse '/opt/Data/Data_jrg/content_cleanup';

/*****************************************************/
/* Generate JSON string for creating export package. */
/*****************************************************/
filename putJson '~/exportAPI.json';

data test;
	length json $ 1000;
	
	json=cats('{"name":', quote(strip("&contentName")), 
	', "items":[', quote(strip("&contentUri")), 
			'], "options":{"includeRules":true}', '}');

	file putjson;
	put json;
run;

/************************************************/
/************** Create Export Job. **************/
/************************************************/
filename export "~/export.json";

proc http method="post" oauth_bearer=sas_services 
		url="&BASE_URI/transfer/exportJobs" 
		out=export in=putJson CT="application/vnd.sas.transfer.export.request+json";
run;
libname export json;

data _null_;
	set export.links;
	where rel="self";
	call symput ("transferUri",  strip(uri));
run;

/************************************************/
/************ Get Transport Package. ************/
/************************************************/
%macro status_check / minoperator;
	%global packageUri;
    %let stop=0;

    %do %until(&stop=1);
		filename package temp;
		proc http method="get" oauth_bearer=sas_services 
				url="&BASE_URI/&transferUri" 
				out=package CT="application/vnd.sas.transfer.export.job+json";
		run;
		libname package json;
		
		data _null_;
			set package.root;
			call symput ("packageUri", strip(packageUri));
			call symput("state", strip(state));
		run;
		%put "&state";

		%if %eval(&state in completed) %then
			%do;
				%let stop=1;
				%put "COMPLETED";
			%end;

		filename package clear;

		%if &stop ne 1 %then %do;
			data _null_;
				x=sleep(5, 1);
				%put "SLEEPING";
			run;
		%end;
	%end;
%mend;
%status_check;

/************************************************/
/************ Create Export Package. ************/
/************************************************/
filename transfer
	filesrvc 
	parenturi	= "&SYS_JES_JOB_URI"
	name		= '_webout.json'
	contenttype = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
	contentdisp = %tslit(attachment; filename="&contentName..json")
;

proc http method="get" oauth_bearer=sas_services 
		url="&BASE_URI/&packageUri" 
		out=transfer  
		ct="application/json";
        headers "Accept"="application/vnd.sas.transfer.package+json";
run;
quit;
