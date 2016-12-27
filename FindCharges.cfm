<cftry>
	<cfset callback=1>
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
			};
			$('.checkboxd').click(function(){
				var show=false;
				$('.checkboxd').each(function(index) {
					if(this.checked) {
						$('#AddCredit').show();
						show=true;
					} else {
						if(show) {
						} else {
							$('#AddCredit').hide();
							show=false;
						};
					};
				});
			});
			$('.checkboxc').click(function(){
				var show=false;
				$('.checkboxc').each(function(index) {
					if(this.checked) {
						$('#RemoveCredit').show();
						show=true;
					} else {
						if(show) {
						} else {
							$('#RemoveCredit').hide();
							show=false;
						};
					};
				});
			});
			$('#AddCredit').click(function() {
				$.ajax({
					type: 'POST',
					url: 'AddCreditNote.cfm',
					data : $('#FindChargesForm').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#loading').html(data);
						$('#loading').fadeOut();
						LoadCharges();
						$('#orderOverlayForm').center();
					},
					error:function(data){
						$('#loading').html(data);
					}
				});
				event.preventDefault();
			});
			$('#RemoveCredit').click(function() {
				$.ajax({
					type: 'POST',
					url: 'AddCreditNoteDelete.cfm',
					data : $('#FindChargesForm').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#update').html(data);
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
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
		});
	</script>
	
	<cfoutput>
		<cfif StructKeyExists(LoadCharges,"msg")>#LoadCharges.msg#</cfif>
		<cfif ArrayLen(LoadCharges.debit)>
			<table border="1" class="tableList" width="300" style="float:left;margin:0 5px 0 0;">
				<tr>
					<th colspan="4">Debited Items</th>
				</tr>
				<tr>
					<th width="15">
						<button type="button" id="AddCredit" class="button" style="display:none;padding: 2px 3px;margin: 0px;font-size: 10px;" title="Credit selected items">
							<img src="images/credit.png" width="12" height="12" style="margin:0;" />
						</button>
					<th width="40">Date</th>
					<th width="">Title</th>
					<th width="50">Qty to Credit</th>
				</tr>
				<cfloop array="#LoadCharges.debit#" index="i">
					<tr>
						<td><input type="checkbox" name="selectItem" class="selectItem checkboxd" value="#i.ID#"></td>
						<td>#DateFormat(i.date,"DD/MM/YYYY")#</td>
						<td>#i.title#</td>
						<td align="center"><input type="text" size="2" name="qty#i.ID#" value="#i.qty#" style="text-align:center;"></td>
					</tr>
				</cfloop>
			</table>
		</cfif>
		<cfif ArrayLen(LoadCharges.credit)>
			<table border="1" class="tableList" width="300" style="float:left;margin:0 5px 0 0;">
				<tr>
					<th colspan="4">Credited Items</th>
				</tr>
				<tr>
					<th width="15"><input type="button" id="RemoveCredit" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
					<th width="40">Date</th>
					<th width="">Title</th>
					<th width="50">Qty Credited</th>
				</tr>
				<cfloop array="#LoadCharges.credit#" index="i">
					<tr class="#i.diType#">
						<td><input type="checkbox" name="selectItem" class="selectItem checkboxc" value="#i.ID#"></td>
						<td>#DateFormat(i.date,"DD/MM/YYYY")#</td>
						<td>#i.title#</td>
						<td align="center">#i.qty#</td>
					</tr>
				</cfloop>
			</table>
		</cfif>
	</cfoutput>
	
	<cfcatch type="any">
		<cfdump var="#cfcatch#" label="cfcatch" expand="no">
	</cfcatch>
</cftry>
