<!DOCTYPE html>
<html>
<head>
<title>Forecasting</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
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
<script type="text/javascript">
	$(document).ready(function() {
		function PrintArea() {
			$('#print-area').printArea();
		};
		var mouseX;
		var mouseY;
		$(document).mousemove( function(e) {
		   mouseX = e.pageX+10; 
		   mouseY = e.pageY+5;
		}); 
		$('td.match').hover(function(event) {
			var id=$(this).attr("abbr");
			var data=parseInt($(this).html(),10);
			var data2=parseInt($('td.matche.'+id+" b").html(),10);
			var total=data+data2;
			$('td').removeClass("matched");
			$('td.'+id).addClass("matched");
			$('#total').html(total);
			if ($('#total').html() == "") {
				$('#total').hide();
			} else {
				$('#total').css({'top':mouseY,'left':mouseX}).fadeIn();
			}
		});
		$('#printBanking').click(function() {
			PrintArea();
			event.preventDefault();
		});
		
		$('.showClients').click(function(event) {
			var id = $(this).data("id");
			$.ajax({
				type: "POST",
				url: "ajax/AJAX_loadCustomersForPub.cfm",
				data: { "id": id },
				success: function(data) {
					$.popup(data);
				}
			});
			event.preventDefault();
		});
	});
</script>
<style type="text/css">
	#total {display:none;position: absolute;padding:2px 8px;background:#fff;font-size:12px;box-shadow: 0 0 6px #666;border-radius: 2px;}
	.matched {background:#00CCFF;}
	span {display:block;}
	span.red {background:#ff0000;color:#fff;}
	span.amber {background: #FF6600;color:#fff;}
</style>
</head>
<cfsetting requesttimeout="300">

<cfobject component="code/forecasting" name="cast">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.limit=0>
<cfset parm.date=LSDateFormat(Now(),"yyyy-mm-dd")>
<cfset forecast=cast.ForecastOrders(parm)>

<cfoutput>
<body>
	<div id="total"></div>
	<div id="controls" style="background: ##EEE;padding: 10px;border-bottom: 1px solid ##CCC;">
		<a href="##" id="printBanking" class="button" style="float:left;font-size:13px;">Print</a>
		<div style="float:left;" id="loading" class="loading"></div>
		<div class="clear"></div>
	</div>
	<div id="print-area" style="font-size:10px;padding:10px;width:860px;">
		<cfset pub=0>
		<cfset group="">
		<cfloop array="#forecast.sorted#" index="i">
			<cfset pub=StructFind(forecast.pubs,i)>
			<cfif pub.group is "news">
				<cfset minium=10>
			<cfelse>
				<cfset minium=0>
			</cfif>
			<cfif pub.group neq group>
				<cfif len(group)></table></cfif>
				<cfset group=pub.group>
				<table border="1" class="tableList trhover" style="float:left;margin:0 10px 0 0;">
				<tr>
					<th colspan="8">#pub.group#</th>
				</tr>
				<tr>
					<th>Publication</th>
					<th width="20">Mon</th>
					<th width="20">Tue</th>
					<th width="20">Wed</th>
					<th width="20">Thu</th>
					<th width="20">Fri</th>
					<th width="20">Sat</th>
					<th width="20">Sun</th>
				</tr>
			</cfif>
			<tr>
				<td><a href="javascript:void(0)" data-id="#pub.id#" class="showClients">#pub.Title#</a></td>
				<td align="center" class="matche mon#pub.ID#" abbr="mon#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stockmon gt pub.mon>
							<cfset monclass="amber">
						<cfelse>
							<cfif pub.stockmon lt pub.mon>
								<cfset monclass="red">
							<cfelse>
								<cfset monclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.mon gt 0>
							<cfset diffmon=pub.stockmon-pub.mon>
							<cfset diffmon=diffmon/pub.mon*100>
							<cfif diffmon lte minium>
								<cfset monclass="red">
							<cfelse>
								<cfset monclass="">
							</cfif>
						<cfelse>
							<cfset monclass="">
						</cfif>
					</cfif>
					<span class="#monclass#" title="#pub.stockmon#"><cfif pub.mon neq 0><b>#pub.mon#</b></cfif></span>
				</td>
				<td align="center" class="matche tue#pub.ID#" abbr="tue#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stocktue gt pub.tue>
							<cfset tueclass="amber">
						<cfelse>
							<cfif pub.stocktue lt pub.tue>
								<cfset tueclass="red">
							<cfelse>
								<cfset tueclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.tue gt 0>
							<cfset difftue=pub.stocktue-pub.tue>
							<cfset difftue=difftue/pub.tue*100>
							<cfif difftue lte minium>
								<cfset tueclass="red">
							<cfelse>
								<cfset tueclass="">
							</cfif>
						<cfelse>
							<cfset tueclass="">
						</cfif>
					</cfif>
					<span class="#tueclass#" title="#pub.stocktue#"><cfif pub.tue neq 0><b>#pub.tue#</b></cfif></span>
				</td>
				<td align="center" class="matche wed#pub.ID#" abbr="wed#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stockwed gt pub.wed>
							<cfset wedclass="amber">
						<cfelse>
							<cfif pub.stockwed lt pub.wed>
								<cfset wedclass="red">
							<cfelse>
								<cfset wedclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.wed gt 0>
							<cfset diffwed=pub.stockwed-pub.wed>
							<cfset diffwed=diffwed/pub.wed*100>
							<cfif diffwed lte minium>
								<cfset wedclass="red">
							<cfelse>
								<cfset wedclass="">
							</cfif>
						<cfelse>
							<cfset wedclass="">
						</cfif>
					</cfif>
					<span class="#wedclass#" title="#pub.stockwed#"><cfif pub.wed neq 0><b>#pub.wed#</b></cfif></span>
				</td>
				<td align="center" class="matche thu#pub.ID#" abbr="thu#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stockthu gt pub.thu>
							<cfset thuclass="amber">
						<cfelse>
							<cfif pub.stockthu lt pub.thu>
								<cfset thuclass="red">
							<cfelse>
								<cfset thuclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.thu gt 0>
							<cfset diffthu=pub.stockthu-pub.thu>
							<cfset diffthu=diffthu/pub.thu*100>
							<cfif diffthu lte minium>
								<cfset thuclass="red">
							<cfelse>
								<cfset thuclass="">
							</cfif>
						<cfelse>
							<cfset thuclass="">
						</cfif>
					</cfif>
					<span class="#thuclass#" title="#pub.stockthu#"><cfif pub.thu neq 0><b>#pub.thu#</b></cfif></span>
				</td>
				<td align="center" class="matche fri#pub.ID#" abbr="fri#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stockfri gt pub.fri>
							<cfset friclass="amber">
						<cfelse>
							<cfif pub.stockfri lt pub.fri>
								<cfset friclass="red">
							<cfelse>
								<cfset friclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.fri gt 0>
							<cfset difffri=pub.stockfri-pub.fri>
							<cfset difffri=difffri/pub.fri*100>
							<cfif difffri lte minium>
								<cfset friclass="red">
							<cfelse>
								<cfset friclass="">
							</cfif>
						<cfelse>
							<cfset friclass="">
						</cfif>
					</cfif>
					<span class="#friclass#" title="#pub.stockfri#"><cfif pub.fri neq 0><b>#pub.fri#</b></cfif></span>
				</td>
				<td align="center" class="matche sat#pub.ID#" abbr="sat#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stocksat gt pub.sat>
							<cfset satclass="amber">
						<cfelse>
							<cfif pub.stocksat lt pub.sat>
								<cfset satclass="red">
							<cfelse>
								<cfset satclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.sat gt 0>
							<cfset diffsat=pub.stocksat-pub.sat>
							<cfset diffsat=diffsat/pub.sat*100>
							<cfif diffsat lte minium>
								<cfset satclass="red">
							<cfelse>
								<cfset satclass="">
							</cfif>
						<cfelse>
							<cfset satclass="">
						</cfif>
					</cfif>
					<span class="#satclass#" title="#pub.stocksat#"><cfif pub.sat neq 0><b>#pub.sat#</b></cfif></span>
				</td>
				<td align="center" class="matche sun#pub.ID#" abbr="sun#pub.ID#">
					<cfif pub.saletype is "limited" OR pub.saletype is "firm">
						<cfif pub.stocksun gt pub.sun>
							<cfset sunclass="amber">
						<cfelse>
							<cfif pub.stocksun lt pub.sun>
								<cfset sunclass="red">
							<cfelse>
								<cfset sunclass="">
							</cfif>
						</cfif>
					<cfelse>
						<cfif pub.sun gt 0>
							<cfset diffsun=pub.stocksun-pub.sun>
							<cfset diffsun=diffsun/pub.sun*100>
							<cfif diffsun lte minium>
								<cfset sunclass="red">
							<cfelse>
								<cfset sunclass="">
							</cfif>
						<cfelse>
							<cfset sunclass="">
						</cfif>
					</cfif>
					<span class="#sunclass#" title="#pub.stocksun#"><cfif pub.sun neq 0><b>#pub.sun#</b></cfif></span>
				</td>
			</tr>
		</cfloop>
		</table>
		
		<cfset pub=0>
		<cfset group="">
		<cfloop array="#forecast.customsorted#" index="i">
			<cfset pub=StructFind(forecast.custompubs,i)>
			<cfif pub.group neq group>
				<cfif len(group)></table></cfif>
				<cfset group=pub.group>
				<table border="1" class="tableList trhover" style="float:left;margin:0 10px 0 0;">
				<tr>
					<th colspan="8">Custom Orders for #pub.group# (averages)</th>
				</tr>
				<tr>
					<th>Publication</th>
					<th width="20">Mon</th>
					<th width="20">Tue</th>
					<th width="20">Wed</th>
					<th width="20">Thu</th>
					<th width="20">Fri</th>
					<th width="20">Sat</th>
					<th width="20">Sun</th>
				</tr>
			</cfif>
			<tr>
				<td><a href="javascript:void(0)" data-id="#pub.id#" class="showClients">#pub.Title#</a></td>
				<td align="center" class="match mon#pub.ID#" abbr="mon#pub.ID#"><cfif pub.mon neq 0>#round(pub.mon)#</cfif></td>
				<td align="center" class="match tue#pub.ID#" abbr="tue#pub.ID#"><cfif pub.tue neq 0>#round(pub.tue)#</cfif></td>
				<td align="center" class="match wed#pub.ID#" abbr="wed#pub.ID#"><cfif pub.wed neq 0>#round(pub.wed)#</cfif></td>
				<td align="center" class="match thu#pub.ID#" abbr="thu#pub.ID#"><cfif pub.thu neq 0>#round(pub.thu)#</cfif></td>
				<td align="center" class="match fri#pub.ID#" abbr="fri#pub.ID#"><cfif pub.fri neq 0>#round(pub.fri)#</cfif></td>
				<td align="center" class="match sat#pub.ID#" abbr="sat#pub.ID#"><cfif pub.sat neq 0>#round(pub.sat)#</cfif></td>
				<td align="center" class="match sun#pub.ID#" abbr="sun#pub.ID#"><cfif pub.sun neq 0>#round(pub.sun)#</cfif></td>
			</tr>
		</cfloop>
		</table>
	</div>
</body>
</cfoutput>
</html>

