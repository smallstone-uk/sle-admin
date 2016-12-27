<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="1200">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rounds">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.charges=session.rounds.charges>
<cfset charge=rounds.ProcessChargedItems(parm)>
<cfset session.rounds.charges={}>

Charging Complete