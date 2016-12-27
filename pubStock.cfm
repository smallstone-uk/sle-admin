<!DOCTYPE html>
<html>
<head>
<title>Publication Stock</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
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
<script type="text/javascript">
	$(document).ready(function() {
		$('#supList').change(function() {
			$.ajax({
				type: 'POST',
				url: 'GetPubs.cfm',
				data : $('#stockForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#pubs').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#pubs').html(data);
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
	});
</script>
<style type="text/css">
input[type="text"] {width: 70px;}
input[type="text"].small {width: 40px;}
</style>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data" id="stockForm">
						<div class="form-header">
							Publication Stock
							<span><div id="loading"></div></span>
						</div>
						
						<div id="Supp" style="float:left;">
							<table border="0" cellpadding="2" cellspacing="0">
								<tr>
									<th>Type</th>
									<th>Supplier</th>
								</tr>
								<tr>
									<td>
										<select name="psType" data-placeholder="Select..." id="typeList">
											<option value="received">Received</option>
											<option value="returned">Returned</option>
											<option value="credited">Credited</option>
										</select>
									</td>
									<td>
										<select name="psSupID" data-placeholder="Select..." id="supList">
											<option value=""></option>
											<option value="WHS">Smiths</option>
											<option value="DASH">Dash</option>
										</select>
									</td>
								</tr>
							</table>
						</div>
						<div id="pubs" style="float:left;"></div>
						<div id="pub" style="float:left;"></div>
						<div class="clear" style="padding:5px 0;"></div>
						<div id="update"></div>
					</form>
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
<script type="text/javascript">
	$("#typeList").chosen({width: "110px",disable_search_threshold: 10});
	$("#supList").chosen({width: "100px",disable_search_threshold: 10});
</script>
</html>

