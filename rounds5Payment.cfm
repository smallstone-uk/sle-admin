<!DOCTYPE html>
<html>
<head>
<title>Round Payment</title>
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
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true,onClose: function() {
		}});
		$('#goReport').click(function(e) {
			LoadReport("rounds5PaymentAction.cfm","#reportForm","#reportResult");
			e.preventDefault();
		});
	});
</script>
</head>


<cfobject component="code/rounds5" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.streetOnly=true>
<cfset list=rnd.LoadRoundList(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap no-print">
					<form method="post" id="reportForm">
						<input type="hidden" name="roundTotal" value="#ArrayLen(list.rounds)#">
						<div class="form-header">
							Round Payment
							<span>
								<input type="button" id="goReport" value="Go" style="float:right;" />
								<div id="loading" class="loading" style="float:right;margin:0 10px 0 0;"></div>
							</span>
						</div>
						<table border="0" cellpadding="2" cellspacing="0" style="float:left;">
							<tr>
								<td width="150">From</td>
								<td><input type="text" name="from" class="datepicker" value="#DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')#"></td>
							</tr>
							<tr>
								<td>To</td>
								<td><input type="text" name="to" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#"></td>
							</tr>
							<tr>
								<td>Round</td>
								<td>
									<select name="roundID" id="roundID" multiple="multiple">
										<cfloop array="#list.rounds#" index="i">
											<option value="#i.ID#" selected="selected">#i.Title#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>Delivery Charge Increase</td>
								<td><input type="text" name="delinc" value="0"></td>
							</tr>
							<tr>
								<td>Mileage Allowance</td>
								<td><input type="text" name="mileageallow" value="0.20"></td>
							</tr>
						</table>
						<table border="0" cellpadding="2" cellspacing="0" style="float:left;margin:0 0 0 30px;">
							<tr>
								<td><strong>Extras</strong></td>
							</tr>
							<tr>
								<td><input type="checkbox" name="pubbonus" value="1" id="pubbonus" checked="checked"><label for="pubbonus">+1p per publication</label></td>
							</tr>
							<!---<tr>
								<td><input type="checkbox" name="dropbonus" value="1" id="dropbonus"><label for="dropbonus">+1p per drop</label></td>
							</tr>--->
							<tr>
								<td><input type="checkbox" name="mileagebonus" value="1" id="mileagebonus" checked="checked"><label for="mileagebonus">+Round mileage allowance</label></td>
							</tr>
						</table>
						<div class="clear"></div>
					</form>
				</div>
				<div id="reportResult"></div>
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
	$("#roundID").chosen({width: "100%",disable_search_threshold:10});
	$("#wageType").chosen({width: "100%",disable_search_threshold:10});
</script>
</html>
