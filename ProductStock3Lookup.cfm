<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.form.source="product">
<cfset parm.form.productID=0>

<cfif form.step is 1>
	<cfset lookup=prod.SendBarcode(parm)>
	<cfoutput>
		<cfif NOT len(lookup.error)>#val(lookup.data.ID)#<cfelse>0</cfif>
	</cfoutput>
<cfelseif form.step is 2>
	<cfset lookup=pstock.CheckProductOnOrder(parm)>
	<cfoutput>
		<cfif NOT len(lookup.error)>
			<h2 style="font-size:40px;line-height: 60px;">#lookup.title# #lookup.unitsize#</h2>
			<h1 style="font-size:40px;">&pound;#DecimalFormat(lookup.RRP)# <cfif lookup.pm>PM</cfif></h1>
			<div class="clear"></div>
			<cfif lookup.received is lookup.boxes><img src="images/tick.png" width="64" /><cfelse><img src="images/warning.png" width="64" /></cfif>
			<p style="font-size:30px;">Booked In</p>
			<cfif lookup.received lt lookup.boxes>
				<h3>Number of Packs Remaining: #lookup.boxes-lookup.received#</h3>
			<cfelse>
				<h3 style="font-size:30px;">Number of Packs: #lookup.received#/#lookup.boxes#</h3>
			</cfif>
			<h3>Total Products: #lookup.qtytotal#</h3>
		<cfelse>
			<h2 style="font-size:40px;line-height: 60px;">#lookup.error#</h2>
			<h1 style="font-size:40px;">&pound;#DecimalFormat(lookup.RRP)#</h1>
			<div class="clear" style="padding:10px 0;"></div>
			<div id="img">#lookup.img#</div>
			#lookup.msg#
			<cfif lookup.sub>
				<cfset openitems=pstock.LoadOrderProductList(parm)>
				<script type="text/javascript">
					$(document).ready(function() { 
						$('##yes').click(function(e) {
							$('##subSelect').show();
							$('##img').hide();
							$('##yes').hide();
							$('##no').hide();
							e.preventDefault();
						});
						$('##no').click(function(e) {
							$('##result').html("<h1>Scan product barcode</h1>");
							e.preventDefault();
						});
						$('##btnSetSub').click(function(e) {
							var siID=$('.subProd').val();
							var prodID=$('.subProdID').val();
							SetSubstitute(siID,prodID);
							e.preventDefault();
						});
						$(".subProd").chosen({width: "400px"});
					});
				</script>
				<a href="##" id="yes" class="button" style="float:none;display:inline-block;">Yes, it's a substitute</a>
				<a href="##" id="no" class="button red" style="float:none;display:inline-block;">No, cancel scan</a>
				<div id="subSelect" style="display:none;">
					<div style="display:inline-block;padding:20px 0;text-align:left;">
						<input type="hidden" class="subProdID" value="#lookup.prodID#" />
						<select name="ProdonOrder" class="subProd">
							<cfset ref=0>
							<cfloop array="#openitems.list#" index="i">
								<cfif ref neq i.orderref>
									<cfset ref=i.orderref>
									</optgroup>
									<optgroup label="#i.orderref#">
								</cfif>
								<option value="#i.ID#">#i.title# #i.UnitSize# - &pound;#DecimalFormat(i.RRP)#</option>
							</cfloop>
							</optgroup>
						</select>
						<a href="##" id="btnSetSub" class="button green" style="float:none;display:inline-block;">Assign</a>
					</div>
				</div>
			</cfif>
		</cfif>
	</cfoutput>
</cfif>