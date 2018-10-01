<script type="text/javascript">
	$(document).ready(function() {
		$('html').click(function() {
			$(".options").removeClass("active");
			$(".order-menu").hide();
		});
		$('.options').click(function(event){
			event.stopPropagation();
		});		
		$('.options').click(function(event) {   
			var id=$(this).attr("href");
			$(".options").removeClass("active");
			$(".order-menu").hide();
			$("#"+id).show();
			$(this).toggleClass("active");
			event.preventDefault();
		});
		$('.orderDetailsLink').click(function(event) {   
			var id=$(this).attr("href");
			$("#orderDetails"+id).toggle();
			$(this).toggleClass("active");
			event.preventDefault();
		});
		$('.orderAddPubLink').click(function(event) {   
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Building publication list...</div>";
			var id=$(this).attr("href");
			var url='AddPubForm.cfm';
			var data=$('#form'+id).serialize();
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: url,
				data : data,
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderAddHolidayLink').click(function(event) {   
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'AddHolidayForm.cfm',
				data : $('#form'+id).serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderAddVoucherLink').click(function(event) {   
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'AddVoucherForm.cfm',
				data : $('#form'+id).serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
					event.preventDefault();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderEditDetailsLink').click(function(event) {
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";  
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'editOrderDetailsForm.cfm',
				data : $('#form'+id).serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderEditItemLink').click(function(event) {
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";  
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'editOrderItemForm.cfm',
				data : $('#form'+id).serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderPubDeleteLink').click(function(event) {
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";  
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'delPubForm.cfm',
				data : $('#form'+id).serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderDelOrderLink').click(function(event) {
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";  
			var id=$(this).attr("href");
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: 'delOrderForm.cfm',
				data : $('#form'+id).serialize(),
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.ManualCharge').click(function(event) {   
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			var url='clientManualCharge.cfm';
			var data=$('#form'+id).serialize();
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: url,
				data : data,
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.CreditNote').click(function(event) {   
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			var url='clientCreditNote.cfm';
			var data=$('#form'+id).serialize();
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: url,
				data : data,
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.AddtoRound').click(function(event) {   
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			var url='clientAddOrderToRound.cfm';
			var data=$('#form'+id).serialize();
			$("#orderOverlay").fadeIn();
			$("#orderOverlay-ui").fadeIn();
			$.ajax({
				type: 'POST',
				url: url,
				data : data,
				beforeSend:function(){
					$('#orderOverlayForm-inner').html(loadingText).fadeIn();
					$('#orderOverlayForm').center();
				},
				success:function(data){
					$('#orderOverlayForm-inner').html(data);
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#orderOverlayForm-inner').html(data).center();
					$('#orderOverlayForm').center();
				}
			});
			event.preventDefault();
		});
		$('.orderOverlayClose').click(function(event) {   
			$("#orderOverlay").fadeOut();
			$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
		$('.selectAll').click(function(event) {   
			var id=$(this).attr("value");
			if(this.checked) {
				$('input.selectPub'+id).each(function() {this.checked = true;});
			} else {
				$('input.selectPub'+id).each(function() {this.checked = false;});
			}
		});
		$('.holOrdLink').click(function(event) {   
			var id=$(this).attr("href");
			$("#holOrderPubs"+id).toggle();
			$("#holOrdLinkBG"+id).toggleClass("activeHol");
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<cfif StructKeyExists(custOrder,"order")>
		<cfif StructKeyExists(custOrder.order,"list")>
			<script type="text/javascript">
				$(document).ready(function() {
					$('.pubList').change(function() {
						$.ajax({
							type: 'POST',
							url: 'checkPublications.cfm',
							data : $(this).serialize(),
							beforeSend:function(){
								$('##loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
							},
							success:function(data){
								$('##loading').fadeOut();
								$('##pubResult').html(data);
							},
							error:function(data){
								$('##loading').fadeOut();
								$('##pubResult').html(data);
							}
						});
						event.preventDefault();
					});
					$('.orderPubList').change(function() {
						$.ajax({
							type: 'POST',
							url: 'checkOrderPubs.cfm',
							data : $('##holidayForm').serialize(),
							beforeSend:function(){
								$('##orderPubResult').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
							},
							success:function(data){
								$('##orderPubResult').html(data);
							},
							error:function(data){
								$('##orderPubResult').html(data);
							}
						});
						event.preventDefault();
					});
					$("##autoFill").change(function() {
						var $input = $(this);
						if ($input.prop('checked')) {
							$("##ordHouseName").val($("##delHouseName").val());
							$("##ordHouseNumber").val($("##delHouseNumber").val());
							$("##ordStreetCode").val($("##delStreet").val());
							$("##ordTown").val($("##delTown").val());
							$("##ordCity").val($("##delCity").val());
							$("##ordPostcode").val($("##delPostcode").val());
						} else {
							$("##ordHouseName").val("");
							$("##ordHouseNumber").val("");
							$("##ordStreetCode").val("");
							$("##ordTown").val("");
							$("##ordCity").val("");
							$("##ordPostcode").val("");
						};
					});
					$('.editPubs').click(function(e) { 
						var id=$(this).attr("data-id");
						OpenEdit(id);
						e.preventDefault();
					});
				});
			</script>
			<div class="clear"></div>
			<cfloop array="#custOrder.order.list#" index="order">
				<form method="post" enctype="multipart/form-data" id="form#val(order.orderID)#">
					<input type="hidden" name="orderID" value="#val(order.orderID)#" />
					<input type="hidden" name="cltID" value="#customer.rec.cltID#" />
					<input type="hidden" name="cltRef" value="#customer.rec.cltRef#" />
					<input type="hidden" name="delCode" value="#order.DeliveryCode#" />
					<input type="hidden" name="cltDefaultHoliday" value="#customer.rec.cltDefaultHoliday#" />
					<div class="order-wrap">
						<div class="wrap-header"<cfif order.type eq "custom"> style="background:##333;color:##fff;"</cfif>>
							<a href="orderMenu#order.orderID#" class="options"><cfif order.type eq "custom"><img src="images/icons/menu-white.png" style="margin:0;" /><cfelse><img src="images/icons/menu.png" style="margin:0;" /></cfif></a>
							<span class="no-print" style="float:left;margin:0 5px 0 0;">(#order.orderID#)</span>
							<h3 style="float: left;margin: 0;font-size: 13px; text-transform:capitalize;">
								<cfif len("#order.HouseNumber##order.HouseName##order.Street##order.Town##order.Postcode#")>
									#order.Contact# #order.HouseNumber# #order.HouseName# #order.Street# #order.Town# #order.City# #order.Postcode#
								<cfelse>
									Order Details need updating
								</cfif>
							</h3>
							<div style="clear:both;"></div>
							<div id="orderMenu#order.orderID#" class="order-menu" style="display:none;margin:-1px 0 0 718px;">
								<ul>
									<li><a href="#order.orderID#" class="orderAddPubLink"><span class="add"></span>Add Publication</a></li>
									<li><a href="#order.orderID#" class="orderAddHolidayLink"><span class="hol"></span>Holidays</a></li>
									<li><a href="#order.orderID#" class="orderAddVoucherLink"><span class="add"></span>Vouchers</a></li>
									<li><a href="#order.orderID#" class="ManualCharge"><span class="add"></span>Charges</a></li>
									<li><a href="#order.orderID#" class="CreditNote"><span class="add"></span>Credits</a></li>
									<li><a href="#order.orderID#" class="AddtoRound"><span class="edit"></span>Rounds</a></li>
									<li><a href="#order.orderID#" class="orderEditItemLink"><span class="edit"></span>Edit Items</a></li>
									<li><a href="#order.orderID#" class="orderEditDetailsLink"><span class="edit"></span>Edit Order Details</a></li>
									<li><a href="#order.orderID#" class="orderPubDeleteLink"><span class="bin"></span>Remove Items</a></li>
									<li><a href="#order.orderID#" class="orderDelOrderLink"><span class="bin"></span>Delete Order</a></li>
								</ul>
							</div>
						</div>
						<div id="orderDetails#order.orderID#" class="order-details" style="display:none;">
							#order.HouseName#<br />
							#order.HouseNumber#<br />
							#order.StreetCode#<br />
							#order.Street#<br />
							#order.Town#<br />
							#order.City#<br />
							#order.Postcode#<br />
							#order.DeliveryCode#<br />
							#order.Type#<br />
							#order.Active#
						</div>
						<div class="clear"></div>
						<div class="scroll">
							<div id="OrderList#order.orderID#">
								<table border="1" class="tableList" width="100%">
									<tr class="clienthead">
										<th width="5" class="no-print"><input type="checkbox" name="selectAll" class="selectAll" value="#order.orderID#" /></th>
										<th width="">Publication</th>
										<th width="40">Type</th>
										<!---<th width="100">Next&nbsp;Issue</th>--->
										<th width="30">Mon</th>
										<th width="30">Tue</th>
										<th width="30">Wed</th>
										<th width="30">Thu</th>
										<th width="30">Fri</th>
										<th width="30">Sat</th>
										<th width="30">Sun</th>
										
										<!---<th width="15"><span title="Voucher">V</span></th>
										<th width="80" align="right"><span title="Vouchers Week Total">VWT</span></th>
										<th width="80" align="right"><span title="Vouchers Month Total">VMT</span></th>--->
										<th width="50" align="right">Weekly<br />Total</th>
										<th width="50" align="right">Monthly<br />Total</th>
									</tr>
									<cfset lessWeekVouchers=0>
									<cfset lessMonthVouchers=0>
									<cfloop array="#order.items#" index="item">
										<tr class="#item.class#">
											<td align="center" class="no-print">
												<input type="checkbox" name="selectPub" class="selectPub#order.orderID#" title="#item.ID#" value="#item.ID#" /></td>
											<td style="text-transform:capitalize;"><a href="##" class="editPubs" data-id="#val(item.pubID)#">#LCase(item.title)#</a></td>
											<td>#item.type#</td>
											<!---<td>#DateFormat(item.nextIssue,"ddd dd-mmm")#<br /><i style="font-size:9px;">Day: #item.arrival#</i></td>--->
												<td align="center"><cfif item.qtymon neq 0><b>#item.qtymon#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.qtytue neq 0><b>#item.qtytue#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.qtywed neq 0><b>#item.qtywed#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.qtythu neq 0><b>#item.qtythu#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.qtyfri neq 0><b>#item.qtyfri#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.qtysat neq 0><b>#item.qtysat#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.qtysun neq 0><b>#item.qtysun#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
											<!---<cfif item.qty is 0>
											<cfelse>
												<td align="center"><cfif item.arrival is 1><b>#item.qtymon#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.arrival is 2><b>#item.qtytue#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.arrival is 3><b>#item.qtywed#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.arrival is 4><b>#item.qtythu#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.arrival is 5><b>#item.qtyfri#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.arrival is 6><b>#item.qtysat#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
												<td align="center"><cfif item.arrival is 7><b>#item.qtysun#</b><br /><i style="font-size:9px;">&pound;#item.price#</i></cfif></td>
											</cfif>--->
											
											<!---<td align="center">#item.voucher#</td>
											
											<td align="right">&pound;#DecimalFormat(item.voucherPerWeek)#</td>					
											<td align="right">&pound;#DecimalFormat(item.voucherPerMonth)#</td>--->					
											<td align="right">&pound;#DecimalFormat(item.linePerWeek)#</td>
											<td align="right">&pound;#DecimalFormat(item.linePerMonth)#</td>
											<cfset lessWeekVouchers=lessWeekVouchers-item.vlinePerWeek>
											<cfset lessMonthVouchers=lessMonthVouchers-item.vlinePerMonth>
										</tr>
									</cfloop>
									<tr>
										<td class="no-print"></td>
										<td colspan="2" rowspan="5" align="center">
											Delivery Code: #order.DeliveryCode#<br />
											<cfif StructKeyExists(application.site,"DelCharges")>
												<cfset tempCharges=StructFind(application.site.DelCharges,order.DeliveryCode)>
												<cfif tempCharges.delPrice2 gt 0>
													<table>
														<tr><td>Mon-Fri</td><td>#tempCharges.delPrice1# #tempCharges.delType#</td></tr>
														<tr><td>Sat</td><td>#tempCharges.delPrice2# #tempCharges.delType#</td></tr>
														<tr><td>Sun</td><td>#tempCharges.delPrice3# #tempCharges.delType#</td></tr>
													</table>
												<cfelse>
													<table>
														<tr><td>Mon-Sun</td><td>#tempCharges.delPrice1# #tempCharges.delType#</td></tr>
													</table>
												</cfif>
											</cfif>
										</td>
										<th align="right" colspan="7">Sub Total</th>
										<!---<td align="right">&pound;#DecimalFormat(order.voucherPerWeek)#</td>					
										<td align="right">&pound;#DecimalFormat(order.voucherPerMonth)#</td>--->
										<td align="right">&pound;#DecimalFormat(order.orderPerWeek)#</td>					
										<td align="right"><b>&pound;#DecimalFormat(order.orderPerMonth)#</b></td>
									</tr>
									<tr class="#order.delClass#">
										<td class="no-print"></td>
										<th align="right" colspan="7">#order.delcount# Delivery Charges</th>
										<td align="right">&pound;#DecimalFormat(order.delPerWeek)#</td>					
										<td align="right"><b>&pound;#DecimalFormat(order.delPerMonth)#</b></td>
									</tr>
									<tr class="ordertotal">
										<cfset orderWeekTotal=order.orderPerWeek+order.delPerWeek>
										<cfset orderMonthTotal=order.orderPerMonth+order.delPerMonth>
										<td class="no-print"></td>
										<th align="right" colspan="7">Order Total</th>
										<td align="right">&pound;#DecimalFormat(orderWeekTotal)#</td>					
										<td align="right"><b>&pound;#DecimalFormat(orderMonthTotal)#</b></td>
									</tr>
									<tr class="ordertotal">
										<td class="no-print"></td>
										<th align="right" colspan="7">Less Vouchers Received</th>
										<td align="right">&pound;#DecimalFormat(lessWeekVouchers)#</td>					
										<td align="right"><b>&pound;#DecimalFormat(lessMonthVouchers)#</b></td>
									</tr>
									<tr class="ordertotal">
										<cfset grandWeekTotal=orderWeekTotal+lessWeekVouchers>
										<cfset grandMonthTotal=orderMonthTotal+lessMonthVouchers>
										<td class="no-print"></td>
										<th align="right" colspan="7">Grand Total</th>
										<td align="right">&pound;#DecimalFormat(grandWeekTotal)#</td>					
										<td align="right"><b>&pound;#DecimalFormat(grandMonthTotal)#</b></td>
									</tr>
								</table>
							</div>
						</div>
					</div>
				</form>
			</cfloop>
		</cfif>
	</cfif>
</cfoutput>
<script type="text/javascript">
	$(".select").chosen({width: "100%"});
	$(".nosearch").chosen({width: "50%",disable_search_threshold: 10});
</script>
<div class="clear" style="padding:10px 0;"></div>