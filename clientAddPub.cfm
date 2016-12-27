<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="fnc">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.rec.cltRef=form.cltRef>
<cfset parm.datasource=application.site.datasource1>
<cfset add=fnc.AddPublicationToOrder(parm)>
<cfset custOrder=fnc.LoadClientOrder(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#selectAll').click(function(event) {   
			if(this.checked) {
				$('input.selectPub').each(function() {this.checked = true;});
			} else {
				$('input.selectPub').each(function() {this.checked = false;});
			}
		});
	});
</script>
<cfoutput>
<cfif ArrayLen(custOrder.order.items)>
	<form method="post" enctype="multipart/form-data">
		<div>
			<input type="submit" name="btnPubDelete" value="Delete" />
		</div>
		<div class="clear"></div>
		<table border="1" class="tableList">
			<tr class="clienthead">
				<th width="5"><input type="checkbox" name="selectAll" id="selectAll" value="1" /></th>
				<th width="60">Code</th>
				<th width="200">Publication</th>
				<th width="80">Type</th>
				<th width="100">Next&nbsp;Issue</th>
				<th width="30">Mon</th>
				<th width="30">Tue</th>
				<th width="30">Wed</th>
				<th width="30">Thu</th>
				<th width="30">Fri</th>
				<th width="30">Sat</th>
				<th width="30">Sun</th>
				
				<th width="15"><span title="Voucher">V</span></th>
				<th width="80" align="right"><span title="Vouchers Week Total">VWT</span></th>
				<th width="80" align="right"><span title="Vouchers Month Total">VMT</span></th>
				<th width="80" align="right"><span title="Charge Week Total">CWT</span></th>
				<th width="80" align="right"><span title="Charge Month Total">CMT</span></th>
			</tr>
			<cfloop array="#custOrder.order.items#" index="item">
				<tr class="#item.class#">
					<td align="center"><input type="checkbox" name="selectPub" class="selectPub" value="#item.ID#" /></td>
					<td align="center">#item.ref#</td>
					<td>#item.title#</td>
					<td>#item.type#</td>
					<td>#DateFormat(item.nextIssue,"ddd dd-mmm")#<br /><i style="font-size:9px;">Day: #item.arrival#</i></td>
					<td align="center">#item.qtymon#<br /><i style="font-size:9px;">&pound;#item.price1#</i></td>
					<td align="center">#item.qtytue#<br /><i style="font-size:9px;">&pound;#item.price2#</i></td>
					<td align="center">#item.qtywed#<br /><i style="font-size:9px;">&pound;#item.price3#</i></td>
					<td align="center">#item.qtythu#<br /><i style="font-size:9px;">&pound;#item.price4#</i></td>
					<td align="center">#item.qtyfri#<br /><i style="font-size:9px;">&pound;#item.price5#</i></td>
					<td align="center">#item.qtysat#<br /><i style="font-size:9px;">&pound;#item.price6#</i></td>
					<td align="center">#item.qtysun#<br /><i style="font-size:9px;">&pound;#item.price7#</i></td>
					
					<td align="center">#item.voucher#</td>
					
					<td align="right">&pound;#DecimalFormat(item.voucherPerWeek)#</td>					
					<td align="right">&pound;#DecimalFormat(item.voucherPerMonth)#</td>					
					<td align="right">&pound;#DecimalFormat(item.linePerWeek)#</td>
					<td align="right">&pound;#DecimalFormat(item.linePerMonth)#</td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="3" rowspan="4" align="center">
					Delivery Code: #custorder.cltdelcode#<br />
					<cfif StructKeyExists(application.site,"DelCharges")>
						<cfset tempCharges=StructFind(application.site.DelCharges,custorder.cltdelcode)>
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
						<!---<cfdump var="#tempCharges#" label="tempCharges" expand="no">--->
					</cfif>
				</td>
				<td align="right" colspan="10">#custOrder.order.delcount# Delivery Charges</td>
				<td></td>
				<td></td>
				<td align="right">&pound;#DecimalFormat(custOrder.order.delPerWeek)#</td>					
				<td align="right">&pound;#DecimalFormat(custOrder.order.delPerMonth)#</td>
			</tr>
			<tr class="#custOrder.order.delClass#">
				<td align="right" colspan="10">Sub-Total</td>
				<td align="right">&pound;#DecimalFormat(custOrder.order.voucherPerWeek)#</td>					
				<td align="right">&pound;#DecimalFormat(custOrder.order.voucherPerMonth)#</td>
				<td align="right">&pound;#DecimalFormat(custOrder.order.orderPerWeek+custOrder.order.delPerWeek)#</td>					
				<td align="right">&pound;#DecimalFormat(custOrder.order.orderPerMonth+custOrder.order.delPerMonth)#</td>
			</tr>
			<tr class="ordertotal">
				<td align="right" colspan="10">Total Order Value</td>
				<td></td>
				<td align="right"></td>					
				<td align="right">&pound;#DecimalFormat(custOrder.order.orderPerWeek+custOrder.order.voucherPerWeek+custOrder.order.delPerWeek)#</td>					
				<td align="right">&pound;#DecimalFormat(custOrder.order.orderPerMonth+custOrder.order.voucherPerMonth+custOrder.order.delPerMonth)#</td>
			</tr>
		</table>
	</form>
</cfif>
</cfoutput>