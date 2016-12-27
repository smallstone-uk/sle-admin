<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ManualCharge" name="man">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset Load=man.LoadManualCharges(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadList() {
			$.ajax({
				type: 'POST',
				url: 'manualChargeList.cfm',
				data : $('#chargeForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#result').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#result').html(data);
					$('#loading').fadeOut();
				}
			});
		};
		$('.checkbox').click(function(){
			var show=false;
			$('.checkbox').each(function(index) {
				if(this.checked) {
					$('#btnDelete').show();
					show=true;
				} else {
					if(show) {
					} else {
						$('#btnDelete').hide();
						show=false;
					};
				};
			});
		});
		$('#btnDelete').click(function(event){
			$.ajax({
				type: 'POST',
				url: 'manualChargeListDel.cfm',
				data : $('#chargeForm').serialize(),
				beforeSend:function(){$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Deleting...").fadeIn();},
				success:function(data){
					$('#saveResults').html(data);
					$('#saveResults').fadeIn();
					LoadList();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				}
			});
			event.preventDefault();
		});
	});
</script>

<style type="text/css">
	#listSort {text-decoration:none;}
	#listSort.active {font-weight: bold;text-decoration: none;color: #FFF;background: #244C58;padding: 4px 10px;border-radius: 10px;}
</style>

<cfoutput>
	<h1>Charged Items for #DateFormat(parm.form.date,"DDDD, DD MMM YY")#</h1>
	<table border="1" class="tableList trhover" width="100%">
		<tr>
			<th width="20"><input type="button" id="btnDelete" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
			<th>Publication</th>
			<th width="80">Price</th>
			<th width="80">Qty</th>
			<th width="80">Line Total</th>
			<th width="80">Charge</th>
		</tr>
		<cfif ArrayLen(Load.list)>
			<cfset group="">
			<cfloop array="#Load.list#" index="i">
				<cfif group neq i.group>
					<tr>
						<th colspan="6" align="left">#i.group#</th>
					</tr>
					<cfset group=i.group>
				</cfif>
				<tr>
					<td><input type="checkbox" name="line" class="lineselect checkbox" value="#i.ID#" /></td>
					<td>#i.PubID#</td>
					<td align="right">&pound;#DecimalFormat(i.Price)#</td>
					<td align="center">#i.Qty#</td>
					<td align="right">&pound;#DecimalFormat(i.lineTotal)#</td>
					<td align="right"><cfif i.Charge neq 0>&pound;#DecimalFormat(i.Charge)#</cfif></td>
				</tr>
			</cfloop>
			<tr>
				<th colspan="3" align="right">Totals</th>
				<td align="center"><strong>#int(Load.qtyTotal)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(Load.pubTotal)#</strong></td>
				<td align="right"><strong>&pound;#DecimalFormat(Load.delTotal)#</strong></td>
			</tr>
		<cfelse>
			<tr>
				<td colspan="8">No items found</td>
			</tr>
		</cfif>
	</table>
</cfoutput>
