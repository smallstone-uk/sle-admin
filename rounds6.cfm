<!DOCTYPE html>
<html>
<head>
<title>Rounds 6</title>
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
<script src="scripts/rounds6.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {

		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1),onClose: function() {}});
		$('#btnRun').click(function(e) {
			LoadRoundSheet();
			e.preventDefault();
		});
		$('.selectAllOnList').click(function(event) {
			if (this.checked) {
				$('.roundstick').prop({checked: true});
				$('.selectAllOnList').prop({checked: true});
			} else {
				$('.roundstick').prop({checked: false});
				$('.selectAllOnList').prop({checked: false});
			}
		})
		$('#showRoundOrder').click(function(e) {
			if (this.checked) {
				$('#priorityLink').hide();
				$('.dispatchtick').prop("checked",true);
				$('#showSummaries').prop("checked",true);
			} else {
				$('#priorityLink').show();
				$('.dispatchtick').prop("checked",false);
				$('#showSummaries').prop("checked",false);
			}
		});
		$('#btnRun').show();
	});
</script>
	<style type="text/css">
		body {background-color:#FFFFFF;}
	</style>
</head>


<cfsetting requesttimeout="300">
<cfobject component="code/functions" name="func">
<cfobject component="code/rounds6" name="rnd">
<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.roundDate=DateFormat(DateAdd('d',1,Now()),'yyyy-mm-dd')>
<cfset parm.pubGroup='news'>
<cfset roundList=rnd.LoadRoundList(parm)>
<cfset clients=man.LoadCustomOrders(parm)>
<cfset pubs=func.GetPubs(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap no-print">
					<form method="post" id="roundForm">
						<div class="form-header">
							Rounds <p style="float:right;font-size:12px;color:##666;margin: 16px 0 0 0;">Version 6.0</p>
							<div id="loading" class="loading" style="float: right;margin: 11px 19px 0px 0px;"></div>
						</div>
						<div class="module">
							<table border="0">
								<tr>
									<td><b>Day</b></td>
									<td colspan="4"><input type="text" name="roundDate" class="datepicker" value="#parm.roundDate#"></td>
								</tr>
								<tr><td colspan="4">&nbsp;</td></tr>
								<tr>
									<td width="80"></td>
									<td width="120" valign="top"><b>Rounds</b></td>
									<!---<td width="250" valign="bottom"><b>Despatch Notes (NOT USED)</b></td>--->
									<td width="200" valign="bottom"><b>Options</b></td>
									<td width="300" valign="bottom"><b>Info</b></td>
								</tr>
								<tr>
									<td></td>
									<td id="roundList" valign="top">
										<input type="checkbox" name="selectAllOnList" class="selectAllOnList" checked="checked" />
										<cfloop array="#roundList.rounds#" index="item">
											<label><input type="checkbox" name="roundsTicked" value="#item.ID#" class="checkbox roundstick" checked="checked" />#item.Title#</label>
										</cfloop>
									</td>
<!---
									<td valign="top">
										<cfloop array="#clients#" index="i">
											<label><input type="checkbox" name="dispatchTicked" value="#i.ID#" class="checkbox dispatchtick" />
											&nbsp;#i.ClientName#</label><br>
										</cfloop>
									</td>
--->
									<td valign="top">
										<label><input type="checkbox" name="showSummaries" id="showSummaries" value="1" class="checkbox" />&nbsp;Show Round Summaries</label><br>
										<label><input type="checkbox" name="showOverallSummary" value="1" class="checkbox" />&nbsp;Show Overall Summary</label><br>
										<label><input type="checkbox" name="showRoundOrder" id="showRoundOrder" value="1" class="checkbox" checked="checked" />&nbsp;Show in Round Order</label><br>
										<label id="priorityLink" style="display:none;">
											<a href="rounds5PriorityOrdering.cfm" target="_blank" style="display:block;padding:5px 0 0 24px;">Sort Priority Order</a>
										</label><br>
									</td>
									<td valign="top">
										To move a customer into a care home; change their Order Group to the relevant home then move their account into the same round
										position as other residents for each day. Also, change the House/Flat number to the person's name in the Order Details.
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
									<td colspan="3"><input type="button" id="btnRun" value="Go" style="float:left;display:none;"/></td>
								</tr>
							</table>
						</div>
					</form>
				</div>
				<div class="clear"></div>
				<div id="RoundResult" class="module"></div>
				<div class="clear"></div>
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
