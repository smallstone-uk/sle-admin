
<!--- 08/06/2025 Process news customer data --->

<cfobject component="code/accounts2" name="acc">
<cfset parm = {}>
<cfset parm.datasource1 = application.site.datasource1>
<cfset parm.form = form>
<cfset customer = acc.LoadClient(parm)>

<cfoutput>
	<cfif StructKeyExists(customer,"msg")>
		#customer.msg#
	<cfelse>
		
		<table id="clientPanel" class="tableList">
			<tr>
				<th width="120">Reference</th><td width="120">#customer.QClient.cltRef#</td>
				<td width="120">(ID: #customer.QClient.cltID#)
					<input name="cltID" id="cltID" value="#customer.QClient.cltID#" type="hidden" size="6" />
					<input name="cltRef" id="cltRef" value="#customer.QClient.cltRef#" type="hidden" size="6" />
				</td>
				<th width="120">Account Type</th><td colspan="2">#customer.QClient.cltAccountType#</td>
			</tr>
			<tr>
				<th>Name</th><td colspan="2">#customer.QClient.cltTitle# #customer.QClient.cltInitial# #customer.QClient.cltName#</td>
				<th>Invoice Delivery</th><td>#customer.QClient.cltInvDeliver#</td>
			</tr>
			<tr>
				<th>Business</th><td colspan="2">#customer.QClient.cltCompanyName#</td>
				<th>Payment Type</th><td>#customer.QClient.cltPaymentType#</td>
			</tr>
			<tr>
				<th>Address</th><td colspan="2">#customer.QClient.cltAddr1#</td>
				<th>Pay Type</th><td>#customer.QClient.cltPayType#</td>
			</tr>
			<tr>
				<th>:</th><td colspan="2">#customer.QClient.cltAddr2#</td>
				<th>Method</th><td>#customer.QClient.cltPayMethod# &nbsp; AllocID: #customer.QClient.cltAllocID#</td>
			</tr>
			<tr>
				<th>Email</th><td colspan="2">#customer.QClient.cltEmail#</td>
				<th>Entered</th><td>#DateFormat(customer.QClient.cltEntered,"dd-mmm-yyyy")#</td>
			</tr>
		</table>
	</cfif>
</cfoutput>
