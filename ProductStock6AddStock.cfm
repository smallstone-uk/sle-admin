
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset result=pstock.AddStockItem(parm)>
<cfoutput>
	#form.barcode#
</cfoutput>