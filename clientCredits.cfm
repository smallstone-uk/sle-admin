<!DOCTYPE html>
<html>
<head>
<title>Customer Credits</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
<script type="text/javascript" src="scripts/checkDates.js"></script>
<script type="text/javascript">
	var toggle=false;
	function CheckClient() {
		$('#searchMsg').fadeOut();
		$('#clientResult').fadeIn();
		var client=document.getElementById('clientRef').value;
		var allTrans=document.getElementById('allTrans').checked;
		$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading transactions...").fadeIn();
		$('#clientResult').load('checkClient.cfm?client='+client+'&allTrans='+allTrans, function (response, status, xhr) {
			$('#loadingDiv').html("").fadeOut();
			if (response.indexOf('Reference') == -1) {
				var msg=$.trim($("#clientResult").text());
			//	alert(msg);
				$('#clientRef').focus();
				$('#pay').fadeOut();
			} else {
				$('#trnRef').focus();
				$('#pay').fadeIn();
			}
		});
		$('#cltDetailsLink').attr("href", "clientDetails.cfm?row=0&ref="+client).fadeIn();
	}
	function NextClient(direction) {
		$('#pay').fadeOut();
		$('#clientResult').fadeOut();
		var client=document.getElementById('clientRef').value;
		var allTrans=document.getElementById('allTrans').checked;
		$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading transactions...").fadeIn();
		$('#clientResult').load('checkClient.cfm?client='+client+'&allTrans='+allTrans+'&'+direction+'=true', function (response, status, xhr) {
			var key=$('#clientKey').html();
			document.getElementById('clientRef').value=key;
			$('#loadingDiv').html("").fadeOut();
			$('#trnRef').focus();
			$('#pay').fadeIn();
			$('#clientResult').fadeIn();
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
					if ($('#trnMethod').val() == "") {
						alert("Please select the payment method");
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
		$('#trnDate').blur(function(event) {
			var dateChecked=checkDate($('#trnDate').val(),false);
			if (!dateChecked) {
				alert('Date is out of range')
				setTimeout(function() {
					$('#trnDate').focus();
				}, 0);
			} else {
				$('#trnDate').val(dateChecked)			
			}
		});
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
							$('#loadingDiv').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
						},
						success:function(data){
							// successful request; do something with the data
							//$('#payResult').empty();
							$('#loadingDiv').html("").fadeOut();
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
<cfif StructKeyExists(URL,"rec")>
<script type="text/javascript">
	$(document).ready(function() {
		$('#clientRef').focus();
		CheckClient();
	});
</script>
</cfif>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form name="payForm" id="payForm" method="post"><!--- onSubmit="return checkForm(this)"--->
						<input type="hidden" name="trnType" id="trnType" value="crn" /> 
						<div class="form-header">
							Customer Credits
							<span>
								<input type="button" onClick="NextClient('next')" value="Next" />
								<input type="button" onClick="NextClient('prev')" value="Previous" />
							</span>
						</div>
						<input type="hidden" size="10" name="btnClicked" id="btnClicked" />
						<div class="form-bar">
							<a href="" id="cltDetailsLink" style="float:right;display:none;" class="button" target="_blank">Client Details</a>
							<div id="loadingDiv"></div>
							<table cellpadding="0" cellspacing="0">
								<tr>
									<td width="120">Client Reference</td>
									<td>
										<input type="text" class="inputfield" name="clientRef" id="clientRef" value="<cfif StructKeyExists(URL,"rec")>#val(url.rec)#</cfif>" size="40" maxlength="20" onBlur="CheckClient()" />
										<label style="padding:0 0 0 10px;"><input type="checkbox" name="allTrans" id="allTrans" onClick="CheckClient()" />&nbsp;All transactions.</label>
									</td>
								</tr>
							</table>
						</div>
						<div id="searchMsg" style="display:block;">Enter a client reference number</div>
						<div class="form-box" id="pay" style="display:none;">
							<div class="form-header small">Credit</div>
							<div class="form-col1">
								<table cellpadding="2" cellspacing="0">
									<tr>
										<td align="right" width="100">Reference</td>
										<td>
											<input type="text" class="inputfield" name="trnRef" id="trnRef" value="" size="20" maxlength="20" />
										</td>
									</tr>
									<tr>
										<td align="right">Date Entered</td>
										<td>
											<input type="text" class="inputfield" name="trnDate" id="trnDate" value="" size="20" />
										</td>
									</tr>
									<tr>
										<td align="right">Description</td>
										<td><input type="text" class="inputfield" name="trnDesc" id="trnDesc" value="" size="60" maxlength="60" /></td>
									</tr>
								</table>
							</div>
							<div class="form-col2">
								<table cellpadding="2" cellspacing="0">
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
										<td align="right">Total</td>
										<td>
											<input type="text" class="inputfield" name="grossTotal" id="grossTotal" value="" size="20" maxlength="20" />
										</td>
									</tr>
								</table>
							</div>
							<div class="clear"></div>
							<div class="form-footer">
								<input type="submit" name="btnSaveAlloc" value="Save Allocation" />
								<input type="submit" name="btnSaveCredit" value="Save Credit Note" />
								<button id="statement">View Statement</button>
								<div class="clear"></div>
							</div>
						</div>
						<div id="clientResult" style="display:none;"></div>
						<div id="payResult"></div>
					</form>
				</div>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>
