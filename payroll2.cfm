<!DOCTYPE html>
<html>
<head>
<title>Payroll</title>
<link href="css/payroll2.css" rel="stylesheet" type="text/css">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="common/scripts/common.js"></script>
<script src="scripts/payroll2.js"></script>
<script src="scripts/main.js"></script>
</head>

<cftry>
	<cfoutput>
		<body>
			<div id="wrapper">
				<cfinclude template="sleHeader.cfm">
				<div id="content">
					<div id="content-inner">
						<div class="form-wrap">
							<div class="form-header">
								Payroll
							</div>
							<cfinclude template="payrollControl.cfm">
						</div>
					</div>
				</div>
				<cfinclude template="sleFooter.cfm">
				<div class="global-loading-bar"></div>
			</div>
			<cfif application.site.showdumps>
				<cfdump var="#session#" label="session" expand="no">
				<cfdump var="#application#" label="application" expand="no">
				<cfdump var="#variables#" label="variables" expand="no">
			</cfif>
		</body>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
</html>

