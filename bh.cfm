
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Bank Holidays</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>
<body>
<table class="tableList">
<cfoutput>
	<cfset parm = {}>
	<cfobject component="code/core" name="x">
	<cfloop from="2013" to="2018" index="yr">
		<cfset parm.yyyy = yr>
		<cfset result = x.BankHolidays(parm)>
			<cfloop array="#result#" index="hol">
				<tr><td align="right" colspan="2">#DateFormat(hol,"ddd dd-mmm-yyyy")#</td></tr>
			</cfloop>
	</cfloop>
	<cfloop from="1" to="31" index="i">
		<cfset newDate = CreateDate(2017,05,i)>
		<tr><td>#newDate#</td><td align="right">#x.IsBankHoliday(newDate)#</td></tr>
	</cfloop>
</cfoutput>
</table>
</body>
</html>
