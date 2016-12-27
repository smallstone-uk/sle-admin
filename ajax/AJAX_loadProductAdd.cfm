<script src="../scripts/jquery-1.11.1.min.js" type="text/javascript"></script>
<script src="../scripts/jquery-ui-1.10.3.custom.min.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() {
		$('#btnSubmit').click(function(e) {
			$('span.err').remove();
			var sendIt = true;
			if ($('#prodRef').val() == "")	{
				$('#prodRef').after('<span class="err">Please enter the reference.</span>');
				sendIt = false;
			} 
			if ($('#prodRecordTitle').val() == "") {
				$('#prodRecordTitle').after('<span class="err">Please enter the product title.</span>');
				sendIt = false;
			} 
			if ($('#prodUnitSize').val() == "") {
				$('#prodUnitSize').after('<span class="err">Please enter the product size.</span>');
				sendIt = false;
			} 
			if ($('#prodPackQty').val() == "") {
				$('#prodPackQty').after('<span class="err">Please enter the number of items in an outer pack.</span>');
				sendIt = false;
			} 
			if ($('#siQtyPacks').val() == "") {
				$('#siQtyPacks').after('<span class="err">Please enter the number of outer packs.</span>');
				sendIt = false;
			} 
			if ($('#prodPackPrice').val() == "") {
				$('#prodPackPrice').after('<span class="err">Please enter the WSP of an outer pack.</span>');
				sendIt = false;
			} 
			if ($('#prodRRP').val() == "") {
				$('#prodRRP').after('<span class="err">Please enter the Retail Price of the item.</span>');
				sendIt = false;
			} 
			if ($('#prodOurPrice').val() == "") {
				$('#prodOurPrice').after('<span class="err">Please enter Our Price of the item.</span>');
				sendIt = false;
			} 
			if ($('#soDate').val() == "") {
				$('#soDate').after('<span class="err">Please enter date ordered.</span>');
				sendIt = false;
			} 
			if ($('#prodVATCode').val() == "0") {
				$('#prodVATCode').after('<span class="err">Please select the relevant VAT code.</span>');
				sendIt = false;
			} 
			if (sendIt) {
				$('#result').html(AddProduct('#ProductForm','result'));
			}
			e.preventDefault();			
		})
		$('.qtys').blur(function(e) {
			var packqty = parseInt($('#prodPackQty').val() || 0);
			var qtypacks = parseInt($('#siQtyPacks').val() || 0);
			$('#siQtyItems').val(packqty * qtypacks);
		})
		$('#btnAddStock').click(function(e) {
			$('#result').html(AddStock('#StockForm','result'));
			e.preventDefault();			
		})
		$('#prodRef').blur(function(e) {
			ref = $(this).val();
			if (ref.length == 0) {
				$('#prodRef_msg').html("Please enter a reference");
			} else {
				$('#prodRef_msg').html("");
			}
		});
		$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2012, 1 - 1, 1)});
	});
</script>

<cftry>
	<cfparam name="barcode" default="">
	<cfobject component="code/ProductStock5" name="pstock">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset suppliers=pstock.LoadSuppliers(parm)>
	<cfoutput>
		<div id="entryForm">
			<h1>Add Product</h1>
			<form name="ProductForm" id="ProductForm" method="post" enctype="multipart/form-data">
				<input type="hidden" name="barcode" value="#barcode#" />	<!--- was form.barcode --->
				<table border="1" class="tableList">
					<tr>
						<td width="120">Supplier</td>
						<td width="450">
							<select name="accID">
								<option value="0">select...</option>
								<cfloop query="suppliers">
									<option value="#accID#"<cfif currentrow is 3> selected="selected"</cfif>>#accName#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr><td>Reference</td><td><input type="text" name="prodRef" id="prodRef" size="10" value="" /></td></tr>
					<tr><td>Description</td><td><input type="text" name="prodRecordTitle" id="prodRecordTitle" size="30" value="" /></td></tr>
					<tr><td>Unit Size</td><td><input type="text" name="prodUnitSize" id="prodUnitSize" size="10" value="" /></td></tr>
					<tr><td>Units per Pack</td><td><input type="text" name="prodPackQty" id="prodPackQty" class="qtys" size="10" value="" /></td></tr>
					<tr><td>No. Outer Packs</td><td><input type="text" name="siQtyPacks" id="siQtyPacks" class="qtys" size="10" value="" /></td></tr>
					<tr><td>Items in Stock</td><td><input type="text" name="siQtyItems" id="siQtyItems" class="qtys" size="10" value="" /> (Units * packs)</td></tr>
					<tr><td>Pack Price</td><td><input type="text" name="prodPackPrice" id="prodPackPrice" size="10" value="" /></td></tr>
					<tr><td>RRP</td><td><input type="text" name="prodRRP" id="prodRRP" size="10" value="" /></td></tr>
					<tr><td>Our Price</td><td><input type="text" name="prodOurPrice" id="prodOurPrice" size="10" value="" /></td></tr>
					<tr><td>Price Marked</td><td><input type="checkbox" name="prodPriceMarked" value="" /></td></tr>
					<tr><td>Purchase Date</td><td><input type="text" name="soDate" id="soDate" size="10" class="datepicker" value="" /></td></tr>
					<tr><td>Expiry Date</td><td><input type="text" name="siExpires" size="10" class="datepicker" value="" /> for 'best before end' select last day of the month</td></tr>
					<tr><td>VAT Rate</td><td>
						<select name="prodVATCode" id="prodVATCode">
							<option value="0">select...</option>
							<option value="1">0.00%</option>
							<option value="2">20.00%</option>
							<option value="3">5.00%</option>
						</select>
					</td></tr>
					<tr><td colspan="2"><input type="submit" name="btnSubmit" id="btnSubmit" value="Add Product" /></td></tr>
				</table>
			</form>
		</div>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

