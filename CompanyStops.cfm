<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Company Holiday Stops</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
</head>

<cftry>
	<cfquery name="QClients" datasource="#application.site.datasource1#">
		SELECT cltTitle,cltInitial,cltRef,cltName,cltCompanyName,cltEmail,cltDelTel,ordID
		FROM tblOrder INNER JOIN tblClients ON cltID=ordClientID
		WHERE cltAccountType<>'N'
		<!---AND cltCompanyName<>""--->
	</cfquery>
	<table class="tableList">
		<tr>
			<th>Reference</th>
			<th>Name</th>
			<th>Company</th>
			<th>Telephone</th>
			<th>E-Mail</th>
			<th>Stop</th>
			<th>Start</th>		
		</tr>
	<cfoutput query="QClients">
		<cfquery name="QStop" datasource="#application.site.datasource1#">
			SELECT * 
			FROM tblHolidayOrder
			WHERE hoOrderID = #QClients.ordID#
			AND (hoStop > '2014-12-01' OR hoStop IS NULL)
			LIMIT 0,1
		</cfquery>
		<tr>
			<td>#cltRef#</td>
			<td>#cltTitle# #cltInitial# #cltName#</td>
			<td>#cltCompanyName#</td>
			<td>#cltDelTel#</td>
			<td>#cltEmail#</td>
			<td>#LSDateFormat(QStop.hoStop)#</td>
			<td>#LSDateFormat(QStop.hoStart)#</td>		
		</tr>
	</cfoutput>
	</table>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

<body>
</body>
</html>
