<!DOCTYPE html>
<html>
<head>
<title>Packing Sheet</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		function PrintArea() {
			$('#print-area').printArea();
		};
		$('#printSheet').click(function() {
			PrintArea();
			event.preventDefault();
		});
	});
</script>
</head>

<cfsetting requesttimeout="300">
<cfset pubs={}>
<cfset pages=1>
<cfset overall=0>
<cfset rowcount=0>
<cfset overflow=30>
<cfset rowLimit=50>
<cfset overallLimit=rowLimit*3>

<cfquery name="QItems" datasource="#application.site.datasource1#">
	SELECT tblDelItems.*, pubShortTitle,pubTitle,pubID  
	FROM tblDelItems,tblPublication
	WHERE diOrderID=6291
	AND diType='debit'
	AND diDate >= #LSDateFormat(DateAdd("d",-28,Now()),"yyyy-mm-dd")#
	AND pubID=diPubID
	AND pubGroup='Magazine'
	AND (pubType='Monthly' OR pubType='Weekly' OR pubType='Fortnightly')
</cfquery>
<cfloop query="QItems">
	<cfif StructKeyExists(pubs,pubID)>
		<cfset pub=StructFind(pubs,pubID)>
		<cfset set={}>
		<cfif len(pubShortTitle)>
			<cfset set.title=pubShortTitle>
		<cfelse>
			<cfset set.title=pubTitle>
		</cfif>
		<cfset set.qty=pub.qty+diQty>
		<cfset set.count=pub.count+1>
		<cfset set.av=int(set.qty/set.count)>
		<cfset StructUpdate(pubs,pubID,set)>
	<cfelse>
		<cfset set={}>
		<cfset set.title=pubTitle>
		<cfset set.qty=diQty>
		<cfset set.count=1>
		<cfset set.av=int(set.qty/set.count)>
		<cfset StructInsert(pubs,pubID,set)>
	</cfif>
</cfloop>
<cfset pubsSorted=StructSort(pubs,"textnocase","asc","title")>

<cfoutput>
<body>
	<div id="controls" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;" class="no-print">
		<a href="##" id="printSheet" class="button" style="float:left;font-size:13px;">Print</a>
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div id="print-area" style="padding:10px;width:700px;">
		<h1 style="line-height:normal;padding:0;margin:0 0 12px 0;font-size:20px;">
			<span style="float:right;color:##333;border:1px solid ##555;width: 200px;height: 30px;margin: 0 15px 0 0;"></span>
			<span style="float:right;color:##333;font-size:14px;font-weight:bold;padding:5px;margin: 2px 0 0 0;">Date<br></span>
			Magazine Packing Sheet
			<div style="font-size:11px;margin:0 14px 0 0;padding:4px 0 0 0;color:##666;font-style:italic;">Date relates to the date the publications arrived to us from WHS</div>
		</h1>
		<cfloop array="#pubsSorted#" index="i">
			<cfif rowcount is 0>
				<table border="1" class="tableList" style="float:left;margin:0 5px 0 0;">
				<tr>
					<th align="left" width="150">Publication</th>
					<th width="20">Avg</th>
					<th width="20">Qty</th>
				</tr>
			</cfif>
			<cfset pub=StructFind(pubs,i)>
			<cfset rowcount=rowcount+1>
			<cfset overall=overall+1>
			<tr>
				<td align="left" style="text-transform:capitalize;">
					<cfif Len(pub.Title) gt 25>
						#Left(LCase(pub.Title),22)#...
					<cfelse>
						#LCase(pub.Title)#
					</cfif>
				</td>
				<td align="center">#pub.av#</td>
				<td></td>
			</tr>
			<cfif overall is StructCount(pubs)>
				<cfset filler=overallLimit*pages-overall>
				<cfloop from="1" to="#filler#" index="num">
					<cfif rowcount is 0>
						<table border="1" class="tableList" style="float:left;margin:0 5px 0 0;">
						<tr>
							<th align="left" width="150">Publication</th>
							<th width="20">Avg</th>
							<th width="20">Qty</th>
						</tr>
					</cfif>
					<cfset rowcount=rowcount+1>
					<cfif num is 1>
						<tr>
							<th colspan="2" style="padding: 2px 5px;">Extras</th>
							<th width="20" style="padding: 2px 5px;">Qty</th>
						</tr>
					<cfelse>
						<tr>
							<td colspan="2">&nbsp;</td>
							<td>&nbsp;</td>
						</tr>
					</cfif>
					<cfif rowcount is rowLimit>
						<cfset rowcount=0>
						</table>
						<cfif overall is overallLimit>
							<cfset pages=pages+1>
							<div style="page-break-before:always;"></div>
							<h1 style="line-height:normal;padding:0;margin:0 0 12px 0;font-size:20px;">
								<span style="float:right;color:##333;border:1px solid ##555;width: 200px;height: 30px;margin: 0 15px 0 0;"></span>
								<span style="float:right;color:##333;font-size:14px;font-weight:bold;padding:5px;margin: 2px 0 0 0;">Date Packed<br></span>
								Magazine Packing Sheet
								<div style="font-size:11px;margin:0 14px 0 0;padding:4px 0 0 0;color:##666;font-style:italic;">Date Packed relates to the date the publications arrived to us from WHS</div>
							</h1>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			<cfif rowcount is rowLimit>
				<cfset rowcount=0>
				</table>
				<cfif overall is overallLimit>
					<cfset pages=pages+1>
					<div style="page-break-before:always;"></div>
					<h1 style="line-height:normal;padding:0;margin:0 0 12px 0;font-size:20px;">
						<span style="float:right;color:##333;border:1px solid ##555;width: 200px;height: 30px;margin: 0 15px 0 0;"></span>
						<span style="float:right;color:##333;font-size:14px;font-weight:bold;padding:5px;margin: 2px 0 0 0;">Date Packed<br></span>
						Magazine Packing Sheet
						<div style="font-size:11px;margin:0 14px 0 0;padding:4px 0 0 0;color:##666;font-style:italic;">Date Packed relates to the date the publications arrived to us from WHS</div>
					</h1>
				</cfif>
			</cfif>
		</cfloop>
	</div>
</body>
</cfoutput>
</html>

