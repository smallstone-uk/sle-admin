<!DOCTYPE html>
<html>
<head>
<title>Invoicing</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/rounds2.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('#btnView').click(function(event) {
			event.preventDefault();
			var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...";
			$.ajax({
				type: 'POST',
				url: 'RoundLoadList.cfm',
				data : $('#roundForm').serialize(),
				beforeSend:function(){
					$('#roundList').html(loadingText).fadeIn();
				},
				success:function(data){
					$('#roundList').html(data);
				},
				error:function(data){
					$('#roundList').html(data);
				}
			});
		});
	});
</script>
</head>

<cfsetting requesttimeout="300">

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfparam name="roundDate" default="#DateFormat(DateAdd("d",1,Now()),"yyyy-mm-dd")#">
				<cfobject component="code/rounds" name="rnd">
				<cfset parms={}>
				<cfset parms.datasource=application.site.datasource1>
				<div class="form-wrap no-print">
					<form method="post" id="roundForm">
						<div class="form-header">
							Rounds to Invoice
							<span></span>
						</div>
						<table border="0">
							<tr>
								<td width="80"><b>From</b></td>
								<td>
									<input type="text" name="fromDate" value="#DateFormat(DateAdd('m',-1,now()),'yyyy-mm-dd')#">
								</td>
								<td width="80"><b>To</b></td>
								<td>
									<input type="text" name="toDate" value="#DateFormat(now(),'yyyy-mm-dd')#">
								</td>
							</tr>
							<tr>
								<td colspan="4"><input type="button" id="btnView" value="View" style="float:left;" /></td>
							</tr>
							<tr>
								<td valign="top"><b>Rounds</b></td>
								<td id="roundList" colspan="3"></td>
							</tr>
						</table>
					</form>
				</div>
				<div class="clear"></div>
				<div id="RoundResult"></div>
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

