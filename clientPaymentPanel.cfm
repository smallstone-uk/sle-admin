<!--- Client payment panel 09/06/2025 --->

<cfoutput>
	<div id="tabs">
		<ul>
			<li><a href="##Payment">Payment</a></li>
			<li><a href="##Credit">Credit</a></li>
		</ul>
		<div id="Payment">
			<form id="payForm">				
				<div class="form-col1">
					<table cellpadding="2" cellspacing="0">
						<tr>
							<td align="right" width="120">Reference</td>
							<td>
								<input type="text" class="inputfield" name="trnRef" id="trnRef" size="20" maxlength="20" />
								<input type="hidden" name="clientID" id="clientID" value="" size="6" />
								<input type="hidden" name="clientRef" id="clientRef1" value="" size="6" />
							</td>
						</tr>
						<tr>
							<td align="right">Date Received</td>
							<td>
								<input type="text" class="datecheck" name="trnDate" id="trnDate" size="20" onBlur="checkPayForm();" />
							</td>
						</tr>
						<tr>
							<td align="right" valign="top">Payment Method</td>
							<td>
								<select name="trnMethod" id="trnMethod" onChange="checkPayForm();">
									<option value="">Select...</option>
									<option value="cash" title="cash taken via shop till">Cash in Shop</option>
									<option value="card" title="chip & pin card transaction">Card in Shop</option>
									<option value="chqs" title="cheque taken via the shop">Cheque in Shop</option>
									<option disabled>-----------------</option>
									<!---<option value="coll" title="money collected by drivers">Cash Collected</option>--->
									<option value="chq" title="cheque collected or posted">Cheque</option>
									<option value="chqx" title="cheque returned from bank">Returned Cheque</option>
									<option disabled>-----------------</option>
									<option value="phone" title="card payment taken online">Card Online</option>
									<option value="ib" title="direct payment from customer">Internet Banking</option>
									<option value="acct" title="money held on account in till">Shop Credit Account</option>
									<option disabled>-----------------</option>
									<option value="dv" title="money off vouchers">Discount Voucher</option>
									<option value="cdv" title="don't know">Collected Voucher</option>
									<option disabled>-----------------</option>
									<!---<option value="cp" title="for cornwall council payments only">Council Payments</option>--->
									<option value="na" title="for journals only">Not Applicable</option>
									<!---<option value="qs">Paid via Quickstop</option>--->
								</select><br>
							</td>
						</tr>
						<tr>
							<td align="right">Description</td>
							<td>
								<input type="text" class="inputfield" name="trnDesc" id="trnDesc" size="30" maxlength="80" />
							</td>
						</tr>
					</table>
				</div>
				<div class="form-col2">
					<table cellpadding="2" cellspacing="0">
						<tr>
							<td align="right">Net Amount</td>
							<td>
								<input type="text" class="inputfield" name="trnAmnt1" id="trnAmnt1" size="20" maxlength="7" onBlur="checkPayForm();" />
							</td>
						</tr>
						<tr>
							<td align="right">Discount</td>
							<td>
								<input type="text" class="inputfield" name="trnAmnt2" id="trnAmnt2" size="20" maxlength="7" onBlur="checkPayForm();" />
							</td>
						</tr>
						<tr>
							<td align="right">Type</td>
							<td>
								<input type="radio" class="inputfield" name="trnType" id="trnTypepay" value="pay" checked="checked" /> Payment
								<input type="radio" class="inputfield" name="trnType" id="trnTypejnl" value="jnl" /> Journal
							</td>
						</tr>
					</table>
				</div>
				<div class="clear"></div>
				<div class="form-footer">
					<div id="feedback"></div>
					<input type="button" name="btnSavePayment" id="btnSavePayment" value="Save Payment" />
					<input type="button" name="btnCancel" id="btnCancel" value="Cancel" />
					<div class="clear"></div>
				</div>
			</form>
		</div>
		<div id="Credit">
			<form id="creditForm">
				<div class="form-col1">
					<table cellpadding="2" cellspacing="0">
						<tr>
							<td align="right" width="120">Reference</td>
							<td>
								<input type="text" class="inputfield" name="crnRef" id="crnRef" value="" size="20" maxlength="20" />
								<input type="hidden" name="clientID" id="clientID2" value="" size="6" />
								<input type="hidden" name="clientRef" id="clientRef2" value="" size="6" />
							</td>
						</tr>
						<tr>
							<td align="right">Date Credited</td>
							<td>
								<input type="text" class="datecheck" name="crnDate" id="crnDate" value="" size="20" onBlur="checkCreditForm();" />
							</td>
						</tr>
						<tr>
							<td align="right">Description</td>
							<td>
								<input type="text" class="inputfield" name="crnDesc" id="crnDesc" value="" size="20" />
							</td>
						</tr>
						<tr>
							<td align="right">&nbsp;</td>
							<td></td>
						</tr>
					</table>
				</div>
				<div class="form-col2">
					<table cellpadding="2" cellspacing="0">
						<tr>
							<td align="right">Net Amount</td>
							<td>
								<input type="text" class="inputfield" name="crnAmnt1" id="crnAmnt1" value="" size="20" maxlength="20" onBlur="checkCreditForm();" />
							</td>
						</tr>
						<tr>
							<td align="right">VAT/Discount</td>
							<td>
								<input type="text" class="inputfield" name="crnAmnt2" id="crnAmnt2" value="" size="20" maxlength="20" onBlur="checkCreditForm();" />
							</td>
						</tr>
					</table>
				</div>
				<div class="clear"></div>
				<div class="form-footer">
					<div id="feedback2"></div>
					<input type="button" name="btnSaveCredit" id="btnSaveCredit" value="Save Credit" />
					<input type="button" name="btnCancel" id="btnCancel2" value="Cancel" />
					<div class="clear"></div>
				</div>
			</form>
		</div>
	</div>
</cfoutput>