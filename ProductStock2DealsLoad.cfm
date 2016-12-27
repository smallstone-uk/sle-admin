<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset dealslist=prod.LoadDeals(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('.selectdeal').click(function() {
			if (this.checked) {
				$('.selectdeal').prop("checked",false);
				$(this).prop("checked",true);
			} else {
				$('.selectdeal').prop("checked",false);
			}
		});
		$('.selectall').click(function() {
			var id=$(this).val();
			if (this.checked) {
				$('.selectdealprod'+id).prop("checked",true);
			} else {
				$('.selectdealprod'+id).prop("checked",false);
			}
		});
		$('.showDealItems').click(function(e) {
			var id=$(this).attr("data-ID");
			$('.dealitems').hide();
			$(id).show();
			$('.showDealItems').css("font-weight","normal");
			$(this).css("font-weight","bold");
			e.preventDefault();
		});
		$('#btnPrintDeals').click(function(e) {
			PrintLabels("#dealsForm");
			e.preventDefault();
		});
	});
</script>

<cfoutput>
	<input type="button" id="btnPrintDeals" value="Print Labels" style="float:right;" /><h2>Deals</h2>
	<table width="300" class="tableList" border="1">
		<tr>
			<th width="10"></th>
			<th align="left">Title</th>
		</tr>
		<cfif ArrayLen(dealslist)>
			<cfloop array="#dealslist#" index="i">
				<tr>
					<td><input type="checkbox" name="selectdeal" class="selectdeal" value="#i.ID#"></td>
					<td><a href="##" class="showDealItems" data-ID="##items#i.ID#">#i.Title#</a></td>
				</tr>
				<tr class="dealitems" id="items#i.ID#" style="display:none;">
					<td colspan="2">
						<table width="100%" class="tableList" border="1">
							<tr>
								<th width="10"><input type="checkbox" class="selectall" value="#i.ID#"></th>
								<th align="left">Product</th>
							</tr>
							<cfif ArrayLen(i.items)>
								<cfloop array="#i.items#" index="p">
									<tr>
										<td><input type="checkbox" name="selectitem" class="selectdealprod#p.dealID#" value="#p.prodID#"></td>
										<td>#p.Title#</td>
									</tr>
								</cfloop>
							<cfelse>
								<tr><td colspan="2">No products assigned to this deal</td></tr>
							</cfif>
						</table>
					</td>
				</tr>
			</cfloop>
		<cfelse>
			<tr>
				<td colspan="2">No deals found</td>
			</tr>
		</cfif>
	</table>
</cfoutput>