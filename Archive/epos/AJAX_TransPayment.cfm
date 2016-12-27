
<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.clerkID=session.user.ID>
<cfset parm.index=RandRange(1024,1220120,'SHA1PRNG')>
<cfset parm.form=form>
<cfset set=epos.AddPaymentToBasket(parm)>
<cfoutput>
@transID: <cfif StructKeyExists(set,"transID")>#val(set.transID)#<cfelse>0</cfif>
@changedue: <cfif StructKeyExists(set,"changedue")>#set.changedue*-1#<cfelse>0</cfif>
@cashonly: <cfif StructKeyExists(set,"cashonly")>#set.cashonly#<cfelse>0</cfif>
@error1: <cfif StructKeyExists(set,"error1")>#set.error1#<cfelse>false</cfif>
</cfoutput>
