<cftry>
<!DOCTYPE html>
<html>
<head>
<title>EPOS</title>
<cfinclude template="sample.html">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/epos.css" rel="stylesheet" type="text/css">
<link href="css/virtualInput.css" rel="stylesheet" type="text/css">
<link href="css/sections.css" rel="stylesheet" type="text/css">
<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>
<script src="../scripts/jquery-barcode.js"></script>
<script src="js/tiles.js"></script>
<script src="js/epos.js"></script>
<script src="js/virtualInput.js"></script>
<script src="js/sections.js"></script>
</head>

<cfobject component="code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset parm.frame = session.epos_frame>
<cfset epos.CleanUpSession()>
<cfset session.cfc_version = epos.GetVersion()>
<cfset epos.LoadDealsIntoSession()>
<cfset epos.LoadNewsStoriesIntoSession()>
<cfset employees = epos.LoadEmployees()>

<cfoutput>
	<body>
		<link rel="stylesheet" href="css/sandbox.css">
		<link rel="stylesheet" href="css/demo-styles.css" />
		<link rel="stylesheet" href="icomoon/style.css" />
		<script>
			$(document).ready(function(e) {
				$.get("ajax/loadHomeScreen.cfm", function(data) {
					$('.home_screen_content').html(data);
					$('*').addClass("disable-select");
				});
			});
		</script>
		<div class="home_screen_content"></div>
	</body>
</cfoutput>
</html>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>