<!DOCTYPE html>
<html>
<head>
<title>New Customer</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
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
		$("#autoFill").change(function() {
			var $input = $(this);
			if ($input.prop('checked')) {
				if ($('#delHouseName').val().length) {
					if ($('#delHouseNumber').val().length) {
						$("#Addr1").val($("#delHouseNumber").val() + ", " + $("#delHouseName").val());
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
				url: 'clientAddAction.cfm',
				data : $('#newCustForm').serialize(),
				beforeSend:function(){
					$('#saveResults').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Creating...").fadeIn();
					$('#saveResults').removeClass("error");
				},
				success:function(data){
					$('#saveResults').html(data);
				}
			});
			event.preventDefault();
		})
	});
</script>
</head>


<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset streets=cust.LoadStreets(parm)>
<cfset charges=cust.LoadDeliveryCharges(parm)>
<cfset lastref=cust.LoadLastClientRef(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post" enctype="multipart/form-data" id="newCustForm">
						<div class="form-header">
							New Customer
							<div id="loadingDiv"></div>
							<span><input type="submit" id="btnSave" value="Create Account" /></span>
						</div>
						<div style="padding:20px 0;">
							<h2>Creating a New Customer</h2>
							<p style="padding:0;">Follow the steps below to successfully create a new customer.</p>
							<div style="float:left;width:25%;">
								<h3>Step 1:</h3>
								<p style="padding:0 10px 0 0;">Fill in the form below. Enter all the information you can. Once finished click the button in the top right called <strong>'Create Account'</strong>.</p>
								<p style="padding:0 10px 0 0;">New customers account types should be set to <strong>'Monthly'</strong>, unless they're a Shop Save customer that wants to <strong>'Pay on Collect'</strong>.</p>
							</div>
							<div style="float:left;width:25%;">
								<h3>Step 2:</h3>
								<p style="padding:0 10px 0 0;">After Creating the Account, <strong>follow the link</strong> to the customer details page.</p>
								<p style="padding:0 10px 0 0;">Create a New Order. This is found under, <strong>Customer Menu > New Order</strong>. Tick <strong>'Copy default address'</strong> tick box to fill in the form with the address from the customer record.</p>
							</div>
							<div style="float:left;width:25%;">
								<h3>Step 3:</h3>
								<p style="padding:0 10px 0 0;">Once a New Order is created, you can <strong>add the publications</strong> the customer wants to thier order.</p>
								<p style="padding:0 10px 0 0;">To add publications, go to the &nbsp;&nbsp;<img src="images/icons/menu.png" width="12">&nbsp;&nbsp; icon on the order and click <strong>'Add Publication'</strong>. Then enter the title of the publication the customer want and <strong>click add</strong>.</p>
							</div>
							<div style="float:left;width:25%;">
								<h3>Step 4:</h3>
								<p style="padding:0 10px 0 0;">The customer now needs to be <strong>added to the rounds</strong>. Based on the customers address assign the drop to the most relevent round by selecting the round from the '<strong>Attach to Round</strong>' section.</p>
								<p style="padding:0 10px 0 0;">Make sure the customer is assigned to a round for <strong>everyday of the week</strong>, even if they don't have publications on a particular day.</p>
								<p style="padding:0 10px 0 0;">Once attached, you need to <strong>order the drop</strong> on the round. You do this by selecting the <strong>round and a day</strong>. Then you will be able to see the drop highlighted in blue. <br><strong>Drag & Drop</strong> the item into the place you want it and <strong>click Save</strong></p>
								<p style="padding:0 10px 0 0;"><i>If you are unsure where to put the drop, leave the ordering alone and ask the driver where they want it placed.</i></p>
							</div>
							<div class="clear"></div>
						</div>
						<div id="saveResults" style="display:none;"></div>
						<cfif StructKeyExists(form,"btnSave")><cfif StructKeyExists(add,"error")>#add.error#</cfif></cfif>
						<div class="panelform" style="margin:0;width: 306px;min-height: 500px;">
							<h2>Account Information</h2>
							<table border="0">
								<tr>
									<td><strong>Reference</strong></td>
									<td><input type="hidden" name="cltRef" value="#lastref.ref+1#"><input type="text" disabled="disabled"></td>
								</tr>
								<tr>
									<td><strong>Contact Title</strong></td>
									<td><input type="text" name="cltTitle" value="" maxlength="15" placeholder="Mr/Mrs" /></td>
								</tr>
								<tr>
									<td><strong>Contact Initial</strong></td>
									<td><input type="text" name="cltInitial" value="" maxlength="15" placeholder="A" /></td>
								</tr>
								<tr>
									<td><strong>Contact Name</strong></td>
									<td><input type="text" name="cltName" value="" /></td>
								</tr>
								<tr>
									<td><strong>Dept</strong></td>
									<td><input type="text" name="cltDept" value="" /></td>
								</tr>
								<tr>
									<td><strong>Company Name</strong></td>
									<td><input type="text" name="cltCompanyName" value="" /></td>
								</tr>
								<tr>
									<td><strong>Telephone</strong></td>
									<td><input type="text" name="cltDelTel" value="" /></td>
								</tr>
								<tr>
									<td><strong>Mobile</strong></td>
									<td><input type="text" name="cltMobile" value="" /></td>
								</tr>
								<tr>
									<td><strong>E-Mail</strong></td>
									<td><input type="text" name="cltEMail" value="" /></td>
								</tr>
								<tr>
									<td><strong>Account Type</strong></td>
									<td>
										<select name="cltAccountType" data-placeholder="Choose a type..." class="typeSelect">
											<option value=""></option>
											<option value="M" selected="selected">Monthly</option>
											<option value="W">Weekly</option>
											<option value="C">Pay on Collect</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><strong>Payment Type</strong></td>
									<td>
										<select name="cltPayType" data-placeholder="Choose a type..." class="methodSelect">
											<option value=""></option>
											<option value="collect" selected="selected">Collection</option>
											<option value="shop">Shop</option>
											<option value="post">Post</option>
											<option value="bacs">Internet</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><strong>Payment Method</strong></td>
									<td>
										<select name="cltPayMethod" data-placeholder="Choose a method..." class="methodSelect">
											<option value=""></option>
											<option value="cash">Cash</option>
											<option value="chq">Cheque</option>
											<option value="card">Card Payment</option>
											<option disabled>-----------------</option>
											<option value="coll">Cash Collected</option>
											<option value="phone">Card by Phone</option>
											<option value="ib">Internet Banking</option>
											<option value="acct">Shop Credit Account</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><strong>Payment Frequency</strong></td>
									<td>
										<select name="cltPaymentType" data-placeholder="Choose a type..." class="typeSelect">
											<option value=""></option>
											<option value="Monthly" selected="selected">Monthly</option>
											<option value="Weekly">Weekly</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><strong>Delivery Charge</strong></td>
									<td>
										<select name="cltDelCode" data-placeholder="Choose a charge..." class="chargeSelect">
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
									<td><strong>Invoice Delivery Type</strong></td>
									<td>
										<select name="cltInvDeliver" data-placeholder="Choose a style..." class="InvDelSelect">
											<option value=""></option>
											<option value="none">None</option>
											<option value="deliver" selected="selected">Deliver</option>
											<option value="post">Post</option>
											<option value="email">Email</option>
										</select>
									</td>
								</tr>
								<tr>
									<td><strong>Invoice Style</strong></td>
									<td>
										<select name="cltInvoiceType" data-placeholder="Choose a style..." class="styleSelect">
											<option value=""></option>
											<option value="simple" selected="selected">VAT Hidden Invoice</option>
											<option value="detail">VAT Invoice</option>
										</select>
									</td>
								</tr>
							</table>
						</div>
						<div class="panelform" style="margin:0;width: 306px;min-height: 500px;">
							<h2>Delivery Address</h2>
							<table border="0">
								<tr>
									<td><strong>House/Building Name</strong></td>
									<td><input type="text" name="cltDelHouseName" value="" id="delHouseName" /></td>
								</tr>
								<tr>
									<td><strong>House/Flat Number</strong></td>
									<td><input type="text" name="cltDelHouseNumber" value="" id="delHouseNumber" /></td>
								</tr>
								<tr>
									<td><strong>Street</strong></td>
									<td>
										<select name="cltStreetCode" data-placeholder="Choose a Street..." class="streetSelect" id="delStreet">
											<option value=""></option>
											<cfif ArrayLen(streets)>
												<cfloop array="#streets#" index="i">
													<option value="#i.ID#">#i.Name#</option>
												</cfloop>
											</cfif>
										</select>
									</td>
								</tr>
								<tr>
									<td><strong>Town</strong></td>
									<td><input type="text" name="cltDelTown" value="" id="delTown" /></td>
								</tr>
								<tr>
									<td><strong>City</strong></td>
									<td><input type="text" name="cltDelCity" value="" id="delCity" /></td>
								</tr>
								<tr>
									<td><strong>Postcode</strong></td>
									<td><input type="text" name="cltDelPostcode" value="" id="delPostcode" /></td>
								</tr>
							</table>
						</div>
						<div class="panelform" style="margin:0;width: 306px;min-height: 500px;">
							<h2>Billing Address</h2>
							<label><input type="checkbox" name="autoFill" id="autoFill" value="1">&nbsp;Same as Delivery Address</label>
							<table border="0">
								<tr>
									<td><strong>Address Line 1</strong></td>
									<td><input type="text" name="cltAddr1" value="" id="Addr1" /></td>
								</tr>
								<tr>
									<td><strong>Address Line 2</strong></td>
									<td><input type="text" name="cltAddr2" value="" id="Addr2" /></td>
								</tr>
								<tr>
									<td><strong>Town</strong></td>
									<td><input type="text" name="cltTown" value="" id="Town" /></td>
								</tr>
								<tr>
									<td><strong>City</strong></td>
									<td><input type="text" name="cltCity" value="" id="City" /></td>
								</tr>
								<tr>
									<td><strong>County</strong></td>
									<td><input type="text" name="cltCounty" value="" /></td>
								</tr>
								<tr>
									<td><strong>Postcode</strong></td>
									<td><input type="text" name="cltPostcode" value="" id="Postcode" /></td>
								</tr>
							</table>
						</div>
					</form>
					<script type="text/javascript">
						$(".streetSelect").chosen({width: "100%",disable_search_threshold: 6});
						$(".chargeSelect").chosen({width: "100%",disable_search_threshold: 6});
						$(".typeSelect").chosen({width: "100%",disable_search_threshold: 6});
						$(".methodSelect").chosen({width: "100%",disable_search_threshold: 6});
						$(".InvDelSelect").chosen({width: "100%",disable_search_threshold: 6});
						$(".styleSelect").chosen({width: "100%",disable_search_threshold: 6});
					</script>
					<div class="clear"></div>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>
