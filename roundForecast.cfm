<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Round Forecast</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css">
	<link rel="stylesheet" type="text/css" href="css/rounds.css"/>
</head>

<cfobject component="code/functions" name="rounds">
<cfobject component="code/analysis" name="analysis">

<cffunction name="ValueRound" access="public" returntype="struct">
	<cfargument name="args" type="struct" required="yes">
	<cfset var result={}>
	<cfset var today="">
	<cfset var thisRound="">
	<cfset var QDrops="">
	<cfset var parm={}>
	<cfset var orders="">
	
	<cfdump var="#args#" label="args" expand="no">
	<cfif IsDate(args.form.dateFrom) AND IsDate(args.form.dateTo)>
		<cfoutput>
			<cfloop from="#LSDateFormat(args.form.dateFrom,'dd-mmm-yyyy')#" to="#LSDateFormat(args.form.dateTo,'dd-mmm-yyyy')#" index="today">
				<h2>#DateFormat(today,"ddd dd-mmm-yyyy")#</h2>
				<cfloop list="#args.form.roundsTicked#" index="thisRound">
					<h3>#thisRound#</h3>
					<cfquery name="QDrops" datasource="#args.datasource#">
						SELECT riID,riItemNote,cltID,cltRef,cltName,cltDelHouse,cltDelCode,cltStreetCode,stName
						FROM tblRoundItems,tblClients, tblStreets
						WHERE riRoundRef=#thisRound#
						AND stRef=cltStreetCode
						AND cltID=riClientID
						AND cltAccountType<>"N"
						ORDER BY riOrder
						LIMIT 0,10;
					</cfquery>
					<cfdump var="#QDrops#" label="QDrops" expand="no">
					<cfloop query="QDrops">
						<cfset parm=args>
						<cfset parm.clientID=cltID>
						<cfset parm.delCode=cltDelCode>
						<cfset orders=analysis.LoadOrders(parm)>
						<cfdump var="#orders#" label="order #currentrow#" expand="no">
					</cfloop>
				</cfloop>
			</cfloop>
		</cfoutput>
	</cfif>
	<cfreturn result>
</cffunction>

<cfsetting requesttimeout="900">
<cfflush interval="200">
<cfset NextMonth=DateAdd("m",1,now())>	<!--- get a date in next month --->
<cfset fromDate=CreateDate(year(NextMonth),Month(NextMonth),1)> <!--- create first day of next month --->
<cfset NextMonth=DateAdd("m",1,fromDate)> <!--- get first day of month after next --->
<cfset NextMonth=DateAdd("d",-1,NextMonth)> <!--- step back one day to last day of next month --->
<cfset toDate=CreateDate(year(NextMonth),Month(NextMonth),Day(NextMonth))> <!--- create last day of next month --->

<cfparam name="dateFrom" default="#fromDate#">
<cfparam name="dateTo" default="#toDate#">
<cfparam name="roundType" default="">
<cfparam name="roundsTicked" default="">
<cfset parms={}>
<cfset parms.roundType="">
<cfset parms.datasource=application.site.datasource1>
<cfset roundList=rounds.LoadRoundList(parms)>

<cfoutput>
<body>
	<div class="form-wrap">
		<form method="post">
			<div class="form-header">
				<h1>Round Forecast</h1>
				<span>
					<input type="submit" name="btnView" value="View Forecast" />
				</span>
				<table border="0">
					<tr>
						<td>Date From</td>
						<td><input type="text" name="dateFrom" size="15" value="#LSDateFormat(dateFrom,'dd/mm/yyyy')#" /></td>
					</tr>
					<tr>
						<td>Date To</td>
						<td><input type="text" name="dateTo" size="15" value="#LSDateFormat(dateTo,'dd/mm/yyyy')#" /></td>
					</tr>
				</table>
			</div>
			<div>
				<cfif StructKeyExists(roundList,"rounds")>
					<table>
						<tr>
							<td valign="top"><b>Rounds</b></td>
							<td colspan="3">
								<cfloop array="#roundList.rounds#" index="item">
									<cfset checked=ListFind(roundsTicked,item.rndRef,",")>
									<label><input type="checkbox" name="roundsTicked" value="#item.rndRef#" <cfif checked> checked="checked"</cfif> />
										#item.rndRef# #item.rndTitle#</label>
								</cfloop>
							</td>
						</tr>
					</table>
				</cfif>
			</div>
		</form>
	</div>
	
	<div class="data">
		<cfif StructKeyExists(form,"btnView")>
			<cfset parms={}>
			<cfset parms.datasource=application.site.datasource1>
			<cfset parms.form=form>
			<cfset ValueRound(parms)>
		</cfif>
	</div>
</body>
</cfoutput>
</html>