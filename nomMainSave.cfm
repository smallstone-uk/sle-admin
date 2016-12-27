<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/accounts" name="noms">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset backup=noms.BackupEntry(parm)>
<cfif parm.form.mode is 1>
	<cfset save=noms.InsertNominalLedger(parm)>
	<cfset tranID=save.tranID>
	<cfoutput><cfif StructKeyExists(save,"msg")><span class="success">#save.msg#</span><cfelse><cfdump var="#save#" label="error" expand="no"></cfif></cfoutput>
	<cfdump var="#save#" label="save" expand="no">
<cfelse>
	<cfset update=noms.UpdateNominalLedger(parm)>
	<cfset tranID=update.tranID>
	<cfoutput><cfif StructKeyExists(update,"msg")><span class="success">#update.msg#</span><cfelse><cfdump var="#update#" label="error" expand="no"></cfif></cfoutput>
	<cfdump var="#update#" label="update" expand="no">
</cfif>

<script type="text/javascript">
	$(document).ready(function() {
		<cfoutput>$('##EditID').val("#tranID#");</cfoutput>
	});
</script>

