<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Import Data</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
	<style>
		.more {color:#553FFF; font-size:16px; font-weight:bold; background-color:#D47FAA !Important}
		.different {color:#553FFF; font-size:16px; font-weight:bold; background-color:#FFCCFF !Important}
		.priceproblem {color:#553FFF; font-size:16px; font-weight:bold; background-color:#F00 !Important}
		.changed {color:#553FFF; font-size:16px; font-weight:bold; background-color:#D4FF55 !Important}
		.ourPrice {color:#553FFF; font-size:16px; font-weight:bold !Important}
		.noBarcode {color:#FF0000; font-weight:bold}
		.pricemarked {color:#FF00ff; font-size:16px; font-weight:bold !Important}
		.pricemarkdiff {color:#FF00ff; background-color:#6633FF; font-size:16px; font-weight:bold !Important}
		.pm-flag {
		  cursor: pointer;
		  display: inline-block;
		  width: 36px;
		  height: 36px;
		}
		.pm-flag .tick {
		  background: url("/images/icons/tick-round.png") no-repeat center center;
		  background-size: contain;
		  display: block;
		  width: 100%;
		  height: 100%;
		}
		.pm-flag .cross {
		  background: url("/images/icons/cross-round.png") no-repeat center center;
		  background-size: contain;
		  display: block;
		  width: 100%;
		  height: 100%;
		}
	</style>
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.sod_status').click(function(event) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var cell = $(this);
				$.ajax({
					type: "POST",
					url: "saveProductStatus.cfm",
					data: {"status": value, "prodID": prodID},
					success: function(data) {
						cell.html(data.trim());
						cell.css("color",'red');
						cell.css("font-weight",'bold');
					}
				});
			});
			$(document).on("click", ".caseQty", function() {
				var $el = $(this);
				var id = $el.data("id");
				var value = $(this).val();
			//	console.log("id " + id + " value " + value);		
				$.ajax({
					url: "ajax/AJAX_stockSetValue.cfm",
					method: "POST",
					data: { stockItemID: id, caseQty: value },
					success: function(response) {
						// Update DOM only if CF update succeeded
					}
				});
			});
			$(document).on("click", ".pm-flag", function() {
				var $el = $(this);
				var id = $el.data("id");
				var currentVal = $el.data("pm");
				var newVal = currentVal == 1 ? 0 : 1;
			
				$.ajax({
					url: "ajax/AJAX_productSetValue.cfm",
					method: "POST",
					data: { productID: id, pm: newVal },
					success: function(response) {
						// Update DOM only if CF update succeeded
						$el.data("pm", newVal);
						if (newVal == 1) {
							$el.find("i.icon-img").removeClass("cross").addClass("tick");
							$el.find("i.icon-text").html(response);
						} else {
							$el.find("i.icon-img").removeClass("tick").addClass("cross");
							$el.find("i.icon-text").html(response);
						}
					}
				});
			});
		});
	</script>
</head>

<body>
<cftry>
	<cfobject component="code/import2" name="import">
	<cfparam name="fileSrc" default="">
	<cfparam name="mode" default="1">
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

		<p><a href="bookerProcess.cfm">Select File...</a></p>
		<h1><a href="#application.site.url_data#stock/#parm.sourcefile#" target="_blank">#parm.sourcefile#</a></h1>
		<p>After checking the price mark flags, refresh the page to correct any incorrect prices.</p>
		<cfflush interval="200">
		<cfsetting requesttimeout="900">
		<cfset CheckStockOrder = import.CheckStockOrder(parm)>
		<cfset parm.stockOrderID = CheckStockOrder.stockOrderID>
		<cfset parm.validTo = CheckStockOrder.validTo>
		<cfset parm.orderDate = CheckStockOrder.orderDate>
		<cfset parm.orderRef = CheckStockOrder.orderRef>
		<cfif mode eq 2>
			<cfset dataImport = import.processFile2(parm)>
			<!---<cfdump var="#dataImport#" label="dataImport" expand="false">--->
			<cfset import.outputData(dataImport)>
			<cfexit>
		<cfelse>
			<cfset records=import.processFile(parm)>
			<!---<cfdump var="#records#" label="records" expand="no">--->
			<!---<cfset qtyField=import.determineQtyFld(records)>--->
		</cfif>

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
			<cfset barcodeArray = []>
			<cfloop array="#records.basket#" index="rec">
<!---					<tr>
						<td colspan="16" style="background-color:##eeeeee"><cfdump var="#rec#" expand="false"></td>
					</tr>
--->				<cfset recResult=import.UpdateRecord(records.header,rec)>
<!---					<tr>
						<td colspan="16" style="background-color:##eeeeee"><cfdump var="#recResult#" expand="false"></td>
					</tr>
--->

				<cfset lineCount++>
				<cfset showRedclass = "">
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
                <cfif recResult.problem><cfset showRedclass = "priceproblem"></cfif>
				<tr>
					<td align="center">#lineCount#</td>
					<td>
						<cfif StructKeyExists(recResult,"barcode")>
							<a href="https://www.booker.co.uk/products/product-list?keywords=#recResult.barcode#" target="booker">#recResult.barcode#</a>
							<cfset ArrayAppend(barcodeArray,recResult.barcode)>
						<cfelse><span class="noBarcode">NO BARCODE</span><cfset noBarcodeCount ++></cfif>
					</td>
					<td><a href="productStock6.cfm?product=#recResult.productID#" target="product">#rec.code#</a></td>
					<td>#rec.description#</td>
					<td>#rec.packsize#</td>
					<td align="center" class="#pmClass# #pmClassDiff#">#int(rec.pm)# = #recResult.prevPM#</td>
					<td align="center">#rec.packQty#</td>
					<td align="right" class="#showRedclass#">&pound;#rec.retail#</td>
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
		Barcodes used:-<br />
		<!--- 03/27/00,16:51:43,0B,9322214006328 --->
		<cfloop array="#barcodeArray#" index="bcode">
		#DateFormat(now(),"mm/dd/yy")#,#TimeFormat(now(),"HH:MM:SS")#,OB,#bcode#<br />
		</cfloop>
	</cfoutput>

    <cfcatch type="any">
		An error occurred. (see log)
		<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
    </cfcatch>
</cftry>
</body>
</html>
