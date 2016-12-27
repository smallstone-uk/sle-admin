<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<cfquery name="QCharges" datasource="#application.site.datasource1#">
	SELECT *
	FROM tblClients,tblOrder,tblDelCharges,tblRoundItems,tblStreets2
	WHERE cltID=ordClientID
	AND ordDeliveryCode=delCode
	AND riOrderID=ordID
	AND riRoundID <> 241
	AND riDay='mon'
	AND (cltAccountType='M' OR cltAccountType='W')
	AND ordActive=1
	AND ordStreetCode=stID
	ORDER BY riRoundID asc, riOrder asc
</cfquery>
<cfquery name="QListCharges" datasource="#application.site.datasource1#">
	SELECT *
	FROM tblDelCharges
	WHERE 1
	ORDER BY delCode asc
</cfquery>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadList() {
			$.ajax({
				type: 'POST',
				url: 'delChargesList.cfm',
				success:function(data){
					$('#list').html(data);
				}
			});
		}
		$('.DelCode').change(function() {
			var client=$(this).attr("data-ID");
			var order=$(this).attr("data-order");
			var value=$(this).val();
			$.ajax({
				type: 'POST',
				url: 'delChargesAction.cfm',
				data: {
					"client":client,
					"order":order,
					"value":value
				},
				success:function(data){
					LoadList();
				}
			});
		});
	});
</script>

<cfoutput>
	<h1>Delivery Charges</h1>
	<div id="dump"></div>
	<table border="1" class="tableList">
		<tr>
			<th width="30">Ref</th>
			<th width="150" align="left">Name</th>
			<th width="300" align="left">Address</th>
			<th width="40">Current Code</th>
			<th width="40">New Code</th>
			<th width="30" align="right">Mon-Fri</th>
			<th width="30" align="right">Sat</th>
			<th width="30" align="right">Sun</th>
			<th width="30" align="right">&nbsp;</th>
			<th width="30" align="right">Mon-Fri</th>
			<th width="30" align="right">Sat</th>
			<th width="30" align="right">Sun</th>
		</tr>
		<cfloop query="QCharges">
			<cfquery name="QNewCharge" datasource="#application.site.datasource1#">
				SELECT *
				FROM tblDelCharges
				WHERE delCode=<cfif ordDelCodeNew neq 0>#ordDelCodeNew#<cfelse>#ordDeliveryCode#</cfif>
			</cfquery>
			<tr>
				<td align="center">#cltRef#</td>
				<td><cfif len(cltName) AND len(cltCompanyName)>#cltName# #cltCompanyName#<cfelse>#cltName##cltCompanyName#</cfif></td>
				<td>
					<cfif len(ordHouseName) AND len(ordHouseNumber)>
						#ordHouseName#, #ordHouseNumber#&nbsp;
					<cfelse>
						#ordHouseName##ordHouseNumber#&nbsp;
					</cfif>
					#stName#
				</td>
				<td align="center"<cfif ordDeliveryCode is 0> style="background:red;"</cfif>>#ordDeliveryCode#</td>
				<td>
					<select class="DelCode" data-ID="#cltID#" data-order="#ordID#">
						<cfloop query="QListCharges">
							<option value="#QListCharges.delcode#"<cfif QCharges.ordDelCodeNew is QListCharges.delcode> selected="selected"</cfif>>
								<cfif QListCharges.delcode is 0>
									No Change
								<cfelse>
									#QListCharges.delcode#
								</cfif>
							</option>
						</cfloop>
					</select>
				</td>
				<td align="right"><cfif delPrice1 neq 0>&pound;#DecimalFormat(delPrice1)#</cfif></td>
				<td align="right"><cfif delPrice2 neq 0>&pound;#DecimalFormat(delPrice2)#</cfif></td>
				<td align="right"><cfif delPrice3 neq 0>&pound;#DecimalFormat(delPrice3)#</cfif></td>
				<td align="right">&nbsp;</td>
				<td align="right"><cfif QNewCharge.delPrice1 neq 0>&pound;#DecimalFormat(QNewCharge.delPrice1+0.05)#</cfif></td>
				<td align="right"><cfif QNewCharge.delPrice2 neq 0>&pound;#DecimalFormat(QNewCharge.delPrice2+0.05)#</cfif></td>
				<td align="right"><cfif QNewCharge.delPrice3 neq 0>&pound;#DecimalFormat(QNewCharge.delPrice3+0.05)#</cfif></td>
			</tr>
		</cfloop>
	</table>
</cfoutput>
