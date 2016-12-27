
<cfset callback=1>
<cfsetting showdebugoutput="no">

<cfobject component="code/accounts" name="accts">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.rowLimit=10>
<cfset acctData=accts.LoadAccount(parm)>
<cfset parm.accType=acctData.account.accType>
<cfif accountID gt 0>
	<cfset tranList=accts.LoadTransactionList(parm)>
</cfif>
<cfdump var="#acctData#" label="acctData" expand="no">
<cfoutput>
	<table border="1" width="540" class="tableList">
		<tr>
			<th>ID</th>
			<th align="right">Date</th>
			<th>Type</th>
			<th align="left">Ref</th>
			<th align="right">Net</th>
			<th align="right">VAT/Disc</th>
			<th align="right">Gross</th>
			<th>Allocated</th>
		</tr>
		<cfloop array="#tranList.transactions#" index="item">
			<tr>
				<td>#item.trnID#</td>
				<td align="right">#LSDateFormat(item.trnDate,"ddd dd-mmm-yyyy")#</td>
				<td align="center">#item.trnType#</td>
				<td>#item.trnRef#</td>
				<td class="amount">#DecimalFormat(item.trnAmnt1)#</td>
				<td class="amount">#DecimalFormat(item.trnAmnt2)#</td>
				<td class="amount">#DecimalFormat(item.trnAmnt1+item.trnAmnt2)#</td>
				<td align="center">#item.trnAlloc#</td>
			</tr>
		</cfloop>
		<tr>
			<td colspan="8">#tranList.rowCount# records.</td>
		</tr>
	</table>

		<table border="1" class="tableList" width="100%">
			<tr>
				<th width="100" align="left">Account Code</th>
				<td>#acctData.Account.accCode# <a href="salesTranList.cfm?account=#acctData.Account.accID#" target="_blank">Tran List</a></td>
				<th width="100" align="left">Account Name</th>
				<td>#acctData.Account.accName#</td>
				<th width="100" align="left">Account Type</th>
				<td>#acctData.Account.accType#</td>
				<th width="100" align="left">Account Group</th>
				<td>#acctData.Account.accGroup#</td>
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

</cfoutput>
