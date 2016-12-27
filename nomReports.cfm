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
<cftry>
	<cfparam name="srchNom" default="">
	<cfparam name="srchDateFrom" default="">
	<cfparam name="srchDateTo" default="">
	<cfparam name="srchSunday" default="false">
	<cfset srchSunday = val(srchSunday)>
	<cfsetting requesttimeout="900">
	<cfobject component="code/accounts" name="noms">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<!---<cfset nominals=noms.LoadNominalCodes(parm)>--->
	<cfset loadNoms = noms.LoadNominalCodes(parm)>
	<cfset nominals = loadNoms.codes>
	
		<cffunction name="getData" access="public" returntype="query">
			<cfargument name="QData" type="query" required="yes">
			<cfset var DataTable=0>
			
			<cfquery dbtype="query" name="DataTable"> 
				SELECT trnDate,absAmount
				FROM Qdata
			</cfquery> 
			<cfreturn DataTable>
		</cffunction>
	
	<cfoutput>
		<div id="wrapper">
			<cfinclude template="sleHeader.cfm">
			<div id="content">
				<div id="content-inner">
					<cfif StructKeyExists(form,"fieldnames")>
						<cfset parm.form=form>
						<cfset nomItems=noms.TranDetails(parm)>
						<cfset DataTable=getData(nomItems.QTrans)>
						<h1>#nomItems.nom.code# - #nomItems.nom.title#</h1>
						<cfchart
							format="jpg"  
							xaxistitle="#nomItems.nom.code# - #nomItems.nom.title#"  
							yaxistitle="Sales"
							chartwidth="1000">
						 
							<cfchartseries type="line"  
								valuecolumn="niAmount"> 
								<cfloop query="DataTable">
									<cfchartdata item="#DateFormat(DataTable.trnDate,'ddd dd-mmm')#" value="#int(DataTable.absAmount)#"> 
								</cfloop>
							</cfchartseries> 
						</cfchart>
					</cfif>
					<form method="post" enctype="multipart/form-data" id="account-form">
					<table>
						<tr>
							<td><b>Nominal Account</b></td>
							<td>
								<select name="srchNom" class="select">
									<option value="">Select...</option>
									<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
									<cfloop list="#keys#" index="key">
										<cfset nom=StructFind(nominals,key)>
										<option value="#nom.nomID#"<cfif nom.nomID is srchNom> selected="selected"</cfif>>#nom.nomCode# - #nom.nomTitle#</option>
									</cfloop>
								</select>							
							</td>
						</tr>
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
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

