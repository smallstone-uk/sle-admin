<style type="text/css">
	.header {width:100%;height:50px; border:solid 1px #fff;}
	
	.ticket {width:33%;height:141px; max-height:141px;float:left;color: #000; border:solid 1px #fff; margin:0px;}
	
	.ticket .ticket-left {border:solid 1px #fff;height:132px; background-color:#fff; overflow:hidden; margin-left:0px;}
	.ticket .ticket-left .title {clear:both; float:left; width:100%; height: 50px; margin:0; color:#000000; font-size:22px;}
	.ticket .ticket-left .info {width: 100%; float:left; margin:5px 0 0 0;font-size:18px; color:#000000;}
	.ticket .ticket-left .code {width: 100%; float: left;font-size:11px; color:#000000; margin-top:16px;}
	.ticket .ticket-left .date {width: 100%; font-size: 10px;color:#000000;}
	.ticket .ticket-left .infobox {width:49%; float:left; color:#000000;}
	.ticket .ticket-left .pricebox {width:49%; float:right; color:#000000;}
	.ticket .ticket-left .rrpStyle {text-decoration:line-through; color:#ff0000; height:14px; font-size:24px;}
	.ticket .ticket-left .price {font-size: 36px; text-align:right; right;padding: 0 20px 0 0;color:#000000;}

	.ticket .ticket-inner {border:solid 1px #fff;height:132px; background-color:#fff; overflow:hidden; margin-left:15px;}
	.ticket .ticket-inner .title {clear:both; float:left; width:100%; height: 50px; margin:0; color:#000000; font-size:22px;}
	.ticket .ticket-inner .info {width: 100%; float:left; margin:5px 0 0 0;font-size:18px; color:#000000;}
	.ticket .ticket-inner .code {width: 100%; float: left;font-size:11px; color:#000000; margin-top:16px;}
	.ticket .ticket-inner .date {width: 100%; font-size: 10px;color:#000000;}
	.ticket .ticket-inner .infobox {width:49%; float:left; color:#000000;}
	.ticket .ticket-inner .pricebox {width:49%; float:right; color:#000000;}
	.ticket .ticket-inner .rrpStyle {text-decoration:line-through; color:#ff0000; height:14px; font-size:24px;}
	.ticket .ticket-inner .price {font-size: 36px; text-align:right; right;padding: 0 20px 0 0;color:#000000;}

	.ticket.deal {height:134px;color: #000;background:#ffffff;}
	.ticket.deal .ticket-inner {border:dotted 1px #ffffff;}
	.ticket.deal .ticket-inner .title {font-size: 14px;width: 100%;}
	.ticket.deal .ticket-inner .info {position: absolute;z-index:99;width: 205px;margin: 100px 0 0 0;height: 20px;font-size: 12px;text-align: left; color:#000000}
	.ticket.deal .ticket-inner .price {font-size: 36px;line-height: 30px;padding:0;text-align: center;height: auto;margin:10px 0;width: 100%;position: relative; color:#000000;}
	.ticket.deal .ticket-inner .price .oldprice {font-size: 12px; text-decoration:line-through;line-height: 14px;}
	.ticket.deal .ticket-inner .dates {position: absolute;z-index:99;width: 205px;margin: 100px 0 0 0;height: 20px;font-size: 11px;text-align: right;}<br />
	
/*	@media print {
		@page {
			size:portrait;
			margin-top:0;
			margin-left:20px;
			margin-right:20px;
			margin-bottom:0;
		}
	}
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
				<cfset count=count+1>
				<cfset labelCount++>
				<cfset itemCount++>
				<cfif len(siBookedIn)><cfset datefld = siBookedIn><cfelse><cfset datefld = Now()></cfif>
				<cfif siOurPrice lt 1><cfset ourprice = "#siOurPrice * 100#p"><cfelse><cfset ourprice = "&pound;#siOurPrice#"></cfif>
				<div class="ticket">
					<cfif count MOD 3 eq 1><cfset boxStyle="ticket-left"><cfelse><cfset boxStyle="ticket-inner"></cfif>
					<div class="#boxStyle#">
						<div class="title">#prodTitle#</div>
						<div class="infobox">
							<div class="info">#siUnitSize#</div>
							<div class="code">#barCode#</div>
							<div class="date">#LSDateFormat(datefld,"dd/mm/yy")#</div>
						</div>
						<div class="pricebox">
							<div class="rrpStyle"><cfif siRRP gt siOurPrice>#siRRP#</cfif></div>
							<div class="price">#ourprice#</div>
						</div>
						<div style="clear:both;"></div>
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

