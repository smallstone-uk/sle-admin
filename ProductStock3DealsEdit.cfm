<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset load=pstock.LoadDeal(parm)>

<script type="text/javascript">
	$(document).ready(function() { 
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			minDate: new Date(2013, 1 - 1, 1),
		});
		$('#btnContinue').click(function(e) {
			AddDeal("#newDealForm");
			e.preventDefault();
		});
		LoadDealsList();
	});
</script>

<cfoutput>
	<h2>Edit Deal</h2>
	<form method="post" id="newDealForm">
		<input type="hidden" name="dealID" value="#load.ID#">
		<table width="300">
			<tr>
				<td width="50%" align="right">Record Title</td>
				<td align="left"><input type="text" name="dealRecordTitle" value="#load.RecordTitle#"></td>
			</tr>
			<tr>
				<td align="right">Display Title</td>
				<td align="left"><input type="text" name="dealTitle" value="#load.Title#"></td>
			</tr>
			<tr>
				<td align="right">Starts</td>
				<td align="left"><input type="text" name="dealStarts" value="#LSDateFormat(load.Starts,'yyyy-mm-dd')#" class="datepicker"></td>
			</tr>
			<tr>
				<td align="right">Ends</td>
				<td align="left"><input type="text" name="dealEnds" value="#LSDateFormat(load.Ends,'yyyy-mm-dd')#" class="datepicker"></td>
			</tr>
			<tr>
				<td align="right">Type</td>
				<td align="left">
					<select name="dealType">
						<option value="discount"<cfif load.Type is "discount"> selected="selected"</cfif>>Discount</option>
						<option value="quantity"<cfif load.Type is "quantity"> selected="selected"</cfif>>Quantity</option>
						<option value="selection"<cfif load.Type is "selection"> selected="selected"</cfif>>Selection</option>
					</select><br /><span style="font-size:10px;color:##666;">TODO - 'Type' might not be needed</span>
				</td>
			</tr>
			<tr>
				<td align="right">Amount</td>
				<td align="left">&pound;<input type="number" name="dealAmount" value="#load.Amount#"></td>
			</tr>
			<tr>
				<td align="right">Qty</td>
				<td align="left"><input type="number" name="dealQty" value="#load.Qty#"></td>
			</tr>
			<tr>
				<td align="right">Status</td>
				<td align="left">
					<select name="dealStatus">
						<option value="active"<cfif load.Status is "active"> selected="selected"</cfif>>Active</option>
						<option value="inactive"<cfif load.Status is "inactive"> selected="selected"</cfif>>Inactive</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2"><input type="button" id="btnContinue" value="Continue"></td>
			</tr>
		</table>
	</form>
</cfoutput>



