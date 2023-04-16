<cftry>
	<cfset callback = true>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.productID = productID>
	<cfset parm.allStock = allStock>
	<cfset parm.form = form>
	<cfset lookup = pstock.LoadProductAndLatestStockItem(parm)>
	<cfif allStock>
		<cfset lastYear = '2013-02-01'>	<!--- beginnning of time --->
	<cfelse>
		<cfset lastYear = DateAdd("d",Now(),-365)>	<!--- exactly one year ago --->
	</cfif>
	<cfset startDate = CreateDate(Year(lastYear),Month(lastYear),1)>	<!--- first of selected month/year --->
	<cfquery name="QSalesItems" datasource="#parm.datasource#">
		SELECT *
		FROM tblepos_items
		INNER JOIN tblEpos_Header ON ehID = eiParent
		WHERE eiProdID = #val(parm.productID)#
		AND eiTimeStamp >= #startDate# 
		ORDER BY eiTimeStamp DESC;		<!---YEAR(eiTimeStamp) DESC, MONTH(eiTimeStamp) DESC, --->
	</cfquery>
	<!---<cfdump var="#QSalesItems#" label="QSalesItems" expand="false">--->
	
	<cfset tot = {count=0,sold=0,waste=0,net=0,VAT=0,trade=0,profit=0}>
	<cfset da = {}>
		
	<style type="text/css">
		.reg {background-color:#FFFFFF;}
		.rfd {background-color:#FCC;}
		.wst {background-color:#FF9;}
	</style>
	
	<cfoutput>
		<table width="100%" class="showTable">
			<tr>
				<th align="left">#lookup.product.prodTitle#</th>
				<th><div id="productID2">#lookup.product.prodID#</div></th>
				<th>Sales from: #DateFormat(startDate,"dd-mmm-yyyy")#</th>
			</tr>
		</table>

		<table class="tableList">
			<tr>
				<th align="center">ID</th>
				<th align="right">Date</th>
				<th align="center">Mode</th>
				<th align="center">Pay Acct</th>
				<th align="right">Class</th>
				<th align="right">Sold</th>
				<th align="right">Waste</th>
				<th align="right">Net</th>
				<th align="right">VAT</th>
				<th align="right">Trade</th>
				<th align="right">Profit</th>
				<th align="right">POR%</th>
			</tr>
			<cfif QSalesItems.recordcount gt 0>
				<cfloop query="QSalesItems">
					<cfset tot.count++>
					<cfset class = ehMode>
					<cfset period = LSDateFormat(eiTimeStamp,"yyyymm")>
					<cfif ehMode eq "reg"> <!--- reg mode --->
						<cfset item = {sold=eiQty, waste=0, net=eiNet * -1, VAT=eiVAT * -1, trade=eiTrade}>
					<cfelseif ehMode eq "wst"> <!--- waste mode --->
						<cfset item = {sold=0, waste=eiQty ,net=0, VAT=0, trade=eiTrade}>
					<cfelse> <!--- refund mode --->
						<cfset item = {sold=eiQty, waste=0, net=eiNet * -1, VAT=eiVAT * -1, trade=eiTrade * -1}>
					</cfif>
					<cfset item.profit = item.net - item.trade>
					<cfset tot.sold += item.sold>
					<cfset tot.waste += item.waste>
					<cfset tot.net += item.net>
					<cfset tot.VAT += item.VAT>
					<cfset tot.trade += item.trade>
					<cfset tot.profit += item.profit>
					<cfif not StructKeyExists(da,period)>
						<cfset StructInsert(da,period,{dateTitle = LSDateFormat(eiTimeStamp,"mmmm yyyy"),valueNet = 0,valueVAT = 0,valueTrade = 0,valueProfit = 0,valueWaste = 0,numSales = 0,numWaste = 0})>
					</cfif>
					<cfset mdata = StructFind(da,period)>
					<cfset mdata.valueNet += item.net>
					<cfset mdata.valueVAT += item.VAT>
					<cfset mdata.valueTrade += item.trade>
					<cfset mdata.valueProfit += item.profit>
					<cfif ehMode eq "wst">
						<cfset mdata.numWaste += item.waste>
						<cfset mdata.valueWaste += item.trade>
					<cfelse>
						<cfset mdata.numSales += item.sold>
					</cfif>
					<cfset StructUpdate(da,period,mdata)>
					<tr class="#class#">
						<td align="center">#ehID#</td>
						<td align="right">#DateFormat(ehTimestamp,"ddd dd-mmm-yy")#</td>
						<td align="center">#ehMode#</td>
						<td align="center">#ehPayAcct#</td>
						<td align="center">#eiClass#</td>
						<td align="center">#item.sold#</td>
						<td align="center">#item.waste#</td>
						<td align="right">#DecimalFormat(item.net)#</td>
						<td align="right">#DecimalFormat(item.VAT)#</td>
						<td align="right">#DecimalFormat(item.trade)#</td>
						<td align="right">#DecimalFormat(item.profit)#</td>
						<td align="right"><cfif item.net neq 0>#DecimalFormat((item.profit / item.net) * 100)#%<cfelse>-</cfif></td>
					</tr>
				</cfloop>
			<cfelse>
				<tr><td colspan="11">No sales records found.</td></tr>
			</cfif>
			<tr>
				<th align="left">#tot.count#</th>
				<th align="left" colspan="4">Totals</th>
				<th align="center">#tot.sold#</th>
				<th align="center">#tot.waste#</th>
				<th align="right">#DecimalFormat(tot.net)#</th>
				<th align="right">#DecimalFormat(tot.VAT)#</th>
				<th align="right">#DecimalFormat(tot.trade)#</th>
				<th align="right">#DecimalFormat(tot.profit)#</th>
				<th align="right"><cfif tot.net neq 0>#DecimalFormat((tot.profit / tot.net) * 100)#%</cfif></th>
			</tr>
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="ProductStock6Items" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

