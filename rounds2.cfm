<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Rounds</title>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


<cfparam name="roundNo" default="2">
<cfparam name="dayNo" default="#DayofWeek(Now())#">
	<p><a href="index.cfm">Home</a></p>
	<cfquery name="QRound" datasource="#application.site.datasource1#">
		SELECT *
		FROM tblRounds
		WHERE rndRef=#val(roundNo)#
		ORDER BY rndRef
	</cfquery>
<body>
	<cfset currRound=-1>
	<table border="1">
	<cfoutput query="QRound">
		<cfif rndRef neq currRound>
			<tr>
				<td colspan="5"><h1>Round #rndRef# #rndTitle# Round: #roundNo# Day: #dayNo#</h1></td>
			</tr>
			<cfset currRound=rndRef>
		</cfif>
		<cfquery name="QRoundItems" datasource="#application.site.datasource1#">
			SELECT tblRoundItems.*, cltRef,cltName,cltDelHouse,cltStreetCode,stName
			FROM tblRoundItems,tblClients, tblStreets
			WHERE riRoundID=#rndRef#
			AND stRef=cltStreetCode
			AND cltID=riClientID
			ORDER BY riOrder
			<!---LIMIT 0,20;--->
		</cfquery>
		<cfif application.site.showdumps><cfdump var="#QRoundItems#" label="QRoundItems" expand="false"></cfif>
		<cfset streetCode=-1>
		<cfset open=false>
		<cfloop query="QRoundItems">
			<cfif cltStreetCode neq streetCode>
			<cfif open></td></tr></cfif>
				<tr>
					<td><strong>#stName#</strong></td>
				</tr>
				<td>
				<cfset streetCode=cltStreetCode>
			</cfif>
			<cfset parms={}>
			<cfset parms.dayNo=dayNo>
			<cfset parms.clientRef=cltRef>
			<cfset parms.datasource=application.site.datasource1>
			<cfobject component="code/functions" name="fn">
			<cfset myOrder=fn.LoadClientOrderForDay(parms)>
			<cfif application.site.showdumps><cfdump var="#myOrder#" label="myOrder" expand="no"></cfif>
			#cltDelHouse# - 
			<cfloop array="#myOrder.roundItems#" index="paper">
				#paper.title# (#paper.qty#)
			</cfloop>
			<br />
		</cfloop>
		<cfif open></td></tr></cfif>
	</cfoutput>
	</table>
</body>
</html>