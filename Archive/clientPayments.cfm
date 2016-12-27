<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Customer Payments</title>
	<link rel="stylesheet" type="text/css" href="css/main.css"/>
	<script type="text/javascript" src="http://kweb.kcc-databases.co.uk/common/scripts/jquery-1.7.1.min.js"></script>
	<script type="text/javascript" src="scripts/checkDates.js"></script>
	<script type="text/javascript">
		var toggle=true;
		function CheckClient() {
			var client=document.getElementById('clientRef').value;
			var allTrans=document.getElementById('allTrans').checked;
			$('#clientResult').html("loading transactions...");
			$('#clientResult').load('checkClient.cfm?client='+client+'&allTrans='+allTrans, function (response, status, xhr) {
				if (response.indexOf('Reference') == -1) {
					var msg=$.trim($("#clientResult").text());
				//	alert(msg);
					$('#clientRef').focus();
				} else {
					$('#trnRef').focus();
				}
			});
		}
		function NextClient() {
			var client=document.getElementById('clientRef').value;
			var allTrans=document.getElementById('allTrans').checked;
			$('#clientResult').html("loading transactions...");
			$('#clientResult').load('checkClient.cfm?client='+client+'&allTrans='+allTrans+'&next='+true, function (response, status, xhr) {
				if (response.indexOf('Reference') == -1) {
					var msg=$.trim($("#clientResult").text());
				//	alert(msg);
					$('#clientRef').focus();
				} else {
					$('#clientRef').val()=$('#clientKey').val();
					$('#trnRef').focus();
				}
			});
		}
		function checkTotal(formname) {
			var payTotal=0;
			var payAmnt=0;
			var maxLines=document.getElementById('tranCount').value;
			for (var c=1;c<=maxLines;c++) {
				if (eval("document.forms."+formname+".tick"+c+".checked")) {
					payAmnt=(eval("document.forms."+formname+".amnt"+c+".value"));
					payAmnt=Math.round(payAmnt*100); // force as clean integers or summation will float
					payTotal=payTotal+payAmnt;
				}
			}
			payTotal=payTotal/100; // convert back to decimal
			document.forms[formname].Total.value=payTotal.toFixed(2); 
		}
		function getSelectedButton(buttonGroup)	{
			for (var i=0; i<buttonGroup.length; i++)	{
				if (buttonGroup[i].checked)	{
					return i;
				}
			}
			return 0;
		}
		function checkall(formname,thestate)	{
			var maxLines=document.getElementById('tranCount').value;
			for (var c=1;c<=maxLines;c++)	{
				document.getElementById("tick"+c).checked=thestate;
			}
			toggle=!toggle;	
			checkTotal(formname);
		}
		function checkForm(form)	{
		//	if (!checkField(form.payAmnt1,"Amount received")) {return false;}
			if (!checkDateFormat(form.trnDate.value))	{
				alert("Transaction Date is incorrectly formatted");
				return false;
			}
			if (form.clientRef.length < 1) {
				alert("Please select a client first");
				form.clientRef.focus();
				return false;
			}
			if (document.getElementById('Total')) {
				var bType=getSelectedButton(form.trnType);
				if (form.trnType[bType].value == "pay")	{
					if (document.getElementById('btnClicked').value == "btnSavePayment") {
						if (Number(form.trnAmnt1.value) > 99999)	{
							alert("Transaction Amount entered is too high");
							return false;	
						}
						if (Number(form.trnAmnt2.value) > 99999)	{
							alert("Settlement Discount entered is too high");
							return false;	
						}
						if (Number(form.trnAmnt1.value)+Number(form.trnAmnt2.value) == 0) {
							alert("Please enter an amount in either the Net Amount or Discount field.");
							return false;		
						}
					}
					if ((Number(form.trnAmnt1.value)+Number(form.trnAmnt2.value) != Number(form.Total.value)) && document.getElementById("Total").value != 0)	{
						alert("Net Amount does not equal the allocated balance.");
						return false;
					}
				}
			} else {
				alert("please select a client first");
				form.clientRef.focus();
				return false;
			}
			return true
		}
		$(document).ready(function() {
			$('#statement').click(function () {
				var allTrans=document.getElementById('allTrans').checked;
				var client=document.getElementById('clientRef').value;
				window.open("checkClient.cfm?client="+client+'&allTrans='+allTrans+'&print=true', '_blank');
				return false;
			});
			$(":submit").click(function () { $("#btnClicked").val(this.name);});
			$("#payForm").submit( function (event) {
			//	if (document.getElementById('btnClicked').value == "btnSavePayment") {
					if (checkForm(this)) {
						$.ajax({
							type: 'POST',
							url: 'clientPaymentPost.cfm',
							data : $(this).serialize(),
							beforeSend:function(){
								// this is where we append a loading image
								$('#payResult').html('<div class="loading"><img src="/images/loading.gif" width="100" alt="Loading..." /></div>');
							},
							success:function(data){
								// successful request; do something with the data
								//$('#payResult').empty();
								$('#payResult').html(data);
								CheckClient();
								var client=document.getElementById('clientRef').value;
								$('#payForm')[0].reset();
								document.getElementById('clientRef').value=client;
								document.getElementById('clientRef').focus();
							},
							error:function(){
								// failed request; give feedback to user
								$('#payResult').html('<p class="error"><strong>Oops!</strong> Try that again in a few moments.</p>');
							}
						});
					}
			//	}
				event.preventDefault();
			})
		});
	</script>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>


<cfoutput>
<body>
	<p><a href="index.cfm">Home</a></p>
	<form name="payForm" id="payForm" method="post"><!--- onSubmit="return checkForm(this)"--->
		<input type="text" size="10" name="btnClicked" id="btnClicked" />
		<table width="600">
			<tr>
				<td align="right">Client Reference</td>
				<td>
					<input type="text" class="inputfield" name="clientRef" id="clientRef" value="" size="20" maxlength="20" onblur="CheckClient()" />
					&nbsp; &nbsp; <input type="checkbox" name="allTrans" id="allTrans" onclick="CheckClient()" />All transactions.
				</td>
				<td>
					<input type="button" onclick="CheckClient('prev')" value="Previous" />
					<input type="button" onclick="NextClient()" value="Next" />
				</td>
			</tr>
			<tr>
				<td colspan="3">
					<div id="clientResult"></div>
					<div id="payResult"></div>
				</td>
			</tr>
			<tr>
				<td colspan="3" align="center">
					<table>
						<tr>
							<td align="right">Pay Reference</td>
							<td>
								<input type="text" class="inputfield" name="trnRef" id="trnRef" value="" size="20" maxlength="20" />
							</td>
						</tr>
						<tr>
							<td align="right">Date Received</td>
							<td>
								<input type="text" class="inputfield" name="trnDate" id="trnDate" value="#DateFormat(Now(),"dd/mm/yyyy")#" size="20" maxlength="20" />
							</td>
						</tr>
						<tr>
							<td align="right">Method</td>
							<td>
								<select name="trnMethod">
									<option value="">Select...</option>
									<option value="cash">Cash</option>
									<option value="chq">Cheque</option>
									<option value="card">Card Payment</option>
									<option value="ib">Internet Banking</option>
									<option value="na">Not Applicable</option>
								</select>
							</td>
						</tr>
						<tr>
							<td align="right">Net Amount</td>
							<td>
								<input type="text" class="inputfield" name="trnAmnt1" id="trnAmnt1" value="" size="20" maxlength="20" />
							</td>
						</tr>
						<tr>
							<td align="right">Discount</td>
							<td>
								<input type="text" class="inputfield" name="trnAmnt2" id="trnAmnt2" value="" size="20" maxlength="20" />
							</td>
						</tr>
						<tr>
							<td align="right">Type</td>
							<td>
								<input type="radio" class="inputfield" name="trnType" id="trnType" value="pay" checked="checked" /> Payment
								<input type="radio" class="inputfield" name="trnType" id="trnType" value="jnl" /> Journal
							</td>
						</tr>
						<tr>
							<td align="right"><button id="statement">View Statement</button></td>
							<td>
								<input type="submit" name="btnSavePayment" value="Save Payment" />
								<input type="submit" name="btnSaveAlloc" value="Save Allocation" />
							</td>
						</tr>		
					</table>
				</td>
			</tr>
		</table>
	</form>
</body>
</cfoutput>
</html>
