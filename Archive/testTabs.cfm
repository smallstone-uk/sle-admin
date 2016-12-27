<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>TestTabs</title>
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script type="text/javascript">
		$(function() {
			$("#tabs").tabs();
		});
		$(function() {
			$( "#tabs" ).tabs({
				beforeLoad: function( event, ui ) {
					ui.jqXHR.error(function() {
						ui.panel.html(
							"Couldn't load this tab. We'll try to fix this as soon as possible. " +
							"If this wouldn't be a demo." );
					});
				}
			});
		});
		</script>
</head>

<cfparam name="srchID" default="1281">
<cfoutput>
	<body>
		<form method="post">
			<input type="hidden" name="srchID" value="#srchID#" />
			<div id="tabs">
				<ul>
					<li><a href="tabContent.cfm?content=orders&ID=#srchID#">Orders</a></li>
					<li><a href="tabContent.cfm?content=msgs&ID=#srchID#">Messages</a></li>
					<li><a href="tabContent.cfm?content=trans&ID=#srchID#">Transactions</a></li>
					<li><a href="tabContent.cfm?content=deliveries&ID=#srchID#">Deliveries</a></li>
				</ul>
			</div>
		</form>
	</body>
</cfoutput>
</html>
