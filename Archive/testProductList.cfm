<!DOCTYPE html>
<html>
<head>
<title>Test Product List</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
</head>

<cfsetting requesttimeout="300">
<cfobject component="code/Products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset data=prod.LoadProductList(parm)>

<body>
<cfoutput>
	<table border="1" class="tableList">
		<tr>
			<th width="20">ID</th>
			<th width="300" align="left">Title</th>
			<th width="40" align="right">Price</th>
			<th width="200" align="left">Barcodes</th>
		</tr>
		<cfloop array="#data#" index="i">
			<tr>
				<td align="center">#i.ID#</td>
				<td>#i.Title# #i.UnitSize#</td>
				<td align="right">&pound;#DecimalFormat(i.Price)#</td>
				<td valign="top">
					<cfif ArrayLen(i.Barcodes)>
						<table border="1" class="tableList" width="100%">
							<tr>
								<th align="left">Barcode</th>
								<th align="right">Price</th>
							</tr>
							<cfloop array="#i.Barcodes#" index="b">
								<tr>
									<td>#b.Barcode#</td>
									<td align="right">&pound;#DecimalFormat(b.Price)#</td>
								</tr>
							</cfloop>
						</table>
					</cfif>
				</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</body>
</html>

