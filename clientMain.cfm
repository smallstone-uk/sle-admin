<!DOCTYPE html>
<html>
<head>
	<title>Client Details</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" href="scripts/themes/smoothness/jquery-ui.css" />
	<script src="common/scripts/common.js"></script>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			});
		$(function() {
			$("#tabs").tabs();
		});
	</script>
</head>

<!---
http://os.alfajango.com/easytabs/#nested-tab-3
--->
<cfoutput>
<body>
	<div id="wrapper">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<div style="padding:10px 0;">
						<div id="tabs">
							<ul>
								<li><a href="##Details">Customer Details</a></li>
								<li><a href="##Orders">Orders</a></li>
								<li><a href="##Deliveries">Deliveries</a></li>
								<li><a href="##Transactions">Transactions</a></li>
							</ul>
							<div class="clear"></div>
						</div>
					</div>
					<div class="clear"></div>
					<div id="Details" class="AddForm">
					</div>
					<div id="Orders" class="AddForm">
					</div>
					<div id="Deliveries" class="AddForm">
					</div>
					<div id="Transactions" class="AddForm">
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</cfoutput>
</html>