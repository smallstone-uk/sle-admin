<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.rec.cltID=form.cltID>
<cfset parm.rec.cltRef=form.cltRef>
<cfset parm.orderID=form.orderRef>
<cfset parm.datasource=application.site.datasource1>
<cfset custOrder=cust.LoadOrderPubs(parm)>

<!---<cfdump var="#parm#" label="parm" expand="no">--->
<!---<cfdump var="#custOrder#" label="custOrder" expand="no">--->

<cfoutput>
	<cfif ArrayLen(custOrder.order.list)>
		<cfloop array="#custOrder.order.list#" index="order">
			<table border="1" width="100%" class="tableList">
				<tr>
					<th width="5"><input type="checkbox" name="selectAllOrderPub" value="1" checked="checked" /></th>
					<th colspan="7" align="left">Publication</th>
				</tr>
				<cfloop array="#order.items#" index="item">
					<tr>
						<td width="5"><input type="checkbox" name="OrderPub" value="#item.ID#" checked="checked" /></td>
						<td colspan="7">#item.title#</td>
					</tr>
				</cfloop>
				<tr>
					<td></td>
					<th>Stop Date</th>
					<td><input type="text" class="inputfield" name="hoStop" id="hoStop" value="#DateFormat(Now(),"dd/mm/yyyy")#" 
						size="20" maxlength="20" placeholder="DD/MM/YYYY" /></td>
					<th>Start Date</th>
					<td><input type="text" class="inputfield" name="hoStart" id="hoStart" value="" size="20" maxlength="20" placeholder="DD/MM/YYYY" /></td>
					<th>Action</th>
					<td width="150">
						<select name="OrderAction" class="nosearch100">
							<option value="cancel">Cancel</option>
							<option value="hold">Hold</option>
						</select>
					</td>
				</tr>
				<tr>
					<th colspan="7"><input type="submit" name="btnAddHoliday" value="Add" /></th>
				</tr>
			</table>
		</cfloop>
		<div class="clear" style="padding:5px 0;"></div>
	<cfelse>
		<p>No publications found.</p>
	</cfif>
</cfoutput>
<script type="text/javascript">
	$(".nosearch100").chosen({width: "100%",disable_search_threshold: 10});
</script>
