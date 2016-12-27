<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products4" name="prod">
<cfobject component="code/ProductStock4" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>

<cfif form.step is 1>
	<!--- only return numeric value in this section --->
	<cfset lookup=prod.SendBarcode(parm)>
	<cfoutput>
		<cfif NOT len(lookup.error)>#val(lookup.data.ID)#<cfelse>0</cfif>
	</cfoutput>
<cfelseif form.step is 2>
	<cfset lookup=pstock.CheckProductOnOrder(parm)><cfdump var="#lookup#" label="CheckProductOnOrder" expand="no">
	<script type="text/javascript">
		$(document).ready(function() {
			$(".subProd").chosen({width: "300px"});
			// date panel parameters - future dates only
			$('.datepicker').datepicker({dateFormat: "dd-mm-yy",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: 0});
			
			$('#btnBookIn').click(function(e) {
				var siID=$('.siID').val();
				var prodID=$('.prodID').val();
				BookStockIn('#stockForm');
				e.preventDefault();
			});
			
			$('#yes').click(function(e) {
				$('#subSelect').show();
				$('#img').hide();
				e.preventDefault();
			});
			
			$('#no').click(function(e) {
				$('#result').html("<h1>Scan product barcode</h1>");
				e.preventDefault();
			});
			
			$('#btnSetSub').click(function(e) {
				SetSubstitute4('#stockForm');
				e.preventDefault();
			});
		});
	</script>

	<cfoutput>
		<form method="post" id="stockForm">
			<input type="hidden" name="siID" class="siID" value="#lookup.siID#" />
			<input type="hidden" name="prodID" class="prodID" value="#lookup.siProduct#" />
			<table border="1" width="600" class="stockItems">
				<tr><td rowspan="10">#lookup.img#</td></tr>
				<tr><td><a href="stockItems.cfm?ref=#lookup.prodID#" target="_blank">#lookup.prodRef#</a></td></tr>
				<tr><td>#lookup.prodTitle#</td></tr>
				<tr><td>Size : #lookup.prodUnitSize#</td></tr>
				<tr><td>&pound;#lookup.prodOurPrice# <cfif lookup.prodPriceMarked> PM </cfif></td></tr>
				<tr><td>Pack Qty : #lookup.prodPackQty#</td></tr>
				<tr><td>Received : #lookup.packs#</td></tr>
				<tr><td>Expires : #LSDateFormat(lookup.siExpires)#</td></tr>
				<tr><td>#lookup.msg2#</td></tr>
				<tr><td>#lookup.msg#</td></tr>
				<cfif lookup.sub>
					<tr><td colspan="2">
						<a href="##" id="yes" class="button" style="float:none;display:inline-block;">Yes, it's a substitute</a>
						<a href="##" id="no" class="button red" style="float:none;display:inline-block;">No, cancel scan</a>
					</td></tr>
					<tr>
						<td colspan="2">
							<cfset openGroup=false>
							<cfset openitems=pstock.LoadOrderProductList(parm)>
							<div id="subSelect" style="display:none;">
								<div style="display:inline-block;padding:20px 0;text-align:left;">
									<p>Please select the product that '#lookup.error#' is replacing.</p>
									<select name="subStockItemID" class="subProd">
										<cfset ref=0>
										<cfloop array="#openitems.list#" index="i">
											<cfif ref neq i.orderref>
												<cfset ref=i.orderref>
												<cfif openGroup></optgroup></cfif>
												<optgroup label="#i.orderref#">
												<cfset openGroup=true>
											</cfif>
											<option value="#i.ID#">#i.title# #i.UnitSize# - &pound;#DecimalFormat(i.RRP)#</option>
										</cfloop>
										<cfif openGroup></optgroup></cfif>
									</select>
									Date Expires: <input type="text" name="expiryDate" id="expiryDate" value="" class="datepicker" tabindex="1" />
									<a href="##" id="btnSetSub" class="button green" style="float:none;display:inline-block;">Assign</a>
								</div>
							</div>						
						</td>
					</tr>
				</cfif>
				<cfif lookup.prompt>
					<tr><td colspan="2">
						Date Expires: <input type="text" name="expiryDate" id="expiryDate" value="" class="datepicker" tabindex="1" />
						<a href="##" id="btnBookIn" class="button green" style="float:none;display:inline-block;">Book In</a>
					</td></tr>
				</cfif>
			</table>
		</form>
	</cfoutput>
</cfif>
