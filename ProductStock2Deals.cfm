<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfif StructKeyExists(parm.form,"selectitem")>
	<cfset prodlist=prod.LoadProductList(parm)>
</cfif>

<script type="text/javascript">
	$(document).ready(function() {
		$('#btnAddDeal').click(function(e) {
			AddDeal("#newDealForm");
			e.preventDefault();
		});
		$('#btnAssign').click(function(e) {
			AssignDeal("#dealsForm");
			e.preventDefault();
		});
		LoadDeals();
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			minDate: new Date(2013, 1 - 1, 1),
		});
	});
</script>

<cfoutput>
	<h1 style="">Deal Manager</h1>
	<div id="NewDeal" style="float:left;width:300px;margin:0 10px 0 0;padding:10px;border:1px solid ##ccc;background:##eee;border-radius:3px;">
		<h2>New Deal</h2>
		<form method="post" id="newDealForm">
			<table width="300">
				<tr>
					<td width="80">Internal Title</td>
					<td><input type="text" name="dealRecordTitle" value=""></td>
				</tr>
				<tr>
					<td width="80">Display Title</td>
					<td><input type="text" name="dealTitle" value=""></td>
				</tr>
				<tr>
					<td width="80">Starts</td>
					<td><input type="text" name="dealStarts" value="" class="datepicker"></td>
				</tr>
				<tr>
					<td width="80">Ends</td>
					<td><input type="text" name="dealEnds" value="" class="datepicker"></td>
				</tr>
				<tr>
					<td>Type</td>
					<td>
						<select name="dealType">
							<option value="discount">Discount</option>
							<option value="quantity">Quantity</option>
							<option value="selection">Selection</option>
						</select><br /><span style="font-size:10px;color:##666;">TODO - work out different types of deal or 'Type' might not be needed</span>
					</td>
				</tr>
				<tr>
					<td>Amount</td>
					<td>&pound;<input type="number" name="dealAmount" value=""></td>
				</tr>
				<tr>
					<td>Qty</td>
					<td><input type="number" name="dealQty" value=""></td>
				</tr>
				<tr>
					<td>Status</td>
					<td>
						<select name="dealStatus">
							<option value="active">Active</option>
							<option value="inactive">Inactive</option>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan="2"><input type="button" id="btnAddDeal" value="Continue"></td>
				</tr>
			</table>
		</form>
	</div>
	<div style="display:none;">
		<form method="post" id="dealsForm">
			<div id="dealList" style="float:left;width:300px;margin:0 10px 0 0;">
			</div>
			<div style="clear:both;"></div>
			<div style="margin:10px 0 0 0;">
				<h2>Selected Products</h2>
				<cfif StructKeyExists(parm.form,"selectitem")>
					<table border="1" class="tableList" width="100%">
						<tr>
							<th width="10"></th>
							<th>Title</th>
						</tr>
						<cfif ArrayLen(prodlist)>
							<cfloop array="#prodlist#" index="i">
								<tr>
									<td><input type="checkbox" name="selectprod" value="#i.ID#"></td>
									<td>#i.Title#</td>
								</tr>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan="2">No products found</td>
							</tr>
						</cfif>
					</table>
				<cfelse>
					Select product to assign to deals
				</cfif>
			</div>
			<input type="button" id="btnAssign" value="Assign">
		</form>
	</div>
	<div style="clear:both;"></div>
</cfoutput>


