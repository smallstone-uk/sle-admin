<!DOCTYPE html>
<html>
<head>
<title>Admin</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
</head>

<cfparam name="type" default="">
<cfparam name="all" default="1">
<cfset run={}>
<cfset run.batch=StructKeyExists(form,"btnRunBatch")>
<cfif run.batch>
	<cfset parm.form=form>
	<cfset type=parm.form.type>
</cfif>
<cfset tabWidth="100%">
<cfset date=DateFormat(Now(),"yy-mm-dd")>
<cfsetting requestTimeOut="300">
<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data">
						<div class="form-header">
							Create Statements
							<span><input type="submit" name="btnRunBatch" value="Run..." /></span>
						</div>
						<div class="form">
							Account Type<br>
							<select name="type">
								<option value="">Any Type</option>
								<option value="M"<cfif type eq "M"> selected="selected"</cfif>>Monthly</option>
								<option value="W"<cfif type eq "W"> selected="selected"</cfif>>Weekly</option>
								<option value="N"<cfif type eq "N"> selected="selected"</cfif>>No Credit</option>
								<option value="C"<cfif type eq "C"> selected="selected"</cfif>>A/c Collect</option>
								<option value="X"<cfif type eq "X"> selected="selected"</cfif>>Special</option>
								<option value="Z"<cfif type eq "Z"> selected="selected"</cfif>>Unknown</option>
							</select>
						</div>
					</form>
					<div class="clear"></div>
				</div>
				<img src="images/loading_2.gif" style="display:none;">
				<cfif run.batch>
					<div id="results"></div>
					<cfset row=0>
					<cfquery name="QClient" datasource="#application.site.datasource1#"> <!--- Get selected client record --->
						SELECT *
						FROM tblClients
						<cfif StructKeyExists(form,"type")><cfif len(parm.form.type)>WHERE cltAccountType='#parm.form.type#'</cfif></cfif>
					</cfquery>
					<cfloop query="QClient">
						<cfset row=row+1>
						<script type="text/javascript">
							var row=#row#;
							var total=#QClient.recordcount#;
							var client=#QClient.cltID#;
							$('##results').load('runBatchStatments.cfm?client='+client+'&row='+row+'&total='+total, function (response, status, xhr) {
								$('##loading').hide();
							});
						</script>
					</cfloop>
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

