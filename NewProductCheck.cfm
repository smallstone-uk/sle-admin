<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfparam name="check" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset cats=product.LoadProductCats(parm)>
<cfif len(parm.form.barcodeCheck)>
	<cfset check=product.CheckProductExists(parm)>
<cfelse>
	<cfset check=false>
</cfif>

<script type="text/javascript">
	$(document).ready(function() { 
		$('#togCal').click(function(event) {
			event.preventDefault();
			$('#orderOverlay').toggle();
			$('#orderOverlayForm').center();
		});
		$('.orderOverlayClose').click(function(event) {
			$("#orderOverlay").fadeOut();
$("#orderOverlay-ui").fadeOut();
			event.preventDefault();
		});
		$('.updateCal').change(function(event) {
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
		});
	});
</script>
<cfoutput>
<div id="orderOverlay-ui"></div>
<div id="orderOverlay">
	<div id="orderOverlayForm">
		<a href="##" class="orderOverlayClose">X</a>
		<div id="orderOverlayForm-inner">
			<h1>Price Calculator</h1>
			<table border="1" class="tableList" width="500" style="font-size:16px;">
				<tr>
					<th width="100">Pack Qty</th>
					<td colspan="2"><input type="text" name="packqty" id="packqty" value="" class="field updateCal" style="font-size:16px;width:95%;"></td>
				</tr>
				<tr>
					<th>Pack Price</th>
					<td colspan="2"><input type="text" name="packprice" id="packprice" value="" class="field updateCal" style="font-size:16px;width:95%;"></td>
				</tr>
				<tr>
					<th>Unit RRP</th>
					<td colspan="2"><input type="text" name="unitprice" id="unitprice" value="" class="field updateCal" style="font-size:16px;width:95%;"></td>
				</tr>
				<tr>
					<th>VAT</th>
					<td colspan="2">
						<select name="vatrate" id="vatrate" class="updateCal class">
							<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
							<cfloop list="#vatKeys#" delimiters="," index="key">
								<cfif key gt 0>
									<cfset vatItem=StructFind(application.site.vat,key)>
									<option value="#vatItem#">#vatItem*100#%</option>
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
					<td><input type="text" name="ourmarkup" id="ourmarkup" value="30.00" class="field nomax updateCal"></td>
					<td><input type="text" name="RRPPOR" id="RRPPOR" value="" class="field nomax" disabled="disabled"></td>
				</tr>
				<tr>
					<th>Retail Value</th>
					<td colspan="2"><input type="text" name="retailvalue" id="retailvalue" value="" class="field" disabled="disabled"></td>
				</tr>
				<tr>
					<th>Gross Profit</th>
					<td colspan="2"><input type="text" name="grossprofit" id="grossprofit" value="" class="field" disabled="disabled"></td>
				</tr>
				<tr>
					<th>Our Price</th>
					<td colspan="2"><input type="text" name="ourprice" id="ourprice" value="" class="field" disabled="disabled"></td>
				</tr>
			</table>
		</div>
	</div>
</div>
</cfoutput>

<cfif check>
	<cfset load=product.LoadProduct(parm)>
	<script type="text/javascript">
		$(document).ready(function() { 
			$('#BtnSaveProduct').click(function(event) {   
				event.preventDefault();
				var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...";
				$.ajax({
					type: 'POST',
					url: 'NewProductSave.cfm',
					data : $('#NewProd').serialize(),
					beforeSend:function(){
						$('#checkResult').html(loadingText).fadeIn();
					},
					success:function(data){
						$('#checkResult').html(data);
						$('#barcodeCheck').focus();
					},
					error:function(data){
						$('#checkResult').html(data);
						$('#barcodeCheck').focus();
					}
				});
			});
		});
	</script>
	<cfoutput>
		<h2>Edit Product</h2>
		<input type="hidden" name="productID" value="#load.ID#">
		<input type="hidden" name="barcode" value="#parm.form.barcodeCheck#">
		<table border="1" class="tableList" width="300">
			<tr>
				<th>Category</th>
				<td>
					<select name="type" class="type">
						<cfloop array="#cats#" index="i">
							<option value="#i.ID#"<cfif load.type eq i.ID> selected="selected"</cfif> style="text-transform:capitalize;">#i.Title#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<th width="50">Title</th>
				<td><input type="text" name="title" id="title" value="#load.Title#" class="field" style="width: 400px;"></td>
			</tr>
			<tr>
				<th>Price</th>
				<td><input type="text" name="price" value="#load.price#" class="field" style="width:165px;margin: 13px 0;"><a href="##" id="togCal" class="button">Price Calculator</a></td>
			</tr>
			<tr>
				<th>Measurement <span style="font-size:12px;color:##666;">(500g/500ml)</span></th>
				<td><input type="text" name="UnitSize" value="#load.UnitSize#" class="field" style="width: 400px;"></td>
			</tr>
			<tr>
				<th>Set Price</th>
				<td>
					<select name="class" class="class">
						<option value="multiple"<cfif load.class eq "multiple"> selected="selected"</cfif>>Yes, price is the same on every product</option>
						<option value="single"<cfif load.class eq "single"> selected="selected"</cfif>>No, price varies</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2"><input type="button" id="BtnSaveProduct" value="Save Changes"></td>
			</tr>
		</table>
	</cfoutput>
<cfelse>
	<script type="text/javascript">
		$(document).ready(function() { 
			$('#BtnAddProduct').click(function(event) {   
				event.preventDefault();
				var type=$('.type').val();
				if (type != 0) {
					var loadingText="<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...";
					$.ajax({
						type: 'POST',
						url: 'NewProductAdd.cfm',
						data : $('#NewProd').serialize(),
						beforeSend:function(){
							$('#checkResult').html(loadingText).fadeIn();
						},
						success:function(data){
							$('#checkResult').html(data);
							$('#barcodeCheck').focus();
						},
						error:function(data){
							$('#checkResult').html(data);
							$('#barcodeCheck').focus();
						}
					});
				} else {
					alert("You haven't selected a category.");
				}
			});
		});
	</script>
	<cfoutput>
		<h2>New Product</h2>
		<input type="hidden" name="barcode" value="#parm.form.barcodeCheck#">
		<table border="1" class="tableList" width="500">
			<tr>
				<th>Category</th>
				<td>
					<select name="type" class="type" data-placeholder="Select..." style="text-transform:capitalize;">
						<option value=""></option>
						<cfloop array="#cats#" index="i">
							<option value="#i.ID#">#i.Title#</option>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<th width="50">Title</th>
				<td><input type="text" name="title" id="title" value="" class="field" style="width: 400px;"></td>
			</tr>
			<tr>
				<th>Price</th>
				<td><input type="text" name="price" value="" id="price" class="field" style="width:165px;margin: 13px 0;"><a href="##" id="togCal" class="button">Price Calculator</a></td>
			</tr>
			<tr>
				<th>Measurement <span style="font-size:12px;color:##666;">(500g/500ml)</span></th>
				<td><input type="text" name="UnitSize" value="" class="field" style="width: 400px;"></td>
			</tr>
			<tr>
				<th>Set Price</th>
				<td>
					<select name="class" class="class">
						<option value="multiple">Yes, price is the same on every product</option>
						<option value="single">No, price varies</option>
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="2"><input type="button" id="BtnAddProduct" value="Add Product"></td>
			</tr>
		</table>
	</cfoutput>
</cfif>
<script type="text/javascript">
	$(".type").chosen({width: "100%"});
	$(".class").chosen({width: "100%",disable_search_threshold: 10});
</script>

