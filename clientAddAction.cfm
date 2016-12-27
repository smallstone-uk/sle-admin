<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset add=cust.AddClient(parm)>

<cfoutput>
	<cfif StructKeyExists(add,"msg")>
		#add.msg#<br>
		<a href="clientDetails.cfm?row=0&ref=#add.Ref#" style="margin:5px 0 0 0;">View Customer Details</a>
	<cfelse>
		#add.error#
		<script type="text/javascript">
			$('##saveResults').addClass("error");
		</script>
	</cfif>
</cfoutput>