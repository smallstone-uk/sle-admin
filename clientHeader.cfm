<script type="text/javascript">
	$(document).ready(function() {
		$('.clientInvoices').click(function(event) {   
			event.preventDefault();
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			var url='clientInvoices.cfm';
			var data={"clientID":id};
			$("#orderOverlay").toggle();
			$("#orderOverlay-ui").toggle();
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
		});
		$('.clientEdit').click(function(event) {   
			event.preventDefault();
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			var url='clientEdit.cfm';
			var data=$('#cltID'+id).serialize();
			$("#orderOverlay").toggle();
			$("#orderOverlay-ui").toggle();
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
		});
		$('.NewOrder').click(function(event) {   
			event.preventDefault();
			var loadingText="<div class='loading'><h1><img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading</h1>Retrieving information...</div>";
			var id=$(this).attr("href");
			var url='AddOrderForm.cfm';
			var data=$('#cltID'+id).serialize();
			$("#orderOverlay").toggle();
			$("#orderOverlay-ui").toggle();
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
		});
	});
</script>
<cfoutput>
<input type="hidden" name="clientID" id="cltID#customer.rec.cltID#" value="#customer.rec.cltID#" />
	<div id="orderOverlay-ui"></div>
	<div id="orderOverlay">
		<div id="orderOverlayForm">
			<a href="##" class="orderOverlayClose">X</a>
			<div id="orderOverlayForm-inner"></div>
		</div>
	</div>
	<div class="form-header">
		<cfif len(customer.rec.cltTitle)>#customer.rec.cltTitle#&nbsp;</cfif>
		<cfif len(customer.rec.cltInitial)>#customer.rec.cltInitial#&nbsp;</cfif>
		<cfif len(customer.rec.cltName) AND len(customer.rec.cltCompanyName)>#customer.rec.cltName# - #customer.rec.cltCompanyName#<cfelse>#customer.rec.cltName##customer.rec.cltCompanyName#</cfif>
		<span class="navBtns">
			<form method="post" action="#script_name#">
				<input type="hidden" name="cltRef" value="#customer.rec.cltRef#" />
				<input type="hidden" name="row" value="#customer.row#" />
				<input type="hidden" name="search" value="true" />
				<input type="submit" name="last" value="" class="last" />
				<input type="submit" name="next" value="" class="next" />
				<input type="submit" name="prev" value="" class="prev" />
				<input type="submit" name="first" value="" class="first" />
			</form>
		</span>
		<span class="navBtns" style="margin: 0 10px 0 0;padding: 0 14px 0 0;">
			<a href="topMenu#customer.rec.cltID#" class="options top">
				<img src="images/icons/menu.png" />&nbsp;Customer
			</a>
			<div id="topMenu#customer.rec.cltID#" class="order-menu top">
				<ul>
					<li><a href="clientPayments.cfm?rec=#customer.rec.cltRef#" target="_blank">Client Payments</a></li>
					<li><a href="#customer.rec.cltID#" class="clientInvoices">Client Invoices</a></li>
					<li><a href="#customer.rec.cltID#" class="clientEdit">Edit Client</a></li>
					<li><a href="#customer.rec.cltID#" class="NewOrder">New Order</a></li>
				</ul>
			</div>
		</span>
	</div>
	<table border="1" class="tableList" width="100%">
		<tr class="clienthead">
			<th width="40">ID</th>
			<th width="40">A/c Ref</th>
			<th width="80">Telephone</th>
			<th width="80">Account Type</th>
			<th width="60">Status</th>
			<th width="150">Delivery Code</th>
			<th width="150">Billing Address</th>
		</tr>
		<tr class="client">
			<td align="center">#customer.rec.cltID#</td>
			<td align="center">#customer.rec.cltRef#</td>
			<td align="center">#customer.rec.cltDelTel#<br />#customer.rec.cltMobile#</td>
			<td align="center">
				<cfif customer.rec.cltAccountType eq "m">Monthly</cfif>
				<cfif customer.rec.cltAccountType eq "w">Weekly</cfif>
				<cfif customer.rec.cltAccountType eq "n">Inactive</cfif>
				<cfif customer.rec.cltAccountType eq "c">Pay on Collection</cfif>
				<cfif customer.rec.cltAccountType eq "h">Account Hold</cfif>
				<cfif customer.rec.cltAccountType eq "x">Special</cfif>
				<cfif customer.rec.cltAccountType eq "z">Unknown</cfif>
			</td>
			<td align="center">#customer.rec.cltState#</td>
			<td align="center">
				<cfif StructKeyExists(customer.rec,"cltDelCode") AND Len(customer.rec.cltDelCode)>
					Delivery Code: #customer.rec.cltDelCode#<br />
					<cfif StructKeyExists(application.site,"DelCharges")>
						<cfset tempCharges=StructFind(application.site.DelCharges,customer.rec.cltDelCode)>
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
				</cfif>
			</td>
			<td align="left">
				<cfif len(customer.rec.cltAddr1)>#customer.rec.cltAddr1#<br /></cfif>
				<cfif len(customer.rec.cltAddr2)>#customer.rec.cltAddr2#<br /></cfif>
				<cfif len(customer.rec.cltTown)>#customer.rec.cltTown#<br /></cfif>
				<cfif len(customer.rec.cltCity)>#customer.rec.cltCity#<br /></cfif>
				<cfif len(customer.rec.cltCounty)>#customer.rec.cltCounty#<br /></cfif>
				<cfif len(customer.rec.cltPostcode)>#customer.rec.cltPostcode#</cfif>
			</td>
		</tr>
	</table>
</cfoutput>
<div class="clear" style="padding:10px 0;"></div>