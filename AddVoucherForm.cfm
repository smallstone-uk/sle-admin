<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.rec.cltID=form.cltID>
<cfset parm.rec.cltRef=form.cltRef>
<cfset custOrder=cust.LoadClientOrder(parm)>
					
<script type="text/javascript">
	$(document).ready(function() {
		function GetOrders() {
			var id=$('#OrderID').val();
			$.ajax({
				type: 'POST',
				url: 'LoadClientOrder.cfm',
				data : $('#voucherForm').serialize(),
				success:function(data){$('#OrderList'+id).html(data);}
			});
		};
		function LoadVouchers() {
			var id=$('#OrderID').val();
			$.ajax({
				type: 'POST',
				url: 'LoadVoucherList.cfm',
				data : {"ID":id},
				success:function(data){
					$('#voucher-list').html(data);
					LoadExpiring();
					$('#orderOverlayForm').center();
				}
			});
		};
		function LoadExpiring() {
			var id=$('#OrderID').val();
			$.ajax({
				type: 'POST',
				url: 'ExpiringVouchers.cfm',
				data : {"ID":id},
				success:function(data){
					$('#expiring-list').html(data);
				}
			});
		};
		
		$('#VoucherWhole').click(function(event) {   
			if(this.checked) {
				$('#dicountparms').fadeToggle("slow");
				$('#VoucherWholeLink').css("color","#000000");
			} else {
				$('#dicountparms').fadeToggle("slow");
				$('#VoucherWholeLink').css("color","#666666");
			};
		});
		$('#btnAddVoucher').click(function(event) { 
			var startDate = $('#vchStart').val();
			var stopDate = $('#vchStop').val();
			if( new Date(startDate).getTime() > new Date(stopDate).getTime() ) {
				alert("stop date must be after the start date");
				return false
			}
			$.ajax({
				type: 'POST',
				url: 'AddVoucherAction.cfm',
				data : $('#voucherForm').serialize(),
				beforeSend:function(){
					$('#saveResults').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
				},
				success:function(data){
					$('#saveResults').html(data);
					$('#saveResults').show();
					GetOrders();
					LoadVouchers();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				},
				error:function(data){
					$('#saveResults').html(data);
				}
			});
			event.preventDefault();
		});
		$('#btnRemoveVoucher').click(function(event) { 
			$.ajax({
				type: 'POST',
				url: 'AddVoucherRemoveAction.cfm',
				data : $('#voucherForm').serialize(),
				beforeSend:function(){
					$('#saveResults').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
				},
				success:function(data){
					$('#saveResults').html(data);
					$('#saveResults').show();
					GetOrders();
					LoadVouchers();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				},
				error:function(data){
					$('#saveResults').html(data);
				}
			});
			event.preventDefault();
		});
		LoadVouchers();
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>

<cfoutput>
	<form name="voucherForm" class="" id="voucherForm" method="post" enctype="multipart/form-data">
		<h1>Vouchers</h1>
		<div id="saveResults" style="display:none;"></div>
		<input type="hidden" name="oiOrderID" id="OrderID" value="#parm.form.orderID#" />
		<input type="hidden" name="orderRef" value="#parm.form.orderID#" />
		<input type="hidden" name="cltID" value="#parm.form.cltID#" />
		<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
		<cfif StructKeyExists(parm.form,"SelectPub")>
			<div style="padding: 10px;border: 1px solid ##999;border-radius: 5px;box-shadow: 1px 1px 3px ##CCC;">
				<h2 style="font-weight: normal;">Add Vouchers</h2>
				<table border="1" width="500" class="tableList">
					<tr>
						<th width="10"><input type="checkbox" name="selectAllOrderPub" value="1" checked="checked" /></th>
						<th align="left">Publication</th>
					</tr>
					<cfloop list="#parm.form.SelectPub#" delimiters="," index="i">
						<cfset itemParm={}>
						<cfset itemParm.datasource=application.site.datasource1>
						<cfset itemParm.oiID=i>
						<cfset item=cust.LoadOrderItem(itemParm)>
						<cfset itemParm.form.oiPubID=item.PubID>
						<cfset check=cust.CheckPublication(itemParm)>
						<tr>
							<td width="10"><input type="checkbox" name="OrderPub" value="#i#" checked="checked" /></td>
							<td>#check.title#</td>
						</tr>
					</cfloop>
				</table>
				<div style="padding:5px 0;"></div>
				<table border="1" width="500" class="tableList">
					<tr>
						<th width="100">From</th>
						<td width="150"><input type="text" class="datepicker" name="vchStart" id="vchStart" value="#DateFormat(Now(),'yyyy-mm-dd')#" size="20" /></td>
						<th width="100">To</th>
						<td width="150"><input type="text" class="datepicker" name="vchStop" id="vchStop" value="#DateFormat(Now(),'yyyy-mm-dd')#" size="20" /></td>
					</tr>
					<tr>
						<th colspan="4"><label id="VoucherWholeLink"><input type="checkbox" id="VoucherWhole" value="1" checked="checked" />&nbsp;Vouchers cover the whole cost of the publication</label></th>
					</tr>
					<tr id="dicountparms" style="display:none;">
						<th>Discount Type</th>
						<td>
							<select name="vchType" id="vchType">
								<option value="flat">Flat Discount</option>
								<option value="pc">Percentage</option>
							</select>
						</td>
						<th>Amount</th>
						<td><input type="text" name="vchDiscount" id="vchDiscount" value="" /></td>
					</tr>
					<tr>
						<th colspan="4">
							<input type="button" id="btnRemoveVoucher" value="Return" style="float:left;" title="Used to return a range of vouchers back to the customer" />
							<input type="button" id="btnAddVoucher" value="Add" style="float:right;" />
							<label style="padding:5px 10px 5px 0;float:right;">
								<cfif len(custOrder.cltEmail)>
									<input type="checkbox" name="autoEmail" value="1" checked="checked" style="float:left;" />
									<div style="float:left;line-height: 18px;">Send confirmation email of vouchers to:<br />#custOrder.cltEmail#</div>
								</cfif>
							</label>
						</th>
					</tr>
				</table>
			</div>
		<cfelse>
			<p>Please select at least one publication to add vouchers.</p>
		</cfif>
	</form>
	
	<div class="clear" style="padding:10px 0;"></div>
	<div id="expiring-list" style="margin:0 0 10px 0;"></div>
	<div id="voucher-list" style="height:300px; overflow-y:scroll;"></div>
</cfoutput>
<script type="text/javascript">
	$(".nosearch100").chosen({width: "100%",disable_search_threshold: 10});
	$("#vchType").chosen({width: "100%",disable_search_threshold: 10});
</script>
