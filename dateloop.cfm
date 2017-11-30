<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Date Loop </title>
</head>

<body>
<cfoutput>
	<cfset startDate = DateAdd("d",1,Now())> 
	<cfset endDate = startDate + 6> 
	<cfloop from="#startDate#" to="#endDate#" index="i" step="1">
		"ord#dateformat(i, 'ddd')#"<br />
	</cfloop>
</cfoutput>
</body>
</html>