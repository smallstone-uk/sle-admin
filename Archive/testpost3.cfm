<!DOCTYPE html>
<html>
<head>
	<script type="text/javascript" src="http://kweb.shortlanesendstore.co.uk/common/scripts/jquery-1.7.1.min.js"></script>
	<script type="text/javascript">
        $(document).ready(function(){
			$("#searchForm").submit( function (event) {
				$.ajax({
					type: 'POST',
					url: 'testpost2.cfm',
					data : $(this).serialize(),
					beforeSend:function(){
						// this is where we append a loading image
						$('#ajax-panel').html('<div class="loading"><img src="/images/loading.gif" alt="Loading..." /></div>');
					},
					success:function(data){
						// successful request; do something with the data
						$('#ajax-panel').empty();
						$('#ajax-panel').html(data);
					},
					error:function(){
						// failed request; give feedback to user
						$('#ajax-panel').html('<p class="error"><strong>Oops!</strong> Try that again in a few moments.</p>');
					}
				});
				event.preventDefault();
			});
		});
	</script>
<script src="jquery-ui-1.10.3.custom.min.js"></script>
</head>

<body>
<cfoutput>
	<form action="/" id="searchForm">
		<table>
			<tr>
				<td align="right">Client Reference</td>
				<td>
					<input type="text" class="inputfield" name="clientRef" id="clientRef" value="" size="20" maxlength="20" onblur="CheckClient()" />
				</td>
			</tr>
		</table>	
		<div id="clientResult"></div>
		<div id="paymentPanel">
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
					<td align="right"></td>
					<td>
						<input type="submit" name="btnSavePayment" value="Save Payment" />
						<input type="submit" name="btnSaveAlloc" value="Save Allocation" />
					</td>
				</tr>		
			</table>
		</div>
	</form>
</cfoutput>
<!-- the result of the search will be rendered inside this div -->
<div id="ajax-panel"></div>
</body>
</html>