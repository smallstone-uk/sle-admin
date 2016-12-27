<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Fix Actuals</title>
</head>

<cfsetting requesttimeout="900">
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT trnID,trnDate,trnDesc, niAmount, niNomID
	FROM tblTrans 
	INNER JOIN tblNomItems ON trnID=niTranID
	WHERE trnType = 'nom' 
	AND trnRef LIKE 'BGC'
	AND niNomID=191
	ORDER BY trnDate,trnDesc
</cfquery>
<cfoutput>
	<table width="500">
	<cfset errCount = 0>
	<cfset fixCount = 0>
	<cfloop query="QTrans">
		<cfset dateStr = ListRest(trnDesc," ")>
		<cfset dayn = ListFirst(dateStr,"/")>
		<cfset mnth = ListLast(dateStr,"/")>
		<cfif dayn gt 0 AND mnth gt 0>
			<cfset actual = CreateDate(Year(trnDate),mnth,dayn)>
			<cfset actual = DateAdd("d",-1,actual)>
			<cfif actual gt trnDate>
				<cfset actual = DateAdd("yyyy",-1,actual)>	
			</cfif>
			<cfset actualStr = LSDateFormat(actual,"dd-mmm-yyyy")>
			<cfquery name="QFixTran" datasource="#application.site.datasource1#">
				UPDATE tblTrans
				SET trnActual = #actual#
				WHERE trnID = #trnID#
			</cfquery>
			<cfset fixCount++>
		<cfelse>
			<cfset errCount++>
			<cfset actualStr = "unknown">
		</cfif>
		<tr>
			<td align="right">#LSDateFormat(trnDate,"ddd dd-mmm-yyyy")#</td>
			<td>&nbsp;</td>
			<td>#trnDesc#</td>
			<td align="right">#niAmount#</td>
			<td align="right">#actualStr#</td>
		</tr>
	</cfloop>
	</table>
	#errCount# errors.<br />
	#fixCount# fixed.<br />
</cfoutput>
<body>
</body>
</html>