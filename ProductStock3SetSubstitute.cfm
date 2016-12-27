<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset set=pstock.SetSubstitute(parm)>

<h2>Success</h2>
<p>This product has been booked in.</p>
<img src="images/tick.png" width="128" />

