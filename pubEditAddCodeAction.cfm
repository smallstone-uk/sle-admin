<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/publications" name="pubs">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form.barcode=form.newcode>
<cfset parm.form.TitleID=form.pubID>
<cfset add=pubs.AddPubBarcode(parm)>

<cfoutput>
{
	"status": "#add.status#",
	"msg": "#add.msg#"
}
</cfoutput>
