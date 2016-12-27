<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>
<cfset check=cust.CheckPublication(parm)>

<cfoutput>
	<div class="clear" style="padding:5px 0;"></div>
	<p>Please enter the quantity wanted by the customer in the days available.</p>
	<table border="1" class="tableList">
		<tr>
			<th width="48">Mon</th>
			<th width="48">Tue</th>
			<th width="48">Wed</th>
			<th width="48">Thu</th>
			<th width="48">Fri</th>
			<th width="48">Sat</th>
			<th width="48">Sun</th>
		</tr>
		<tr>
			<td align="center"><input type="text" name="oiMon" style="text-align:center;" size="2"<cfif check.Mon is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
			<td align="center"><input type="text" name="oiTue" style="text-align:center;" size="2"<cfif check.Tue is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
			<td align="center"><input type="text" name="oiWed" style="text-align:center;" size="2"<cfif check.Wed is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
			<td align="center"><input type="text" name="oiThu" style="text-align:center;" size="2"<cfif check.Thu is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
			<td align="center"><input type="text" name="oiFri" style="text-align:center;" size="2"<cfif check.Fri is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
			<td align="center"><input type="text" name="oiSat" style="text-align:center;" size="2"<cfif check.Sat is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
			<td align="center"><input type="text" name="oiSun" style="text-align:center;" size="2"<cfif check.Sun is 0> value="0" disabled="disabled"<cfelse> value="1"</cfif> /></td>
		</tr>
		<tr>
			<th><cfif check.Mon neq 0>&pound;#check.Mon#</cfif></th>
			<th><cfif check.Tue neq 0>&pound;#check.Tue#</cfif></th>
			<th><cfif check.Wed neq 0>&pound;#check.Wed#</cfif></th>
			<th><cfif check.Thu neq 0>&pound;#check.Thu#</cfif></th>
			<th><cfif check.Fri neq 0>&pound;#check.Fri#</cfif></th>
			<th><cfif check.Sat neq 0>&pound;#check.Sat#</cfif></th>
			<th><cfif check.Sun neq 0>&pound;#check.Sun#</cfif></th>
		</tr>
	</table>
</cfoutput>
