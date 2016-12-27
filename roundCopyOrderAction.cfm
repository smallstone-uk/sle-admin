<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.roundID=roundID>
<cfset parm.roundDay=roundDay>
<cfset parm.days=days>
<cfset copy=rnd.CopyRoundOrder(parm)>

