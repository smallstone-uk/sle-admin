<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">


<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.nomType="purch">
<cfset nominals=supp.LoadNominalCodes(parm)>
<cfset parm.form=form>
<cfif NOT len(parm.form.trnID)>
	<cfset tran=supp.AddTransaction(parm)>
	<cfset tranID=tran.ID>
	<cfset tranLoad.error=0>
	<cfset parm.tranID=tran.ID>
	<cfset tranLoad=supp.LoadTransaction(parm)>
	<cfoutput>
		<script type="text/javascript">
			$(document).ready(function() {
				$('##EditID').val("#tran.ID#");
			});
		</script>
	</cfoutput>
<cfelse>
	<cfset parm.tranID=trnID>
	<cfset tranLoad=supp.LoadTransaction(parm)>
	<cfset tranID=tranLoad.tran[1].trnID>
	
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
	</style>
	<script type="text/javascript">
		$(document).ready(function() {
			function LoadItems() {
				$.ajax({
					type: 'POST',
					url: 'suppLoadItems.cfm',
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
			$('#Add').click(function(event) {
				$.ajax({
					type: 'POST',
					url: 'suppAddItem.cfm',
					data : $('#account-form').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
						$('#niAmount').val("");
					},
					success:function(data){
						$('#ItemsList').html(data);
						$('#loading').fadeOut();
						LoadItems();
					},
					error:function(data){
						$('#ItemsList').html(data);
						$('#loading').fadeOut();
					}
				});
				event.preventDefault();
			});
			LoadItems();
		});
	</script>
</cfif>

<cfoutput>
	<cfif tranLoad.error is 0>
		<div class="clear" style="padding:5px 0;"></div>
		<input type="hidden" name="transID" value="#tranID#">
		<table border="1" class="tableList" width="100%">
			<tr>
				<th>Title</th>
				<th width="50">Amount</th>
				<th width="20"></th>
			</tr>
			<tr>
				<td>
					<select name="nomID" tabindex="9" class="nom">
						<option value=""></option>
						<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
						<cfloop list="#keys#" index="key">
							<cfset nom=StructFind(nominals,key)>
							<option value="#nom.nomID#">#nom.nomCode# - #nom.nomTitle#</option>
						</cfloop>
					</select>
				</td>
				<td><input type="text" name="niAmount" id="niAmount" value="" tabindex="10"></td>
				<td><input type="button" name="btnAdd" id="Add" value="+" tabindex="11"></td>
			</tr>
		</table>
		<div id="ItemsList"></div>
	<cfelse>
		Transaction not found
	</cfif>
</cfoutput>

<script type="text/javascript">
	$(".nom").chosen({width: "100%"});
</script>

