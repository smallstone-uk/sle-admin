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
		ORDER BY eiTimeStamp DESC;		<!---YEAR(eiTimeStamp) DESC, MONTH(eiTimeStamp) DESC, --->
	</cfquery>

	<cfset numSales = 0>
	<cfset numWaste = 0>
	<cfset numNet = 0>
	<cfset valueNet = 0>
	<cfset valueTrade = 0>
	<cfset tot = {count=0,qty=0,net=0,VAT=0,trade=0,profit=0}>
	
		
	<style type="text/css">
		.refund {background-color:#FCC;}
		.normal {background-color:#FFFFFF;}
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
				<th align="right">Qty</th>
				<th align="right">Net</th>
				<th align="right">VAT</th>
				<th align="right">Trade</th>
				<th align="right">Profit</th>
				<th align="right">POR%</th>
			</tr>
			<cfif QSalesItems.recordcount gt 0>
				<cfloop query="QSalesItems">
					<cfset tot.count++>
					<cfset flag = 2 * int(ehMode eq "rfd") - 1>
					<cfif flag eq -1> <!--- reg mode --->
						<cfset item = {qty=eiQty ,net=eiNet * flag, VAT=eiVAT * flag, trade=eiTrade}>
						<cfset class = "normal">
					<cfelse> <!--- refund mode --->
						<cfset item = {qty=0 ,net=eiNet * -1, VAT=eiVAT * -1, trade=eiTrade * -1}>
						<cfset class = "refund">
					</cfif>
					<cfset item.profit = item.net - item.trade>
					<cfset tot.qty += item.qty>
					<cfset tot.net += item.net>
					<cfset tot.VAT += item.VAT>
					<cfset tot.trade += item.trade>
					<cfset tot.profit += item.profit>
					<tr class="#class#">
						<td align="center">#ehID#</td>
						<td align="right">#DateFormat(ehTimestamp,"ddd dd-mmm-yy")#</td>
						<td align="center">#ehMode#</td>
						<td align="center">#ehPayAcct#</td>
						<td align="center">#eiClass#</td>
						<td align="center">#item.qty#</td>
						<td align="right">#DecimalFormat(item.net)#</td>
						<td align="right">#DecimalFormat(item.VAT)#</td>
						<td align="right">#DecimalFormat(item.trade)#</td>
						<td align="right">#DecimalFormat(item.profit)#</td>
						<td align="right"><cfif flag eq -1>#DecimalFormat((item.profit / item.net) * 100)#%<cfelse>-</cfif></td>
					</tr>
				</cfloop>
			<cfelse>
				<tr><td colspan="11">No records found.</td></tr>
			</cfif>
			<tr>
				<th align="left">#tot.count#</th>
				<th colspan="4" align="left">Totals</th>
				<th>#tot.qty#</th>
				<th>#DecimalFormat(tot.net)#</th>
				<th>#DecimalFormat(tot.VAT)#</th>
				<th>#DecimalFormat(tot.trade)#</th>
				<th>#DecimalFormat(tot.profit)#</th>
				<th><cfif tot.net neq 0>#DecimalFormat((tot.profit / tot.net) * 100)#%</cfif></th>
			</tr>
		</table>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

