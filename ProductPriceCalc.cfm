

<script type="text/javascript">
	$(document).ready(function() {
		function Calculate() {
			var packqty=Number($('#packqty').val(),10);
			var packprice=Number($('#packprice').val(),10);
			var unitprice=Number($('#unitprice').val(),10);
			var vat=Number($('#vatrate').val(),10);
			var ourmarkup=Number($('#ourmarkup').val(),10);
			
			var vatrate=1+vat;
			var vatNet=packprice*vatrate;
			
			if (vatrate > 0) {
				var wspgross=packprice*vatrate;
			} else {
				var wspgross=packprice;
			}
			
			if($('#pricemarked').prop('checked')) {
				var retailvalue=unitprice*packqty*vatrate;
				$('#ourprice').val(unitprice);
				$('#ourmarkup').attr("disabled", true);
			} else {
				$('#ourmarkup').attr("disabled", false);
				var retailvalue=packprice*(1+(ourmarkup/100))*vatrate;
				var ourprice=retailvalue/packqty;
				$('#ourprice').val(ourprice.toFixed(2));
			}
			
			var grossprofit=retailvalue-wspgross;
			var RRPPOR=grossprofit/retailvalue*100;
			
			$('#retailvalue').val(retailvalue.toFixed(2));
			$('#grossprofit').val(grossprofit.toFixed(2));
			$('#RRPPOR').val(RRPPOR.toFixed(2));
			$('#price').val($('#ourprice').val());
			$('#ShelfPrice').val($('#ourprice').val());
		};
		$('.updateCal').change(function(event) {
			Calculate();
		});
		Calculate();
	});
</script>
<cfoutput>
<h1>Price Calculator</h1>
<table border="1" class="tableList" width="500" style="font-size:16px;">
	<tr>
		<th width="100">Pack Qty</th>
		<td colspan="2"><input type="text" name="packqty" id="packqty" value="#form.pskPack#" class="field updateCal" style="font-size:16px;width:250px;"></td>
	</tr>
	<tr>
		<th>Pack Price</th>
		<td colspan="2"><input type="text" name="packprice" id="packprice" value="#form.pskPackPrice#" class="field updateCal" style="font-size:16px;width:250px;"></td>
	</tr>
	<tr>
		<th>Unit RRP</th>
		<td colspan="2"><input type="text" name="unitprice" id="unitprice" value="#form.pskShelfPrice#" class="field updateCal" style="font-size:16px;width:250px;"></td>
	</tr>
	<tr>
		<th>VAT</th>
		<td colspan="2">
			<select name="vatrate" id="vatrate" class="updateCal class" style="width:250px;">
				<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
				<cfloop list="#vatKeys#" delimiters="," index="key">
					<cfif key gt 0>
						<cfset vatItem=StructFind(application.site.vat,key)>
						<option value="#vatItem#"<cfif form.pskVatRate eq vatItem> selected="selected"</cfif>>#vatItem*100#%</option>
					</cfif>
				</cfloop>
			</select>
		</td>
	</tr>
	<tr>
		<th>Price Marked</th>
		<th>Our Markup</th>
		<th>RRP POR</th>
	</tr>
	<tr>
		<td><label style="position: relative;float: left;width: 56px;height: auto;margin: 0;padding: 10px 0;text-align: center;"><input type="checkbox" name="pricemarked" id="pricemarked" value="1" class="field updateCal"></label></td>
		<td><input type="text" name="ourmarkup" id="ourmarkup" value="30.00" class="field nomax updateCal" style="width:250px;"></td>
		<td><input type="text" name="RRPPOR" id="RRPPOR" value="" class="field nomax" disabled="disabled" style="width:250px;"></td>
	</tr>
	<tr>
		<th>Retail Value</th>
		<td colspan="2"><input type="text" name="retailvalue" id="retailvalue" value="" class="field" disabled="disabled" style="width:250px;"></td>
	</tr>
	<tr>
		<th>Gross Profit</th>
		<td colspan="2"><input type="text" name="grossprofit" id="grossprofit" value="" class="field" disabled="disabled" style="width:250px;"></td>
	</tr>
	<tr>
		<th>Our Price</th>
		<td colspan="2"><input type="text" name="ourprice" id="ourprice" value="" class="field" disabled="disabled" style="width:250px;"></td>
	</tr>
</table>
</cfoutput>
<script type="text/javascript">
	$(".class").chosen({width: "100%",disable_search_threshold: 10});
</script>



