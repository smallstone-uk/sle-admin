<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cftry>
	<cfobject component="code/functions" name="func">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset parm.type="claim">
	<cfset stock=func.GetPubStockByDate(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
			function LoadCreditList() {
				$.ajax({
					type: 'POST',
					url: 'GetClaimedStock.cfm',
					data : $('#claimForm').serialize(),
					beforeSend:function(){
						$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#claimedlist').html(data);
						$('#loading4').fadeOut();
					},
					error:function(data){
						$('#claimedlist').html(data);
						$('#loading4').fadeOut();
					}
				});
			};
			$('.checkboxcl').click(function(){
				var show=false;
				$('.checkboxcl').each(function(index) {
					if(this.checked) {
						$('#btnDeletecl').show();
						show=true;
					} else {
						if(show) {
						} else {
							$('#btnDeletecl').hide();
							show=false;
						};
					};
				});
			});
			$('#btnDeletecl').click(function(event){
				$.ajax({
					type: 'POST',
					url: 'pubStockDelItem.cfm',
					data : $('#stocklistcl').serialize(),
					beforeSend:function(){$('#loading4').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Deleting...").fadeIn();},
					success:function(data){
						$('#loading4').html(data);
						LoadCreditList();
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
				LoadCreditList();
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
	</style>
	
	<cfoutput>
		<cfif ArrayLen(stock.list)>
			<form method="post" id="stocklistcl" enctype="multipart/form-data">
				<input type="hidden" name="psDate" value="#parm.form.psDate#" />
				<table border="1" class="tableList trhover" width="100%">
					<tr>
						<th width="20"><input type="button" id="btnDeletecl" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
						<th><a href="##" id="listSort">Title</a></th>
						<th width="60">Issue</th>
						<th width="60">Retail</th>
						<th width="60">Discount</th>
						<th width="60">Credited</th>
						<th width="60">Line Total</th>
						<th width="60">Vat Rate</th>
						<th width="60">Vat</th>
					</tr>
					<cfloop array="#stock.list#" index="item">
						<tr>
							<td><cfif item.ID neq 0><input type="checkbox" name="line" class="lineselect checkboxcl" value="#item.ID#" /></cfif></td>
							<td style="text-transform:capitalize;"><a href="##" class="editPub" data-ID="#item.pubID#">#LCase(item.Title)#</a><span style="float:right;">#item.Ref#</span></td>
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
						<td align="right">&pound;#stock.GrandTotal+stock.VatTotal#</td>
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

