<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.clientID=cltID>
<cfset parm.rec.cltID=cltID>
<cfset clientInfo.info=cust.LoadClientByID(parm)>
<cfset parm.rec.cltRef=clientInfo.info[1].cltRef>
<cfset parm.orderID=oiOrderID>
<cfset custOrder=cust.LoadClientOrder(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.selectAll').click(function(event) {   
			var id=$(this).attr("value");
			if(this.checked) {
				$('input.selectPub'+id).each(function() {this.checked = true;});
			} else {
				$('input.selectPub'+id).each(function() {this.checked = false;});
			}
		});
		$('.editPubs').click(function(e) { 
			var id=$(this).attr("data-id");
			OpenEdit(id);
			e.preventDefault();
		});
	});
</script>
<cfoutput>
<cfloop array="#custOrder.order.list#" index="order">
	<table border="1" class="tableList" width="100%">
		<tr class="clienthead">
			<th width="5"><input type="checkbox" name="selectAll" class="selectAll" value="#order.orderID#" /></th>
			<th width="">Publication</th>
			<th width="60">Type</th>
			<!---<th width="100">Next&nbsp;Issue</th>--->
			<th width="30">Mon</th>
			<th width="30">Tue</th>
			<th width="30">Wed</th>
			<th width="30">Thu</th>
			<th width="30">Fri</th>
			<th width="30">Sat</th>
			<th width="30">Sun</th>
			
			<!---<th width="15"><span title="Voucher">V</span></th>
			<th width="80" align="right"><span title="Vouchers Week Total">VWT</span></th>
			<th width="80" align="right"><span title="Vouchers Month Total">VMT</span></th>--->
			<th width="80" align="right">Weekly Total</th>
			<th width="80" align="right">Monthly Total</th>
		</tr>
		<cfset lessWeekVouchers=0>
		<cfset lessMonthVouchers=0>
		<cfloop array="#order.items#" index="item">
			<tr class="#item.class#">
				<td align="center"><input type="checkbox" name="selectPub" class="selectPub#order.orderID#" title="#item.ID#" value="#item.ID#" /></td>
				<td style="text-transform:capitalize;"><a href="##" class="editPubs" data-id="#val(item.pubID)#">#LCase(item.title)#</a></td>
				<td>#item.type#</td>
				<!---<td>#DateFormat(item.nextIssue,"ddd dd-mmm")#<br /><i style="font-size:9px;">Day: #item.arrival#</i></td>--->
					<td align="center"><cfif item.qtymon neq 0><b>#item.qtymon#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.qtytue neq 0><b>#item.qtytue#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.qtywed neq 0><b>#item.qtywed#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.qtythu neq 0><b>#item.qtythu#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.qtyfri neq 0><b>#item.qtyfri#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.qtysat neq 0><b>#item.qtysat#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.qtysun neq 0><b>#item.qtysun#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
				<!---<cfif item.qty is 0>
				<cfelse>
					<td align="center"><cfif item.arrival is 1><b>#item.qtymon#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.arrival is 2><b>#item.qtytue#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.arrival is 3><b>#item.qtywed#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.arrival is 4><b>#item.qtythu#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.arrival is 5><b>#item.qtyfri#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.arrival is 6><b>#item.qtysat#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
					<td align="center"><cfif item.arrival is 7><b>#item.qtysun#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
				</cfif>--->
				
				<!---<td align="center">#item.voucher#</td>
				
				<td align="right">&pound;#DecimalFormat(item.voucherPerWeek)#</td>					
				<td align="right">&pound;#DecimalFormat(item.voucherPerMonth)#</td>--->					
				<td align="right">&pound;#DecimalFormat(item.linePerWeek)#</td>
				<td align="right">&pound;#DecimalFormat(item.linePerMonth)#</td>
				<cfset lessWeekVouchers=lessWeekVouchers-item.vlinePerWeek>
				<cfset lessMonthVouchers=lessMonthVouchers-item.vlinePerMonth>
			</tr>
		</cfloop>
		<tr>
			<td colspan="2" rowspan="5" align="center">
				Delivery Code: #order.DeliveryCode#<br />
				<cfif StructKeyExists(application.site,"DelCharges")>
					<cfset tempCharges=StructFind(application.site.DelCharges,order.DeliveryCode)>
					<cfif tempCharges.delPrice2 gt 0>
						<table>
							<tr><td>Mon-Fri</td><td>#tempCharges.delPrice1# #tempCharges.delType#</td></tr>
							<tr><td>Sat</td><td>#tempCharges.delPrice2# #tempCharges.delType#</td></tr>
							<tr><td>Sun</td><td>#tempCharges.delPrice3# #tempCharges.delType#</td></tr>
						</table>
					<cfelse>
						<table>
							<tr><td>Mon-Sun</td><td>#tempCharges.delPrice1# #tempCharges.delType#</td></tr>
						</table>
					</cfif>
				</cfif>
			</td>
			<th align="right" colspan="8">Sub Total</th>
			<!---<td align="right">&pound;#DecimalFormat(order.voucherPerWeek)#</td>					
			<td align="right">&pound;#DecimalFormat(order.voucherPerMonth)#</td>--->
			<td align="right">&pound;#DecimalFormat(order.orderPerWeek)#</td>					
			<td align="right"><b>&pound;#DecimalFormat(order.orderPerMonth)#</b></td>
		</tr>
		<tr class="#order.delClass#">
			<th align="right" colspan="8">#order.delcount# Delivery Charges</th>
			<td align="right">&pound;#DecimalFormat(order.delPerWeek)#</td>					
			<td align="right"><b>&pound;#DecimalFormat(order.delPerMonth)#</b></td>
		</tr>
		<tr class="ordertotal">
			<cfset orderWeekTotal=order.orderPerWeek+order.delPerWeek>
			<cfset orderMonthTotal=order.orderPerMonth+order.delPerMonth>
			<th align="right" colspan="8">Order Total</th>
			<td align="right">&pound;#DecimalFormat(orderWeekTotal)#</td>					
			<td align="right"><b>&pound;#DecimalFormat(orderMonthTotal)#</b></td>
		</tr>
		<tr class="ordertotal">
			<th align="right" colspan="8">Less Vouchers Received</th>
			<td align="right">&pound;#DecimalFormat(lessWeekVouchers)#</td>					
			<td align="right"><b>&pound;#DecimalFormat(lessMonthVouchers)#</b></td>
		</tr>
		<tr class="ordertotal">
			<cfset grandWeekTotal=orderWeekTotal+lessWeekVouchers>
			<cfset grandMonthTotal=orderMonthTotal+lessMonthVouchers>
			<th align="right" colspan="8">Grand Total</th>
			<td align="right">&pound;#DecimalFormat(grandWeekTotal)#</td>					
			<td align="right"><b>&pound;#DecimalFormat(grandMonthTotal)#</b></td>
		</tr>
	</table>
</cfloop>
</cfoutput>