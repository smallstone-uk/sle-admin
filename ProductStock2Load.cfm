<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset check=prod.SendBarcode(parm)>
<cfset cats=prod.LoadProductCats(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function SendPORData() {
			var units=$('#pskPack').val();
			var cost=$('#pskPackPrice').val();
			var sell=$('#pskShelfPrice').val();
			var vat=$('#pskVatRate').val();
			UpdatePOR(units,cost,sell,vat);
		}
		$('#title').focus();
		$('#AddCat').click(function(event) {
			event.preventDefault();
		});
		$('#FoundProd').click(function() {
			var val=$('#prodList').val();
			var code=$('#barcode').val();
			GetProduct(val,"ID",code);
		});
		$('#AddStock').click(function() {
			SubmitFormData();
		});
		$('.UpdatePOR').on("change",function(e) {
			SendPORData();
		});
		$('.UpdatePOR').on("keyup",function(e) {
			SendPORData();
		});
		SendPORData();
	});
</script>

<cfoutput>
	<div style="clear:both;padding:10px 0;"></div>
	<cfif check.mode is 2>
		<h1>#check.data.title# #check.data.UnitSize#</h1>
		<input type="hidden" name="mode" value="#val(check.mode)#">
		<input type="hidden" name="prodID" value="#val(check.data.ID)#">
		<cfif StructKeyExists(parm.form,"ID")>
			<input type="hidden" name="barcode" id="barcode" value="#parm.form.code#">
		<cfelse>
			<input type="hidden" name="barcode" id="barcode" value="#parm.form.barcode#">
		</cfif>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th>Title</th>
				<th>Category</th>
				<th width="40">Pack</th>
				<th width="60">Size</th>
				<th width="40">Pack Price</th>
				<th width="40">Shelf Price</th>
				<th width="40">Vat Rate</th>
				<th width="40">POR</th>
				<th width="40">Profit</th>
			</tr>
			<tr>
				<td><input type="text" id="title" name="prodTitle" value="#check.data.title#" style="width:95%;"></td>
				<td id="catList" width="150">
					<select name="catID" class="type" style="text-align:left;">
						<option value="0"<cfif check.data.CatID is 0> selected="selected"</cfif> style="text-transform:capitalize;">Select...</option>
						<cfloop array="#cats#" index="i">
							<option value="#i.ID#"<cfif check.data.CatID is i.ID> selected="selected"</cfif> style="text-transform:capitalize;">#i.Title#</option>
						</cfloop>
					</select>
				</td>
				<td><input type="text" name="pskPack" id="pskPack" class="UpdatePOR" value="#check.data.PackQty#" style="width:60px;text-align:center;"></td>
				<td><input type="text" name="prodSize" value="#check.data.UnitSize#" style="width:80px;"></td>
				<td><input type="text" name="pskPackPrice" id="pskPackPrice" class="UpdatePOR" value="#check.data.PackPrice#" style="width:60px;text-align:right;"></td>
				<td><input type="text" name="pskShelfPrice" id="pskShelfPrice" class="UpdatePOR" id="ShelfPrice" value="#check.data.Price#" style="width:60px;text-align:right;"></td>
				<td>
					<select name="pskVatRate" id="pskVatRate" class="UpdatePOR">
						<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
						<cfloop list="#vatKeys#" delimiters="," index="key">
							<cfif key gt 0>
								<cfset vatItem=StructFind(application.site.vat,key)>
								<option value="#vatItem#"<cfif check.data.VatRate eq vatItem> selected="selected"</cfif>>#vatItem*100#%</option>
							</cfif>
						</cfloop>
					</select>
				</td>
				<td id="POR"></td>
				<td id="Profit"></td>
			</tr>
			<tr>
				<th colspan="9">
					<input type="button" id="AddStock" value="Update" style="float:right;padding:5px 20px;">
					<a href="##" id="AddCat" class="button" style="float:left;color:##fff;">Add Category</a>
				</th>
			</tr>
		</table>
	<cfelseif check.mode is 1>
		<h1>Unrecognized Barcode</h1>
		<cfset prods=prod.LoadProducts(parm)>
		<p>Check to see if you can find the product by typing the name of the product.</p>
		<select name="prodList" id="prodList" style="text-align:left;">
			<option value="">Select...</option>
			<cfloop array="#prods#" index="i">
				<option value="#i.ID#">#i.Title# #i.UnitSize#</option>
			</cfloop>
		</select>
		<input type="button" id="FoundProd" value="Ok" style="float: none;padding: 4px 10px;">
		<p>If you can't find the product in the list, enter the details below.</p>
		<input type="hidden" name="mode" value="1">
		<input type="hidden" name="prodID" value="0">
		<cfif StructKeyExists(parm.form,"ID")>
			<input type="hidden" name="barcode" id="barcode" value="#parm.form.code#">
		<cfelse>
			<input type="hidden" name="barcode" id="barcode" value="#parm.form.barcode#">
		</cfif>
		<table border="1" class="tableList" width="100%">
			<tr>
				<th>Title</th>
				<th>Category</th>
				<th width="40">Pack</th>
				<th width="60">Size</th>
				<th width="40">Pack Price</th>
				<th width="40">Shelf Price</th>
				<th width="40">Vat Rate</th>
				<th width="40">POR</th>
				<th width="40">Profit</th>
			</tr>
			<tr>
				<td><input type="text" id="title" name="prodTitle" value="" style="width:95%;"></td>
				<td id="catList" width="150">
					<select name="catID" class="type" style="text-align:left;">
						<option value="">Select...</option>
						<cfloop array="#cats#" index="i">
							<option value="#i.ID#">#i.Title#</option>
						</cfloop>
					</select>
				</td>
				<td><input type="text" name="pskPack" id="pskPack" class="UpdatePOR" value="" style="width:60px;text-align:center;"></td>
				<td><input type="text" name="prodSize" value="" style="width:80px;"></td>
				<td><input type="text" name="pskPackPrice" id="pskPackPrice" class="UpdatePOR" value="" style="width:60px;text-align:right;"></td>
				<td><input type="text" name="pskShelfPrice" id="pskShelfPrice" class="UpdatePOR" id="ShelfPrice" value="" style="width:60px;text-align:right;"></td>
				<td>
					<select name="pskVatRate" id="pskVatRate" class="UpdatePOR">
						<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
						<cfloop list="#vatKeys#" delimiters="," index="key">
							<cfif key gt 0>
								<cfset vatItem=StructFind(application.site.vat,key)>
								<option value="#vatItem#">#vatItem*100#%</option>
							</cfif>
						</cfloop>
					</select>
				</td>
				<td id="POR"></td>
				<td id="Profit"></td>
			</tr>
			<tr>
				<th colspan="9">
					<input type="button" id="AddStock" value="Add" style="float:right;padding:5px 20px;">
					<a href="##" id="AddCat" class="button" style="float:left;color:##fff;">Add Category</a>
				</th>
			</tr>
		</table>
	<cfelse>
		#check.error#
	</cfif>
</cfoutput>
<script type="text/javascript">
	$(".type").chosen({width: "150px"});
	$("#prodList").chosen({width: "300px"});
	$('#prodList').trigger('chosen:activate');
</script>

