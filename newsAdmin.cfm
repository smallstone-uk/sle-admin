<!DOCTYPE html>
<html>
<head>
	<title>News Admin</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<link href="css/main5.css" rel="stylesheet" type="text/css">
	<link href="css/chosen2.css" rel="stylesheet" type="text/css">
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
	<script src="scripts/main.js"></script>
	<script type="text/javascript" src="scripts/checkDates.js"></script>
	<script type="text/javascript">
		$(function() {
			$("#tabs").tabs();
		});
	</script>
</head>

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div id="tabs">
					<ul>
						<li><a href="#Credits" id="CreditedTab">Credits</a></li>
						<li><a href="#Returns" id="ReturnedTab">Returns</a></li>
						<li><a href="#Claims" id="ClaimTab">Claims</a></li>
						<li><a href="#Received" id="ReceivedTab">Received</a></li>
					</ul>
					<div id="Credits">Credits
						<cfoutput>
						<form>
							<select name="psPubID" data-placeholder="Select..." id="pubList" class="pubselect">
								<option value=""></option>
								<cfloop from="1" to="20" index="i">
									<option value="#i#">#chr(64+i)#-item #i#</option>
								</cfloop>
							</select>
						</form>
						</cfoutput>
					</div>
					<div id="Returns">Returns
					</div>
					<div id="Claims">Claims
					</div>
					<div id="Received">Received
					</div>
				</div>
			</div>
		</div>
	</div>
	<script type="text/javascript">
		$("#pubList").chosen({width: "350px",enable_split_word_search:false});
	</script>
</body>
</html>
