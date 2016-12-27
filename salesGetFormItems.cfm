<!--- AJAX call - check client do not show debug data at all --->

<cftry>
	<cfset callback=1><!--- force exit of onrequestend.cfm --->
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	
	<cfobject component="code/accounts" name="supp">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset parm.nomType="sales">
	<cfset parm.tillButtons=1>
	<!---<cfset nominals=supp.LoadNominalCodes(parm)>--->
	<cfset loadNoms = supp.LoadNominalCodes(parm)>
	<cfset nominals = loadNoms.codes>
	<cfset parm.nomType="">
	<cfset parm.tillButtons=2>
	<cfset payAccounts=supp.LoadNominalCodes(parm)>
	
	<cfif NOT len(parm.form.trnID)>
		<cfset tran=supp.AddTransaction(parm)>
		<cfset tranID=tran.ID>
		<cfset parm.tranID=tran.ID>
		<cfset tranLoad=supp.LoadSalesTransaction(parm)>
		<cfoutput>
			<script type="text/javascript">
				$(document).ready(function() {
					$('##EditID').val("#tran.ID#");
				});
			</script>
		</cfoutput>
	<cfelse>
		<cfset parm.tranID=trnID>
		<cfset tranLoad=supp.LoadSalesTransaction(parm)>
		<cfset tranID=trnID>
		<cfif tranLoad.error is 0>
			<cfoutput>
				<script type="text/javascript">
					$(document).ready(function() {
						$('##Mode').val(2);
						$('##Ref').val("#tranLoad.tran[1].trnRef#");
						$('##trnDate').val("#DateFormat(tranLoad.tran[1].trnDate,'DD/MM/YYYY')#");
						$('##Ref').val("#tranLoad.tran[1].trnRef#");
						$('##NetAmount').val("#tranLoad.NetAmount#");
						$('##VATAmount').val("#tranLoad.VatAmount#");
						$('##Active').html("#tranLoad.tran[1].trnActive#");
					});
				</script>
			</cfoutput>
		</cfif>
	</cfif>
	
	<cfif tranLoad.error is 0>	
		<style type="text/css">
			.red {color:#ff0000;}
			.green {color:#35AF06;}
			.amount {text-align:right; color:#3300FF;}
		</style>
		<script type="text/javascript">
			$(document).ready(function() {
				function LoadItems() {
					$.ajax({
						type: 'POST',
						url: 'salesLoadItems.cfm',
						data : $('#account-form').serialize(),
						beforeSend:function(){
							$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
						},
						success:function(data){
							$('#ItemsList').html(data);
							var netString=$('#NetAmount').val();
							var totString=$('#check-total').val();
						//	alert('check-total = '+totString);
						//	var net=netString.replace("£","");
						//	var tot=totString.replace("£","");
							var netNum=Number(netString,10);
							var totNum=Number(totString,10);
							var checktotal=netNum-totNum;
							$('#Check').html(checktotal.toFixed(2));
							if (totNum == netNum) {
								$('#Check').addClass("green");
							} else {
								$('#Check').addClass("red");
							}
							var vatString=$('#VATAmount').val();
							var vattotString=$('#check-VatTotal').val();
						//	var vat=vatString.replace("£","");
						//	var vattot=vattotString.replace("£","");
							var vatNum=Number(vatString,10);
							var vattotNum=Number(vattotString,10);
							var checkvattotal=vatNum-vattotNum;
							$('#CheckVat').html(checkvattotal.toFixed(2));
							if (vattotNum == vatNum) {
								$('#CheckVat').addClass("green");
							} else {
								$('#CheckVat').addClass("red");
							}
							
							$('#loading').fadeOut();
						},
						error:function(data){
							$('#ItemsList').html(data);
							$('#loading').fadeOut();
						}
					});
				}		
				$('#SaveSalesList').click(function(event) {
					$.ajax({
						type: 'POST',
						url: 'salesUpdateItem.cfm',
						data : $('#account-form').serialize(),
						beforeSend:function(){
							$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
							$('#catList').fadeTo( "slow" , 0.3, function() {});
						},
						success:function(data){
							$('#catList').fadeTo( "slow" , 1, function() {
								$('#catList').html(data);
								$('#catList').ready(function() {
									$('html, body').animate({scrollTop: $("html").offset().top},500);
									CheckTotals();
								});
							});
							$('#loading').fadeOut();
						},
						error:function(data){
							$('#catList').html(data);
							$('#loading').fadeOut();
						}
					});
					event.preventDefault();
				});
				$('.nomAmount').blur(function(event) {
					var amount=0;
					var total=0;
					var total=Number($('#check-total').val(),10);
					$('.nomAmount').each(function() {
						var thisAmount=Number($(this).val(),10);
						amount=amount+thisAmount;
					});				
					var sumTot=amount;
					$('#check-total').val(sumTot.toFixed(2));
					$('#check-total-v').html(sumTot.toFixed(2));
					CheckTotals();
				});
				function CheckTotals() {
					var netString=$('#NetAmount').val();
					var totString=$('#check-total').val();
					var netNum=Number(netString,10);
					var totNum=Number(totString,10);
					var checktotal=netNum-totNum;
					$('#Check').html(checktotal.toFixed(2));
					if (totNum == netNum) {
						$('#Check').addClass("green");
					} else {
						$('#Check').addClass("red");
					}
					var vatString=$('#VATAmount').val();
					var vattotString=$('#check-VatTotal').val();
					var vatNum=Number(vatString,10);
					var vattotNum=Number(vattotString,10);
					var checkvattotal=vatNum-vattotNum;
					$('#CheckVat').html(checkvattotal.toFixed(2));
					if (vattotNum == vatNum) {
						$('#CheckVat').addClass("green");
					} else {
						$('#CheckVat').addClass("red");
					}
				};
				CheckTotals();
			});
			$(".nomAmount").focus(function() {
				$("tr").removeClass('RowHighlight');
				$(this).closest("tr").addClass('RowHighlight');
			}).blur(function() {
				$("tr").removeClass('RowHighlight');
			//	var value = $(this).val();
				var value = isNaN(parseFloat($(this).val())) ? 0 : parseFloat($(this).val())
				$(this).val(parseFloat(value).toFixed(2));
			});
		</script>
	</cfif>
	
	<cfoutput>
		<cfif tranLoad.error is 0>
			<input type="hidden" name="transID" value="#tranID#">
			<div class="clear" style="padding:5px 0;"></div>
			<div id="catList">
				<table border="1" class="tableList" width="50%">
					<tr>
						<th width="30">Code</th>
						<th width="150">Title</th>
						<th width="30">Amount</th>
					</tr>
					<cfif ArrayLen(tranLoad.items)>
						<cfloop array="#tranLoad.items#" index="item">
							<input type="hidden" name="niID" value="#item.niID#">
							<tr>
								<td>#item.nomCode#</td>
								<td>#item.nomTitle#</td>
								<td><input type="text" name="niAmount_#item.niID#" class="amount nomAmount" value="#DecimalFormat(item.niAmount)#" size="10"></td>
								<td></td>
							</tr>
						</cfloop>
					<cfelse>
						<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
						<cfloop list="#keys#" index="key">
							<cfset nom=StructFind(nominals,key)>
							<input type="hidden" name="niNomID" value="#nom.nomID#">
							<tr>
								<td>#nom.nomCode#</td>
								<td>#nom.nomTitle#</td>
								<td><input type="text" name="niAmount_#nom.nomID#" value="" class="amount nomAmount" size="10"></td>
							</tr>
						</cfloop>
					</cfif>
					<tr>
						<th></th>
						<th align="right">Total</th>
						<td align="right"><input type="hidden" name="total" id="check-total" value="#tranLoad.GrandTotal#">
							<strong id="check-total-v">#DecimalFormat(tranLoad.GrandTotal)#</strong></td>
						<td align="right"><input type="hidden" name="VatTotal" id="check-VatTotal" value="#tranLoad.GrandVatTotal#">
							<strong>#DecimalFormat(tranLoad.GrandVatTotal)#</strong></td>
					</tr>
					<tr>
						<th></th>
						<th align="right">Difference</th>
						<td id="Check" align="right"></td>
						<td id="CheckVat" align="right"></td>
					</tr>
				</table>
			</div>
			<div class="clear" style="padding:5px 0;"></div>
			<input type="button" name="btnSaveSalesList" id="SaveSalesList" value="Save List" tabindex="99">
		<cfelse>
			Transaction not found
		</cfif>
	</cfoutput>
	
	<script type="text/javascript">
		$(".nom").chosen({width: "100%"});
	</script>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

