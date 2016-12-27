<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset get=epos.GetBarcode(parm)>
<cfoutput>
@id: #get.ID#
@type: #get.type#
@error: #get.error#
</cfoutput>