<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/ProductStock3" name="pstock">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfif StructKeyExists(parm.form,"dealID")>
	<cfset add=pstock.AddDeal(parm)>
	<cfset parm.form.dealID=add.ID>
<cfelse>
	<cfset parm.form.dealID=deal>
</cfif>
<cfset load=pstock.LoadDeal(parm)>

<script type="text/javascript">
	$(document).ready(function() { 
		$(document).keypress(function(e){
			if ($('input').is(":focus")) {
				//console.log("focused");
			} else {
				<cfoutput>scanner(e,"addtodeal","#load.ID#");</cfoutput>
			}
		});
	});
</script>

<cfoutput>
	<cfif parm.form.dealID is 0>
		<h2>New Deal</h2>
	<cfelse>
		<h2>Edit Deal</h2>
	</cfif>
	<form method="post" id="newDealForm2">
		<table width="100%">
			<tr><th width="50%" align="right">Internal Title</th><td align="left">#load.RecordTitle#</td></tr>
			<tr><th align="right">Display Title</th><td align="left">#load.Title#</td></tr>
			<tr><th align="right">Starts</th><td align="left">#LSDateFormat(load.Starts,"dd/mmm/yyyy")#</td></tr>
			<tr><th align="right">Ends</th><td align="left">#LSDateFormat(load.Ends,"dd/mmm/yyyy")#</td></tr>
			<tr><th align="right">Type</th><td align="left">#load.Type#</td></tr>
			<tr><th align="right">Amount</th><td align="left">&pound;#DecimalFormat(load.Amount)#</td></tr>
			<tr><th align="right">Qty</th><td align="left">#val(load.Qty)#</td></tr>
			<tr><th align="right">Status</th><td align="left">#load.Status#</td></tr>
		</table>
		<div class="clear" style="padding:10px 0;"></div>
		<div style="width:100%;height:200px;overflow-y:scroll;">
			<table width="100%" class="tableList" border="1">
				<tr>
					<th align="left">Products</th>
				</tr>
				<cfloop array="#load.items#" index="i">
					<tr>
						<td align="left">#i.Title# #i.size#</td>
					</tr>
				</cfloop>
			</table>
		</div>
		<p>Scan all product barcodes you want to be assigned to this deal.</p>
		<h2>Scan Product Barcodes</h2>
		<div id="scanresult"></div>
	</form>
</cfoutput>