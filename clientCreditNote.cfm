<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfset parm={}>
<cfset parm.form=form>

<script type="text/javascript">
	$(document).ready(function() {
		$('#SelectAll').click(function() {
			if(this.checked) {
				$('.selectItem').prop("checked", true);
			} else {
				$('.selectItem').prop("checked", false);
			}
		});
		$('#btnFindCharges').click(function() {
			$.ajax({
				type: 'POST',
				url: 'FindCharges.cfm',
				data : $('#FindChargesForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#update').html(data);
					$('#loading').fadeOut();
					$('#orderOverlayForm').center();
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
			event.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
	});
</script>
<style type="text/css">
.credit {color: #E00;}
.debit {background: #F7F7F7;font-weight: bold;}
#update {max-height: 500px;overflow-y: scroll;}
</style>

<cfoutput>
<form method="post" enctype="multipart/form-data" id="FindChargesForm">
	<input type="hidden" name="orderID" value="#parm.form.orderID#" />
	<input type="hidden" name="cltID" value="#parm.form.cltID#" />
	<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
	<h1>Credit Note</h1>
	<div id="saveResults" style="display:none;"></div><div id="loading"></div>
	<table border="1" width="100%" class="tableList">
		<tr>
			<th width="50%">From</th>
			<th width="50%">To</th>
		</tr>
		<tr>
			<td align="center"><input type="text" name="dateFrom" class="datepicker" value="#DateFormat(DateAdd('d',-7,Now()),'yyyy-mm-dd')#" /></td>
			<td align="center"><input type="text" name="dateTo" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#" /></td>
		</tr>
		<tr>
			<td align="center">Credit Reason</td>
			<td align="center">
				<select name="crdReason">
					<option value="">Select...</option>
					<option value="missed">Missed Delivery</option>
					<option value="short">Short Stock</option>
					<option value="wrong">Wrong Delivery</option>
					<option value="unwanted">Unwanted Delivery</option>
					<option value="On Holiday">Holiday</option>
				</select>
			</td>
		</tr>
		<tr>
			<th colspan="2"><input type="button" id="btnFindCharges" value="Find" /></th>
		</tr>
		<tr>
			<td colspan="2">
				Reasons:-<br />
				*Missed Delivery - Driver failed to deliver.<br />
				Short Stock - Papers late or short stock.<br />
				*Wrong Delivery - Wrong title delivered.<br />
				*Unwanted Delivery - Delivered while cancelled.<br />
				Holiday - Normal cancellation.<br />
				<br />
				* Deducted from drivers pay
			</td>
		</tr>
	</table>
	<div class="clear" style="padding:5px 0;"></div>
	<div id="update"></div>
</form>
</cfoutput>


