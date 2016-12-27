<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset add=prod.AddDeal(parm)>

<cfoutput>
	<h2>New Deal</h2>
	<form method="post" id="newDealForm2">
		<p>Scan all product barcodes you want to be assigned to this deal.</p>
		<table width="300">
			<tr><td width="80">Internal Title</td><td>#add.RecordTitle#</td></tr>
			<tr><td width="80">Display Title</td><td>#add.Title#</td></tr>
			<tr><td width="80">Starts</td><td>#LSDateFormat(add.Starts,"dd/mmm/yyyy")#</td></tr>
			<tr><td width="80">Ends</td><td>#LSDateFormat(add.Ends,"dd/mmm/yyyy")#</td></tr>
			<tr><td width="80">Type</td><td>#add.Type#</td></tr>
			<tr><td width="80">Amount</td><td>&pound;#DecimalFormat(add.Amount)#</td></tr>
			<tr><td width="80">Qty</td><td>#val(add.Qty)#</td></tr>
			<tr><td width="80">Status</td><td>#add.Status#</td></tr>
		</table>
		<p>&nbsp;</p>
		<table width="300">
			<tr>
				<td width="100"><strong>Scan Product Barcode</strong></td>
				<td><input type="text" name="prodBarcode" value=""></td>
			</tr>
		</table>
	</form>
</cfoutput>