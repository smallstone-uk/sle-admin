<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset openitems=pstock.LoadOrderProductList(parm)>

<script type="text/javascript">
	$(document).ready(function() { 
		$('.selectAll').click(function(e) {
			var id=$(this).val();
			if(this.checked) {
				$('.selectitem'+id).prop({checked: true});
				$('#controls').show();
			} else {
				$('.selectitem'+id).prop({checked: false});
				$('#controls').hide();
			};
		});
		$('a').click(function () {
			this.blur(); // or $(this).blur();
			  //...  
		});
		$('.item').click(function(e) {
			var show=false;
			$('.item').each(function() {
				if(this.checked) {
					show=true;
				};
			});
			if (show) {
				$('#controls').show();
			} else {
				$('#controls').hide();
			}
		});
		$('#btnMark').click(function(e) {
			MarkStockItems('#listForm','#marking');
			e.preventDefault();
		});
	});
</script>
	
<cftry>
	<cfoutput>
		<h3>Unscanned Items (#ArrayLen(openitems.list)#)</h3>
		<form method="post" id="listForm">
			<div style="width:100%;height:550px;overflow-y:scroll;">
				<table class="tableList" border="1" width="100%">
					<cfset ref="">
					<cfloop array="#openitems.list#" index="i">
						<cfif ref neq i.orderref>
							<cfset ref=i.orderref>
							<tr>
								<th width="5%"><input type="checkbox" class="selectAll" value="#i.orderref#" /></th>
								<th align="left" style="background:##FF8080">#i.orderref#</th>
								<th>Info</th>
								<th width="15%">Packs</th>
							</tr>
						</cfif>
						<tr>
							<td><input type="checkbox" name="selectitem" class="item selectitem#i.orderref#" value="#i.ID#" /></td>
							<td><b>#i.title#</b> #i.UnitSize# - &pound;#DecimalFormat(i.RRP)#</td>
							<td><a href="stockItems.cfm?ref=#i.prodID#" target="_blank"><img src="images/icons/info.jpg" width="25" /></a></td>
							<td align="center">#i.boxes#</td>
						</tr>
					</cfloop>
				</table>
			</div>
			<div id="controls" style="display:none;margin:10px 0;">
				<input type="button" id="btnMark" value="Out of Stock" style="float:left;"><span id="marking" style="float:right;"></span>
				<div class="clear"></div>
			</div>
			<div class="clear"></div>
		</form>
	</cfoutput>

    <cfcatch type="any">
        <cfdump var="#cfcatch#" label="cfcatch" expand="no">
    </cfcatch>
</cftry>
