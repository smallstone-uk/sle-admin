<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset assign=pstock.AssignProductToDeal(parm)>
<cfset parm.form.dealID=parm.form.deal>
<cfset load=pstock.LoadDeal(parm)>

<cfoutput>
	<h1>#assign.title#</h1>
	<img src="images/tick.png" width="128" />
	<p>#assign.msg#</p>
	<div class="clear" style="padding:10px 0;"></div>
	<div style="width:100%;height:300px;overflow-y:scroll;">
		<table width="100%" class="tableList" border="1">
			<tr>
				<th align="left">Products</th>
			</tr>
			<cfloop array="#load.items#" index="i">
				<tr>
					<td align="left">#i.Title# #i.size#</td>
				</tr>
			</cfloop>
		</table>
	</div>
</cfoutput>