
<cfobject component="code/ProductStock6" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset result=pstock.FindProduct(parm)>
<cfoutput>
	#result.product.prodID#
	<cfif result.product.prodID neq 0>
		<cfquery name="GetListStr" datasource="#parm.datasource#">
			SELECT ctlStockList
			FROM tblControl
			WHERE ctlID = 1
		</cfquery>
		<cfif NOT ListFind(GetListStr.ctlStockList,result.product.prodID,",")>
			<cfif len(GetListStr.ctlStockList)><cfset dl = ","><cfelse><cfset dl = ""></cfif>
			<cfquery name="saveToDB" datasource="#parm.datasource#">
				UPDATE tblControl
				SET	ctlStockList = '#GetListStr.ctlStockList##dl##result.product.prodID#'
				WHERE ctlID = 1
			</cfquery>
		</cfif>
	</cfif>
</cfoutput>
