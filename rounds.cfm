<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Rounds</title>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


	<p><a href="index.cfm">Home</a></p>
	<cfquery name="QClients" datasource="#application.site.datasource1#">
		SELECT cltStreetCode,cltDelCode,cltDelRound,cltname,cltDelHouse,stName
		FROM tblClients, tblStreets
		WHERE stRef=cltStreetCode
		AND cltAge=0
		ORDER BY cltDelRound, cltRef
	</cfquery>
	<cfif application.site.showdumps><cfdump var="#QClients#" label="QClients" expand="no"></cfif>
<body>
	<cfset currRound=-1>
	<table>
	<cfoutput query="QClients">
		<cfif cltDelRound neq currRound>
			<tr>
				<td colspan="5"><h1>Round #cltDelRound#</h1></td>
			</tr>
			<cfset currRound=cltDelRound>
		</cfif>
		<tr>
			<td>#cltStreetCode#</td>
			<td>#cltDelCode#</td>
			<td>#cltname#</td>
			<td>#cltDelHouse#</td>
			<td>#stName#</td>
		</tr>
	</cfoutput>
	</table>
</body>
</html>