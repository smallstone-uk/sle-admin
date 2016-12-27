<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/rounds5" name="rounds">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=rounds.SavePriorityOrdering(parm)>

<cfoutput>#save.msg#</cfoutput>

