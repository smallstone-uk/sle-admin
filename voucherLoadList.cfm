<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/vouchers" name="vch">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset vouchers=vch.LoadVouchers(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.checkbox').click(function(){
			var show=false;
			$('.checkbox').each(function(index) {
				if(this.checked) {
					$('#tickRequired').fadeIn();
					show=true;
				} else {
					if(show) {
					} else {
						$('#tickRequired').fadeOut();
						show=false;
					};
				};
			});
		});
		$('#ref').val($('#refList').val());
		$('#date').val($('#dateList').val());
	});
</script>

<cfoutput>
	<form method="post" id="listForm">
		<cfif ArrayLen(vouchers.list)>
			<input type="hidden" id="refList" value="#vouchers.ref#" />
			<input type="hidden" id="dateList" value="#LSDateFormat(vouchers.date,'yyyy-mm-dd')#" />
		<cfelse>
			<input type="hidden" id="refList" value="#parm.form.ref#" />
			<input type="hidden" id="dateList" value="#LSDateFormat(parm.form.date,'yyyy-mm-dd')#" />
		</cfif>
		<table border="1" class="tableList trhover" width="100%">
			<tr>
				<th width="20"></th>
				<th align="left">Voucher Description</th>
				<th width="60">Qty</th>
				<th width="60" align="right">Retail Price</th>
				<th width="60" align="right">Hand Allow</th>
				<th width="60" align="right">Line Total</th>
			</tr>
			<cfset totalqty=0>
			<cfset totalNet=0>
			<cfset totalHand=0>
			<cfif ArrayLen(vouchers.list)>
				<cfloop array="#vouchers.list#" index="i">
					<tr>
						<td>
							<cfif i.Status is "open">
								<input type="checkbox" name="selectitem" class="selectitem checkbox" value="#i.ID#">
							</cfif>
						</td>
						<td>VCH #i.Title# <cfif i.Amount lt 1>#i.Amount*100#p<cfelse>&pound;#DecimalFormat(i.Amount)#</cfif> Off <span style="float:right;">#i.status#</span></td>
						<td align="center">#i.Qty#</td>
						<td align="right">&pound;#DecimalFormat(i.Amount)#</td>
						<td align="right">&pound;#DecimalFormat(i.HandAllow)#</td>
						<td align="right">&pound;#DecimalFormat(i.LineTotal)#</td>
					</tr>
					<cfset totalqty=totalqty+i.qty>
					<cfset totalNet=totalNet+(i.Amount*i.qty)>
					<cfset totalHand=totalHand+(i.HandAllow*i.qty)>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="6">No vouchers found</td>
				</tr>
			</cfif>
			<tr>
				<th colspan="2" align="right">Total</th>
				<td align="center"><strong>#totalqty#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(totalNet)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(totalHand)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(vouchers.total)#</strong></td>
			</tr>
		</table>
	</form>
</cfoutput>

