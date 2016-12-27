<!DOCTYPE html>
<html>
<head>
<title>Client Details</title>
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
<script src="scripts/jquery.tablednd.js"></script>
<script src="scripts/pubstock.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: false});
		$('.detailtab').click(function(e) {
			var id=$(this).attr("href");
			var file=$(this).attr("data-file");
			var custID=$(this).attr("data-custID");
			var custRef=$(this).attr("data-custRef");
			var srchDelDate=$(this).attr("data-srchDelDate");
			$.ajax({
				type: 'POST',
				url: file,
				data: {
					"customer.rec.cltID":custID,
					"customer.rec.cltRef":custRef,
					"srchDelDate":srchDelDate
				},
				success:function(data){
					$(id).html(data);
				}
			});
			e.preventDefault();
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
				<cftry>
					<cfobject component="code/functions" name="cust">
					<cfif StructKeyExists(session,"clientSearch")>
						<cfset search=Duplicate(session.clientSearch)>
						<cfif StructKeyExists(form,"search")>
							<cfset search.row=form.row>
							<cfif StructKeyExists(form,"next")>
								<cfset search.direction="next">
							<cfelseif StructKeyExists(form,"prev")>
								<cfset search.direction="prev">
							<cfelseif StructKeyExists(form,"first")>
								<cfset search.direction="first">
							<cfelseif StructKeyExists(form,"last")>
								<cfset search.direction="last">
							</cfif>
						<cfelseif StructKeyExists(url,"row")>
							<cfset search.row=url.row>
						</cfif>
						<cfif StructKeyExists(form,"fieldnames")>
							<cfset parm={}>
							<cfset parm.form=form>
							<cfset parm.datasource=application.site.datasource1>
							<cfif StructKeyExists(form,"btnAddOrder")>
								<cfset newOrder=cust.AddOrder(parm)>
							</cfif>
						</cfif>
						<cfset search.datasource=application.site.datasource1>
					<cfelse>
						<cfset search={}>
						<cfset search.datasource=application.site.datasource1>
						<cfset search.srchRefFrom="">
						<cfset search.srchRefTo="">
						<cfset search.srchName="">
						<cfset search.srchAddr="">
						<cfset search.srchLastDel="">
						<cfset search.srchType="">
						<cfset search.limitRecs="">
						<cfset search.srchSort="">
						<cfset search.srchDelDate="recent">
					</cfif>
					
					<cfif StructKeyExists(URL,"ref")>
						<cfset search.clientRef=url.ref>
					</cfif>
					<cfset session.clientSearch=search>
						
					<cfset customer=cust.LoadClient(search)>
					<cfset session.clientSearch=customer>
					<cfset custOrder=cust.LoadClientOrder(customer)>
															
					<cfset init.datasource=search.datasource>
					<cfset init.streetcode=customer.rec.cltStreetCode>
					<cfset street=cust.LoadStreets(customer)>
					<cfset charges=cust.LoadDeliveryCharges(customer)>
					<div class="form-wrap">
						<script type="text/javascript">
							$(function() {
								$("##tabs").tabs();
							});
						</script>
						<div id="clientHeader"><cfinclude template="clientHeader.cfm"></div>
						<div id="tabs">
							<ul class="no-print">
								<li><a href="##Orders">Orders</a></li>
								<li><a href="##Messages" class="detailtab" data-file="clientMsgs.cfm" data-custID="#customer.rec.cltID#" data-custRef="#customer.rec.cltRef#" data-srchDelDate="#customer.srchDelDate#">Messages</a></li>
								<li><a href="##Trans" class="detailtab" data-file="clientTrans.cfm" data-custID="#customer.rec.cltID#" data-custRef="#customer.rec.cltRef#" data-srchDelDate="#customer.srchDelDate#">Transactions</a></li>
								<li><a href="##DelItems" class="detailtab" data-file="clientDelItems.cfm" data-custID="#customer.rec.cltID#" data-custRef="#customer.rec.cltRef#" data-srchDelDate="#customer.srchDelDate#">Deliveries</a></li>
							</ul>
							<div id="Orders"><cfinclude template="clientOrder.cfm"></div>
							<div id="Messages"></div>
							<div id="Trans"></div>
							<div id="DelItems"></div>
						</div>
					</div>
		
				<cfcatch type="any">
					<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
						output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
				</cfcatch>
				</cftry>
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

