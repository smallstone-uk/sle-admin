<style type="text/css">
	.header {width:100%; height:10px; border:solid 1px #ff000;}
	
	.ticket {width:230px; height:141px; max-height:141px; float:left;color:#000; border:dashed 1px #fff; margin:0px;}
 	
	.ticket .ticket-left {border:solid 1px #eee; height:132px; background-color:#fff; overflow:hidden; margin:0px; padding:10px;}
	.ticket .ticket-left .title {clear:both; float:left; width:100%; height: 50px; margin:0; overflow:hidden; color:#000000; font-size:18px;}
	.ticket .ticket-left .info {width: 100%; float:left; margin:0 0 0 0; height: 40px; font-size:18px; color:#000000;}
	.ticket .ticket-left .price {text-align:right; padding:0 0 0 0; color:#000000; height:28px; font-size:22px; font-weight:bold;}
	.ticket .ticket-left .code {width: 58%; float: left; font-size:11px; color:#000000; margin-top:4px;}
	.ticket .ticket-left .date {width: 38%; float:right; font-size: 10px; color:#000000; margin-top:4px; text-align:right;}
	.ticket .ticket-left .foozy {width:100%; float:left; color:#000000; border:solid 1px #fff;}
	.ticket .ticket-left .infobox {width:49%; float:left; color:#000000;}
	.ticket .ticket-left .pricebox {width:49%; float:right; color:#000000; height: 28px;}
	.ticket .ticket-left .codebox {width: 100%; float:left; color:#000000; margin-top:5px;}
	.ticket .ticket-left .rrpStyle {text-decoration:line-through; float:left; color:#ff0000; height:14px; font-size:16px;}

	.ticket .ticket-inner {border:solid 1px #eee; height:132px; background-color:#fff; overflow:hidden; margin-left:0px; padding:10px;}
	.ticket .ticket-inner .title {clear:both; float:left; width:100%; height: 50px; margin:0; overflow:hidden; color:#000000; font-size:18px;}
	.ticket .ticket-inner .info {width: 100%; float:left; margin:0 0 0 0; height: 40px; font-size:18px; color:#000000;}
	.ticket .ticket-inner .price {text-align:right; padding:0 0 0 0; color:#000000; height:28px; font-size:22px; font-weight:bold;}
	.ticket .ticket-inner .code {width: 58%; float: left; font-size:11px; color:#000000; margin-top:4px;}
	.ticket .ticket-inner .date {width: 38%; float:right; font-size: 10px; color:#000000; margin-top:4px; float:right; text-align:right;}
	.ticket .ticket-inner .foozy {width:100%; float:left; color:#000000; border:solid 1px #fff;}
	.ticket .ticket-inner .infobox {width:49%; float:left; color:#000000;}
	.ticket .ticket-inner .pricebox {width:49%; float:right; color:#000000; height: 28px;}
	.ticket .ticket-inner .codebox {width: 100%; float:left; color:#000000; margin-top:5px;}
	.ticket .ticket-inner .rrpStyle {text-decoration:line-through; float:left; color:#ff0000; height:14px; font-size:16px;}
	
/*	@media print {
		@page {
			size:portrait;
			margin-top:0;
			margin-left:20px;
			margin-right:20px;
			margin-bottom:0;
		}
	}
	border:dashed 1px #000;
*/
</style>
<cftry>
	<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
	<cfset callback=1>
	<cfsetting showdebugoutput="no" requesttimeout="300">
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfquery name="getStockListFromDB" datasource="#parm.datasource#">
		SELECT ctlStockList
		FROM tblControl
		WHERE ctlID = 1
	</cfquery>
	<cfset parm.stocklist = getStockListFromDB.ctlStockList>
	<cfif Len(parm.stocklist)>
		<cfset labels = pstock.LoadStockFromList(parm)>
	<cfelse>
		<strong>Your list is empty.</strong>
		<cfabort>
	</cfif>
	<cfset count=0>
	<cfoutput>
		<div class="header"></div>
		<cfif labels.stockItems.recordCount gt 0>
			<cfset count=0>
			<cfset labelCount=0>
			<cfset itemCount=0>
			<cfloop query="labels.stockItems">
				<cfset count++>
				<cfset labelCount++>
				<cfset itemCount++>
				<cfif len(siBookedIn)><cfset datefld = siBookedIn><cfelse><cfset datefld = Now()></cfif>
				<cfif siOurPrice lt 1><cfset ourprice = "#siOurPrice * 100#p"><cfelse><cfset ourprice = "&pound;#siOurPrice#"></cfif>
				<div class="ticket">
					<cfif count MOD 3 eq 1><cfset boxStyle="ticket-left"><cfelse><cfset boxStyle="ticket-inner"></cfif>
					<div class="#boxStyle#">
						<div class="title">#Left(prodTitle,50)#</div>
						<div class="foozy">
							<div class="infobox">
								<div class="info">#siUnitSize#</div>							
							</div>
							<div class="pricebox">
								<cfif siRRP gt siOurPrice><div class="rrpStyle">#siRRP#&nbsp;</div></cfif>
								<div class="price">#ourprice#</div>
							</div>
						</div>
						<div class="codebox">
							<div class="code">#barCode#</div>
							<div class="date">#LSDateFormat(datefld,"yymmdd")#</div>
							<div style="clear:both;"></div>
						</div>
					</div>
				</div>
				<cfif count eq 21 AND labelCount LT labels.stockItems.recordCount>
					<cfset count=0>
					<div style="page-break-after:always;clear:both;"></div>
					<div class="header"></div>
				</cfif>
			</cfloop>
		<cfelse>
			<p>No Products Found</p>
		</cfif>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
