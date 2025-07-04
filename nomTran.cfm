<!DOCTYPE html>
<html>
<head>
	<title>Nominal Transactions</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/tabs.css" rel="stylesheet" type="text/css">
	<link href="css/accounts.css" rel="stylesheet" type="text/css">
	<script src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script src="scripts/checkDates.js"></script>
	<script src="scripts/main.js"></script>
	<script src="scripts/html2csv.js"></script>
	
	<style type="text/css">
		.shaded { background-color:#ddd; border:#ff0000;}
		.normal { background-color:#fff; border:#ccc;}
		@media print {
			.noPrint {display:none;}
			body {
				font-family: serif;
				color: black;
				background-color: white;
			}
			.module {
				border: none;
				border-radius: none;
				box-shadow: none;
				background:#FFF;
				margin: 0;
				padding: 0;
				min-height: 35px;
				height: auto;
				float: left;
				width: 100%;
			}
		}
	</style>
</head>

<cfobject component="code/accounts" name="accts">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfoutput>
	<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfinclude template="nomTranContent.cfm">
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
	</body>
</cfoutput>
</html>
