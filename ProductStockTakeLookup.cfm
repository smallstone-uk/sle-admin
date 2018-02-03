
<cftry>
	<cfset callback=1>
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm={}>
	<cfset parm.form=form>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.url = application.site.normal>
	<cfset lookup=pstock.FindProduct(parm)>
	<cfoutput>
		<script src="scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
		<script src="scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
		<script type="text/javascript">
			$(document).ready(function() { 
				$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: 0});
				
				$('##Add').click(function(e) {
					$.ajax({
						type: "POST",
						url: "#parm.url#ajax/AJAX_loadProductAdd.cfm",
						data: $('##stockform').serialize(),
						success: function(data) {
							$('##result').html(data);
						},
						error:function(data){
							$('##result').html(data);
						}			
					});
					e.preventDefault();
				});
				$('##clear').click(function(e) {
					 location.reload();
				});
			});
		</script>
		<cfswitch expression="#lookup.action#">
			<cfcase value="found">
				<table class="showTable" width="600">
					<tr><td width="200">Barcode</td><td>#lookup.barcode#</td></tr>
					<tr><td>Supplier</td><td>#lookup.supplier#</td></tr>
					<tr><td>Product ID</td><td><a href="productStock6.cfm?product=#lookup.product.prodID#" target="_blank">#lookup.product.prodID#</a></td></tr>
					<tr><td>Reference</td><td><a href="productStock6.cfm?product=#lookup.product.prodID#" target="_blank">#lookup.product.prodRef#</a></td></tr>
					<tr><td>Product</td><td>#lookup.product.prodTitle#</td></tr>
					<tr><td>Unit Size</td><td>#lookup.stockitem.siUnitSize#</td></tr>
					<tr><td>Outer Pack Qty</td><td>#lookup.stockitem.siPackQty#</td></tr>
					<tr><td>Last Counted</td><td>#LSDateFormat(lookup.product.prodCountDate)#</td></tr>
					<tr><td>Expected Stock Level</td><td>#lookup.product.prodStockLevel#</td></tr>
					<tr><td>Message</td><td>#lookup.msg#</td></tr>
					<tr><td class="ourPrice">Our Price</td><td class="ourPrice">&pound;#lookup.product.prodOurPrice#</td></tr>
				</table>
					<form method="post" enctype="multipart/form-data" id="stockform">
						<input name="barcode" type="hidden" value="#lookup.barcode#" />
						<input name="prodID" type="hidden" value="#lookup.product.prodID#" />
						<input name="prodRef" type="hidden" value="#lookup.product.prodRef#" />
						<input name="prodTitle" type="hidden" value="#lookup.product.prodTitle#" />
						<input name="maxLevel" id="maxLevel" type="hidden" value="#lookup.stockitem.siPackQty * 3#" />				
						<table class="tableList2" border="1" width="340">
							<!---<cfif val(lookup.QOrders.recordcount) gt 0>
								<input name="siID" type="hidden" value="#lookup.msgs[1].item#" />
								<tr>
									<td><b>Product Expiry Date</b></td>
									<td><input type="text" size="10" name="expiryDate" id="expiryDate" class="datepicker" /></td>
								</tr>
							</cfif>--->
							<tr>
								<td><b>Please enter the current stock level</b></td>
								<td><input type="text" size="4" name="stockLevel" id="stockLevel" /></td>
							</tr>
						</table>
					</form>
			</cfcase>
			<cfdefaultcase>
				<form method="post" enctype="multipart/form-data" id="stockform">
					<input name="barcode" type="hidden" value="#lookup.barcode#" />
				</form>
				<table class="tableList2" border="1">
					<tr>
						<td width="150">Barcode</td>
						<td width="150"><div id="barcode">#lookup.barcode#</div></td>
					</tr>
					<tr>
						<td>Message</td>
						<td>#lookup.msg#</td>
					</tr>
					<tr>
						<td colspan="2" class="request">What would you like to do?</td>
					</tr>
					<tr>
						<cfloop list="#lookup.action#" index="choice" delimiters=",">
							<td height="40" align="center">
								<button id="#choice#">#choice#</button>
							</td>
						</cfloop>
					</tr>
				</table>
			</cfdefaultcase>
		</cfswitch>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
