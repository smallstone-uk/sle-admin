<!DOCTYPE html>
<html>
<head>
	<title>Transaction Details</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/tabs.css" rel="stylesheet" type="text/css">
	<script src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script src="scripts/autoCenter.js" type="text/javascript"></script>
	<script src="scripts/popup.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			});
	</script>
</head>
<cfsetting requesttimeout="300">
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfobject component="code/accounts" name="accts">
				<cfif StructKeyExists(session,"tranSearch")>
					<cfset search=Duplicate(session.tranSearch)>
					<cfif StructKeyExists(form,"search")>
						<cfset search.row=form.row>
						<cfif StructKeyExists(form,"next")>
							<cfset search.direction="next">
						<cfelseif StructKeyExists(form,"prev")>
							<cfset search.direction="prev">
						<cfelseif StructKeyExists(form,"first")>
							<cfset search.direction="first">
						<cfelseif StructKeyExists(form,"last")>
							<cfset search.direction="last">
						</cfif>
					<cfelseif StructKeyExists(url,"row")>
						<cfset search.row=url.row>
					</cfif>
					<cfif StructKeyExists(form,"fieldnames")>
						<cfset parm={}>
						<cfset parm.form=form>
						<cfset parm.datasource=application.site.datasource1>
						<cfif StructKeyExists(form,"btnAddTran")>
							<cfset newOrder=accts.AddTran(parm)>
						<cfelseif StructKeyExists(form,"btnDelTran")>
							<cfset delOrder=accts.DeleteTran(parm)>
						</cfif>
					</cfif>
					<cfset search.datasource=application.site.datasource1>
					<cfif application.site.showdumps><cfdump var="#search#" label="search" expand="no"></cfif>					
					<cfset initTest.datasource=search.datasource>
					<div class="form-wrap">
						<script type="text/javascript">
							$(function() {
								$("##tabs").tabs();
							});
						</script>
						<!---<cfinclude template="clientHeader.cfm">--->
						<div id="tabs">
							<ul>
								<li><a href="##tab1">Tab 1</a></li>
								<li><a href="##tab2">Tab 2</a></li>
								<li><a href="##tab3">Tab 3</a></li>
							</ul>
							<!---<div id="Orders"><cfinclude template="clientOrder.cfm"></div>
							<div id="Trans"><cfinclude template="clientTrans.cfm"></div>
							<div id="DelItems"><cfinclude template="clientDelItems.cfm"></div>--->
						</div>
					</div>
				<cfelse>
					<cflocation url="tranSearch.cfm">
				</cfif>
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

