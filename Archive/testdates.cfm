<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>test</title>
</head>

<body>
<cfset calendar={}>
<cfset calendar.FYD=CreateDate(2013,7,1)>
<cfset calendar.FYM=Month(calendar.FYD)>
<cfloop from="1" to="12" index="i">
	<cfset "calendar.mnth#i#.thisDate"=CreateDate(2013,i,1)>
	<cfset "calendar.mnth#i#.currMonth"=DateDiff("m",calendar.FYD,CreateDate(2013,i,1))>
</cfloop>
<cfset calendar.today=now()>
<cfset calendar.currMonth=DateDiff("m",calendar.FYD,calendar.today)>
<cfdump var="#calendar#" label="calendar" expand="true">
</body>
</html>
