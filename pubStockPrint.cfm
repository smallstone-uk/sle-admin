<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.type="returned">
<cfset parm.group=form.printType>
<cfset stock=func.GetPubStockForPrint(parm)>

<cfset stockSorted=StructSort(stock.list,"textnocase","asc","Title")>

<cfoutput>

	<div style="float:right;">
		<h3 style="text-align:right;margin:0;padding:0;">#LSDateFormat(parm.form.psDate,"DDDD DD-MMM-YY")#</h3>
		<h1 style="text-align:right;">212956</h1>
		<div id="reBarcode">#stock.URN#</div>
		<div style="font-size:10px;text-align:center;">#stock.URN#</div>
	</div>
	<div style="float:left;">
		<b>#application.company.companyname#</b><br>
		Church Road<br>
		Shortlanesend<br>
		Truro<br>
		TR4 9DY
	</div>
	<div style="clear:both;margin:0 0 20px 0;"></div>
	<cfif ArrayLen(stockSorted)>
		<table border="1" class="tableList trhover" width="100%" style="font-size:10px;border-color:##333;">
			<tr style="border-color:##333;">
				<th width="60" style="border-color:##333;">Qty Returned</th>
				<th style="border-color:##333;">Description</th>
				<th style="border-color:##333;" width="60">Issue</th>
			</tr>
			<cfloop array="#stockSorted#" index="i">
				<cfset item=StructFind(stock.list,i)>
				<tr style="border-color:##333;">
					<td style="border-color:##333;" align="center">#val(item.Qty)#</td>
					<td style="border-color:##333;">#UCase(item.Title)#</td>
					<td style="border-color:##333;" align="center">#UCase(item.Issue)#</td>
				</tr>
			</cfloop>
		</table>
		<div style="clear:both;margin:0 0 20px 0;"></div>
		<div style="float:right;border:2px solid ##333;padding:5px 10px;">
			<b>Voucher Envelope Ref No:</b><br><br>
			<div id="voBarcode"></div>
		</div>
		<div style="float:left; width:400px;font-size:12px;margin:0 0 20px 0;">
			<b>To be completed by customer 212956</b><br>
			I confirm that the quantities/issues claimed are correct. Number of parcels Returned - ............<br><br>
			Signature<br><br>
			Date<br><br>
			<b>Checked By &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Input By</b>
		</div>
		<p style="clear:both;font-size:14px;font-weight:bold;line-height:20px;text-align:center;">Note: All publications are scanned individually</p>
	</cfif>
	
	<cfif len(stock.URN)>
		<script type="text/javascript">
			$(document).ready(function() {
				$("##reBarcode").barcode('#stock.URN#', 'code128', {
					"barHeight":25,
					"barWidth":1,
					"showHRI":true
				});
			});
		</script>
	</cfif>
</cfoutput>




