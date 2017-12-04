<!DOCTYPE html>
<html>
<head>
<title>Admin</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="css/rounds.css"/>
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
</head>

<cfparam name="roundID" default="">
<cfparam name="type" default="">
<cfobject component="code/functions" name="fnc">
<cfset run={}>
<cfset run.view=StructKeyExists(form,"btnView")>
<cfset run.print=StructKeyExists(form,"btnPrint")>
<cfif run.view>
	<cfset parm={}>
	<cfset parm.form=form>
	<cfset parm.datasource=application.site.datasource1>
	<cfset results=fnc.LoadPrintList(parm)>
	<!---<cfdump var="#results#" label="results" expand="no">--->
</cfif>
<cfif run.print>
	<cfset parm={}>
	<cfset parm.form=form>
	<cfset parm.datasource=application.site.datasource1>
	<!---<cfset print=fnc.PrintStatments(parm)>
	<cfdump var="#print#" label="print" expand="no">--->
</cfif>

<cfset initTest={}>
<cfset initTest.datasource=application.site.datasource1>
<cfset initTest.roundType="morning">
<cfset roundList=fnc.LoadRoundList(initTest)>

<!---<cfdump var="#GetPrinterInfo()#" label="GetPrinterInfo" expand="no">--->

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data">
						<div class="form-header">
							Print Statements
							<span><input type="submit" name="btnView" value="View..." /></span>
						</div>
						<div class="form">
							<table border="0" cellspacing="0">
								<tr>
									<td><b>Account Type</b></td>
									<td>
										<select name="type">
											<option value="">Any Type</option>
											<option value="M"<cfif type eq "M"> selected="selected"</cfif>>Monthly</option>
											<option value="W"<cfif type eq "W"> selected="selected"</cfif>>Weekly</option>
											<option value="N"<cfif type eq "N"> selected="selected"</cfif>>No Credit</option>
											<option value="C"<cfif type eq "C"> selected="selected"</cfif>>A/c Collect</option>
											<option value="X"<cfif type eq "X"> selected="selected"</cfif>>Special</option>
											<option value="Z"<cfif type eq "Z"> selected="selected"</cfif>>Unknown</option>
										</select>
									</td>
								</tr>
								<cfif StructKeyExists(roundList,"rounds")>
									<td valign="top"><b>Rounds</b></td>
									<td colspan="3">
										<select name="roundID">
											<option value="">Any Round</option>
											<cfloop array="#roundList.rounds#" index="item">
												<option value="#item.rndRef#"<cfif roundID eq item.rndRef> checked="checked"</cfif>>#item.rndRef# #item.rndTitle#</option>
											</cfloop>
										</select>
									</td>
								</cfif>
							</table>
						</div>
					</form>
					<div class="clear"></div>
				</div>
				<cfif run.view>
					<form method="post" enctype="multipart/form-data">
						<div><strong>Found: #results.count#</strong><input type="submit" name="btnPrint" value="Print" /></div>
						<cfif ArrayLen(results.list)>
							<cfset row=0>
							<cfloop array="#results.list#" index="i">
								<cfset row=row+1>
								<div class="" style="font-size:10px;">
									<label for="client#i.ID#">
										<input type="checkbox" name="client" value="#i.ID#" id="client#i.ID#" checked="checked">&nbsp;#i.name#
										<div style="color:##666;font-size:9px;padding:5px;">
											<cfif len(i.Addr1)>#i.Addr1#<br></cfif>
											<cfif len(i.Addr2)>#i.Addr2#<br></cfif>
											<cfif len(i.Town)>#i.Town#<br></cfif>
											<cfif len(i.City)>#i.City#<br></cfif>
											<cfif len(i.Postcode)>#i.Postcode#</cfif>
										</div>
									</label>
								</div>
								<cfif row eq 5><div class="clear"></div><cfset row=0></cfif>
							</cfloop>
						</cfif>
					</form>
				</cfif>
				<cfif run.print>
					<div id="results"></div>
					<cfif StructKeyExists(parm.form,"client")>
						<cfset row=0>
						<cfset totalCount=ListLen(parm.form.client,",")>
						<cfloop list="#parm.form.client#" delimiters="," index="i">
							<cfset row=row+1>
							<script type="text/javascript">
								var row=#row#;
								var total=#totalCount#;
								var client=#i#;
								$('##results').load('runBatchPrint.cfm?client='+client+'&row='+row+'&total='+total, function (response, status, xhr) {});
							</script>
						</cfloop>
					</cfif>
					<!---<cfif ArrayLen(print.list)>
						<cfloop array="#print.list#" index="item">
							<div class="">
								ClientID: #item.ID#<br>
								Status: #item.Status#<br>
								<cfif len(item.file)><a href="#item.file#" target="_blank">View Statment</a></cfif>
							</div>
						</cfloop>
					</cfif>--->
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

