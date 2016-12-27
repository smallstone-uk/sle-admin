<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="prod">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset cats=prod.LoadProductCats(parm)>


<cfoutput>
	<cfset row=parm.form.row+1>
	<tr>
		<td>
			<script type="text/javascript">
				$(document).ready(function() {
					$('.newbarcode').click(function(e) {
						var id=$(this).attr("data-prodID");
						var row=$(this).attr("data-row");
						ManageBarcodes(id,row);
						e.preventDefault();
					});
				});
			</script>
			<a href="##" class="newbarcode" data-prodID="0" data-row="#row#">##</a>
		</td>
		<td>
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
					$('##rows').val("#row#");
				});
			</script>
			<input type="text" id="title#row#" name="prodTitle#row#" value="" style="width:95%;">
		</td>
		<td id="catList" width="100">
			<input type="hidden" name="row" id="row#row#" value="#row#">
			<input type="hidden" name="prodID#row#" id="ID#row#" value="0">
			<select name="catID#row#" class="type" style="text-align:left;">
				<option value="" style="text-transform:capitalize;">Select...</option>
				<cfloop array="#cats#" index="c">
					<option value="#c.ID#" style="text-transform:capitalize;">#c.Title#</option>
				</cfloop>
			</select>
		</td>
		<td><input type="text" name="pskPack#row#" id="pskPack#row#" class="UpdatePOR#row#" value="" style="width:60px;text-align:center;"></td>
		<td><input type="text" name="prodSize#row#" value="" style="width:80px;"></td>
		<td><input type="text" name="pskPackPrice#row#" id="pskPackPrice#row#" class="UpdatePOR#row#" value="" style="width:60px;text-align:right;"></td>
		<td><input type="text" name="pskShelfPrice#row#" id="pskShelfPrice#row#" class="UpdatePOR#row#" value="" style="width:60px;text-align:right;"></td>
		<td>
			<select name="pskVatRate#row#" id="pskVatRate#row#" class="UpdatePOR#row#">
				<cfset vatKeys=ListSort(StructKeyList(application.site.vat,","),"numeric","asc")>
				<cfloop list="#vatKeys#" delimiters="," index="key">
					<cfif key gt 0>
						<cfset vatItem=StructFind(application.site.vat,key)>
						<option value="#vatItem#">#vatItem*100#%</option>
					</cfif>
				</cfloop>
			</select>
		</td>
		<td id="POR#row#"></td>
		<td id="Profit#row#"></td>
	</tr>
</cfoutput>
<script type="text/javascript">
	$(".type").chosen({width: "100px"});
</script>
