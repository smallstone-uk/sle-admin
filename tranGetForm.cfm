
<cfset callback=1>
<cfsetting showdebugoutput="no">

<cfobject component="code/accounts" name="accts">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.rowLimit=10>
<cfset acctData=accts.LoadAccount(parm)>
<cfset parm.account=acctData.account><cfdump var="#parm#" label="parm" expand="no">
<cfif StructKeyExists(acctData.account,"accID") gt 0>
	<cfoutput>
		<div style="padding:10px 0;"></div>
		<input type="hidden" name="accID" value="#parm.account.accID#">
		<table border="1" class="tableList" width="100%">
			<tr>
				<td width="100"></td>
				<td>
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
							<th width="100" align="left">Description</th>
							<td><input type="text" name="trnDesc" value="" id="trnDesc" size="50" maxlength="255" tabindex="8"></td>
							<th width="100" align="left">Active</th>
							<td id="Active"><input type="checkbox" name="trnActive" value="1" checked="checked" disabled="disabled" /></td>
						</tr>
						<tr>
							<td colspan="4" id="btnCell">
								<input type="button" id="btnSave" value="Save" tabindex="9" style="float:right;" />
							</td>
						</tr>
					</table>
				</td>
				<td width="100"></td>
			</tr>
		</table>
	</cfoutput>
<cfelse>
	<table border="1" class="tableList" width="100%">
		<tr>
			<td>No account found. Please select an account from the pop-up menu or enter an existing transaction ID or reference.</td>
		</tr>
	</table>
</cfif>