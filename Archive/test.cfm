<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>test</title>
</head>

<body>
	<cfset itemAmount="-£1,234.69">
	<cfoutput>
		<cfset amount=REReplace(itemAmount,"[^-0-9.]","","all")>
		Amount1 = #itemAmount#<br />
		Amount2 = #amount#<br />
	</cfoutput>
	<hr />
	<cfset loc={}>
	<cfset loc.date1=CreateDate(2014,04,06)>
	<cfset loc.week1=Week(loc.date1)>
	<cfset loc.date2=Now()>
	<cfset loc.diff=DateDiff("w",loc.date1,loc.date2)>
	<cfdump var="#loc#" label="loc" expand="true">
	
	<hr />
	
	<cfset loc2={}>
	<cfset loc2.payDate=CreateDate(2015,1,3)>
	<cfset loc2.weekNoStart = "#Year(Now())#-#DateFormat(application.controls.weekNoStartDate, 'mm-dd')#">
	<cfset loc2.
	<cfset 
</body>
</html>