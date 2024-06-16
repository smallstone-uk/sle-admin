<!DOCTYPE html>
<html>
<head>
<title>Deal Manager</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<link href='https://fonts.googleapis.com/css?family=Roboto:400,300italic,300,100italic,100,400italic,500,500italic,700,700italic,900,900italic' rel='stylesheet' type='text/css'>
<link href="css/dealmanager.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.11.1.min.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/main.js" type="text/javascript"></script>
<script src="scripts/dealManager.js" type="text/javascript"></script>
</head>

<cfobject component="code/deals" name="deals">
<cfset existingDeals = deals.LoadLatestDeals()>

<cfoutput>
<body>
	<script>
		$(document).ready(function(e) {
			editDeal = function(dealID, callback) {
				$.ajax({
					type: "POST",
					url: "ajax/deals/loadEditDealForm.cfm",
					data: {"dealID": dealID},
					success: function(data) {
						if (typeof callback == "function") callback(data);
					}
				});
			}

			$(document).on("click", ".deal_item", function(event) {
				var caller = $(this);
				var dealID = Number(caller.data("id"));

				editDeal(dealID, function(data) {
					$('.deal_editor').html(data);
					$('*').blur();
				});

				event.preventDefault();
			});

			$(document).on("click", ".club_item", function(event) {
				var caller = $(this);

				$.ajax({
					type: "POST",
					url: "ajax/deals/loadEditClubForm.cfm",
					data: getDataAttributes(caller, "plain"),
					success: function(data) {
						$('.deal_editor').html(data);
						$('*').blur();
					}
				});

				event.preventDefault();
			});

			$('.ctrlCreateDeal').clickAjax({
				type: "POST",
				url: "ajax/deals/loadNewDealForm.cfm",
				data: {},
				success: function(data) {
					$('.deal_editor').html(data);
					$('*').blur();
				}
			});

			$('.ctrlCreateRetailClub').clickAjax({
				type: "POST",
				url: "ajax/deals/loadNewClubForm.cfm",
				data: {},
				success: function(data) {
					$('.deal_editor').html(data);
					$('*').blur();
				}
			});

			$('.ctrlCreateDeal').click();

			load_deals = function(retailClub) {
				$.ajax({
					type: "POST",
					url: "ajax/deals/load_deals.cfm",
					data: {"retailClub": (retailClub || $('##retailClubSelect').val())},
					success: function(data) {
						$('.deal_wrapper').html(data);
						$('*').blur();
					}
				});
			}

			load_clubs = function() {
				$.ajax({
					type: "GET",
					url: "ajax/deals/load_clubs.cfm",
					success: function(data) {
						$('.club_wrapper').html(data);
						$('*').blur();
					}
				});
			}

			$('##retailClubSelect').change(function(event) {
				var clubID = $(this).val();
				load_deals(clubID);
			});

			load_deals();
			load_clubs();
		});
	</script>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<cfset retailClubs = deals.LoadRetailClubs()>
		<div id="content">
			<div id="content-inner" style="padding-right:0;">
				<div class="module">
					<h1>Deal Manager</h1>
					<a href="javascript:void(0)" class="sleui-button ctrlCreateDeal">Create Deal</a>
					<a href="javascript:void(0)" class="sleui-button ctrlCreateRetailClub" style="margin-right: 5px;">Create Retail Club</a>
				</div>
				<div class="module" style="width:27%;">
					<h2>Existing Deals</h2>
					<div style="margin-bottom: 10px">
						<select name="retail_club" id="retailClubSelect">
						<!---	<option value="-1">All Deals</option>--->
							<optgroup label="Retail Clubs">
								<cfloop array="#retailClubs#" index="item">
									<option value="#item.ercID#">#item.ercTitle#</option>
								</cfloop>
							</optgroup>
						</select>
					</div>
					<div class="deal_wrapper"></div>
				</div>
				<div class="module" style="width: calc(48% - 20px);float: left;margin-left: 10px;">
					<h2 id="editor_title">Create Deals</h2>
					<div class="deal_editor"></div>
				</div>
				<div class="module" style="width:25%;float:left;margin-left:10px;">
					<h2>Retail Clubs</h2>
					<div class="club_wrapper"></div>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
</body>
</cfoutput>
</html>