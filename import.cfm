<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Import Data</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
</head>

<body>
<cftry>
	<cfobject component="code/import" name="import">
	<cfparam name="fileSrc" default="">
	<cfparam name="silent" default="false">
	<cfif len(fileSrc) IS 0>
		<p>Please select a file <a href="bookerProcess.cfm">here</a></p>
		<cfexit>
	</cfif>
	<cfparam name="supplierID" default="21">	<!--- Booker --->
	<cfoutput>
		<cfset parm={}>
		<cfset parm.markup=100>
		<cfset parm.fileDir="#application.site.dir_data#stock\">
		<cfset parm.sourcefile=fileSrc>
		<cfset parm.supplierID=supplierID>
		<cfif FindNoCase("prom",fileSrc,1)>
			<cfset parm.orderRef=ListFirst(fileSrc,"-")>
			<cfset parm.orderDate=ListGetAt(fileSrc,2,"-")>
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
		<p><a href="bookerProcess.cfm">Select File...</a></p>
		<h1><a href="#application.site.url_data#stock/#parm.sourcefile#" target="_blank">#parm.sourcefile#</a></h1>
		<cfsetting requesttimeout="900">
		<cfflush interval="200">
		<cfset records=import.processFile(parm)>
		<cfset qtyField=import.determineQtyFld(records)>
	</cfoutput>
	<!---<cfdump var="#records#" label="records" expand="no">--->
	<cfoutput>
		<table class="tableList">
			<tr>
				<th width="50">No.</th>
				<th width="90">Barcode</th>
				<th width="50">Product</th>
				<th>Description</th>
				<th width="50">PM</th>
				<th width="50">Pack Qty</th>
				<th width="50">Unit Size</th>
				<th width="50">RRP</th>
				<th width="50">Our Price</th>
				<th width="50">VAT</th>
				<th width="50">WSP</th>
				<th width="50">Retail Net</th>
				<th width="50">Profit</th>
				<th width="50">POR</th>
				<th width="120">Action</th>
			</tr>
			<cfset lineCount=0>
			<cfset totWSP=0>
			<cfset totRetail=0>
			<cfset totProfit=0>
			<cfset totalValue=0>
			<cfset category="">
			<cfloop array="#records#" index="rec">
				<cfset recResult=import.UpdateRecord(rec,qtyField)><!---<cfdump var="#recResult#" label="#rec.fld03#" expand="no">--->
				<cfset lineCount++>
				<cfset totWSP=totWSP+rec.fld05>
				<cfset totRetail=totRetail+recResult.totalValue>
				<cfset totProfit=totProfit+recResult.profit>
				<cfif rec.category neq category>
					<tr>
						<td colspan="15" style="background-color:##eeeeee"><strong>#rec.category#</strong></td>
					</tr>
					<cfset category=rec.category>
				</cfif>
				<tr>
					<td align="center">#lineCount#</td>
					<td>#rec.barcode#</td><!---<br /><img src="http://www.booker.co.uk/catalog/barcode.aspx?barcode=#rec.fld01#" width="200px" />--->
					<td>#rec.fld02#</td>
					<td>#rec.fld03#</td>
					<td align="center">#rec.pm#</td>
					<td align="center">#rec.packQty#</td>
					<td>#rec.fld04#</td>
					<td align="right">#recResult.RRP#</td>
					<td align="right">#recResult.ourPrice#</td>
					<td align="right">#recResult.VAT#%</td>
					<td align="right">#recResult.WSP#</td>
					<td align="right">#DecimalFormat(recResult.totalValue)#</td>
					<td align="right">#DecimalFormat(recResult.profit)#</td>
					<td align="right">#recResult.POR#%</td>
					<td align="right">#recResult.action#</td>
				</tr>
			</cfloop>
			<cfif totRetail GT 0>
				<cfset totPOR=DecimalFormat((totProfit/totRetail)*100)>
				<tr>
					<td class="amountTotal" colspan="10">Totals</td>
					<td class="amountTotal">#DecimalFormat(totWSP)#</td>
					<td class="amountTotal">#DecimalFormat(totRetail)#</td>
					<td class="amountTotal">#DecimalFormat(totProfit)#</td>
					<td class="amountTotal">#DecimalFormat(totPOR)#%</td>
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
