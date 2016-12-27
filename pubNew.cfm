<!DOCTYPE html>
<html>
<head>
<title>New Publication</title>
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

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data">
						<div class="form-header">
							New Publication
							<span><div id="loading"></div></span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0">
							<tr>
								<td width="150">Title</td>
								<td><input type="text" name="pubTitle" value=""></td>
							</tr>
							<tr>
								<td>Ref</td>
								<td><input type="text" name="pubRef" value="" placeholder="(If known)"></td>
							</tr>
							<tr>
								<td>Barcode</td>
								<td><input type="text" name="pubBarcode" value="" placeholder="(If known)"></td>
							</tr>
							<tr>
								<td width="150">Supplier</td>
								<td>
									<select name="pubWholesaler" data-placeholder="Select..." id="Supplier">
										<option value=""></option>
										<option value="WHS">Smiths</option>
										<option value="DASH">Dash</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Group</td>
								<td>
									<select name="pubGroup" data-placeholder="Select..." id="Group">
										<option value=""></option>
										<option value="News">News</option>
										<option value="Magazine">Magazine</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Type</td>
								<td>
									<select name="pubType" data-placeholder="Select..." id="Type">
										<option value=""></option>
										<option value="Morning">Morning</option>
										<option value="Saturday">Saturday</option>
										<option value="Sunday">Sunday</option>
										<option value="Weekly">Weekly</option>
										<option value="Fortnightly">Fortnightly</option>
										<option value="Monthly">Monthly</option>
										<option value="Bi-Monthly">Bi-Monthly</option>
										<option value="Three-Weekly">Three-Weekly</option>
										<option value="Four-Weekly">Four-Weekly</option>
										<option value="Quarterly">Quarterly</option>
										<option value="Yearly">Yearly</option>
										<option value="One Shots">One Shots</option>
										<option value="Part Works">Part Works</option>
									</select>
								</td>
							</tr>
						</table>
						<input type="submit" name="btnNew" id="New" value="Save" />
					</form>
				</div>
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
<script type="text/javascript">
	$("#Supplier").chosen({width: "150px",disable_search_threshold: 10});
	$("#Group").chosen({width: "150px",disable_search_threshold: 10});
	$("#Type").chosen({width: "200px"});
</script>
</html>

