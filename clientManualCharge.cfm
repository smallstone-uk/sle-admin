<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>
<cfset pubs=cust.LoadPublications(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadCharges() {
			$.ajax({
				type: 'POST',
				url: 'clientManualChargeLoad.cfm',
				data : $('#AddChargeForm').serialize(),
				success:function(data){
					$('#list').html(data);
					$('#orderOverlayForm').center();
				}
			});
		};
		$('#AddCharge').click(function() {
			$.ajax({
				type: 'POST',
				url: 'AddManualCharge.cfm',
				data : $('#AddChargeForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading').html(data);
					//$('#loading').fadeOut();
					$('#orderOverlayForm').center();
					LoadCharges();
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
			event.preventDefault();
		});
		LoadCharges();
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1), onClose: function() {
			LoadCharges();
		}
		});
	});
</script>

<cfoutput>
<form method="post" enctype="multipart/form-data" id="AddChargeForm">
	<input type="hidden" name="orderID" value="#parm.form.orderID#" />
	<input type="hidden" name="cltID" value="#parm.form.cltID#" />
	<input type="hidden" name="cltRef" value="#parm.form.cltRef#" />
	<input type="hidden" name="delCode" value="#parm.form.delCode#" />
	<h1>Manual Charge</h1>
	<div id="saveResults" style="display:none;"></div><div id="loading"></div>
	<table border="1" class="tableList" width="100%">
		<tr>
			<th align="right">Date Delivered</th>
			<td colspan="2"><input type="text" name="datefrom" class="datepicker" value="#DateFormat(Now(),'yyyy-mm-dd')#" /></td>
		</tr>
		<tr>
			<th>Publication</th>
			<th>Qty</th>
		</tr>
		<tr>
			<td width="300">
				<select name="PubID" data-placeholder="Choose a publication..." class="select">
					<option value=""></option>
					<cfloop array="#pubs.list#" index="item">
						<option value="#item.ID#">#item.Title#</option>
					</cfloop>
				</select>
			</td>
			<td><input type="text" name="qty" value="0" size="5" style="text-align:center;" /></td>
			<td><input type="button" name="btnAdd" value="+" id="AddCharge" style="padding: 3px 8px;" /></td>
		</tr>
	</table>
	<div class="clear" style="padding:5px 0;"></div>
	<div id="list"></div>
</form>
</cfoutput>
<script type="text/javascript">
	$(".select").chosen({width: "100%"});
</script>
