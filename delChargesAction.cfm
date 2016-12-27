<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset save=func.SaveNewDelCode(parm)>

<cfoutput>#save.msg#</cfoutput>

