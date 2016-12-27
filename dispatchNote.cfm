<!--- 24/02/2014 - This is for Treliske, to help them manage stock --->
<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<link href="css/main3.css" rel="stylesheet" type="text/css">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.Date=LSDateFormat("2014-02-19","yyyy-mm-dd")><!--- Round Date --->
<cfset parm.clientID=6391><!--- TODO - Make variable maybe? --->
<cfset Load=rnd.LoadDispatchNote(parm)>

<cfoutput>
	<table border="1" class="tableList">
		<tr>
			<th>Date</th>
			<td colspan="2">#LSDateFormat(DateAdd("d",1,parm.Date),"dd/mm/yyyy")#</td>
			<th colspan="5">Stock Management</th>
		</tr>
		<tr>
			<th width="200" align="left">Publication</th>
			<th width="60" align="right">Price</th>
			<th width="50" align="center">Qty<br>Supplied</th>
			<th width="80">&nbsp;</th>
			<th width="80">&nbsp;</th>
			<th width="50">Qty<br>Returned</th>
			<th width="50">Qty<br>Wasted</th>
			<th width="50">Qty<br>Sold</th>
		</tr>
		<cfset group="">
		<cfloop array="#Load.list#" index="item">
			<cfset i=StructFind(load.group,item)>
			<cfif i.group neq group>
				<cfset group=i.group>
				<tr>
					<td align="left" colspan="8"><strong>#i.group#</strong></td>
				</tr>
			</cfif>
			<tr>
				<td align="left">#i.Title#</td>
				<td align="right">&pound;#DecimalFormat(i.Price)#</td>
				<td align="center">#i.Qty#</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td<cfif i.Group is "News" AND i.Type neq "Weekly"> style="background:##ddd;"</cfif>>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
			</tr>
		</cfloop>
	</table>
</cfoutput>


