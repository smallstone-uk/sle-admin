<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Tran Details</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
</head>

<cfobject component="code/accounts" name="accts">
<cfset parm={}>
<cfset parm.url=url>
<cfset parm.datasource=application.site.datasource1>
<cfset summary=accts.TranDetails(parm)>
<cfdump var="#summary#" label="summary" expand="false">
<body>
<cfoutput>
	<table width="700">
		<tr>
			<td colspan="8">#summary.QTrans.nomCode# #summary.QTrans.nomTitle#</td>
		</tr>
		<tr>
			<th>Code</th>
			<th>Name</th>
			<th>ID</th>
			<th>Ref</th>
			<th>Date</th>
			<th align="right">Amnt1</th>
			<th align="right">Amnt2</th>
			<th align="right">Amount</th>
		</tr>
		<cfloop query="summary.QTrans">
			<tr>
				<td>#accCode#</td>
				<td>#accName#</td>
				<td><a href="">#trnID#</a></td>
				<td>#trnRef#</td>
				<td>#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
				<td align="right">#trnAmnt1#</td>
				<td align="right">#trnAmnt2#</td>
				<td align="right">#niAmount#</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</body>
</html>
