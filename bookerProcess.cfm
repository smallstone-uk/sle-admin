<cftry>
<!DOCTYPE html>
<html>
<head>
<title>Order Processor</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
	});
</script>

<cfset fileLimit = 30>
<cfset dataDir="#application.site.dir_data#\stock\">
<cfdirectory directory="#dataDir#" action="list" name="QDir" sort="name DESC">
<cfquery name="QStockOrders" datasource="#application.site.datasource1#">
	SELECT tblStockOrder.*, Count(siID) AS items
	FROM tblStockOrder
	INNER JOIN tblStockItem ON siOrder=soID
	GROUP BY soID
	ORDER BY soDate DESC
	LIMIT #fileLimit#
</cfquery>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfif StructKeyExists(url,"processAll")>
					<table>
					<cfoutput>
						<cfset recCount=0>
						<cfloop query="QDir">
							<cfif type eq "file" AND Left(name,5) eq "order">#name#<br>
								<cfset recCount++>
								<script type="text/javascript">
									$(document).ready(function() {
										function processFile(fileSrc) {
											$.ajax({
												url : 'import.cfm',
												type : 'GET',
												async: false,
												data : {
													'fileSrc' : fileSrc
												},
												success:function(data){
												},
												error:function(data){
												}
											});
										};
										processFile('#name#');
									});			
								</script>
								<tr>
									<td>#currentrow#</td>
									<td><a href="#application.site.url_data#stock/#name#" target="_blank">#name#</a></td>
									<td><a href="import.cfm?fileSrc=#name#" target="_blank">import</a></td>
									<td>#LSDateFormat(datelastmodified,"dd-mmm-yyyy")#</td>
									<td>#size#</td>
								</tr>
								<cfif recCount eq 2><cfbreak></cfif>
							</cfif>
						</cfloop>
					</cfoutput>
					</table>
				</cfif>
				<div id="orderOverlay-ui"></div>
				<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<h2>Files Available</h2>
				<table width="100%" class="tableList" border="1">
					<tr>
						<th align="left">#</td>
						<th align="left">File</td>
						<th align="left">Import</td>
						<th align="left">Date Modified</td>
						<th align="left">Size (KB)</td>
					</tr>
					<cfset recCount=0>
					<cfoutput>
						<cfloop query="QDir">
							<cfif type eq "file" AND Left(name,5) eq "order">
								<cfset recCount++>
								<tr>
									<td>#recCount#</td>
									<td><a href="#application.site.url_data#stock/#name#" target="_blank">#name#</a></td>
									<td><a href="import2.cfm?fileSrc=#name#" target="_blank">import</a></td>
									<td>#LSDateFormat(datelastmodified,"dd-mmm-yyyy")#</td>
									<td>#size#</td>
								</tr>
								<cfif recCount eq fileLimit><cfbreak></cfif>
							</cfif>
						</cfloop>
						<tr><td colspan="5">&nbsp;</td></tr>
						<cfset recCount=0>
						<cfloop query="QDir">
							<cfif type eq "file" AND Left(name,4) eq "prom">
								<cfset recCount++>
								<tr>
									<td>#recCount#</td>
									<td><a href="#application.site.url_data#stock/#name#" target="_blank">#name#</a></td>
									<td><a href="import2.cfm?fileSrc=#name#" target="_blank">import</a></td>
									<td>#LSDateFormat(datelastmodified,"dd-mmm-yyyy")#</td>
									<td>#size#</td>
								</tr>
								<cfif recCount eq fileLimit><cfbreak></cfif>
							</cfif>
						</cfloop>
					</cfoutput>
				</table>
				<!---<a href="bookerprocess.cfm?processAll=true">Reprocess all files?</a><br>--->
				<h2>Processed Orders</h2>
				<table width="100%" class="tableList" border="1">
					<tr>
						<th align="left">#</td>
						<th align="left">ID</th>
						<th align="left">Order Reference</th>
						<th align="left">Date Submitted</th>
						<th align="left">Items</th>
						<th align="left">Date Scanned</th>
					</tr>
					<cfoutput query="QStockOrders">
						<tr>
							<td>#currentrow#</td>
							<td>#soID#</td>
							<td><a href="stockDetails.cfm?ref=#soRef#" target="_blank">#soRef#</a></td>
							<td>#LSDateFormat(soDate,"ddd dd-mmm-yyyy")#</td>
							<td>#items#</td>
							<td>#LSDateFormat(soScanned,"ddd dd-mmm-yyyy")# #TimeFormat(soScanned,"HH:mm:ss")#</td>
						</tr>
					</cfoutput>
				</table>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</html>
    <cfcatch type="any">
         <cfdump var="#cfcatch#" label="cfcatch" expand="no">
    </cfcatch>
</cftry>