<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Round Valuation</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css">
	<link rel="stylesheet" type="text/css" href="css/rounds.css"/>
</head>

<cfobject component="code/functions" name="rnd">

<cffunction name="valueRound" access="public" returntype="struct">
	<cfargument name="args" type="struct" required="yes">
	<cfset var result={}>
	<cfset var dayNo="">
	<cfset var parms={}>
	
	<cfdump var="#args#" label="args" expand="no">
	<cfsetting requesttimeout="900">
	<cfflush interval="200">
	<cfoutput>
		<cfloop list="#args.roundsTicked#" index="roundNo">
			<h1>#roundNo#</h1>
			<cfloop from="1" to="7" index="dayNo">
				<p>Day: #dayNo#</p>
				<cfset parms.dayNo=dayNo>
				<cfset parms.roundNo=roundNo>
				<cfset parms.datasource=application.site.datasource1>
				<cfset parms.chargeAccts=StructKeyExists(form,"chgAcct")>
				<cfset roundData=rnd.LoadRoundData(parms)>
				<cfdump var="#roundData#" label="round #roundNo# day #dayNo#" expand="no">
			</cfloop>
		</cfloop>
	</cfoutput>
	<cfreturn result>
</cffunction>

<cfset roundList={}>
<cfparam name="roundType" default="morning">
<cfparam name="roundsTicked" default="">
<cfif StructKeyExists(form,"btnList")>
	<cfset parms={}>
	<cfset parms.roundType=form.roundType>
	<cfset parms.datasource=application.site.datasource1>
	<cfset roundList=rnd.LoadRoundList(parms)><cfdump var="#roundList#" label="" expand="no">
</cfif>


<cfif StructKeyExists(form,"btnValue")>
	<cfset valueRound(form)>
</cfif>
<cfoutput>
<body>
	<div class="form-wrap">
		<form method="post">
			<div class="form-header">
				Value Rounds
				<span>
					<input type="submit" name="btnList" value="List" />
					<input type="submit" name="btnValue" value="Value" />
				</span>
				<table border="0">
					<tr>
						<td><b>Round Type</b></td>
						<td>
							<select name="roundType">
								<option value="morning"<cfif roundType eq "morning"> selected="selected"</cfif>>Morning</option>
								<option value="evening"<cfif roundType eq "evening"> selected="selected"</cfif>>Evening</option>
								<option value="sunday"<cfif roundType eq "sunday"> selected="selected"</cfif>>Sunday</option>
							</select>
						</td>
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
</body>
</cfoutput>
</html>