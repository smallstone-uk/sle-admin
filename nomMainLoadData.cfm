<cfset callback=1>
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset dr=true>

<cfobject component="code/accounts" name="noms">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.row=0>
<cfset nominals=noms.LoadNominalCodes(parm)>
<cfset load=noms.LoadNomData(parm)>

<cfif NOT StructKeyExists(load,"error")>
	<script type="text/javascript">
		$(document).ready(function() {
			<cfoutput>
				$('##trnDate').val("#load.date#");
				$('##Ref').val("#load.Ref#");
				$('##desc').val("#load.desc#");
				$('##NetAmount').val("#load.Amnt1#");
				$('##VATAmount').val("#load.Amnt2#");
				$('##Row').val("#ArrayLen(load.items)#");
				$('##Mode').val(2);
				$('##btnSave').val("Save Changes");
				$('##result').html("");
			</cfoutput>
			<cfif ArrayLen(load.items)>
				GrossTotal();
				TotalDR();
				TotalCR();
			<cfelse>
				AddRow();
			</cfif>
		});
	</script>
	
	
	<cfoutput>
		<table width="500">
			<cfif ArrayLen(load.items)>
				<cfloop array="#load.items#" index="i">
					<cfset parm.row=parm.row+1>
					<tr>
						<td width="10">#parm.row#<input type="hidden" name="rowID" value="#parm.row#"></td>
						<td>
							<select name="nomID#parm.row#" id="rowItemSelect#parm.row#" class="select">
								<option value=""></option>
								<cfset keys=ListSort(StructKeyList(nominals,","),"text","asc",",")>
								<cfloop list="#keys#" index="key">
									<cfset nom=StructFind(nominals,key)>
									<option value="#nom.nomID#"<cfif nom.nomID is i.NomID> selected="selected"</cfif>>#nom.nomCode# - #nom.nomTitle#</option>
								</cfloop>
							</select>							
						</td>
						<cfif i.amount gt 0>
							<cfset dr=true>
							<cfset amount=i.amount>
						<cfelse>
							<cfset dr=false>
							<cfset amount=ReReplace(i.amount,"-","","all")>
						</cfif>
						<td width="100"><input type="text" name="drValue#parm.row#"<cfif NOT dr> disabled="disabled"<cfelse> value="#amount#"</cfif> class="drRowItem" alt="#parm.row#" id="drValue#parm.row#" style="width:100px;text-align:right;" /></td>
						<td width="100"><input type="text" name="crValue#parm.row#"<cfif dr> disabled="disabled"<cfelse> value="#amount#"</cfif> class="crRowItem" alt="#parm.row#" id="crValue#parm.row#" style="width:100px;text-align:right;"  /></td>
					</tr>
				</cfloop>
			</cfif>
		</table>										
	</cfoutput>
	<script type="text/javascript">
		$(".select").chosen({width: "100%"});
	</script>
<cfelse>
	<script type="text/javascript">
		$(document).ready(function() {
			Reset();
			$('#result').html("Transaction not found");
		});
	</script>
</cfif>	
	


