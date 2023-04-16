<cftry>
	<cfset callback = true>
	<cfsetting showdebugoutput="no">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset parm.productID = productID>
	<cfset parm.allStock = allStock>
	<cfset parm.form=form>
	<cfset lookup=pstock.LoadProductAndLatestStockItem(parm)>
	<cfif allStock>
		<cfset lastYear = '2013-02-01'>
	<cfelse>
		<cfset lastYear = DateAdd("d",Now(),-365)>
	</cfif>
	<cfset startDate = CreateDate(Year(lastYear),Month(lastYear),1)>

	<cfquery name="QSalesItems" datasource="#parm.datasource#">
		SELECT *
		FROM tblepos_items
		INNER JOIN tblEpos_Header ON ehID = eiParent
		WHERE eiProdID = #val(parm.productID)#
		AND eiTimeStamp >= #startDate# 
		ORDER BY YEAR(eiTimeStamp) DESC, MONTH(eiTimeStamp) DESC, eiTimeStamp DESC;
	</cfquery>
	<!---<cfdump var="#QSalesItems#" label="" expand="false">--->

	<cfset numSales = 0>
	<cfset numWaste = 0>
	<cfset numNet = 0>
	<cfset valueNet = 0>
	<cfset valueTrade = 0>
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
				<th align="right">Date</th>
				<th align="center">Sales</th>
				<th align="center">Waste</th>
				<td>&nbsp;</td>
				<th align="right">Net</th>
				<th align="right">VAT</th>
				<th align="right">Waste</th>
				<td>&nbsp;</td>
				<th align="right">Trade</th>
				<th align="right">Profit</th>
				<th align="right">POR%</th>
			</tr>
			<cfset tot = {count=0,sold=0,waste=0,net=0,VAT=0,trade=0,profit=0}>
			<cfset da = {}>
			<cfset dateKey = 0>
			<cfset totNumSales = 0>
			<cfset totNumWaste = 0>
			<cfset totNumNet = 0>
			<cfset totValueSales = 0>
			<cfset totValueWaste = 0>
			<cfset totValueNet = 0>
			<cfset totTrade = 0>
			<cfset totProfit = 0>
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
			</cfloop>
			
			<cfset dateKeys = ListSort(StructKeyList(da,","),"numeric","desc")>
			<cfloop list="#dateKeys#" index="key">
				<cfset data = StructFind(da,key)>
				<cfif data.valueNet neq 0>
					<cfset POR = data.valueProfit / data.valueNet * 100>
				<cfelse>
					<cfset POR = 0>
				</cfif>
				<!---<cfdump var="#data#" label="#key#" expand="false">--->
				<tr>
					<td align="right">#data.dateTitle#</td>
					<td align="center">#data.numSales#</td>
					<td align="center">#data.numWaste#</td>
					<td>&nbsp;</td>
					<td align="right">&pound;#DecimalFormat(data.valueNet)#</td>
					<td align="right">&pound;#DecimalFormat(data.valueVAT)#</td>
					<td align="right">&pound;#DecimalFormat(data.valueWaste)#</td>
					<td>&nbsp;</td>
					<td align="right">&pound;#DecimalFormat(data.valueTrade)#</td>
					<td align="right">&pound;#DecimalFormat(data.valueProfit)#</td>
					<td align="right">#DecimalFormat(POR)#%</td>
				</tr>
<!---				<cfset profit = data.valueNet - data.valueWaste - data.valueTrade>
				<cfif data.valueNet neq 0>
					<cfset POR = profit / (data.valueNet - data.valueWaste) * 100>
				<cfelse>
					<cfset POR = 0>
				</cfif>
				<cfset totNumSales += data.numSales>
				<cfset totNumWaste += data.numWaste>
				<cfset totNumNet += (data.numSales - data.numWaste)>
				<cfset totValueSales += data.valueNet>
				<cfset totValueWaste += data.valueWaste>
				<cfset totValueNet += data.valueNet - data.valueWaste>
				<cfset totTrade += data.valueTrade>
				<cfset totProfit += profit>
				<tr>
					<td align="right">#data.dateTitle#</td>
					<td align="center">#data.numSales#</td>
					<td align="center">#data.numWaste#</td>
					<td align="center">#data.numSales - data.numWaste#</td>
					<td>&nbsp;</td>
					<td align="right">&pound;#DecimalFormat(data.valueNet)#</td>
					<td align="right">&pound;#DecimalFormat(data.valueWaste)#</td>
					<td align="right">&pound;#DecimalFormat(data.valueNet - data.valueWaste)#</td>
					<td>&nbsp;</td>
					<td align="right">&pound;#DecimalFormat(data.valueTrade)#</td>
					<td align="right">&pound;#DecimalFormat(profit)#</td>
					<td align="right">#DecimalFormat(POR)#%</td>
				</tr>
--->
			</cfloop>
			<tr>
				<th align="left">Totals</th>
				<th align="center">#tot.sold#</th>
				<th align="center">#tot.waste#</th>
				<th></th>
				<th align="right">#DecimalFormat(tot.net)#</th>
				<th align="right">#DecimalFormat(tot.VAT)#</th>
				<th align="right">#DecimalFormat(tot.waste)#</th>
				<th></th>
				<th align="right">#DecimalFormat(tot.trade)#</th>
				<th align="right">#DecimalFormat(tot.profit)#</th>
				<th align="right"><cfif tot.net neq 0>#DecimalFormat((tot.profit / tot.net) * 100)#%</cfif></th>
			</tr>
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

