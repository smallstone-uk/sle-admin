<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset prods=prod.LoadProducts(parm)>

<script type="text/javascript">
	$(document).ready(function() { 
		$('.datepicker').datepicker({
			dateFormat: "yy-mm-dd",
			changeMonth: true,
			changeYear: true,
			showButtonPanel: true,
			minDate: new Date(2013, 1 - 1, 1),
			onClose: function() {
				LoadStockByDate("#stockForm");
			}
		});
		LoadStockByDate("#stockForm");
		$('#ProdFindManual').change(function() {
			var id=$(this).val();
			GetProductBarcode(id);
		});
	});
</script>

<cfoutput>
	<form method="post" id="stockForm">
		<input type="hidden" name="supp" id="supp" value="#parm.form.supp#">
		<label><b>Date Received</b>&nbsp;&nbsp;<input type="text" name="pskDate" class="datepicker" value="#LSDateFormat(Now(),'yyyy-mm-dd')#"></label>
		<cfif parm.form.type is "scan">
			<script type="text/javascript">
				$(document).ready(function() { 
					$(document).keypress(function(e){
						if ($('input').is(":focus")) {
							//console.log("focused");
						} else {
							scanner(e);
						}
					});
				});
			</script>
			<div id="scanBarcode">
				Scan Barcode <br /><br /> or <br /><br />
				<div style="text-align:left;width:300px;margin:0 auto;">
					<select name="ProdFind" id="ProdFindManual" style="">
						<option value="">Search for product...</option>
						<cfloop array="#prods#" index="i">
							<option value="#i.ID#">#i.Title#</option>
						</cfloop>
					</select>
				</div>
			</div>
		<cfelse>
			<div id="findProduct" style="margin:20px 0 0 0;">
				<cfif ArrayLen(prods) gt 20>
					<select name="ProdFind" id="ProdFind" style="text-align:left;">
						<option value="">Search for product...</option>
						<cfloop array="#prods#" index="i">
							<option value="#i.ID#">#i.Title#</option>
						</cfloop>
					</select>
				<cfelse>
					<cfset cats=prod.LoadProductCats(parm)>
					<script type="text/javascript">
						$(document).ready(function() {
							$('##SaveStock').click(function() {
								SubmitMuliFormData();
							});
							$('##AddCat').click(function(e) {
								e.preventDefault();
							});
							$('##AddRow').click(function(e) {
								AddMultiRow();
								e.preventDefault();
							});
							$('.managebarcode').click(function(e) {
								var id=$(this).attr("data-prodID");
								var row=$(this).attr("data-row");
								ManageBarcodes(id,row);
								e.preventDefault();
							});
						});
					</script>
					<table border="1" class="tableList" width="100%">
						<tr>
							<th colspan="10">
								<input type="button" id="SaveStock" value="Save" style="float:right;padding:5px 20px;">
								<a href="##" id="AddCat" class="button" style="float:left;color:##fff;">Add Category</a>
								<a href="##" id="AddRow" class="button" style="float:left;color:##fff;">Add Row</a>
							</th>
						</tr>
						<tr>
							<th width="5">##</th>
							<th>Title</th>
							<th width="100">Category</th>
							<th width="40">Pack</th>
							<th width="60">Size</th>
							<th width="40">Pack Price</th>
							<th width="40">Shelf Price</th>
							<th width="40">Vat Rate</th>
							<th width="40">POR</th>
							<th width="40">Profit</th>
						</tr>
						<cfset row=0>
						<cfloop array="#prods#" index="i">
							<cfset row=row+1>
							<script type="text/javascript">
								$(document).ready(function() {
									function SendPORData#row#() {
										var units=$('##pskPack#row#').val();
										var cost=$('##pskPackPrice#row#').val();
										var sell=$('##pskShelfPrice#row#').val();
										var vat=$('##pskVatRate#row#').val();
										var row=$('##row#row#').val();
										UpdatePOR(units,cost,sell,vat,row);
									}
									$('.UpdatePOR#row#').on("change",function(e) {
										SendPORData#row#();
									});
									$('.UpdatePOR#row#').on("keyup",function(e) {
										SendPORData#row#();
									});
									SendPORData#row#();
								});
							</script>
							<input type="hidden" name="row" id="row#row#" value="#row#">
							<input type="hidden" name="prodID#row#" id="ID#row#" value="#i.ID#">
							<tr>
								<td><a href="##" class="managebarcode" data-prodID="#i.ID#" data-row="#row#">##</a></td>
								<td><input type="text" id="title#row#" name="prodTitle#row#" value="#i.title#" style="width:95%;"></td>
								<td id="catList" width="100">
									<select name="catID#row#" class="type" style="text-align:left;">
										<option value="0"<cfif i.CatID is 0> selected="selected"</cfif> style="text-transform:capitalize;">Select...</option>
										<cfloop array="#cats#" index="c">
											<option value="#c.ID#"<cfif i.CatID is c.ID> selected="selected"</cfif> style="text-transform:capitalize;">#c.Title#</option>
										</cfloop>
									</select>
								</td>
								<td><input type="text" name="pskPack#row#" id="pskPack#row#" class="UpdatePOR#row#" value="#i.PackQty#" style="width:60px;text-align:center;"></td>
								<td><input type="text" name="prodSize#row#" value="#i.UnitSize#" style="width:80px;"></td>
								<td><input type="text" name="pskPackPrice#row#" id="pskPackPrice#row#" class="UpdatePOR#row#" value="#i.PackPrice#" style="width:60px;text-align:right;"></td>
								<td><input type="text" name="pskShelfPrice#row#" id="pskShelfPrice#row#" class="UpdatePOR#row#" value="#i.Price#" style="width:60px;text-align:right;"></td>
								<td>
									<select name="pskVatRate#row#" id="pskVatRate#row#" class="UpdatePOR#row#">
										<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
										<cfloop list="#vatKeys#" delimiters="," index="key">
											<cfif key gt 0>
												<cfset vatItem=StructFind(application.site.vat,key)>
												<option value="#vatItem#"<cfif i.VatRate eq vatItem> selected="selected"</cfif>>#vatItem*100#%</option>
											</cfif>
										</cfloop>
									</select>
								</td>
								<td align="right" id="POR#row#"></td>
								<td align="right" id="Profit#row#"></td>
							</tr>
						</cfloop>
						<tbody id="NewRows"></tbody>
					</table>
					<input type="hidden" name="rows" id="rows" value="#row#">
				</cfif>
			</div>
		</cfif>
		<div id="result" style="display:none;"></div>
	</form>
</cfoutput>
<script type="text/javascript">
	$("#ProdFind").chosen({width: "300px"});
	$('#ProdFind').trigger('chosen:activate');
	$(".type").chosen({width: "100px"});
	$("#ProdFindManual").chosen({width: "300px"});
</script>
