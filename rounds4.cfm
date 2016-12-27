<!DOCTYPE html>
<html>
<head>
<title>Rounds</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/rounds2.css" rel="stylesheet" type="text/css">
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
<script type="text/javascript">
	$(document).ready(function() {
		function LoadRoundRoute() {
			$.ajax({
				type: 'POST',
				url: 'RoundLoadRoute.cfm',
				data : $('#roundForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Building round sheets...").fadeIn();
				},
				success:function(data){
					$('#loading').fadeOut();
					$('#RoundResult').html(data);
				},
				error:function(data){
					$('#loading').fadeOut();
					$('#RoundResult').html(data);
				}
			});
		};
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true,onClose: function() {
			LoadRoundRoute()
		}});
		$('#pubList').change(function(event) {
			LoadRoundRoute();
		});
		$('#btnRun').click(function(event) {
			LoadRoundRoute();
			event.preventDefault();
		});
		$('.checkbox').click(function(){
			$('#btnRun').show();
		});
		LoadRoundRoute();
	});
</script>
</head>


<cfsetting requesttimeout="300">
<cfobject component="code/functions" name="func">
<cfobject component="code/rounds" name="rnd">
<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset roundList=rnd.LoadRoundList(parm)>
<cfset clients=man.LoadCustomOrders(parm)>
<cfset pubs=func.GetPubs(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<cfparam name="roundDate" default="#DateFormat(DateAdd('d',1,Now()),'yyyy-mm-dd')#">
				<cfobject component="code/rounds" name="rnd">
				<cfset parms={}>
				<cfset parms.datasource=application.site.datasource1>
				<div class="form-wrap no-print">
					<form method="post" id="roundForm">
						<div class="form-header">
							Rounds
							<span><div id="loading" class="loading"></div></span>
						</div>
						<table border="0">
							<tr>
								<td><b>Day</b></td>
								<td colspan="3"><input type="text" name="roundDate" class="datepicker" value="#DateFormat(DateAdd('d',1,now()),'yyyy-mm-dd')#"></td>
							</tr>
							<tr><td colspan="4">&nbsp;</td></tr>
							<tr>
								<td width="80"></td>
								<td width="170" valign="top"><b>Rounds</b></td>
								<td width="170" valign="bottom"><b>Dispatch Notes</b></td>
								<td width="170" valign="bottom"><b>Options</b></td>
							</tr>
							<tr>
								<td></td>
								<td id="roundList">
									<cfloop array="#roundList.rounds#" index="item">
										<label><input type="checkbox" name="roundsTicked" value="#item.ID#" class="checkbox" checked="checked" />#item.Ref# #item.Title#</label>
									</cfloop>
								</td>
								<td valign="top">
									<cfloop array="#clients#" index="i">
										<label><input type="checkbox" name="dispatchTicked" value="#i.ClientID#" class="checkbox" checked="checked" />&nbsp;#i.ClientName#</label><br>
									</cfloop>
								</td>
								<td valign="top">
									<label><input type="checkbox" name="showSummaries" value="1" class="checkbox" checked="checked" />&nbsp;Show Round Summaries</label><br>
									<label><input type="checkbox" name="showOverallSummary" value="1" class="checkbox" checked="checked" />&nbsp;Show Overall Summary</label><br>
									<label><input type="checkbox" name="showRoundOrder" value="1" class="checkbox" checked="checked" />&nbsp;Show in Round Order</label><br>
								</td>
							</tr>
							<tr><td colspan="4">&nbsp;</td></tr>
							<tr>
								<td><b>Publications</b></td>
								<td colspan="3">
									<select name="PubSelect" data-placeholder="Show all..." id="pubList" multiple="multiple">
										<option value=""></option>
										<cfloop array="#pubs.list#" index="item">
											<option value="#item.ID#">#item.Title#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td></td>
								<td colspan="3"><input type="button" id="btnRun" value="Update" style="float:left;display:none;"/></td>
							</tr>
						</table>
					</form>
				</div>
				<div class="clear"></div>
				<div id="RoundResult"></div>
			</div>
		</div>
		<div class="no-print"><cfinclude template="sleFooter.cfm"></div>
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
<script type="text/javascript">
	$("#pubList").chosen({width: "350px",enable_split_word_search:false,allow_single_deselect: true});
</script>
</html>
