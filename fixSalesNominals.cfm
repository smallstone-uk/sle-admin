<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix EPOS Totals</title>
</head>
<cftry>

<cfsetting requesttimeout="900">
<cfset startDate = '2020-01-01'>
<cfset endDate = '2020-05-31'>
<cfparam name="doFix" default="false">
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT *
	FROM `tblepos_totals`
	WHERE `totAcc` IN ('BANKXFR','ONLINE')
	AND totDate BETWEEN '#startDate#' AND '#endDate#'
	ORDER BY totDate
</cfquery>
<cfset errCount = 0>
<cfset fixCount = 0>
<cfset dupeCount = 0>
<cfset totStruct = {}>
<cfloop query="QTrans">
	<cfset titDate = DateFormat(totDate,'yyyy-mm-dd')>
	<cfif !StructKeyExists(totStruct,titDate)>
		<cfset StructInsert(totStruct,titDate,{})>
	</cfif>
	<cfset keys = StructFind(totStruct,titDate)>
	<cfif !StructKeyExists(keys,totAcc)>
		<cfset StructInsert(keys,totAcc,totValue)>
	<cfelse>
		<cfset dupeCount++>
	</cfif>
</cfloop>
<cfoutput>
	<table width="300">
		<cfset findBank = 0>
		<cfset findOnline = 0>
		<cfloop from="#startDate#" to="#endDate#" index="today">
			<tr>
				<td>
					<cfset today = DateFormat(today,'yyyy-mm-dd')>
					<cfset findDay = StructKeyExists(totStruct,today)>
					<cfif findDay>
						<cfset dayKeys = StructFind(totStruct,today)>
						<cfset findBank = StructKeyExists(dayKeys,"BANKXFR")>
						<cfset findOnline = StructKeyExists(dayKeys,"ONLINE")>
					<cfelse>
						#today# : #findDay#<br />
					</cfif>
					<cfif doFix>
						<cfif !findBank>
							<cfquery name="QFixTran" datasource="#application.site.datasource1#">
								INSERT INTO tblepos_totals 
									(totDate,totAcc,totValue) 
								VALUES 
									('#today#',"BANKXFR",-1)
							</cfquery>fixed bank<br />
							<cfset fixCount++>
						<cfelse>
							found bank<br />
						</cfif>
						<cfif !findOnline>
							<cfquery name="QFixTran" datasource="#application.site.datasource1#">
								INSERT INTO tblepos_totals 
									(totDate,totAcc,totValue) 
								VALUES 
									('#today#',"ONLINE",-1)
							</cfquery>fixed online<br />
							<cfset fixCount++>
						<cfelse>
							found online<br />
						</cfif>
					</cfif>
				</td>
				<td align="right">#LSDateFormat(today,"ddd dd-mmm-yyyy")#</td>
			</tr>
		</cfloop>
	</table>
	#dupeCount# duplicates.<br />
	#errCount# found.<br />
	#fixCount# fixed.<br />
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
<body>
</body>
</html>