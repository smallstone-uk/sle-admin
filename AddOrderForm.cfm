<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.clientID=clientID>
<cfset clientInfo.info=cust.LoadClientByID(parm)>
<cfset street=cust.LoadStreets(parm)>
<cfset charges=cust.LoadDeliveryCharges(parm)>

<cfoutput>
<script type="text/javascript">
	$(document).ready(function() {
		$("##autoFill").change(function() {
			var $input = $(this);
			if ($input.prop('checked')) {
				$("##ordHouseName").val($("##delHouseName").val());
				$("##ordHouseNumber").val($("##delHouseNumber").val());
				$("##ordStreetCode").val($("##delStreet").val());
				$("##ordTown").val($("##delTown").val());
				$("##ordCity").val($("##delCity").val());
				$("##ordPostcode").val($("##delPostcode").val());
				$("##ordDeliveryCode").val($("##delCode").val());
				$("##ordStreetCode").trigger("chosen:updated");
				$("##ordDeliveryCode").trigger("chosen:updated");
			} else {
				$("##ordHouseName").val("");
				$("##ordHouseNumber").val("");
				$("##ordStreetCode").val("");
				$("##ordTown").val("");
				$("##ordCity").val("");
				$("##ordPostcode").val("");
				$("##ordDeliveryCode").val("");
				$("##ordStreetCode").trigger("chosen:updated");
				$("##ordDeliveryCode").trigger("chosen:updated");
			};
		});
	});
</script>
<h1>New Order</h1>
<form method="post" enctype="multipart/form-data">
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
			<td><strong>Copy default address</strong></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order Reference</strong></td>
			<td><input type="text" name="ordRef" value="" id="ordRef" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order Contact</strong></td>
			<td><input type="text" name="ordContact" value="" id="ordContact" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>House/Building Name</strong></td>
			<td><input type="text" name="ordHouseName" value="" id="ordHouseName" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>House/Flat Number</strong></td>
			<td><input type="text" name="ordHouseNumber" value="" id="ordHouseNumber" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Street</strong></td>
			<td>
				<select name="ordStreetCode" data-placeholder="Choose a Street..." class="select" id="ordStreetCode">
					<option value=""></option>
					<cfif ArrayLen(street)>
						<cfloop array="#street#" index="i">
							<option value="#i.ID#">#i.Name#</option>
						</cfloop>
					</cfif>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Town</strong></td>
			<td><input type="text" name="ordTown" value="" id="ordTown" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>City</strong></td>
			<td><input type="text" name="ordCity" value="Truro" id="ordCity" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Postcode</strong></td>
			<td><input type="text" name="ordPostcode" value="" id="ordPostcode" /></td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Delivery Charge</strong></td>
			<td>
				<select name="ordDeliveryCode" data-placeholder="Choose a charge..." class="select" id="ordDeliveryCode">
					<option value=""></option>
					<cfif ArrayLen(charges)>
						<cfloop array="#charges#" index="i">
							<option value="#i.Code#">#i.Code# - £#i.Price1#</option>
						</cfloop>
					</cfif>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Order</strong></td>
			<td>
				<select name="ordType" class="nosearch">
					<option value="Standard" selected="selected">Standing Order</option>
					<option value="Custom">Custom Order</option>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><strong>Active</strong></td>
			<td>
				<select name="ordActive">
					<option value="1">Yes</option>
					<option value="0">No</option>
				</select>
			</td>
		</tr>
		<tr>
			<td width="25%" align="right"><input type="checkbox" name="ordDifferent" value="1" /></td>
			<td><strong>Delivery address differs from Billing address</strong></td>
		</tr>
		<tr>
			<td></td>
			<td><input type="submit" name="btnAddOrder" value="Add" /></td>
		</tr>									
	</table>
</form>
</cfoutput>
<script type="text/javascript">
	$("select").chosen({width: "100%"});
</script>
