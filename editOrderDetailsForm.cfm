<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.orderID=form.orderID>
<cfset parm.clientID=form.cltID>
<cfset clientInfo.info=cust.LoadClientByID(parm)>
<cfset street=cust.LoadStreets(parm)>
<cfset charges=cust.LoadDeliveryCharges(parm)>
<cfset order=cust.LoadOrder(parm)>
<cfset orderGroups = cust.LoadOrderGroups(parm)>

<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
		$("##autoFill").change(function() {
			var $input = $(this);
			if ($input.prop('checked')) {
				var street=$("##delStreet").val();
				$("##ordRef").val($("##ordRef").val());
				$("##ordHouseName").val($("##delHouseName").val());
				$("##ordHouseNumber").val($("##delHouseNumber").val());
				$("##ordStreetCode").val($("##delStreet").val());
				$("##ordTown").val($("##delTown").val());
				$("##ordCity").val($("##delCity").val());
				$("##ordPostcode").val($("##delPostcode").val());
				$("##ordDeliveryCode").val($("##delCode").val());
				$("##ordDelCodeNew").val($("##ordDelCodeNew").val());
				$("##ordStreetCode").trigger("chosen:updated");
				$("##ordDeliveryCode").trigger("chosen:updated");
			} else {
				$("##ordRef").val("");
				$("##ordHouseName").val("");
				$("##ordHouseNumber").val("");
				$("##ordStreetCode").val("");
				$("##ordTown").val("");
				$("##ordCity").val("");
				$("##ordPostcode").val("");
			};
		});
		$("##btnSave").click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'editOrderDetailsAction.cfm',
				data : $('##editForm').serialize(),
				success:function(data){
					$('##saveResults').html(data);
					$('##saveResults').show();
					setTimeout(function(){$("##saveResults").fadeOut("slow");}, 5000);
				}
			});
			event.preventDefault();
		})
	});
</script>
<form method="post" enctype="multipart/form-data" id="editForm">
	<h1 style="width:500px;">
		Edit Order
		<button id="btnSave" type="submit" class="overlayNav">
			<img src="images/icons/save.png">&nbsp;Save
		</button>
	</h1>
	<div id="saveResults" style="display:none;"></div>
	<input type="hidden" name="orderID" value="#parm.orderID#" />
	<input type="hidden" name="cltID" value="#clientInfo.info[1].cltID#" />
	<input type="hidden" name="cltRef" value="#clientInfo.info[1].cltRef#" />
	<input type="hidden" name="cltDelHouseName" value="#clientInfo.info[1].cltDelHouseName#" id="delHouseName" />
	<input type="hidden" name="cltDelHouseNumber" value="#clientInfo.info[1].cltDelHouseNumber#" id="delHouseNumber" />
	<input type="hidden" name="cltStreetCode" value="#clientInfo.info[1].cltStreetCode#" id="delStreet" />
	<input type="hidden" name="cltDelTown" value="#clientInfo.info[1].cltDelTown#" id="delTown" />
	<input type="hidden" name="cltDelCity" value="#clientInfo.info[1].cltDelCity#" id="delCity" />
	<input type="hidden" name="cltDelPostcode" value="#clientInfo.info[1].cltDelPostcode#" id="delPostcode" />
	<input type="hidden" name="cltDelCode" value="#clientInfo.info[1].cltDelCode#" id="delCode" />
	<table border="0" width="450">
		<tr>
			<td width="25%" align="right"><input type="checkbox" name="ordSameAsBilling" value="1" id="autoFill" /></td>
			<td><label for="autoFill">Copy default address</label></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order Reference</strong></td>
			<td><input type="text" name="ordRef" value="#order.ordRef#" id="ordRef" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order Contact</strong></td>
			<td><input type="text" name="ordContact" value="#order.ordContact#" id="ordContact" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>House/Building Name</strong></td>
			<td><input type="text" name="ordHouseName" value="#order.HouseName#" id="ordHouseName" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>House/Flat Number</strong></td>
			<td><input type="text" name="ordHouseNumber" value="#order.HouseNumber#" id="ordHouseNumber" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Street</strong></td>
			<td>
				<select name="ordStreetCode" data-placeholder="Choose a Street..." class="select" id="ordStreetCode">
					<option value=""></option>
					<cfif ArrayLen(street)>
						<cfloop array="#street#" index="i">
							<option value="#i.ID#"<cfif order.streetcode eq i.ID> selected="selected"</cfif>>#i.Name#</option>
						</cfloop>
					</cfif>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Town</strong></td>
			<td><input type="text" name="ordTown" value="#order.Town#" id="ordTown" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>City</strong></td>
			<td><input type="text" name="ordCity" value="#order.City#" id="ordCity" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Postcode</strong></td>
			<td><input type="text" name="ordPostcode" value="#order.Postcode#" id="ordPostcode" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Delivery Note</strong></td>
			<td><input type="text" name="ordNote" value="#order.Note#" id="ordNote" style="width:95%;" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Current Delivery Charge</strong></td>
			<td>
				<select name="ordDeliveryCode" data-placeholder="Choose a charge..." id="ordDeliveryCode">
					<option value=""></option>
					<cfif ArrayLen(charges)>
						<cfloop array="#charges#" index="i">
							<option value="#i.Code#"<cfif order.DeliveryCode eq i.Code> selected="selected"</cfif>>#i.Code# - &pound;#i.Price1#</option>
						</cfloop>
					</cfif>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>New Delivery Charge</strong></td>
			<td>
				<select name="ordDelCodeNew" data-placeholder="Choose a charge..." id="ordDelCodeNew">
					<option value=""></option>
					<cfif ArrayLen(charges)>
						<cfloop array="#charges#" index="i">
							<option value="#i.Code#"<cfif order.DelCodeNew eq i.Code> selected="selected"</cfif>>#i.Code# - &pound;#i.Price1#</option>
						</cfloop>
					</cfif>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order Group</strong></td>
			<td>
				<select name="ordGroup">
					<cfloop query="orderGroups.QGetOrderGroups">
						<option value="#ogID#"<cfif order.ordGroup eq ogID> selected="selected"</cfif>>#ogName#</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order</strong></td>
			<td>
				<select name="ordType">
					<option value="Standard"<cfif order.Type eq "Standard"> selected="selected"</cfif>>Standing Order</option>
					<option value="Custom"<cfif order.Type eq "Custom"> selected="selected"</cfif>>Custom Order</option>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Active</strong></td>
			<td>
				<select name="ordActive">
					<option value="1"<cfif order.Active eq 1> selected="selected"</cfif>>Yes</option>
					<option value="0"<cfif order.Active eq 0> selected="selected"</cfif>>No</option>
				</select>
			</td>
		</tr>
		<tr><td colspan="2"></td></tr>
		<tr>
			<td width="25%" align="right"><input type="checkbox" name="ordDifferent"<cfif order.ordDifferent> checked="checked"</cfif> value="1" id="ordDifferent" /></td>
			<td><label for="ordDifferent">Delivery address differs from Billing address</label></td>
		</tr>
		<tr><td colspan="2"></td></tr>
		<tr>
			<th align="right" valign="top">Delivery Days</th>
			<td align="center">
				<table>
					<tr>
						<th width="8">Mon</th>
						<th width="8">Tue</th>
						<th width="8">Wed</th>
						<th width="8">Thu</th>
						<th width="8">Fri</th>
						<th width="8">Sat</th>
						<th width="8">Sun</th>
					</tr>
					<tr>
						<td align="center"><input type="checkbox" name="ordMon"<cfif order.ordMon> checked="checked"</cfif> value="1" /></td>
						<td align="center"><input type="checkbox" name="ordTue"<cfif order.ordTue> checked="checked"</cfif> value="1" /></td>
						<td align="center"><input type="checkbox" name="ordWed"<cfif order.ordWed> checked="checked"</cfif> value="1" /></td>
						<td align="center"><input type="checkbox" name="ordThu"<cfif order.ordThu> checked="checked"</cfif> value="1" /></td>
						<td align="center"><input type="checkbox" name="ordFri"<cfif order.ordFri> checked="checked"</cfif> value="1" /></td>
						<td align="center"><input type="checkbox" name="ordSat"<cfif order.ordSat> checked="checked"</cfif> value="1" /></td>
						<td align="center"><input type="checkbox" name="ordSun"<cfif order.ordSun> checked="checked"</cfif> value="1" /></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
</form>
</cfoutput>
<script type="text/javascript">
	$("select").chosen({width: "100%",disable_search_threshold: 10});
</script>
