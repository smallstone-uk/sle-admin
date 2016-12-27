
<cftry>
<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<script type="text/javascript">
	$(document).ready(function() {
		function GrossTotal() {
			var netString=$('#NetAmount').val();
			var vatString=$('#VATAmount').val();
			
		//	var net=netString.replace("£","");
		//	var vat=vatString.replace("£","");
			
			var netNum=Number(netString,10);
			var vatNum=Number(vatString,10);
			
			var total=netNum+vatNum;
			
			$('#NetAmount').val(netNum.toFixed(2));
		//	$('#VATAmount').val(vatNum.toFixed(2));
			$('#GrossTotal').val(total.toFixed(2));
		}
		$('#NetAmount').on("change", function() {GrossTotal();});
		$('#VATAmount').on("change", function() {GrossTotal();});
		$('#New').click(function() {GetFormItems();});
		$('#Save').click(function() {UpdateTran();});
		function GetFormItems() {
			$.ajax({
				type: 'POST',
				url: 'suppGetFormItems.cfm',
				data : $('#account-form').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#transItems').html(data);
					$('#loading').fadeOut();
				},
				error:function(data){
					$('#transItems').html(data);
					$('#loading').fadeOut();
				}
			});
		//	event.preventDefault();
		}
		function UpdateTran() {
			$.ajax({
				type: 'POST',
				url: 'suppUpdateTran.cfm',
				data : $('#account-form').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#loading').fadeOut();
					GetFormItems();
				},
				error:function(data){
					$('#loading').fadeOut();
				}
			});
		//	event.preventDefault();
		}
		$('#EditID').blur(function() {
			$('#Mode').val(2);
			var edit=$('#EditID').val();
			if (edit != "") {
				$.ajax({
					type: 'POST',
					url: 'suppGetFormItems.cfm',
					data : $('#account-form').serialize(),
					beforeSend:function(){
						$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
					},
					success:function(data){
						$('#transItems').html(data);
						$('#loading').fadeOut();
						GrossTotal();
					},
					error:function(data){
						$('#transItems').html(data);
						$('#loading').fadeOut();
					}
				});
				$('#Save').show();
				$('#New').hide();
			} else {
				$('#Mode').val(1);
				<cfoutput>$('##Date').val("#DateFormat(Now(),'DD/MM/YYYY')#");</cfoutput>
				$('#Ref').val("");
				$('#NetAmount').val("");
				$('#VATAmount').val("");
				$('#GrossTotal').val("");
				$('#transItems').html("");
				$('#ItemsList').html("");
				$('#Save').hide();
				$('#New').show();
			}
		//	event.preventDefault();
		});
		$('.tab').click(function() {
			var type=$(this).attr("rel");
			$('#Type').val(type);
			$('#Mode').val(1);
			<cfoutput>$('##Date').val("#DateFormat(Now(),'DD/MM/YYYY')#");</cfoutput>
			$('#EditID').val("");
			$('#Ref').val("");
			$('#NetAmount').val("");
			$('#VATAmount').val("");
			$('#GrossTotal').val("");
			$('#transItems').html("");
			$('#ItemsList').html("");
			$('#Save').hide();
			$('#New').show();
			if (type == "crn") {
				$('.tableList th').css("background","#FF9E9E");
			} else {
				$('.tableList th').css("background","#EEE");
			};
		});
	});
</script>


<cfobject component="code/accounts" name="supp">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.accountID=accID>
<cfset parm.nomType=form.accType>
<cfset nominals=supp.LoadNominalCodes(parm)>
<cfset suppData=supp.LoadTransactionListOld(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
			$(function() {
				$("#tabs").tabs();
			});
			
			$('#trnDate').blur(function(event) {
				var dateChecked=checkDate($('#trnDate').val());
				if (!dateChecked) {
					alert('Date is out of range')
					setTimeout(function() {
						$('#trnDate').focus();
					}, 0);
				} else {
					$('#trnDate').val(dateChecked)			
				}
			});
		});
	</script>
<cfoutput>
	<div id="tabs">
		<ul>
			<li><a href="##Invoice" rel="inv" class="tab">Invoice</a></li>
			<li><a href="##Credit" rel="crn" class="tab">Credit Note</a></li>
		</ul>
		<div id="Invoice">
		</div>
		<div id="Credit">
		</div>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th width="100" align="left">Account Code</th>
				<td>#suppData.Account[1].accCode# <a href="suppTranList.cfm?account=#suppData.Account[1].accID#" target="_blank">Tran List</a></td>
				<th width="100" align="left">Account Name</th>
				<td>#suppData.Account[1].accName#</td>
				<th width="100" align="left">Account Type</th>
				<td>#suppData.Account[1].accType#</td>
				<th width="100" align="left">Account Group</th>
				<td>#suppData.Account[1].accGroup#</td>
			</tr>
		</table>
		<div style="padding:10px 0;"></div>
		<input type="hidden" name="type" value="inv" id="Type">
		<input type="hidden" name="mode" value="1" id="Mode">
		<table border="1" class="tableList" width="100%">
			<tr>
				<th width="100" align="left">Trans ID</th>
				<td><input type="text" name="trnID" value="" id="EditID" tabindex="2"></td>
				<th width="100" align="left">Net Amount</th>
				<td><input type="text" name="trnAmnt1" value="" id="NetAmount" tabindex="5"></td>
			</tr>
			<tr>
				<th width="100" align="left">Trans Date</th>
				<td><input type="text" name="trnDate" value="" id="trnDate" tabindex="3"></td>
				<th width="100" align="left">VAT Amount</th>
				<td><input type="text" name="trnAmnt2" value="" id="VATAmount" tabindex="6"></td>
			</tr>
			<tr>
				<th width="100" align="left">Trans Ref</th>
				<td><input type="text" name="trnRef" value="" tabindex="4" id="Ref"></td>
				<th width="100" align="left">Gross Total</th>
				<td><input type="text" name="trnTotal" value="" id="GrossTotal" tabindex="7"></td>
			</tr>
			<tr>
				<th width="100" align="left">Trans Active</th>
				<td id="Active">0</td>
				<td colspan="2" id="btnCell">
					<input type="button" id="New" value="Save" tabindex="8" style="float:right;" />
					<input type="button" id="Save" value="Save Changes" tabindex="8" style="float:right;display:none;" />
				</td>
			</tr>
		</table>
		<div id="transItems"></div>
		<div class="clear"></div>
	</div>
</cfoutput>

<script type="text/javascript">
	$(".nom").chosen({width: "200px"});
	$("#Group").chosen({width: "150px",disable_search_threshold: 10});
</script>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
