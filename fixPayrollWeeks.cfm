<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Payroll</title>
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<style>
	.diffy {background-color:#FF00FF;}
	.fixed {background-color:#09F;}
	.shaded { background-color:#ddd; border:#ff0000;}
	.normal { background-color:#fff; border:#ccc;}
</style>
</head>
<cfobject component="code/payroll2" name="pr2">
<cfparam name="fixData" default="0">
<cfsetting requesttimeout="900">
<cfflush interval="200">

<body>
<cfquery name="QPayroll" datasource="#application.site.datasource1#">
	SELECT phID,phDate,phWeekNo,phEmployee, empFirstName, empLastName
	FROM `tblPayHeader` 
	INNER JOIN tblEmployee ON empID=phEmployee
	WHERE 1
	ORDER BY phDate, phID
</cfquery>

<cfoutput>
	<table class="tableList" border="1" width="600">
		<tr>
			<th align="right">phID</th>
			<th align="right">phDate</th>
			<th align="right">weekNo</th>
			<th align="right">phWeekNo</th>
			<th align="right">phEmployee</th>
			<th align="left">Employee Name</th>
		</tr>
		<cfset errorCount = 0>
		<cfset lastDate = -1>
		<cfset changeCounter = 0>
		<cfloop query="QPayroll">
			<cfset rowClass = "">
			<cfset weekNo = pr2.GetPayrollWeekNumber(phDate)>
			<cfif weekNo neq phWeekNo>
				<cfset rowClass = "diffy">
				<cfset errorCount++>
				<cfif fixData>
					<cfquery name="QFixRec" datasource="#application.site.datasource1#">
						UPDATE tblPayHeader
						SET phWeekNo = #weekNo#
						WHERE phID = #phID#
					</cfquery>
					<cfset rowClass = "fixed">
				</cfif>
			</cfif>
			<cfif lastDate neq phDate>
				<cfset changeCounter++>
			</cfif>
			<cfset dayMod = changeCounter MOD 2>
			<cfif dayMod eq 1>
				<cfset rowStyle = "shaded">
			<cfelse>
				<cfset rowStyle = "normal">
			</cfif>
			<cfset lastDate = phDate>
			<tr class="#rowStyle#">
				<td align="right">#phID#</td>
				<td align="right">#LSDateFormat(phDate,"ddd dd-mmm-yy")#</td>
				<td align="right">#weekNo#</td>
				<td align="right" class="#rowClass#">#phWeekNo#</td>
				<td align="right">#phEmployee#</td>
				<td align="left">#empFirstName# #empLastName#</td>
			</tr>
		</cfloop>
		<tr>
			<td>#errorCount# Errors.</td>
		</tr>
	</table>
</cfoutput>
</body>
</html>