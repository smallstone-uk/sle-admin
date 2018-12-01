<style type="text/css">
	.header {width:100%;height:60px;}
	
	.ticket {width:33%;height:142px; max-height:142px;float:left;color: #000; border:solid 1px #ffffff; margin:0px;}
	
	.ticket .ticket-inner {border:solid 1px #ffffff;height:132px; background-color:#fff; overflow:hidden; margin:3px;}
	.ticket .ticket-inner .title {clear:both; float:left; width:100%; height: 50px; margin:0; color:#000;}
	.ticket .ticket-inner .info {margin:5px 0 0 0;font-size:18px; color:#000}
	.ticket .ticket-inner .code {float: left;width: 65px;font-size:11px; color:#000; margin-top:35px;}
	.ticket .ticket-inner .price {font-size: 45px; text-align:right; float:right; width:160px; right;margin: 0px 0 0 0;padding: 0 20px 20px 0;color:#000000}
	.ticket .ticket-inner .date {width: 65px;font-size: 10px; color:#000000}
/*	.ticket .ticket-inner .price {z-index:99;width: 205px;height: 20px;font-size: 50px;text-align: right;margin: 51px 0 0 0;
		padding: 20px 0;line-height: 20px; color:#0070DF}
*/
	.ticket.deal {height:134px;color: #000;background:#ffffff;}
	.ticket.deal .ticket-inner {border:dotted 1px #ffffff;}
	.ticket.deal .ticket-inner .title {font-size: 14px;width: 100%;}
	.ticket.deal .ticket-inner .info {position: absolute;z-index:99;width: 205px;margin: 100px 0 0 0;height: 20px;font-size: 12px;text-align: left; color:#000}
	.ticket.deal .ticket-inner .price {font-size: 35px;line-height: 30px;padding:0;text-align: center;height: auto;margin:10px 0;width: 100%;position: relative; color:#000;}
	.ticket.deal .ticket-inner .price .oldprice {font-size: 12px; text-decoration:line-through;line-height: 14px;}
	.ticket.deal .ticket-inner .dates {position: absolute;z-index:99;width: 205px;margin: 100px 0 0 0;height: 20px;font-size: 11px;text-align: right;}
	@page  
	{   size:portrait;
		margin-top:0px;
		margin-left:10px;
		margin-right:0px;
		margin-bottom:0px;
	}
</style>
<cftry>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfobject component="code/labels" name="labs">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfif StructKeyExists(parm.form,"dealLabels")>
	<cfset labels=labs.LoadDealLabelsFromList(parm)>
<cfelse>
	<cfset labels=labs.LoadPriceLabelsFromList(parm)>
</cfif>
<cfset count=0>
<cfoutput>
	<div class="header"></div>	
	<cfif ArrayLen(labels.list)>
		<cfset count=0>
		<cfset labelCount=0>
		<cfset itemCount=0>
		<cfloop array="#labels.list#" index="i">
			<cfset count=count+1>
			<cfset labelCount++>
			<cfset itemCount++>
			<cfif len(i.title) lt 20>
				<cfset style="font-size: 22px;">
			<cfelse><cfset style="font-size: 22px;"></cfif>
			<cfif StructKeyExists(parm.form,"dealLabels")>
				<div class="ticket deal">
					<!---<div class="ticket-inner">
						<div class="info">#i.UnitSize#</div>
						<div class="dates">Ends: #i.Ends#</div>
						<div class="price">#i.dealTitle#<cfif i.type is "discount"><div class="oldprice">was #i.price#</div></cfif></div>
						<div class="title"><span style="#style#">#i.title#</span></div>
						<div style="clear:both;"></div>
					</div>--->
				</div>
			<cfelse>
<!---				<script type="text/javascript">
					$(document).ready(function() {
						var code="#Right(i.barCode,13)#";
						var type="ean13";
						if (code.length == 8) {
							type="ean8";
						} else if (code.length == 13) {
							type="ean13";
						} else {
							type="upc";
						}
						$(".barcode#itemCount#").barcode(code, type); //,{barWidth:2, barHeight:20}
					});
				</script>
						<!---<div class="barcode#itemCount#">#i.barCode#</div>--->
--->
				<div class="ticket">
					<div class="ticket-inner">
						<div class="title"><span style="#style#">#i.title#</span></div>
						<div class="info">#i.UnitSize#</div>
						<div class="code">#i.barCode#</div>
						<div class="price">#i.price#</div>
						<div class="date">#LSDateFormat(Now(),"dd/mm/yy")#</div>
						<div style="clear:both;"></div>
					</div>
				</div>
			</cfif>
			<cfif count eq 21 AND labelCount LT ArrayLen(labels.list)>
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

