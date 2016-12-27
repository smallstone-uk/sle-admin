<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>
<cfset LoadCharges=func.LoadChargesFromDate(parm)>

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
		$('.checkbox').click(function(){
			var show=false;
			$('.checkbox').each(function(index) {
				if(this.checked) {
					$('#DeleteDebit').show();
					show=true;
				} else {
					if(show) {
					} else {
						$('#DeleteDebit').hide();
						show=false;
					};
				};
			});
		});
		$('#DeleteDebit').click(function() {
			$.ajax({
				type: 'POST',
				url: 'AddCreditNoteDelete.cfm',
				data : $('#AddChargeForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#list').html(data);
					$('#loading').fadeOut();
					$('#orderOverlayForm').center();
					LoadCharges();
				},
				error:function(data){
					$('#loading').html(data);
				}
			});
			event.preventDefault();
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1), onClose: function() {
			LoadCharges();
		}
		});
	});
</script>

<cfoutput>
		<h2>Debited Items</h2>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th width="10"><input type="button" id="DeleteDebit" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
				<th width="40">Date</th>
				<th width="">Title</th>
				<th width="50">RRP</th>
				<th width="50">Charge</th>
				<th width="50">Qty</th>
			</tr>
			<cfif ArrayLen(LoadCharges.debit)>
				<cfloop array="#LoadCharges.debit#" index="i">
					<tr class="#i.diType#">
						<td><input type="checkbox" name="selectItem" class="selectItem checkbox" value="#i.ID#"></td>
						<td>#DateFormat(i.date,"DD/MM/YYYY")#</td>
						<td>#i.title#</td>
						<td>#i.price#</td>
						<td>#i.charge#</td>
						<td>#i.qty#</td>
					</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="8">No items found</td>
				</tr>
			</cfif>
		</table>
</cfoutput>