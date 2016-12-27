<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cftry>
	<cfobject component="code/functions" name="func">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset parm.type="received">
	<cfset stock=func.GetPubStockByDate(parm)>
	
	<script type="text/javascript">
		$(document).ready(function() {
			function LoadReceivedList() {
				$.ajax({
					type: 'POST',
					url: 'GetReceivedStock.cfm',
					data : $('#stockForm').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#receivedlist').html(data);
						$('#loading').fadeOut();
					},
					error:function(data){
						$('#receivedlist').html(data);
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
					url: 'pubStockDelItem.cfm',
					data : $('#stocklist').serialize(),
					beforeSend:function(){$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Deleting...").fadeIn();},
					success:function(data){
						$.ajax({
							type: 'POST',
							url: 'GetReceivedStock.cfm',
							data : $('#stockForm').serialize(),
							beforeSend:function(){
								$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
							},
							success:function(data){
								$('#receivedlist').html(data);
								$('#loading').fadeOut();
							},
							error:function(data){
								$('#receivedlist').html(data);
								$('#loading').fadeOut();
							}
						});
					}
				});
				event.preventDefault();
			});
			$('#listSort').click(function(event){
				var list=$('#listOrder').val();
				if (list == "entry") {
					$('#listOrder').val('title');
					$('#listSort').addClass('active');
				} else {
					$('#listOrder').val('entry');
					$('#listSort').removeClass('active');
				};
				LoadReceivedList();
				event.preventDefault();
			});
			var listOrd=$('#listOrder').val();
			if (listOrd == "entry") {
				$('#listSort').removeClass('active');
			} else {
				$('#listSort').addClass('active');
			};
			$('.editPub').click(function(e){
				var id=$(this).attr("data-ID");
				OpenEdit(id);
				e.preventDefault();
			});
		});
	</script>
	
	<style type="text/css">
		#listSort {text-decoration:none;}
		#listSort.active {font-weight: bold;text-decoration: none;color: #FFF;background: #244C58;padding: 4px 10px;border-radius: 10px;}
		.normal {background-color:#FFFFFF;}
		.misc {background-color:#FFFFCC;}
		.recharge {background-color:#FFCCCC;}
	</style>
	
	<cfoutput>
		<cfif ArrayLen(stock.list)>
			<form method="post" id="stocklist" enctype="multipart/form-data">
				<table border="1" class="tableList trhover" width="100%">
					<tr>
						<th width="20"><input type="button" id="btnDelete" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
						<th><a href="##" id="listSort">Title</a></th>
						<th width="60">Type</th>
						<th width="60">Issue</th>
						<th width="60">Retail</th>
						<th width="60">Discount</th>
						<th width="60">Received</th>
						<th width="60">Line Total</th>
						<th width="60">Vat Rate</th>
						<th width="60">Vat</th>
					</tr>
					<cfloop array="#stock.list#" index="item">
						<tr class="#item.psSubType#">
							<td><cfif item.ID neq 0><input type="checkbox" name="line" class="lineselect checkbox" value="#item.ID#" /></cfif></td>
							<td style="text-transform:capitalize;"><a href="##" class="editPub" data-ID="#item.pubID#">#LCase(item.Title)#</a></td>
							<td>#item.psSubType#</td>
							<td>#UCase(item.Issue)#</td>
							<td align="right">&pound;#item.Retail#</td>
							<td align="right">
								<cfif item.DiscountType eq "pc">
									#item.Discount#%
								<cfelse>
									#item.Discount#-
								</cfif>
							</td>
							<td align="center">#item.Qty#</td>
							<td align="right">&pound;#item.LineTotal#</td>
							<td align="right">#item.Vat*100#%</td>
							<td align="right">&pound;#item.VatLineTotal#</td>
						</tr>
					</cfloop>
				</table>
			</form>
			<div class="clear" style="text-align:center;width: 200px;margin: 10px auto;">
				<table border="1" class="tableList" width="200">
					<tr>
						<th align="right" width="100">Total Net</th>
						<td align="right">&pound;#stock.GrandTotal#</td>
					</tr>
					<tr>
						<th align="right">Total VAT</th>
						<td align="right">&pound;#stock.VatTotal#</td>
					</tr>
					<tr>
						<th align="right">Grand Total</th>
						<td align="right">&pound;#DecimalFormat(ReReplace(stock.GrandTotal,",","","all")+ReReplace(stock.VatTotal,",","","all"))#</td>
					</tr>
				</table>
			</div>
		</cfif>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

