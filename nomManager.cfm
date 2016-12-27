<cftry>
<!DOCTYPE html>
<html>
<head>
<title>Nominal Manager</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/nomManager.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script src="scripts/main.js"></script>
<script src="scripts/jquery.scrollTo.min.js"></script>
</head>

<cfobject component="code/accounts" name="acc">
<cfsetting showdebugoutput="no">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset nominals = acc.LoadNominalGroupsWithItems(parm)>

<cfoutput>
	<script>
		$(document).ready(function() {
			loadGroup = function(grpName) {
				$.ajax({
					type: "POST",
					url: "#parm.url#ajax/AJAX_loadNomGroupContent.cfm",
					data: {"grpName": grpName},
					cache: false,
					success: function(data) {
						$('.nomMan-itemWrapper[data-item="' + grpName + '"]').html(data);
					}
				});
			}
		
			loadAll = function() {
				$.ajax({
					type: "GET",
					url: "#parm.url#ajax/AJAX_loadAllNominalGroups.cfm",
					cache: false,
					beforeSend: function() {
						$('.nomMan-callback').html("loading...");
					},
					success: function(data) {
						$('.nomMan-callback').html(data);
					},
					error: function(e) {
						$('.nomMan-callback').html(e);
					}
				});
			}
			
			loadLeftIndexes = function() {
				$.ajax({
					type: "GET",
					url: "#parm.url#ajax/AJAX_loadGroupIndexes.cfm",
					cache: false,
					success: function(data) {
						$('##nomMan-controls').html(data);
					}
				});
			}

			loadAll();
			loadLeftIndexes();
			$.moduleLeft();
			
			$('##nomManNew').click(function(event) {
				$.ajax({
					type: "GET",
					url: "#parm.url#ajax/AJAX_loadNewNominalAccountForm.cfm",
					success: function(data) {
						$('##nomMan-topContent').html(data).slideDown(500);
						$('body').scrollTo('##nomMan-topContent', 1000, {
							easing: "easeInOutCubic",
							offset: {left: 0, top: -40}
						});
					}
				});
				event.preventDefault();
			});
			
			$('##nomManNewGrp').click(function(event) {
				$.ajax({
					type: "GET",
					url: "#parm.url#ajax/AJAX_loadNewGroupForm.cfm",
					success: function(data) {
						$('##newGrpPopup').remove();
						$('##nomMan-topControls').append(data);
						$('##newGrpPopup').fadeIn(200);
						$('input[name="name"]').focus();
					}
				});
				event.preventDefault();
			});
		});
	</script>
	<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<div class="form-header">
						Nominal Manager
						<span><div id="loading"></div></span>
					</div>
					<div class="module" id="nomMan-topControls">
						<a href="javascript:void(0)" class="button button_white" id="nomManNew" style="float:left;margin-left:0;">New Nominal Account</a>
						<a href="javascript:void(0)" class="button button_white" id="nomManNewGrp" style="float:left;">New Group</a>
					</div>
					<div class="module" id="nomMan-topContent" style="display:none;"></div>
					<div class="module-left" id="nomMan-controls"></div>
					<div class="nomMan-callback"></div>
					<div class="clear"></div>
				</div>
				<div class="clear"></div>
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
</cfoutput>
</html>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no">
</cfcatch>
</cftry>