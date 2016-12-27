<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>step</title>
</head>

<body>
	<cfset reconInfo={}>
	<cfset reconInfo.rowCount=903>
	<cfoutput>
		<cfloop from="1" to="#reconInfo.rowCount#" index="i" step="100">
		<!---<cfloop from="1" to="10" step="2" index="i">--->
			counter is #i# to #i+99#<br />
		</cfloop>
		<cfset rec={}>
		<cfset rec.description="30">
		<cfset rec.description2="SMITHS #NumberFormat(Replace(rec.description,"_",""),'000000')#_">
		<cfdump var="#rec#" label="rec" expand="false">
	</cfoutput>
</body>
</html>
