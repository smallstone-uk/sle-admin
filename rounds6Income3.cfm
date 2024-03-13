<!DOCTYPE html>
<html>
<head>
<title>Rounds Income</title>
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
			LoadIncomeSheet();
			e.preventDefault();
		});
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
		.roundList {border-spacing: 0px;border-collapse: collapse;border-color: #CCC;border: 1px solid #CCC;font-size: 12px;}
		.roundList th {padding:4px; border-color: #ccc;}
		.summaryList {border-spacing: 0px;border-collapse: collapse;border-color: #CCC;border: 1px solid #CCC;font-size: 14px;}
		.summaryList th {padding:4px 5px; border-color: #ccc;}
		.summaryList td {padding:2px 5px; border-color: #ccc;}

		.header td {background-color:#55BFFF; padding:4px 5px;}
		.footer {background-color:#AAFFFF}
		.rndheader {background-color:#55BF55; font-weight:bold; font-size:20px !important}
		.rndfooter td {background-color:#D6FE89; padding:4px 0px; font-weight:bold; font-size:14px !important}
	</style>
</head>

<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.roundDate=DateFormat(DateAdd('d',1,Now()),'yyyy-mm-dd')>
<cfobject component="code/rounds6" name="rnd">
<cfset roundList=rnd.LoadRoundList(parm)>

	<cfparam name="showTrans" default="0">
	<cfparam name="showDumps" default="0">
	<cfparam name="useNewCode" default="0">
	<cfparam name="useSamples" default="0">
	<cfparam name="DeliveryCode" default="">
	
	<cfquery name="QDelRates" datasource="#application.site.datasource1#">
		SELECT * FROM tbldelcharges
		ORDER BY delCode
	</cfquery>	

	<cfquery name="QOrigCodeDelCounts" datasource="#application.site.datasource1#">
		SELECT ordDeliveryCode, delPrice1, COUNT(*) AS delCount
		FROM tblorder
		INNER JOIN tblClients ON cltID=ordClientID
		INNER JOIN tbldelcharges ON delCode=ordDeliveryCode
		WHERE ordActive = 1 
		AND cltAccountType NOT IN ('N','H')
		GROUP BY ordDeliveryCode
	</cfquery>

	<cfquery name="QNewCodeDelCounts" datasource="#application.site.datasource1#">
		SELECT ordDelCodeNew, delPrice1, COUNT(*) AS delCount
		FROM tblorder
		INNER JOIN tblClients ON cltID=ordClientID
		INNER JOIN tbldelcharges ON delCode=ordDelCodeNew
		WHERE ordActive = 1 
		AND cltAccountType NOT IN ('N','H')
		GROUP BY ordDelCodeNew
	</cfquery>

<cfoutput>
<body>
	<div id="wrapper">
		<div class="no-print"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap no-print">
					<form method="post" id="roundForm">
                    	<div id="loading" class="loading" style="float: right;margin: 11px 19px 0px 0px;"></div>
						<div class="module">
							<table border="0">
								<tr>
									<td><b>Day</b></td>
									<td><input type="text" name="roundDate" class="datepicker" value="#parm.roundDate#"></td>
								</tr>
								<tr>
                                    <td><b>Options</b></td>
                                    <td>
                                        <input name="showTrans" type="checkbox" value="1"<cfif showTrans> checked</cfif> /> Show Transactions?<br>
                                        <input name="showDumps" type="checkbox" value="1"<cfif showDumps> checked</cfif> /> Show Dumps?<br>
                                        <input name="useNewCode" type="checkbox" value="1"<cfif useNewCode> checked</cfif> /> Use New Delivery Code?<br>
                                        <input name="useSamples" type="checkbox" value="1"<cfif useSamples> checked</cfif> /> Use Sample Data?<br>
                                    </td>
                                </tr>
								<tr>
									<td></td>
									<td id="roundList" valign="top">
										<cfloop array="#roundList.rounds#" index="item">
											<label><input type="checkbox" name="roundsTicked" value="#item.ID#" class="checkbox roundstick" />#item.Title#</label>
										</cfloop>
									</td>
                                </tr>
								<tr>
									<td><b>Delivery Code</b></td>
									<td>
                                    	Select a delivery code to view:-
                                        <select name="DeliveryCode" data-placeholder="Choose a delivery charge..." class="chargeSelect">
                                            <option value="">any code</option>
                                            <cfloop query="QDelRates">
                                                <option value="#delCode#" <cfif DeliveryCode eq delCode>selected="selected"</cfif>>#delCode# - &pound;#delPrice1#</option>
                                            </cfloop>
                                        </select><br>
                                    </td>
								</tr>
								<tr>
									<td></td>
									<td><input type="button" id="btnRun" value="Go" style="float:left;display:none;"/></td>
								</tr>
							</table>
						</div>
					</form>
				</div>
				<div class="clear"></div>
				<div id="IncomeResult" class="module"></div>
				<div class="clear"></div>
			</div>
		</div>
		<div class="no-print"><cfinclude template="sleFooter.cfm"></div>
    </div>
</body>
</cfoutput>
</html>