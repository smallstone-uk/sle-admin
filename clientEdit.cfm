<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<script type="text/javascript">
	$(document).ready(function() {
		$("#autoFill").change(function() {
			var $input = $(this);
			if ($input.prop('checked')) {
				if ($('#delHouseName').val().length) {
					if ($('#delHouseNumber').val().length) {
						$("#Addr1").val($("#delHouseNumber").val() + ", " + $("#delHouseName").val());
					} else {
						$("#Addr1").val($("#delHouseName").val());
					};
					$("#Addr2").val($("#delStreet option:selected").text());
				} else {
					$("#Addr1").val($("#delHouseNumber").val() + " " + $("#delStreet option:selected").text());
					$("#Addr2").val("");
				};
				$("#Town").val($("#delTown").val());
				$("#City").val($("#delCity").val());
				$("#Postcode").val($("#delPostcode").val());
			} else {
				$("#Addr1").val("");
				$("#Addr2").val("");
				$("#Town").val("");
				$("#City").val("");
				$("#Postcode").val("");
			};
		});
		$("#btnSave").click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'clientEditAction.cfm',
				data : $('#editForm').serialize(),
				success:function(data){
					$('#saveResults').html(data);
					$('#saveResults').show();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000);
				}
			});
			event.preventDefault();
		})
		$("#delStreet").trigger("chosen:updated");
		$(".chargeSelect").trigger("chosen:updated");
		$('#orderOverlayForm').center();
	});
</script>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.clientID=clientID>
<cfset parm.datasource=application.site.datasource1>

<cfset streets=cust.LoadStreets(parm)>
<cfset charges=cust.LoadDeliveryCharges(parm)>
<cfset customer=cust.LoadClientByID(parm)>

<cfoutput>
<form method="post" enctype="multipart/form-data" id="editForm">
	<input type="hidden" name="cltID" value="#customer[1].cltID#">
	<input type="hidden" name="cltRef" value="#customer[1].cltRef#">
	<h1>
		<cfif len(customer[1].cltName) AND len(customer[1].cltCompanyName)>#customer[1].cltName# - #customer[1].cltCompanyName#<cfelse>#customer[1].cltName##customer[1].cltCompanyName#</cfif>
		<button id="btnSave" type="submit" class="overlayNav">
			<img src="images/icons/save.png">&nbsp;Save
		</button>
	</h1>
	<div id="saveResults" style="display:none;"></div>
	<div class="overlayInnerForm" style="height:600px;">
		<div class="panelform">
			<h2>Account Information</h2>
			<table border="0">
				<tr>
					<td><strong>Reference</strong></td>
					<td><input type="text" value="#customer[1].cltRef#" disabled="disabled"></td>
				</tr>
				<tr>
					<td><strong>Payment Key</strong></td>
					<td><input type="text" name="cltKey" value="#customer[1].cltKey#"></td>
				</tr>
				<tr>
					<td><strong>Contact Title</strong></td>
					<td><input type="text" name="cltTitle" value="#customer[1].cltTitle#" maxlength="15" placeholder="Mr/Mrs" /></td>
				</tr>
				<tr>
					<td><strong>Contact Initial</strong></td>
					<td><input type="text" name="cltInitial" value="#customer[1].cltInitial#" maxlength="15" placeholder="A" /></td>
				</tr>
				<tr>
					<td><strong>Contact Name</strong></td>
					<td><input type="text" name="cltName" value="#customer[1].cltName#" /></td>
				</tr>
				<tr>
					<td><strong>Dept</strong></td>
					<td><input type="text" name="cltDept" value="#customer[1].cltDept#" /></td>
				</tr>
				<tr>
					<td><strong>Company Name</strong></td>
					<td><input type="text" name="cltCompanyName" value="#customer[1].cltCompanyName#" /></td>
				</tr>
				<tr>
					<td><strong>Telephone</strong></td>
					<td><input type="text" name="cltDelTel" value="#customer[1].cltDelTel#" /></td>
				</tr>
				<tr>
					<td><strong>Mobile</strong></td>
					<td><input type="text" name="cltMobile" value="#customer[1].cltMobile#" /></td>
				</tr>
				<tr>
					<td><strong>E-Mail</strong></td>
					<td><input type="text" name="cltEMail" value="#customer[1].cltEMail#" /></td>
				</tr>
				<tr>
					<td><strong>Account Type</strong></td>
					<td>
						<select name="cltAccountType" data-placeholder="Choose a type..." class="typeSelect">
							<option value=""></option>
							<option value="M"<cfif customer[1].cltAccountType eq "M"> selected="selected"</cfif>>Monthly</option>
							<option value="W"<cfif customer[1].cltAccountType eq "W"> selected="selected"</cfif>>Weekly</option>
							<option value="C"<cfif customer[1].cltAccountType eq "C"> selected="selected"</cfif>>Pay on Collect</option>
							<!---<option value="X"<cfif customer[1].cltAccountType eq "X"> selected="selected"</cfif>>Special</option>--->
							<option value="H"<cfif customer[1].cltAccountType eq "H"> selected="selected"</cfif>>Account Hold</option>
							<option value="N"<cfif customer[1].cltAccountType eq "N"> selected="selected"</cfif>>Inactive</option>
							<!---<option value="Z"<cfif customer[1].cltAccountType eq "Z"> selected="selected"</cfif>>Unknown</option>--->
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Payment Type</strong></td>
					<td>
						<select name="cltPayType" data-placeholder="Choose a type..." class="methodSelect">
							<option value=""></option>
							<option value="collect"<cfif customer[1].cltPayType eq "collect"> selected="selected"</cfif>>Collection</option>
							<option value="shop"<cfif customer[1].cltPayType eq "shop"> selected="selected"</cfif>>Shop</option>
							<option value="post"<cfif customer[1].cltPayType eq "post"> selected="selected"</cfif>>Post</option>
							<option value="bacs"<cfif customer[1].cltPayType eq "bacs"> selected="selected"</cfif>>Internet</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Payment Method</strong></td>
					<td>
						<select name="cltPayMethod" data-placeholder="Choose a method..." class="methodSelect">
							<option value=""></option>
							<option value="cash"<cfif customer[1].cltPayMethod eq "cash"> selected="selected"</cfif>>Cash</option>
							<option value="chq"<cfif customer[1].cltPayMethod eq "chq"> selected="selected"</cfif>>Cheque</option>
							<option value="card"<cfif customer[1].cltPayMethod eq "card"> selected="selected"</cfif>>Card Payment</option>
							<option value="ib"<cfif customer[1].cltPayMethod eq "ib"> selected="selected"</cfif>>Internet Banking</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Payment Frequency</strong></td>
					<td>
						<select name="cltPaymentType" data-placeholder="Choose a type..." class="typeSelect">
							<option value=""></option>
							<option value="Monthly"<cfif customer[1].cltPaymentType eq "Monthly"> selected="selected"</cfif>>Monthly</option>
							<option value="Weekly"<cfif customer[1].cltPaymentType eq "Weekly"> selected="selected"</cfif>>Weekly</option>
							<option value="Unknown"<cfif customer[1].cltPaymentType eq "Unknown"> selected="selected"</cfif>>Unknown</option>
						</select>
					</td>
				</tr>
			</table>
		</div>
		<div class="panelform">
			<h2>Delivery Address</h2>
			<table border="0">
				<tr>
					<td><strong>House (OLD)</strong></td>
					<td><input type="text" name="cltDelHouse" value="#customer[1].cltDelHouse#" id="delHouse" /></td>
				</tr>
				<tr>
					<td><strong>House/Building Name</strong></td>
					<td><input type="text" name="cltDelHouseName" value="#customer[1].cltDelHouseName#" id="delHouseName" /></td>
				</tr>
				<tr>
					<td><strong>House/Flat Number</strong></td>
					<td><input type="text" name="cltDelHouseNumber" value="#customer[1].cltDelHouseNumber#" id="delHouseNumber" /></td>
				</tr>
				<tr>
					<td><strong>Street</strong></td>
					<td>
						<select name="cltStreetCode" data-placeholder="Choose a Street..." class="streetSelect" id="delStreet">
							<option value=""></option>
							<cfif ArrayLen(streets)>
								<cfloop array="#streets#" index="i">
									<option value="#i.ID#"<cfif customer[1].cltStreetCode eq i.ID> selected="selected"</cfif>>#i.Name#</option>
								</cfloop>
							</cfif>
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Town</strong></td>
					<td><input type="text" name="cltDelTown" value="#customer[1].cltDelTown#" id="delTown" /></td>
				</tr>
				<tr>
					<td><strong>City</strong></td>
					<td><input type="text" name="cltDelCity" value="#customer[1].cltDelCity#" id="delCity" /></td>
				</tr>
				<tr>
					<td><strong>Postcode</strong></td>
					<td><input type="text" name="cltDelPostcode" value="#customer[1].cltDelPostcode#" id="delPostcode" /></td>
				</tr>
			</table>
		</div>
		<div class="panelform">
			<h2>Billing Address</h2>
			<label><input type="checkbox" name="autoFill" id="autoFill" value="1">&nbsp;Same as Delivery Address</label>
			<table border="0">
				<tr>
					<td><strong>Address Line 1</strong></td>
					<td><input type="text" name="cltAddr1" value="#customer[1].cltAddr1#" id="Addr1" /></td>
				</tr>
				<tr>
					<td><strong>Address Line 2</strong></td>
					<td><input type="text" name="cltAddr2" value="#customer[1].cltAddr2#" id="Addr2" /></td>
				</tr>
				<tr>
					<td><strong>Town</strong></td>
					<td><input type="text" name="cltTown" value="#customer[1].cltTown#" id="Town" /></td>
				</tr>
				<tr>
					<td><strong>City</strong></td>
					<td><input type="text" name="cltCity" value="#customer[1].cltCity#" id="City" /></td>
				</tr>
				<tr>
					<td><strong>County</strong></td>
					<td><input type="text" name="cltCounty" value="#customer[1].cltCounty#" /></td>
				</tr>
				<tr>
					<td><strong>Postcode</strong></td>
					<td><input type="text" name="cltPostcode" value="#customer[1].cltPostcode#" id="Postcode" /></td>
				</tr>
				<tr>
					<td><strong>Delivery Charge</strong></td>
					<td>
						<select name="cltDelCode" data-placeholder="Choose a charge..." class="chargeSelect">
							<option value=""></option>
							<cfif ArrayLen(charges)>
								<cfloop array="#charges#" index="i">
									<option value="#i.Code#"<cfif customer[1].cltDelCode eq i.Code> selected="selected"</cfif>>#i.Code# - £#i.Price1#</option>
								</cfloop>
							</cfif>
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Invoice Delivery Type</strong></td>
					<td>
						<select name="cltInvDeliver" data-placeholder="Choose a style..." class="InvDelSelect">
							<option value=""></option>
							<option value="none"<cfif customer[1].cltInvDeliver eq "none"> selected="selected"</cfif>>None</option>
							<option value="deliver"<cfif customer[1].cltInvDeliver eq "deliver"> selected="selected"</cfif>>Deliver</option>
							<option value="post"<cfif customer[1].cltInvDeliver eq "post"> selected="selected"</cfif>>Post</option>
							<option value="email"<cfif customer[1].cltInvDeliver eq "email"> selected="selected"</cfif>>Email</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Invoice Style</strong></td>
					<td>
						<select name="cltInvoiceType" data-placeholder="Choose a style..." class="styleSelect">
							<option value=""></option>
							<option value="simple"<cfif customer[1].cltInvoiceType eq "simple"> selected="selected"</cfif>>Simple</option>
							<option value="detail"<cfif customer[1].cltInvoiceType eq "detail"> selected="selected"</cfif>>Detailed</option>
						</select>
					</td>
				</tr>
				<tr>
					<td><strong>Default Holiday Action</strong></td>
					<td>
						<select name="cltDefaultHoliday" data-placeholder="Choose a style..." class="styleSelect">
							<option value=""></option>
							<option value="cancel"<cfif customer[1].cltDefaultHoliday eq "cancel"> selected="selected"</cfif>>Cancel</option>
							<option value="hold"<cfif customer[1].cltDefaultHoliday eq "hold"> selected="selected"</cfif>>Hold</option>
							<option value="stop"<cfif customer[1].cltDefaultHoliday eq "stop"> selected="selected"</cfif>>Stop</option>
						</select>
					</td>
				</tr>
			</table>
		</div>
	</div>
</form>
</cfoutput>
<script type="text/javascript">
	$(".streetSelect").chosen({width: "100%",disable_search_threshold: 6});
	$(".chargeSelect").chosen({width: "100%",disable_search_threshold: 6});
	$(".typeSelect").chosen({width: "100%",disable_search_threshold: 6});
	$(".methodSelect").chosen({width: "100%",disable_search_threshold: 6});
	$(".InvDelSelect").chosen({width: "100%",disable_search_threshold: 6});
	$(".styleSelect").chosen({width: "100%",disable_search_threshold: 6});
</script>
