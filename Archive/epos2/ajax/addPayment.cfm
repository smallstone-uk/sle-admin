<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.form = form>
<cfset sign = (2 * int(session.epos_frame.mode eq "reg")) - 1>

<cfif session.epos_frame.result.changeDue lt 0>
	<cfset paymentValue = -val(session.epos_frame.result.changeDue)>
<cfelse>
	<cfset paymentValue = val(session.epos_frame.result.changeDue)>
</cfif>

<cfif epos.IsPayingSupplier()>
	<cfset paymentValue = -val(parm.form.value)>
</cfif>

<cfif val(parm.form.value) lte 0>
	<cfset parm.form.value = paymentValue>
</cfif>

<cfif StructKeyExists(session.epos_frame.basket.payment, parm.form.type)>
	<cfset paymentItem = StructFind(session.epos_frame.basket.payment, parm.form.type)>
	<cfif paymentItem.value neq 0>
		<cfset paymentItem.value += val(parm.form.value)>
	<cfelse>
		<cfset paymentItem.value = val(parm.form.value)>
	</cfif>
<cfelse>
	<cfif parm.form.value gt 0>
		<cfset StructInsert(session.epos_frame.basket.payment, parm.form.type, {
			title = UCase(parm.form.type),
			value = val(parm.form.value)
		})>
	<cfelse>
		<cfset StructInsert(session.epos_frame.basket.payment, parm.form.type, {
			title = UCase(parm.form.type),
			value = paymentValue
		})>
	</cfif>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>