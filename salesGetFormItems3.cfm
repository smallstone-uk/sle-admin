<!--- AJAX call - check client do not show debug data at all --->
<cftry>
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/accounts3" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.nomType="sales">
<cfset parm.tillButtons=1>
<cfset nominals=supp.LoadNominalCodes(parm)>

<cfset parm.nomType="">
<cfset parm.tillButtons=2>
<cfset payAccounts=supp.LoadPayAccounts(parm)>

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
					url: 'salesLoadItems3.cfm',
					data : $('#account-form').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading itemsz...").fadeIn();
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
						alert("error loading items");
						$('#ItemsList').html(data);
						$('#loading').fadeOut();
					}
				});
			}		
			function ReloadItems() {
				$.ajax({
					type: 'POST',
					url: 'salesGetFormItems3.cfm',
					data : $('#account-form').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Reloading items...").fadeIn();
					},
					success:function(data){
						$('#transItems').html(data);
						$('#loading').fadeOut();
					},
					error:function(data){
						alert("error loading items");
						$('#transItems').html(data);
						$('#loading').fadeOut();
					}
				});
			}
			$('#SaveSalesList').click(function(event) {
				$.ajax({
					type: 'POST',
					url: 'salesUpdateItem3.cfm',
					data : $('#account-form').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Updating items...").fadeIn();
						$('#catList').fadeTo( "slow" , 0.3, function() {});
					},
					success:function(data){
						$('#catList').fadeTo( "slow" , 1, function() {
							$('#catList').html(data);
							$('#catList').ready(function() {
								$('html, body').animate({scrollTop: $("html").offset().top},500);
								ReloadItems();
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
			$('.R3').blur(function(event) {
				var amount=0;
				var total=0;
				var total=Number($('#paycheck-total').val(),10);
				$('.R3').each(function() {
					var thisAmount=Number($(this).val(),10);
					amount=amount+thisAmount;
				});				
				var sumTot=amount;
				$('#paycheck-total').val(sumTot.toFixed(2));
				$('#paycheck-total-v').html(sumTot.toFixed(2));
				CheckTotals();
			});
			$('.R4').blur(function(event) {
				CheckTotals();
			});
			function CheckTotals() {
				var netString=$('#NetAmount').val();
				var totString=$('#check-total').val();
				var payString=$('#paycheck-total').val();
				var w2String=$('#W2').val();
				var netNum=Number(netString,10);
				var totNum=Number(totString,10);
				var payNum=Number(payString,10);
				var w2Num=Number(w2String,10);
				var checktotal=netNum-totNum;
				var paytotal=netNum-payNum;
				console.log(paytotal);

				var cashString=$('#CASH').val();
				var cardString=$('#CARD').val();
				var chqString=$('#CHQ').val();
				var suppString=$('#SUPP').val();
				var cbString=$('#CB').val();
				var cashNum=Number(cashString,10);
				var cardNum=Number(cardString,10);
				var chqNum=Number(chqString,10);
				var suppNum=Number(suppString,10);
				var cbNum=Number(cbString,10);
				
				var cashINDW = cashNum - suppNum - cbNum;
				$('#cashINDW').html(cashINDW.toFixed(2));
				var cardINDW = cardNum + cbNum;
				$('#cardINDW').html(cardINDW.toFixed(2));
			//	var checkDrawer = totNum - (cashINDW + cardINDW + chqNum + suppNum);
			//	$('#drawer').html(checkDrawer.toFixed(2));
				
				$('#Check').html(checktotal.toFixed(2));
				$('#CheckPay').html(paytotal.toFixed(2));
				if (totNum == netNum) {
					$('#Check').addClass("green");
				} else {
					$('#Check').addClass("red");
				}
				if (payNum == netNum) {
					$('#CheckPay').addClass("green");
				} else {
					$('#CheckPay').addClass("red");
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
		<input type="hidden" name="payItemCount" value="#tranLoad.payItemCount#">
		<div class="clear" style="padding:5px 0;"></div>
		<div id="catList" style="float:left; margin-right:20px;">
			<table border="1" class="tableList">
				<tr>
					<th width="30">Code</th>
					<th width="150">Title</th>
					<th width="20">Amount</th>
				</tr>
				<cfif ArrayLen(tranLoad.items)>
					<cfloop array="#tranLoad.items#" index="item">
						<input type="hidden" name="niID" value="#item.niID#">
						<tr>
							<td>#item.nomCode#</td>
							<td>#item.nomTitle#</td>
							<td align="right"><input type="text" name="niAmount_#item.niID#" class="amount nomAmount" value="#DecimalFormat(item.niAmount)#" size="10"></td>
						</tr>
					</cfloop>
				<cfelse>
					<cfset keys=ListSort(StructKeyList(nominals.codes,","),"text","asc",",")>
					<cfloop list="#keys#" index="key">
						<cfif StructKeyExists(nominals.codes,key)>
							<cfset nom=StructFind(nominals.codes,key)>
							<input type="hidden" name="niNomID" value="#nom.nomID#">
							<tr>
								<td>#nom.nomCode#</td>
								<td>#nom.nomTitle#</td>
								<td align="right"><input type="text" name="niAmount_#nom.nomID#" value="" class="amount nomAmount" size="10"></td>
							</tr>
						</cfif>
					</cfloop>
				</cfif>
				<tr>
					<th></th>
					<th align="right">Total</th>
					<td align="right"><input type="hidden" name="total" id="check-total" value="#tranLoad.GrandTotal#">
						<strong id="check-total-v">#DecimalFormat(tranLoad.GrandTotal)#</strong></td>
				</tr>
				<tr>
					<th></th>
					<th align="right">Difference</th>
					<td id="Check" align="right"></td>
				</tr>
			</table>
		</div>
		<div id="payDiv" style="float:left;">
			<table border="1" class="tableList">
				<tr>
					<th width="30">Code</th>
					<th width="150">Title</th>
					<th width="20">Amount</th>
					<cfif ArrayLen(tranLoad.payItems)>
						<cfset currGroup = "">
						<cfloop array="#tranLoad.payItems#" index="item">
							<input type="hidden" name="niPay" value="#item.niID#">
							<cfif currGroup neq "" AND currGroup neq item.nomGroup>
								<tr><td colspan="3">&nbsp;</td></tr>
							</cfif>
							<tr>
								<td>#item.nomCode#</td>
								<td>#item.nomTitle#</td>
								<cfif item.niID neq 0>
									<cfif item.niAmount neq 0><cfset value=item.niAmount><cfelse><cfset value=""></cfif>
									<td align="right">
										<input type="text" name="niPay_#item.niID#" id="#item.nomCode#" size="10" class="amount #item.nomGroup#" value="#value#" /></td>
								<cfelse>
									<td align="right"><input type="text" name="niPay_#item.nomID#" id="#item.nomCode#" size="10" class="amount #item.nomGroup#" value="" /></td>
								</cfif>
							</tr>
							<cfset currGroup = item.nomGroup>
						</cfloop>
					</cfif>
				</tr>
				<tr><td colspan="3">&nbsp;</td></tr>
				<tr>
					<th height="20"></th>
					<th align="right">Cash INDW</th>
					<td id="cashINDW" align="right"></td>
				</tr>
				<tr>
					<th height="20"></th>
					<th align="right">Card INDW</th>
					<td id="cardINDW" align="right"></td>
				</tr>
				<tr>
					<th></th>
					<th align="right">Total</th>
					<td align="right"><input type="hidden" name="paytotal" id="paycheck-total" value="#tranLoad.payTotal#">
						<strong id="paycheck-total-v">#DecimalFormat(tranLoad.payTotal)#</strong></td>
				</tr>
				<tr>
					<th></th>
					<th align="right">Difference</th>
					<td id="CheckPay" align="right"></td>
				</tr>
<!---
				<tr>
					<th></th>
					<th align="right">Check</th>
					<td id="drawer" align="right"></td>
				</tr>
--->
			</table>
			<div class="clear" style="padding:5px 0;"></div>
			<input type="button" name="btnSaveSalesList" id="SaveSalesList" value="Save List" tabindex="999">
		</div>
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
