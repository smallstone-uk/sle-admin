<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form.OrderID=ID>
<cfset vouchers=cust.LoadVouchers(parm)>

<script type="text/javascript">
	$(document).ready(function() {
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
		$('.checkboxv').click(function(){
			var show=false;
			$('.checkboxv').each(function(index) {
				if(this.checked) {
					$('#btnDeletev').show();
					show=true;
				} else {
					if(show) {
					} else {
						$('#btnDeletev').hide();
						show=false;
					};
				};
			});
		});
		$('#btnDeletev').click(function(event){
			$.ajax({
				type: 'POST',
				url: 'AddVoucherRemove.cfm',
				data : $('#removeVoucherForm').serialize(),
				success:function(data){
					$('#saveResults').html(data).fadeIn();
					LoadVouchers();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				}
			});
			event.preventDefault();
		});
	});
</script>

<style type="text/css">
	.out {background:#FF9696;}
</style>

<cfoutput>
	<form method="post" enctype="multipart/form-data" id="removeVoucherForm">
		<table border="1" width="100%" class="tableList">
			<tr>
				<th width="20"><input type="button" id="btnDeletev" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
				<th width="200">Publication</th>
				<th width="80">Start Date</th>
				<th width="80">Stop Date</th>
				<th width="80">Discount</th>
			</tr>
			<cfif ArrayLen(vouchers.list)>
				<cfloop array="#vouchers.list#" index="item">
					<tr class="#item.status#">
						<td><input type="checkbox" name="line" class="lineselect checkboxv" value="#item.ID#" /></td>
						<td>#item.pub#</td>
						<td>#item.start#</td>
						<td>#item.stop#</td>
						<td align="right"><cfif item.type is "pc">#item.discount#%<cfelse>-&pound;#item.discount#</cfif></td>
					</tr>
				</cfloop>
			<cfelse>
				<tr>
					<td colspan="5">No Vouchers found for this order.</td>
				</tr>
			</cfif>
		</table>
	</form>
</cfoutput>

