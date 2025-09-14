<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/vouchers" name="vch">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset vouchers=vch.LoadVouchers(parm)>

<cfoutput>
	<cfif parm.form.suppID is "whs">
		<h1 style="width:500px;font-size:16px;">Voucher Recall Note <span style="float:right;font-size:12px;">#LSDateFormat(parm.form.date,"dd-mmm-yy")#</span></h1>
		<table style="font-size:12px;" width="500">
			<tr>
				<td width="150">Your Customer Number</td>
				<td><div style="width:200px;padding:5px;border:1px solid ##000;">212956</div></td>
			</tr>
			<tr>
				<td>Envelope Reference</td>
				<td><div style="width:200px;padding:5px;border:1px solid ##000; text-transform:uppercase;">#parm.form.ref#&nbsp;</div></td>
			</tr>
			<tr>
				<td>Customer Signature</td>
				<td><div style="width:200px;padding:5px;border-bottom:1px dotted ##000;">&nbsp;</div></td>
			</tr>
		</table>
		<div class="clear" style="padding:5px 0;"></div>
		<table border="1" class="tableList" width="500">
			<tr>
				<th style="background:none;">Description</th>
				<th style="background:none;" width="60">Value</th>
				<th style="background:none;" width="60">Qty</th>
				<th style="background:none;" width="60">Total</th>
			</tr>
			<cfset qty=0>
			<cfif ArrayLen(vouchers.list)>
				<cfloop array="#vouchers.list#" index="i">
					<tr>
						<td>#i.Title# <cfif i.Amount lt 1>#i.Amount*100#p<cfelse>&pound;#DecimalFormat(i.Amount)#</cfif> Off</td>
						<td align="right">&pound;#DecimalFormat(i.Amount+i.HandAllow)#</td>
						<td align="center">#i.Qty#</td>
						<cfset qty=qty+i.Qty>
						<cfset line=(i.Amount+i.HandAllow)*i.Qty>
						<td align="right">&pound;#DecimalFormat(line)#</td>
					</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="4">No vouchers found</td>
				</tr>
			</cfif>
			<tr>
				<th style="background:none;" colspan="2" align="right">Total</th>
				<td align="center">#qty#</td>
				<td align="right">&pound;#DecimalFormat(vouchers.total)#</td>
			</tr>
		</table>
	<cfelse>
		<h1 style="float:left;width:200px;line-height:30px;">222</h1>
		<h1 style="float:left;width:200px;font-size:20px;line-height:30px;">#application.company.companyname#</h1>
		<h1 style="float:right;font-size:14px;line-height:30px;">#LSDateFormat(parm.form.date,"dd-mmm-yy")#</h1>
		<div style="clear:both;font-size:12px;">Church Road, Shortlanesend, Truro, TR4 9DY</div>
		<div class="clear" style="padding:5px 0;"></div>
		<table border="1" class="tableList" width="500">
			<tr>
				<th style="background:none;">Voucher Description</th>
				<th style="background:none;" width="60">Value</th>
				<th style="background:none;" width="60">Return</th>
				<th style="background:none;" width="60">Total</th>
			</tr>
			<cfset qty=0>
			<cfif ArrayLen(vouchers.list)>
				<cfloop array="#vouchers.list#" index="i">
					<tr>
						<td>#i.Title# <cfif i.Amount lt 1>#i.Amount*100#p<cfelse>&pound;#DecimalFormat(i.Amount)#</cfif> Off</td>
						<td align="right">&pound;#DecimalFormat(i.Amount+i.HandAllow)#</td>
						<td align="center">#i.Qty#</td>
						<cfset qty=qty+i.Qty>
						<cfset line=(i.Amount+i.HandAllow)*i.Qty>
						<td align="right">&pound;#DecimalFormat(line)#</td>
					</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="4">No vouchers found</td>
				</tr>
			</cfif>
			<tr>
				<th style="background:none;" colspan="2" align="right">Total</th>
				<td align="center">#qty#</td>
				<td align="right">&pound;#DecimalFormat(vouchers.total)#</td>
			</tr>
		</table>
		<div style="font-size:12px;padding:20px 0 0 0">
			Signed:    _______________________________________
		</div>
	</cfif>
</cfoutput>




