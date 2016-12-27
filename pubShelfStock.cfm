<!DOCTYPE html>
<html>
<head>
<title>Publication Shelf Stock</title>
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
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/rounds5.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
</head>

<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<body>
<cfoutput>
	<cfquery name="QMags" datasource="#parm.datasource#">
		SELECT tblPubStock.*,pubTitle
		FROM tblPubStock,tblPublication
		WHERE psType='received'
		AND psDate='#LSDateFormat(Now(),"YYYY-MM-DD")#'
		AND psPubID=pubID
		AND pubGroup='magazine'
	</cfquery>

	<table border="1" class="tableList morespace" width="100%">
		<tr>
			<th align="left">Publication</th>
			<th width="80">Start</th>
			<th width="80">End</th>
			<th width="80">Sold</th>
		</tr>
		<cfloop query="QMags">
			<tr>
				<td>#pubTitle#</td>
				<td></td>
				<td></td>
				<td></td>
			</tr>
		</cfloop>
		<cfloop from="1" to="9" index="i">
			<tr>
				<td>&nbsp;</td>
				<td></td>
				<td></td>
				<td></td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
</body>
</html>