<!--- AJAX call - check client do not show debug data at all --->

<cftry>
	<cfset callback=1><!--- force exit of onrequestend.cfm --->
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	
	<cfobject component="code/accounts3" name="supp">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.form=form>
	<cfset parm.tranID=form.transID>

	<cfif NOT StructKeyExists(parm.form, "niID")>
		<cfset update=supp.AddListItem(parm)>
	<cfelse>
		<cfset update=supp.UpdateListItem(parm)>
	</cfif>
	<cfset load=supp.LoadSalesTransaction(parm)>

	<script type="text/javascript">
		$(document).ready(function() {
			$('#Mode').val(2);
		});
	</script>
	<cfoutput>
		<table border="1" class="tableList" width="100%">
					<tr>
						<th width="30">Code</th>
						<th width="150">Title</th>
						<th width="30">Amount</th>
					</tr>
			<cfloop array="#load.items#" index="item">
				<input type="hidden" name="niID" value="#item.niID#">
				<tr>
					<td>#item.nomCode#</td>
					<td>#item.nomTitle#</td>
					<td><input type="text" name="niAmount_#item.niID#" value="#DecimalFormat(item.niAmount)#" class="amount nomAmount" size="10"></td>
				</tr>
			</cfloop>
			<tr>
				<th></th>
				<th align="right">Total</th>
				<td align="right"><input type="hidden" name="total" id="check-total" value="#load.GrandTotal#"><strong>#DecimalFormat(load.GrandTotal)#</strong></td>
			</tr>
			<tr>
				<th></th>
				<th align="right">Difference</th>
				<td id="Check" align="right"></td>
			</tr>
		</table>
	</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

