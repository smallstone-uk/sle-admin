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
	<!---<cfdump var="#lookup#" label="lookup" expand="false">--->
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
				<th align="center">Net</th>
				<td>&nbsp;</td>
				<th align="right">Value</th>
				<th align="right">Waste</th>
				<th align="right">Net</th>
				<td>&nbsp;</td>
				<th align="right">Trade</th>
				<th align="right">Profit</th>
				<th align="right">POR%</th>
			</tr>
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
				<cfset period = LSDateFormat(eiTimeStamp,"yyyymm")>
				<cfif not StructKeyExists(da,period)>
					<cfset StructInsert(da,period,{dateTitle = LSDateFormat(eiTimeStamp,"mmmm yyyy"), valueNet = 0,valueTrade = 0,valueWaste = 0,numSales = 0,numWaste=0})>
				</cfif>
				<cfset mdata = StructFind(da,period)>
				<cfset mdata.valueTrade += eiTrade>
				<cfif ehMode eq 'wst'>
					<cfset mdata.numWaste += abs(eiQty)>
					<cfset mdata.valueWaste += eiNet>
				<cfelse>
					<cfset mdata.numSales += eiQty>
					<cfset mdata.valueNet -= eiNet>
				</cfif>
				<cfset valueNet += eiNet>
				<cfset valueTrade += eiTrade>
				<cfif eiQty gt 0>
					<cfset numSales += eiQty>
				<cfelse>
					<cfset numWaste -= eiQty>
				</cfif>
				<cfset StructUpdate(da,period,mdata)>
			</cfloop>
			<cfset dateKeys = ListSort(StructKeyList(da,","),"numeric","desc")>
			<cfloop list="#dateKeys#" index="key">
				<cfset data = StructFind(da,key)>
				<cfset profit = data.valueNet - data.valueWaste - data.valueTrade>
				<cfset POR = profit / (data.valueNet - data.valueWaste) * 100>
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
			</cfloop>
			<tr>
				<th></th>
				<th align="center">#totNumSales#</th>
				<th align="center">#totNumWaste#</th>
				<th align="center">#totNumNet#</th>
				<td>&nbsp;</td>
				<th align="right">&pound;#DecimalFormat(totValueSales)#</th>
				<th align="right">&pound;#DecimalFormat(totValueWaste)#</th>
				<th align="right">&pound;#DecimalFormat(totValueNet)#</th>
				<td>&nbsp;</td>
				<th align="right">&pound;#DecimalFormat(totTrade)#</th>
				<th align="right">&pound;#DecimalFormat(totProfit)#</th>
				<th align="right"><cfif totValueNet neq 0>#DecimalFormat((totProfit / totValueNet) * 100)#%<cfelse> - </cfif></th>
			</tr>
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

