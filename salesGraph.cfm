<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Nominal Reports</title>
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
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

<cfparam name="srchNom" default="">
<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchGrouped" default="">
<cfparam name="srchSunday" default="false">
<cfset srchSunday = val(srchSunday)>
<cfsetting requesttimeout="900">
<cfobject component="code/accounts" name="noms">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset nominals=noms.LoadNominalCodes(parm)>

	<cffunction name="getData" access="public" returntype="query">
		<cfset var DataTable=0>

		<cfif StructKeyExists(form,"srchGrouped")>
			<cfquery datasource="#parm.datasource#" name="DataTable"> 
				SELECT trnDate,-sum(trnAmnt1) AS NetAmount
				FROM tblTrans
				WHERE trnLedger = 'sales'
				AND trnClientRef=0
				AND trnAccountID=1
				AND trnDate>='#form.srchDateFrom#'
				AND trnDate<='#form.srchDateTo#'
				<cfif NOT srchSunday>AND DayOfWeek(trnDate) <> 1</cfif>
				GROUP BY Year(trnDate), Month(trnDate)
			</cfquery>		
		<cfelse>		
			<cfquery datasource="#parm.datasource#" name="DataTable"> 
				SELECT trnDate,-trnAmnt1 AS NetAmount
				FROM tblTrans
				WHERE trnLedger = 'sales'
				AND trnClientRef=0
				AND trnAccountID=1
				AND trnDate>='#form.srchDateFrom#'
				AND trnDate<='#form.srchDateTo#'
				<cfif NOT int(srchSunday)>AND DayOfWeek(trnDate) <> 1</cfif>
			</cfquery>
		</cfif>
		<cfreturn DataTable>
	</cffunction>

<cfoutput>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfif StructKeyExists(form,"fieldnames")>
					<cfset parm.form=form>
					<cfset total=0>
					<!---<cfset nomItems=noms.TranDetails(parm)>--->
					<cfset DataTable=getData()><cfdump var="#DataTable#" label="" expand="false">
					<h1>Sales</h1>
					<cfchart 
						format="jpg"  
						xaxistitle="Date"  
						yaxistitle="Sales"
						chartwidth="1000">
					 
						<cfchartseries type="line"  
							valuecolumn="NetAmount"> 
							<cfloop query="DataTable">
								<cfset total=total+abs(DataTable.NetAmount)>
								<cfchartdata item="#DateFormat(DataTable.trnDate,'ddd dd-mmm')#" value="#int(DataTable.NetAmount)#"> 
							</cfloop>
						</cfchartseries> 
					</cfchart>
					<cfoutput>
						Records: #DataTable.recordcount#<br />
						Days: #DateDiff("d",form.srchDateFrom,form.srchDateTo)#<br />
						Total: &pound;#NumberFormat(total)#<br />
						Average: &pound;#NumberFormat(int(total/DataTable.recordcount))#<br />
					</cfoutput>
				</cfif>
				<form method="post" enctype="multipart/form-data" id="account-form">
				<table>
					<tr>
						<td><b>Date From</b></td>
						<td>
							<input type="text" name="srchDateFrom" value="#srchDateFrom#" class="datepicker" />
						</td>
					</tr>
					<tr>
						<td><b>Date To</b></td>
						<td>
							<input type="text" name="srchDateTo" value="#srchDateTo#" class="datepicker" />
						</td>
					</tr>
					<tr>
						<td><b>Grouped</b></td>
						<td>
							<input type="checkbox" name="srchGrouped" <cfif StructKeyExists(form,"srchGrouped")> checked="checked"</cfif> />
						</td>
					</tr>
					<tr>
						<td><b>Exclude Sundays</b></td>
						<td>
							<input type="checkbox" name="srchSunday" <cfif StructKeyExists(form,"srchSunday")> checked="checked"</cfif> />
						</td>
					</tr>
					<tr>
						<td><input type="submit" name="btnRun" value="Run" /></td>
					</tr>
				</table>
				</form>
			</div>
		</div>
	</body>
</cfoutput>
</html>