
<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.clerkID=session.user.ID>
<cfset parm.form=form>
<cfset set=epos.AddPaymentToBasket(parm)>
<cfoutput>
@changedue: #set.changedue*-1#
@error1: <cfif StructKeyExists(set,"error1")>#set.error1#<cfelse>false</cfif>
</cfoutput>
