<cftry>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/stock" name="stock">
	<cfset parm = {}>
	<cfset parm.newWSP = wsp>
	<cfset parm.ourPrice = ourPrice>
	<cfset parm.vatRate = vatRate>
	<cfset parm.packQty = packQty>
	<cfset parm.qtyPacks = qtyPacks>
	<cfset parm.stockID = stockID>
	<cfset parm.datasource = application.site.datasource1>
	<cfset saveWSP = stock.SaveProductWSP(parm)>
	
	<cfoutput>
		{"wsp":"#DecimalFormat(saveWSP.wsp)#", "unitTrade":"#DecimalFormat(saveWSP.unitTrade)#", "tradeTotal":"#DecimalFormat(saveWSP.tradeTotal)#", "por":"#DecimalFormat(saveWSP.POR)#"}
	</cfoutput>

	<cfcatch type="any">
	<cfdump var="#cfcatch#" label="SaveProductWSP" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
	</cfcatch>
</cftry>
