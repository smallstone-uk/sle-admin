<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cftry>
	<cfobject component="code/functions" name="func">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset parm.type="returned">
	<cfset stock=func.GetPubStockByDate(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
			function ReceivedPubList() {
				$.ajax({
					type: 'POST',
					url: 'GetPubIssue.cfm',
					data : $('#returnPubForm').serialize(),
					beforeSend:function(){
						$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#issue').html(data);
						$('#loading2').fadeOut();
					},
					error:function(data){
						$('#issue').html(data);
						$('#loading2').fadeOut();
					}
				});
			};
			function LoadReturnedList() {
				$.ajax({
					type: 'POST',
					url: 'GetReturnedStock.cfm',
					data : $('#returnPubForm').serialize(),
					beforeSend:function(){
						$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#returnedlist').html(data);
						$('#loading2').fadeOut();
					},
					error:function(data){
						$('#returnedlist').html(data);
						$('#loading2').fadeOut();
					}
				});
			};
			$('.checkboxr').click(function(){
				var show=false;
				$('.checkboxr').each(function(index) {
					if(this.checked) {
						$('#btnDeleter').show();
						show=true;
					} else {
						if(show) {
						} else {
							$('#btnDeleter').hide();
							show=false;
						};
					};
				});
			});
			$('#btnDeleter').click(function(event){
				$.ajax({
					type: 'POST',
					url: 'pubStockDelItem.cfm',
					data : $('#stocklistR').serialize(),
					beforeSend:function(){$('#loading2').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Deleting...").fadeIn();},
					success:function(data){
						$('#loading2').html(data);
						LoadReturnedList();
						ReceivedPubList();
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
				LoadReturnedList();
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
			<form method="post" id="stocklistR" enctype="multipart/form-data">
				<table border="1" class="tableList trhover" width="100%">
					<tr>
						<th width="20"><input type="button" id="btnDeleter" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
						<th><a href="##" id="listSort">Title</a></th>
						<th width="60">Issue</th>
						<th width="60">Retail</th>
						<th width="60">Discount</th>
						<th width="60">Returned</th>
						<th width="60">Line Total</th>
						<th width="60">Vat Rate</th>
						<th width="60">Vat</th>
					</tr>
					<cfloop array="#stock.list#" index="item">
						<tr>
							<td><cfif item.ID neq 0><input type="checkbox" name="line" class="lineselect checkboxr" value="#item.ID#" /></cfif></td>
							<td style="text-transform:capitalize;">
								<a href="##" class="editPub" data-ID="#item.pubID#">#LCase(item.Title)#</a>
								<cfif len(item.OrderStamp)><br /><span style="color:##666;font-size:10px;">#item.OrderStamp#</span></cfif>
							</td>
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
						<td align="right">&pound;#DecimalFormat(stock.GrandTotal+stock.VatTotal)#</td>
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

