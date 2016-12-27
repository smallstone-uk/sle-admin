
<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=epos.LoadBasketTotal(parm)>

<cfoutput>
	<span class="total">
		<cfif load.total lt 0>
			<span class="totaltext">Change Due</span>
			<span class="totalamount">&pound;#DecimalFormat(load.total*-1)#</span>
		<cfelse>
			<span class="totaltext">Sub Total</span>
			<span class="totalamount">&pound;#DecimalFormat(load.total)#</span>
		</cfif>
	</span>
</cfoutput>