<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>News EMail</title>
<link rel="stylesheet" type="text/css" href="css/main.css">
</head>

<body>
<cftry>
	<cfpop server="mail.shortlanesendstore.co.uk" username="#application.company.email_news#" password="sle5946" action="getall" name="QMsgs">
	<!---<cfdump var="#QMsgs#" label="QMsgs" expand="false">--->
	<table class="tableList" width="100%">
	<tr>
		<td>##</td>
		<td>Date</td>
		<td>From</td>
		<td>To</td>
		<td>Subject</td>
	</tr>
	<cfoutput query="QMsgs">
		<tr>
			<td>#messageNumber#</td>
			<td>#Date#</td>
			<td>#From#</td>
			<td>#To#</td>
			<td>#Subject#</td>
		</tr>
		<tr>
			<td colspan="5">#body#</td>
		</tr>
	</cfoutput>
	</table>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>	
</body>
</html>
