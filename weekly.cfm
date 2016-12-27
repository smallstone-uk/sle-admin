<!DOCTYPE html>
<html>
<head>
	<title>Weekly Report</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="css/rounds.css"/>
	<script type="text/javascript" src="common/scripts/common.js"></script>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/jquery.tablednd.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			});
	</script>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfparam name="roundsTicked" default="">
				<cfif application.site.showdumps><cfdump var="#form#" label="form" expand="no"></cfif>
				<cfobject component="code/functions" name="rnd">
				<cfset roundList={}>
				<cfset parms={}>
				<cfset parms.datasource=application.site.datasource1>
				<cfset parms.roundType="">
				<cfset roundList=rnd.LoadRoundList(parms)>
				<cfif StructKeyExists(form,"btnRun")>
					<cfsetting requesttimeout="900">
					<cfloop list="#form.roundsTicked#" index="roundNo">
						<cfset parms.roundNo=roundNo>
						<cfset roundData=rnd.LoadRoundDataForWeek(parms)>
						<!---<cfdump var="#roundData#" label="roundData" expand="no">--->
						<cfset totVoucherPerWeek=0>
						<cfset totOrderPerWeek=0>
						<cfset totDelPerWeek=0>
						<cfset totVoucherPerMonth=0>
						<cfset totOrderPerMonth=0>
						<cfset totDelPerMonth=0>
						<h1>#roundData.roundNo# - #roundData.roundName#</h1>
						<table>
							<tr>
								<th>Ref</th>
								<th>Name</th>
								<th>Address</th>
								<th align="right">voucher Per Week</th>
								<th align="right">order per week</th>
								<th align="right">del per week</th>
								<th align="right">voucher Per Month</th>
								<th align="right">order per month</th>
								<th align="right">del per month</th>
							</tr>
							<cfloop array="#roundData.orders#" index="data">
								<cfset totVoucherPerWeek=totVoucherPerWeek+data.order.voucherPerWeek>
								<cfset totOrderPerWeek=totOrderPerWeek+data.order.orderperweek>
								<cfset totDelPerWeek=totDelPerWeek+data.order.delperweek>
								<cfset totVoucherPerMonth=totVoucherPerMonth+data.order.voucherPerMonth>
								<cfset totOrderPerMonth=totOrderPerMonth+data.order.orderperMonth>
								<cfset totDelPerMonth=totDelPerMonth+data.order.delperMonth>
								<tr>
									<td>#data.cltRef#</td>
									<td>#data.cltName#</td>
									<td>#data.cltDelHouse# #data.cltDelAddr#</td>
									<td align="right">#DecimalFormat(data.order.voucherPerWeek)#</td>
									<td align="right">#DecimalFormat(data.order.orderPerWeek)#</td>
									<td align="right">#DecimalFormat(data.order.delPerWeek)#</td>
									<td align="right">#DecimalFormat(data.order.voucherPerMonth)#</td>
									<td align="right">#DecimalFormat(data.order.orderpermonth)#</td>
									<td align="right">#DecimalFormat(data.order.delpermonth)#</td>
								</tr>
							</cfloop>
							<tr>
								<th colspan="3"></th>
								<th align="right">#DecimalFormat(totVoucherPerWeek)#</th>
								<th align="right">#DecimalFormat(totOrderPerWeek)#</th>
								<th align="right">#DecimalFormat(totDelPerWeek)#</th>
								<th align="right">#DecimalFormat(totVoucherPerMonth)#</th>
								<th align="right">#DecimalFormat(totOrderPerMonth)#</th>
								<th align="right">#DecimalFormat(totDelPerMonth)#</th>
							</tr>
						</table>
					</cfloop>
				</cfif>
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Weekly Report
							<span>
								<input type="submit" name="btnRun" value="View" />
							</span>
						</div>
						<table border="0">
							<cfif StructKeyExists(roundList,"rounds")>
							<tr>
								<td valign="top"><b>Rounds</b></td>
								<td colspan="3">
									<cfloop array="#roundList.rounds#" index="item">
										<cfset checked=ListFind(roundsTicked,item.rndRef,",")>
										<label><input type="checkbox" name="roundsTicked" value="#item.rndRef#" <cfif checked> checked="checked"</cfif> />#item.rndRef# #item.rndTitle#</label>
									</cfloop>
								</td>
							</tr>
							</cfif>
						</table>
					</form>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
</body>
</cfoutput>
</html>