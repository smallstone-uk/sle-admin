<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/accounts" name="noms">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.row=val(row)+1>
<cfset nominals=noms.LoadNominalCodes(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		CheckTotal();
		$('.drRowItem').blur(function(event) {
			TotalDR();
		});
		$('.crRowItem').blur(function(event) {
			TotalCR();
		});
		<cfoutput>$('##Row').val("#parm.row#");</cfoutput>
	});
</script>

<cfoutput>
	<table width="500">
		<tr>
			<td width="10">#parm.row#<input type="hidden" name="rowID" value="#parm.row#"></td>
			<td>
				<select name="nomID#parm.row#" id="rowItemSelect#parm.row#" class="select">
					<option value=""></option>
					<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
					<cfloop list="#keys#" index="key">
						<cfset nom=StructFind(nominals,key)>
						<option value="#nom.nomID#">#nom.nomCode# - #nom.nomTitle#</option>
					</cfloop>
				</select>							
			</td>
			<td width="100"><input type="text" name="drValue#parm.row#" class="drRowItem" alt="#parm.row#" id="drValue#parm.row#" style="width:100px;text-align:right;" /></td>
			<td width="100"><input type="text" name="crValue#parm.row#" class="crRowItem" alt="#parm.row#" id="crValue#parm.row#" style="width:100px;text-align:right;"  /></td>
		</tr>	
	</table>										
</cfoutput>
<script type="text/javascript">
	$(".select").chosen({width: "100%"});
	$(".select").trigger('chosen:activate');
</script>
