<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Import Data</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
	<style>
		.more {color:#553FFF; font-size:16px; font-weight:bold; background-color:#D47FAA !Important}
		.different {color:#553FFF; font-size:16px; font-weight:bold; background-color:#FFCCFF !Important}
		.changed {color:#553FFF; font-size:16px; font-weight:bold; background-color:#D4FF55 !Important}
		.ourPrice {color:#553FFF; font-size:16px; font-weight:bold !Important}
		.noBarcode {color:#FF0000; font-weight:bold}
		.pricemarked {color:#FF00ff; font-size:16px; font-weight:bold !Important}
		.pricemarkdiff {color:#FF00ff; background-color:#6633FF; font-size:16px; font-weight:bold !Important}
	</style>
</head>

<body>
<cftry>
	<cfobject component="code/import2" name="import">
	<cfparam name="fileSrc" default="">
	<cfparam name="silent" default="false">
	<cfif len(fileSrc) IS 0>
		<p>Please select a file <a href="bookerProcess.cfm">here</a></p>
		<cfexit>
	</cfif>
	<cfparam name="supplierID" default="21">	<!--- Booker --->
	<cfoutput>
		<cfset parm = {}>
		<cfset parm.markup = 143>
		<cfset parm.fieldCount = 11>
		<cfset parm.fileDir="#application.site.dir_data#stock\">
		<cfset parm.sourcefile=fileSrc>
		<cfset parm.supplierID=supplierID>
		<cfif FindNoCase("prom",fileSrc,1)>
			<cfset parm.orderDate=ListGetAt(fileSrc,2,"-")>
			<cfif IsDate(parm.orderDate)>
				<cfset parm.orderRef = DateFormat(parm.orderDate,"yyyymmdd")>				
			<cfelse>
				<cfset parm.orderRef=ListFirst(fileSrc,"-")>
			</cfif>
			<cfset parm.validTo=ListFirst(ListGetAt(fileSrc,3,"-"),".")>
		<cfelse>
			<cfset parm.orderDate=ListGetAt(fileSrc,2,"-")>
			<cfset parm.orderRef=ListFirst(ListGetAt(fileSrc,3,"-"),".")>
			<cfset parm.validTo="">
		</cfif>

		<cfset CheckStockOrder=import.CheckStockOrder(parm)>
		<cfset parm.stockOrderID=CheckStockOrder.stockOrderID>
		<cfset parm.validTo=CheckStockOrder.validTo>
		<cfset parm.orderDate=CheckStockOrder.orderDate>
		<cfset parm.orderRef=CheckStockOrder.orderRef>
		<p><a href="bookerProcess.cfm">Select File...</a></p>
		<h1><a href="#application.site.url_data#stock/#parm.sourcefile#" target="_blank">#parm.sourcefile#</a></h1>
		<cfsetting requesttimeout="900">
		<cfflush interval="200">
		<cfset records=import.processFile(parm)>
		<!---<cfdump var="#records#" label="records" expand="no">--->
		<!---<cfset qtyField=import.determineQtyFld(records)>--->
	</cfoutput>

	<cfoutput>
		<table class="tableList">
			<tr>
				<th width="30">No.</th>
				<th width="90">Barcode</th>
				<th width="50">Product</th>
				<th>Description</th>
				<th width="40">Size</th>
				<th width="40">PM</th>
				<th width="40">Pack Qty</th>
				<th width="40">RRP</th>
				<th width="40">Cases</th>
				<th width="40">VAT</th>
				<th width="50">Our Price</th>
				<th width="40">Profit / POR%</th>
				<th width="80">WSP</th>
				<th width="50">Retail Net</th>
				<th width="50">Total Profit</th>
				<th width="150">Action</th>
			</tr>
			<cfset lineCount=0>
			<cfset totWSP=0>
			<cfset totRetail=0>
			<cfset totalValue=0>
			<cfset category="">
			<cfset noBarcodeCount = 0>
			<cfloop array="#records.basket#" index="rec">
				<cfset recResult=import.UpdateRecord(records.header,rec)>
<!---
					<tr>
						<td colspan="16" style="background-color:##eeeeee"><cfdump var="#recResult#" label="#rec.description#" expand="false"></td>
					</tr>
--->
				<cfset lineCount++>
				<cfset pmClass = "">
				<cfset pmClassDiff = "">
				<cfset totWSP += rec.wsp>
				<cfset totRetail += recResult.netTotalValue>
				<cfif rec.category neq category>
					<tr>
						<td colspan="16" style="background-color:##eeeeee"><strong>#rec.category#</strong></td>
					</tr>
					<cfset category=rec.category>
				</cfif>
				<cfif rec.pm><cfset pmClass = "pricemarked"></cfif>
				<cfif int(rec.pm) neq recResult.prevPM><cfset pmClassDiff = "pricemarkdiff"></cfif>
				<tr>
					<td align="center">#lineCount#</td>
					<td>
						<cfif StructKeyExists(recResult,"barcode")>
							<a href="https://www.booker.co.uk/products/product-list?keywords=#recResult.barcode#" target="booker">#recResult.barcode#</a>
						<cfelse><span class="noBarcode">NO BARCODE</span><cfset noBarcodeCount ++></cfif>
					</td>
					<td><a href="productStock6.cfm?product=#recResult.productID#" target="product">#rec.code#</a></td>
					<td>#rec.description#</td>
					<td>#rec.packsize#</td>
					<td align="center" class="#pmClass# #pmClassDiff#">#int(rec.pm)# = #recResult.prevPM#</td>
					<td align="center">#rec.packQty#</td>
					<td align="right">&pound;#rec.retail#</td>
					<td align="center" class="#recResult.classQty#">#recResult.qty1#</td>
					<td align="center">#rec.vat#%</td>
					<td align="right" class="#recResult.class#">&pound;#recResult.ourPrice#</td>
					<td align="right">#DecimalFormat(recResult.profit)#<br />#recResult.POR#%</td>
					<td align="right">&pound;#rec.WSP#<br />(&pound;#recResult.netUnitPrice# each)</td>
					<td align="right">&pound;#DecimalFormat(recResult.netTotalValue)#</td>
					<td align="right">&pound;#DecimalFormat(recResult.netTotalValue - rec.WSP)#</td>
					<td align="right">#recResult.action#</td>
				</tr>
			</cfloop>
			<cfif totRetail GT 0>
				<cfset totProfit = totRetail - totWSP>
				<cfset totPOR=DecimalFormat((totProfit / totRetail)*100)>
				<tr>
					<td class="amountTotal noBarcode" colspan="2">#noBarcodeCount# without barcodes.</td>
					<td class="amountTotal" colspan="10">Totals</td>
					<td class="amountTotal">&pound;#DecimalFormat(totWSP)#</td>
					<td class="amountTotal">&pound;#DecimalFormat(totRetail)#</td>
					<td class="amountTotal">&pound;#DecimalFormat(totProfit)#</td>
					<td class="amountTotal" align="left">#DecimalFormat(totPOR)#%</td>
				</tr>
			</cfif>
		</table>
	</cfoutput>

    <cfcatch type="any">
		An error occurred. (see log)
		<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
    </cfcatch>
</cftry>
</body>
</html>
