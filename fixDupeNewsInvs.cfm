<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Fix Dupe News Invoices</title>
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<style>
		.dupe {color:#FF00FF;}
		.normal {color:#000000;}
	</style>
	<link href="css/main3.css" rel="stylesheet" type="text/css">
</head>

	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		});
	</script>

	<cffunction name="DeleteTran" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.status = false>
		
		<cftry>
			<cfquery name="loc.QTran" datasource="#args.datasource#" result="loc.QTranResult">
				<!---SELECT * FROM tblTrans--->
				DELETE FROM tblTrans
				WHERE trnID = #val(args.tranID)#
			</cfquery>
			<cfif loc.QTranResult.recordcount gt 0>
				<cfset loc.result.status = true>
			</cfif>
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<cfflush interval="200">
<cfsetting requesttimeout="900">
<cfparam name="doUpdate" default="false">
<cfparam name="limit" default="1000">
<cfparam name="srchInvDate" default="2022-06-25">

<body>
	<cfoutput>
		<div id="wrapper">
			<cfinclude template="sleHeader.cfm">
			<div id="content">
				<h1>Delete Duplicate Invoices</h1>
				<div id="content-inner">
					<div class="form-wrap">
						<form method="post">
							<div class="form-header">
								Stock Search
								<span><input type="submit" name="btnSearch" value="Search" /></span>
							</div>
							<div class="module">
								<table border="0">
									<tr>
										<td><b>Invoice Date</b></td>
										<td>
											<input type="text" name="srchInvDate" value="#srchInvDate#" class="datepicker" />
										</td>
									</tr>
									<tr>
										<td><b>Options</b></td>
										<td>
											<input type="checkbox" name="srchRun" value="1" />Run Code
										</td>
									</tr>
								</table>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</cfoutput>
	<cfif StructKeyExists(form,"fieldnames")>
		<cftry>
			<cfset parm={}>
			<cfset parm.datasource=application.site.datasource1>
			<cfquery name="QInvoices" datasource="#application.site.datasource1#">
				SELECT cltName,trnID,trnDate,trnRef,trnDesc,trnAmnt1,trnAmnt2
				FROM `tbltrans` 
				INNER JOIN tblClients ON cltID=trnClientID
				WHERE `trnLedger` = 'sales' 
				AND `trnAccountID` = 4 
				AND `trnType` = 'inv' 
				AND `trnDate` = '#srchInvDate#'
				LIMIT #limit#;
			</cfquery>
			<!---<cfdump var="#QInvoices#" label="QInvoices" expand="false">--->
			<cfset lastRef = 0>
			<cfset lastAmount = 0>
			<cfset lastTitle = "">
			<cfset lastUnitSize = "">
			<cfset dupCount = 0>
			<cfset class = "normal">
			<cfset doUpdate = StructKeyExists(form,"srchRun")>
			<cfoutput>
				<h1>#QInvoices.recordcount# records found</h1>
				<table class="tableList" border="1">
					<tr>
						<th align="right">ID</th>
						<th align="right">Date</th>
						<th>Reference</th>
						<th>Name</th>
						<th>Description</th>
						<th align="right">Net</th>
						<th align="right">VAT</th>
						<th>Status</th>
					</tr>
					<cfloop query="QInvoices">
						<cfset msg = "">
						<cfif lastRef neq 0>
							<cfif lastRef eq trnRef AND lastAmount eq trnAmnt1>
								<cfset dupCount++>
								<cfset class = "dupe">
								<cfif doUpdate>
									<cfset parm.tranID = trnID>
									<cfset result = DeleteTran(parm)>
									<cfset msg = "delete record: #trnID# #result.status#">
								</cfif>
							<cfelse>
								<cfset class = "normal">
							</cfif>
						</cfif>
						<tr class="#class#">
							<td align="right">#trnID#</td>
							<td align="right">#DateFormat(trnDate,'ddd dd-mmm-yyyy')#</td>
							<td>#trnRef#</td>
							<td>#cltName#</td>
							<td>#trnDesc#</td>
							<td align="right">#trnAmnt1#</td>
							<td align="right">#trnAmnt2#</td>
							<td>#msg#</td>
						</tr>
						<cfset lastRef = trnRef>
						<cfset lastAmount = trnAmnt1>
						
					</cfloop>
					<tr>
						<th colspan="7">#dupCount# duplicates found.</th>
					</tr>
				</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cfif>
	
</body>
</html>