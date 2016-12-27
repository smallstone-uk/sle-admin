<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Parser</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
</head>

	<cffunction name="UpdateRecord" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cftry>
			<cfquery name="loc.prodExists" datasource="#application.site.datasource0#">
				SELECT prodID
				FROM tblProducts
				WHERE prodRef='#args.fld03#'
				LIMIT 1;
			</cfquery>
			<cfif loc.prodExists.recordcount eq 1>
				product found
			<cfelse>
				<cfquery name="loc.QAddProduct" datasource="#application.site.datasource0#" result="loc.QAddProductResult">
					INSERT INTO tblProducts
					SET (
						prodRef,prodRecordTitle,prodPriceMarked,prodPackQty,prodUnitSize,prodRRP,prodVatRate,prodPackPrice
					) VALUES (
						'#args.fld03#','#args.fld04#',#args.pm#,#args.qty#,'#args.fld05#',#args.fld07#,#args.fld08#,,#args.fld06#
					)
				</cfquery>
				<cfquery name="QAddStock" datasource="#application.site.datasource0#">
					INSERT INTO tblBarcodes
					SET (
						barCode,barType,barProdID
					) VALUES (
						'#args.fld01#','product',#loc.QAddProductResult.generatedKey#
					)
				</cfquery>

			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>

		<cfreturn loc.result>
	</cffunction>


<body>
	<cfparam name="fileSrc" default="">	
	<cfoutput>
		<cfset parm={}>
		<cfset parm.fileDir="#application.site.dir_data#stock\">
		<cfset parm.sourcefile=fileSrc>
		<!---<cfset parm.findStr1='<tr class="genericListItem"(.*?)<\tr>'>--->
		<cffile action="read" file="#parm.fileDir##parm.sourcefile#" variable="content">
		<cfset records=[]>
		<p><a href="bookerProcess.cfm">Select File...</a></p>
		<h1><a href="#application.site.url_data#stock/#parm.sourcefile#" target="_blank">#parm.sourcefile#</a></h1>
		<cfscript>
			jsoup = createObject("java", "org.jsoup.Jsoup");
			doc = jsoup.parse(content);
			elements = doc.select("tr.genericListItem");	// select data rows
		//	header=doc.select("h2");
		//	WriteOutput(header.text());
			for (ele in elements) {		// for each row
				cells=ele.select("td");	// get the TDs
			//	WriteOutput(HTMLCodeFormat(cells.toString()));
				fields={};	// struct to store data
				image=ele.select("img"); // get product image reference
			//	WriteOutput(image.attr("src")); // get source path
				count=1;
				StructInsert(fields,"fld#NumberFormat(count,"00")#",image.attr("alt")); // store barcode text
				for (cell in cells)	{ // loop cells
					count++;
					fld=cell.text();	// get text in field
					if (Find(chr(194),fld,1)) { // odd character
						fld=Replace(fld,chr(194),"","all"); // remove it
					}
					if (count eq 4) { // field 4 (description)
						pm=ReFind("PM\d{0,4}",fld) gt 0;	// contains price mark e.g. PM159
						StructInsert(fields,"PM",pm);	// set the PM flag
						if (pm) {
							fld=ReReplace(fld,"PM\d{0,4}","");	// remove PMnnn from title
						}
					}
					if (count eq 5) { // qty field	e.g 12 x 100g
						qty=ListFirst(fld,"x");	// get first item (qty)
						StructInsert(fields,"qty",qty);	// add qty to struct
						fld=ListRest(fld,"x"); // get unit size
					}
					if (count eq 6) { // WSP field
						if (Find("Now",fld)) { // found price change e.g. Was: £4.99 Now: £4.69
							fld=Replace(ListLast(fld," "),"£",""); // get now price and remove £
						} else {
							fld=Replace(fld,"£",""); // remove £
						}
					}
					if (count eq 7) { // RRP remove £
						fld=Replace(fld,"£","");
					}
					if (count eq 8) { // VAT Rate
						fld=Replace(fld,"%",""); // remove %
					}
					//	WriteOutput(fld);
					StructInsert(fields,"fld#NumberFormat(count,"00")#",fld);	// add modified fld item to fields struct
				}
				ArrayAppend(records,fields); // add row data to array
			}
		</cfscript>
	</cfoutput>
	<cfdump var="#records#" label="records" expand="false">
	
	<cfoutput>
		<table class="tableList">
			<tr>
				<th width="50">No.</th>
				<th width="90">Barcode</th>
				<th width="50">Product</th>
				<th>Description</th>
				<th width="50">PM</th>
				<th width="50">Qty</th>
				<th width="50">Unit Size</th>
				<th width="50">RRP</th>
				<th width="50">VAT</th>
				<th width="50">WSP</th>
				<th width="50">Retail Net</th>
				<th width="50">Profit</th>
				<th width="50">POR</th>
			</tr>
			<cfset lineCount=0>
			<cfset totWSP=0>
			<cfset totRetail=0>
			<cfset totProfit=0>
			<cfloop array="#records#" index="rec">
				<cfset UpdateRecord(rec)>
				<cfset lineCount++>
				<cfset POR=0>
				<cfset retailNet=val(rec.fld07)/(1+(rec.fld08/100))>
				<cfset totalValue=val(rec.qty)*retailNet>
				<cfset totWSP=totWSP+rec.fld06>
				<cfset totRetail=totRetail+totalValue>
				<cfif totalValue neq 0>
					<cfset profit=totalValue-rec.fld06>
					<cfset totProfit=totProfit+profit>
					<cfset POR=DecimalFormat((profit/totalValue)*100)>
				</cfif>
				<tr>
					<td align="center">#lineCount#</td>
					<td>#rec.fld01#</td><!---<br /><img src="http://www.booker.co.uk/catalog/barcode.aspx?barcode=#rec.fld01#" width="200px" />--->
					<td>#rec.fld03#</td>
					<td>#rec.fld04#</td>
					<td align="center">#rec.pm#</td>
					<td align="center">#rec.qty#</td>
					<td>#rec.fld05#</td>
					<td align="right">#rec.fld07#</td>
					<td align="right">#rec.fld08#%</td>
					<td align="right">#rec.fld06#</td>
					<td align="right">#DecimalFormat(totalValue)#</td>
					<td align="right">#DecimalFormat(profit)#</td>
					<td align="right">#POR#%</td>
				</tr>
			</cfloop>
			<cfset totPOR=DecimalFormat((totProfit/totRetail)*100)>
			<tr>
				<td class="amountTotal" colspan="9">Totals</td>
				<td class="amountTotal">#DecimalFormat(totWSP)#</td>
				<td class="amountTotal">#DecimalFormat(totRetail)#</td>
				<td class="amountTotal">#DecimalFormat(totProfit)#</td>
				<td class="amountTotal">#DecimalFormat(totPOR)#%</td>
			</tr>
		</table>
	</cfoutput>
</body>
</html>
