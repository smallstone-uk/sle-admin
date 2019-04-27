<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Birthdays</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>

<cfquery name="QBirthdays" datasource="#application.site.datasource1#">
	SELECT 
		empDOB,empStart,MONTH(empDOB )*100 + DAY(empDOB) AS mmdd, 
		empFirstName,empLastName,CONCAT(LPAD(DAY(empDOB),2,'0'),'-',MONTHNAME(empDOB)) AS Birthday, 
		FLOOR(DATEDIFF(CurDate(),empDOB)/365) AS Age
	FROM tblemployee
	WHERE empStatus = 'active' 
	ORDER BY mmdd ASC
</cfquery>

<table class="tableList" width="500" border="1">
	<tr>
		<th>Name</th>
		<th>Birthday</th>
		<th>Age</th>
		<th>Start Date</th>
	</tr>
	<cfoutput query="QBirthdays">
	<tr>
		<td>#empFirstName# #empLastName#</td>
		<td>#Birthday#</td>
		<td align="center">#Age#</td>
		<td>#DateFormat(empStart,'dd-mmm-yyyy')#</td>
	</tr>
	</cfoutput>
</table>
</body>
</html>