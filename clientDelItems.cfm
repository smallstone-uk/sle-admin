<script type="text/javascript">
	$(document).ready(function() {
		$('#srchDelDate').change(function(event) {
			var chosen=$('#srchDelDate').val();
			$.ajax({
				type: "POST",
				url: "clientLoadDelItems.cfm",
				data : $('#delItems').serialize(),
				beforeSend: function() {
					$('#loading').html("Loading...");
				},
				success: function(data) {
					$('#loading').html("");
					$('#DelItems').html(data);
					$('#srchDelDate').val(chosen);
				}
			});
		});
	});
</script>

<style type="text/css">
	.debit {color:#000000;}
	.credit {color:#FF0000;}
</style>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.rec.cltID=customer.rec.cltID>
<cfset parm.srchDelDate=srchDelDate>
<cfset custDelItems=cust.LoadClientDelItems(parm)>

<cffunction name="formatNum" access="public" returntype="string">
	<cfargument name="num" type="numeric" required="yes">
	<cfif num neq 0>
		<cfreturn DecimalFormat(num)>
	<cfelse>
		<cfreturn "">
	</cfif>
</cffunction>
	

<cfoutput>
	<h1>Delivery History</h1>
	<form id="delItems">
		<select name="srchDelDate" id="srchDelDate">
			<option value="recent">Recent Deliveries</option>
			<option value="current">Billed on current invoice</option>
			<option value="previous">Billed on previous invoice</option>
			<option value="thisyear">Deliveries this financial year</option>
			<option value="all">All deliveries</option>
		</select>
		<input type="hidden" name="cltID" value="#customer.rec.cltID#" />
	</form>
	<table class="tableList" border="1" width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<th>ID</th>
			<th>Order</th>
			<th>Type</th>
			<th>Reference</th>
			<th width="100">Date</th>
			<th>Category</th>
			<th width="180">Title</th>
			<th width="40">Item</th>
			<th width="40">Qty</th>
			<th width="50" align="right">Price</th>
			<th width="50" align="right">Value</th>
			<th width="50" align="right">Charge</th>
		</tr>
		<cfloop array="#custDelItems.delItems#" index="item">
			<tr>
				<td>#item.ID#</td>
				<td>#item.orderID#</td>
				<td>#item.type#</td>
				<td>#item.ref#</td>
				<td>#LSDateFormat(item.date,"ddd dd-mmm-yy")#</td>
				<td align="center">#item.category#</td>
				<td>#item.title#</td>
				<td align="center">#item.delType#</td>
				<td align="center">#item.qty#</td>
				<td align="right" class="#item.delType#">#item.price#</td>
				<td align="right" class="#item.delType#">#item.value#</td>
				<td align="right" class="#item.delType#">#formatNum(item.charge)#</td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="6"></td>
			<td align="right"><strong>Invoice Total</strong></td>
			<td align="right"><strong>#custDelItems.netTotal#</strong></td>
			<td colspan="2" align="right"><strong>Totals</strong></td>
			<td align="right"><strong>#custDelItems.pubTotal#</strong></td>
			<td align="right"><strong>#custDelItems.delTotal#</strong></td>
		</tr>
	</table>
</cfoutput>
