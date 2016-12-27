<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.rec.cltID=form.cltID>
<cfset parm.rec.cltRef=form.cltRef>
<cfset parm.datasource=application.site.datasource1>
<cfset custOrder=cust.LoadClientOrder(parm)>
<script type="text/javascript">
	$(document).ready(function() {
		function LoadHolidays() {
			$.ajax({
				type: 'POST',
				url: 'LoadHolidayList.cfm',
				data : $('#holidayForm').serialize(),
				success:function(data){
					$('#hol-list').html(data);
					$('#orderOverlayForm').center();
				}
			});
		};
		$('.holOrdLink').click(function(event) {   
			var id=$(this).attr("href");
			$("#holOrderPubs"+id).toggle();
			$("#holOrdLinkBG"+id).toggleClass("activeHol");
			event.preventDefault();
		});
		$('#hoUFN').click(function(event) {   
			if(this.checked) {
				$('#hoStart').prop({disabled: true});
			} else {
				$('#hoStart').prop({disabled: false});
			};
		});
		function AddHoliday() {
			$.ajax({
				type: 'POST',
				url: 'AddHolidayAction.cfm',
				data : $('#holidayForm').serialize(),
				beforeSend:function(){
					$('#saveResults').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
				},
				success:function(data){
					$('#saveResults').html(data).fadeIn();
					LoadHolidays();
					//setTimeout(function(){$("#saveResults").fadeOut("slow");}, 15000 );
				},
				error:function(data){
					$('#saveResults').html(data);
				}
			});
		};
		$('#btnAddHoliday').click(function(event) {
			var startDate = $('#hoStart').val();
			var stopDate = $('#hoStop').val();
			if( new Date(startDate).getTime() < new Date(stopDate).getTime() ) {
				alert("start date must be after the stop date");
				return false
			}
			$.ajax({
				type: 'POST',
				url: 'AddHolidayCheckVouchers.cfm',
				data : $('#holidayForm').serialize(),
				beforeSend:function(){
					$('#dump').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
				},
				success:function(data){
					$('#dump').html(data).fadeIn();
					AddHoliday();
					//setTimeout(function(){$("#saveResults").fadeOut("slow");}, 15000 );
				},
				error:function(data){
					$('#dump').html(data);
				}
			});
			event.preventDefault();
		});
		LoadHolidays();
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>

<cfoutput>
		<form name="holidayForm" class="" id="holidayForm" method="post" enctype="multipart/form-data">
			<h1>Holiday</h1>
			<div id="dump"></div>
			<div id="saveResults" style="display:none;"></div>
			<input type="hidden" name="orderRef" value="#parm.form.orderID#" />
			<input type="hidden" name="cltID" value="#parm.form.cltID#" />
			<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
			<cfif StructKeyExists(parm.form,"SelectPub")>
				<table border="1" width="100%" class="tableList">
					<tr>
						<th width="5"><input type="checkbox" name="selectAllOrderPub" value="1" checked="checked" /></th>
						<th align="left" colspan="2">Publication</th>
						<th align="left" width="150">Action</th>
					</tr>
					<cfloop list="#parm.form.SelectPub#" delimiters="," index="i">
						<cfset itemParm={}>
						<cfset itemParm.datasource=application.site.datasource1>
						<cfset itemParm.oiID=i>
						<cfset item=cust.LoadOrderItem(itemParm)>
						<cfset itemParm.form.oiPubID=item.PubID>
						<cfset check=cust.CheckPublication(itemParm)>
						<tr>
							<td width="5"><input type="checkbox" name="OrderPub" value="#i#" checked="checked" /></td>
							<td colspan="2">#check.title#</td>
							<td><cfif parm.form.cltDefaultHoliday eq "hold"></cfif>
								<select name="OrderAction#i#" class="nosearch100">
									<option value="cancel"<cfif parm.form.cltDefaultHoliday eq "cancel"> selected="selected"</cfif>>Cancel</option>
									<option value="hold"<cfif parm.form.cltDefaultHoliday eq "hold"> selected="selected"</cfif>>Hold</option>
									<option value="stop"<cfif parm.form.cltDefaultHoliday eq "stop"> selected="selected"</cfif>>Stop</option>
								</select>
							</td>
						</tr>
					</cfloop>
					<tr>
						<th>Stop Date</th>
						<td><input type="text" name="hoStop" id="hoStop" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#" size="20" /></td>
						<th>Start Date</th>
						<td>
							<label><input type="checkbox" name="hoUFN" id="hoUFN" value="1" />&nbsp;Stop until futher notice</label><br />
							<input type="text" class="datepicker" name="hoStart" id="hoStart" value="#DateFormat(Now(),'yyyy-mm-dd')#" size="20" />
						</td>
					</tr>
					<tr>
						<th colspan="4" align="center"><label style="padding:5px 0;"><input type="checkbox" name="returnVouchers" value="1" />&nbsp;Return vouchers to customer in holiday date range (if required).</label></th>
					</tr>
					<tr>
						<th colspan="4" align="center">
							<label style="padding:5px 0;float:left;">
								<cfif len(custOrder.cltEmail)>
									<input type="checkbox" name="autoEmail" value="1" checked="checked" style="float:left;" />
									<div style="float:left;line-height: 18px;">Send confirmation email of holiday booking to:<br />#custOrder.cltEmail#</div>
								</cfif>
							</label>
							<input type="button" name="btnAddHoliday" id="btnAddHoliday" value="Add" />
						</th>
					</tr>
				</table>
			<cfelse>
				<p>Please select at least one publication to add a holiday.</p>
			</cfif>
		</form>
	
	<div id="hol-list" class="clear" style="padding:10px 0;height: 400px;overflow-y: scroll;"></div>
</cfoutput>
<script type="text/javascript">
	$(".nosearch100").chosen({width: "100%",disable_search_threshold: 10});
</script>
