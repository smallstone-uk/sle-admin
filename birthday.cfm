<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Birthdays</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<body>
	<cfparam name="all" default="false">
	<cfparam name="sort" default="birthdate">
	<cfquery name="QBirthdays" datasource="#application.site.datasource1#">
		SELECT 
			empDOB,empStart,empLeave,MONTH(empDOB )*100 + DAY(empDOB) AS mmdd, 
			empFirstName,empLastName,CONCAT(LPAD(DAY(empDOB),2,'0'),'-',MONTHNAME(empDOB)) AS Birthday, 
			FLOOR(DATEDIFF(CurDate(),empDOB)/365) AS Age,
			IF (LENGTH(empLeave) > 0, ROUND(DATEDIFF(empLeave,empStart)/365,2),
				ROUND(DATEDIFF(CurDate(),empStart)/365,2)) AS Service
		FROM tblemployee
		WHERE 1
		<cfif all eq false>AND empStatus = 'active' </cfif>
		<cfif sort eq 'birthdate'>
			ORDER BY mmdd ASC
		<cfelse>
			ORDER BY empLastName ASC
		</cfif>
	</cfquery>
	<p>all = show all employees<br />
	sort = birthdate = order by birthday<br />
	sort = name = order by last name</p>
	<cfoutput>
		<table class="tableList" border="1">
			<tr>
				<th>Name</th>
				<th>Birthday</th>
				<th>Age</th>
				<th width="100">Start Date</th>
				<th width="100">Leave Date</th>
				<th>Service</th>
			</tr>
			<cfloop query="QBirthdays">
				<tr>
					<td>#empLastName# #empFirstName#</td>
					<td>#Birthday#</td>
					<td align="center">#Age#</td>
					<td>#DateFormat(empStart,'dd-mmm-yyyy')#</td>
					<td>#DateFormat(empLeave,'dd-mmm-yyyy')#</td>
					<td align="center">#Service#</td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="5">#QBirthdays.recordCount# records as at: #DateFormat(Now(),'dd-mmm-yyyy')#</th>
			</tr>
		</table>
	</cfoutput>
</body>
</html>