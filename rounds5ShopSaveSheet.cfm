<cfsetting requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.Date=Now()>
<cfset parm.datasource=application.site.datasource1>
<cfset accounts=func.LoadShopSaveAccounts(parm)>

<style type="text/css">
	#controls { background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;}
	@media print {
		#controls {display:none}
	}
</style>
<cfoutput>
	<div id="controls">
		<a href="##" id="printBanking" class="button" style="float:left;font-size:13px;">Print</a>
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div style="page-break-before:always;"></div>
	<div id="print-area" style="font-family:Arial, Helvetica, sans-serif;font-size:11px;padding:10px;width:860px;">
		<span style="float: right;margin: 0 30px 0 0;line-height: 23px;font-weight: bold;"></span>
		<h1 style="margin: 0 0 10px 0 !important;">Weekly News Accounts Payments</h1>
		<div style="clear:both;"></div>
		<table border="1" class="tableList" style="font-size:18px;">
			<tr>
				<th width="100" align="center">Account</th>
				<th width="100" align="right">Total</th>
				<th width="200" align="center">Name</th>
				<th width="200" align="center">Printed: #LSDateFormat(Now(),"DD MMM YY")#</th>
			</tr>
			<cfloop array="#accounts#" index="item">
				<cfset total=0>
				<tr>
					<td align="center">#item.cltRef#</td>
					<td align="right">
						<cfif StructKeyExists(item,"order")>
							<cfloop array="#item.order.list#" index="order">
								<cfset total=order.orderPerWeek>
								<cfloop array="#order.items#" index="p">
									<cfquery name="QCheckVouchers" datasource="#parm.datasource#">
										SELECT *
										FROM tblVoucher
										WHERE vchOrderID=#order.OrderID#
										AND vchPubID=#p.PubID#
										AND (vchStart <= '#LSDateFormat(parm.Date,'yyyy-mm-dd')#' AND vchStop >= '#LSDateFormat(parm.Date,'yyyy-mm-dd')#')
									</cfquery>
									<cfset qty=p.qtyMon+p.qtyTue+p.qtyWed+p.qtyThu+p.qtyFri+p.qtySat+p.qtySun>
									<cfif QCheckVouchers.recordcount neq 0>
										<cfset total=total-(p.Price*qty)>
									</cfif>
								</cfloop>
							</cfloop>
							&pound;#DecimalFormat(total+order.DelPerWeek)#
						</cfif>
					</td>
					<td colspan="2">#item.cltName#</td>
				</tr>
			</cfloop>
		</table>
		
		<h2>DO NOT WRITE ALTERATIONS ON THIS SHEET!</h2>
		<p>Any changes must be written clearly on the newspaper enquiry form and put in the office.</p>
	</div>
</cfoutput>
