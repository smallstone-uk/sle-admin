<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>

<body>
	<cfset ping = []>
	<cfloop from="1" to="5" index="i">
		<cfset ArrayAppend(ping,{ref=i, title="colour"
		})>
	</cfloop>
	<cfset ping[3].title="blue">
	<cfdump var="#ping#" label="" expand="true">
</body>
</html>