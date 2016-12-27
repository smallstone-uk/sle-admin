<!DOCTYPE html>
<html>
<head>
<title>Rollback Invoice</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>

</head>

<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchType" default="">
<cfparam name="srchPayType" default="">
<cfparam name="srchMin" default="">
<cfparam name="resetInvNo" default="">
<cfparam name="runNow" default="false">
<cfset invPath=application.site.dir_invoices>

	<cffunction name="rollbackCheck" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelItems="">
		<cfset var QTrans="">
		<cfset var QDir="">
		
		<cfset result.ready=false>
		<cfset result.pathFound=false>
		<cfset result.status="">
		<cfif IsDate(args.form.srchDateFrom) AND IsDate(args.form.srchDateTo)>
			<cfset result.dateRange=DateDiff("d",args.form.srchDateFrom,args.form.srchDateTo)+1>
		<cfelse><cfset result.dateRange=999></cfif>
		<cfquery name="QDelItems" datasource="#args.datasource#">
			SELECT Count(*) as recCount
			FROM tblDelItems
			WHERE diDate>='#args.form.srchDateFrom#'
			AND diDate<='#args.form.srchDateTo#'
			AND diInvoiceID<>0
		</cfquery>
		<cfset result.delItems=QDelItems.recCount>
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT Count(*) AS recCount
			FROM tblTrans
			WHERE trnDate>='#args.form.srchDateFrom#'
			AND trnDate<='#args.form.srchDateTo#'
			AND trnClientRef>0
			AND (trnType='inv' OR trnType='crn' OR trnMethod='sv')
			AND trnLedger='sales'
			ORDER BY trnRef
		</cfquery>
		<cfset result.invPath="#invPath##mid(args.form.srchDateTo,3,8)#">
		<cfif DirectoryExists(invPath)>
			<cfdirectory action="list" directory="#result.invPath#" name="QDir">
			<cfset result.pathFound=true>
		</cfif>
		<cfset result.invCount=QDir.recordcount>
		<cfset result.Trans=QTrans.recCount>
		<cfif result.dateRange LTE 28 AND result.Trans gt 0 AND result.Trans LTE 400 AND result.pathFound>
			<cfset result.ready=true>			
			<cfset result.status="Ready to run">
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="CheckInvNumbers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var tranRef=0>

		<cfset result.trans=[]>
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnClientRef>0
			AND (trnType='inv' OR trnType='crn')
			AND trnLedger='sales'
			ORDER BY trnRef
		</cfquery>
		<cfif QTrans.recordcount gt 1>
			<cfloop query="QTrans">
				<cfif val(tranRef) gt 0 AND tranRef+1 neq trnRef>
					<cfset ArrayAppend(result.trans,{"Date"=LSDateFormat(trnDate,'dd-mmm-yyyy'),"Ref"='#tranRef+1#',"Client"="","msg"='missing Invoice'})>
				</cfif>
				<cfset ArrayAppend(result.trans,{"Date"=LSDateFormat(trnDate,'dd-mmm-yyyy'),"Ref"=trnRef,"Client"=trnClientRef,"msg"=''})>
				<cfset tranRef=val(trnRef)>
			</cfloop>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="rollback" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelItems="">
		<cfset var QControl="">
		<cfset var QTrans="">
		<cfset var QDir="">
		
		<cftry>
			<cftransaction>
				<cfquery name="QDelItems" datasource="#args.datasource#">
					UPDATE tblDelItems
					SET diInvoiceID=0
					WHERE diDate>='#args.form.srchDateFrom#'
					AND diDate<='#args.form.srchDateTo#'
					AND diInvoiceID<>0
				</cfquery>
				<cfquery name="QTrans" datasource="#args.datasource#">
					DELETE FROM tblTrans
					WHERE trnDate>='#args.form.srchDateFrom#'
					AND trnDate<='#args.form.srchDateTo#'
					AND trnClientRef>0
					AND (trnType='inv' OR trnType='crn' OR trnMethod='sv')
					AND trnLedger='sales'
				</cfquery>
				<cfquery name="QControl" datasource="#args.datasource#">
					UPDATE tblControl
					SET	ctlNextInvNo=#val(args.form.resetInvNo)#
					WHERE ctlID=1
					LIMIT 1;
				</cfquery>
				<cfset result.invPath="#invPath##mid(args.form.srchDateTo,3,8)#\">
				<cfif DirectoryExists(invPath)>
					<cfset result.pathFound=true>
					<cfdirectory action="list" directory="#result.invPath#" name="QDir">
					<cfloop query="QDir">
						<cffile action="delete" file="#result.invPath##name#">
					</cfloop>
					<cfif DirectoryExists(result.invPath)>
						<cfdirectory action="delete" directory="#result.invPath#">
					</cfif>
					<cfif FileExists("#invPath#compiled\#mid(args.form.srchDateTo,3,8)#.pdf")>
						<cffile action="delete" file="#invPath#compiled\#mid(args.form.srchDateTo,3,8)#.pdf">
					</cfif>
				</cfif>
			</cftransaction>
			<cfset result.status="Rollback complete">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="rollback" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">		
			<cfset result.status="Rollback failed">
		</cfcatch>
		</cftry>
		<cfset result.ready=false>
		<cfreturn result>
	</cffunction>

<cfif StructKeyExists(form,"fieldnames")>
	<cfsetting requesttimeout="900">
	<cfflush interval="200">
	<cfset parms={}>
	<cfset parms.datasource=application.site.datasource1>
	<cfset parms.form=form>
	<cfif StructKeyExists(parms.form,"runNow")>
		<cfset result=rollback(parms)>
		<cfset runNow=result.ready>
	<cfelse>
		<cfset refs=CheckInvNumbers(parms)>
		<cfset result=rollbackCheck(parms)>
		<cfset runNow=result.ready>
		<cfoutput>
			<h1>All missing invoice numbers</h1>
			<table width="500">
			<cfloop array="#refs.trans#" index="item">
				<cfif len(item.msg)>
				<tr>
					<td>#item.Date#</td>
					<td>#item.Ref#</td>
					<td>#item.Client#</td>
					<td>#item.msg#</td>
				</tr>
				</cfif>
			</cfloop>
			</table>
			<h1>#result.status#</h1>
		</cfoutput>
	</cfif>
	<cfdump var="#result#" label="result" expand="no">
</cfif>

<cfoutput>#application.site.dir_logs#
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Rollback Invoice Run
							<span><input type="submit" name="btnSearch" value="Start" /></span>
						</div>
						<table border="1">
							<tr>
								<td width="150"><b>Delivery Date From</b></td>
								<td width="150">
									<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
								</td>
								<td width="350"></td>
							</tr>
							<tr>
								<td><b>Delivery Date To</b></td>
								<td>
									<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
								</td>
								<td></td>
							</tr>
							<tr>
								<td><b>Reset Invoice Number</b></td>
								<td>
									<input type="text" name="resetInvNo" value="#resetInvNo#" />
								</td>
								<td></td>
							</tr>
							<cfif runNow>
							<tr>
								<td><b>Status</b></td>
								<td>
									<input type="submit" name="runNow" value="Run Now" />
								</td>
								<td></td>
							</tr>
							</cfif>
							<tr>
								<td colspan="3">
									<p>This routine will rollback an invoice run. <br>Do not use this to rollback invoices that have already been issued
									to customers or that have been included on a VAT return.</p>
								</td>
							</tr>
						</table>
					</form>
				</div>
			</div>
		</div>
	</div>
</body>
</cfoutput>
</html>

