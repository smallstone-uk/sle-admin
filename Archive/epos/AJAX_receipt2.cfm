<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfif StructKeyExists(parm.form,"transID") AND parm.form.transID is 0 AND session.eposlasttransID neq 0>
	<cfset parm.form.transID=session.eposlasttransID>
</cfif>

<cfif StructKeyExists(parm.form,"transID") AND parm.form.transID neq 0>
	<cfset trans=epos.LoadTransaction(parm)>

	<style type="text/css">
		@page {   
			size:portrait;
			margin-top:0px;
			margin-left:8px;
			margin-right:7px;
			margin-bottom:0px;
		}
		@media print {	
			table {border-spacing: 0px;border-collapse: collapse;font-size: 8pt;font-weight: normal; font-family: ;border:none !important;}
			table th {padding: 0 2px;color: #000;font-weight: bold; background:#FFF; vertical-align:top;border:none !important;}
			table td {padding: 0 2px;color: #000; vertical-align:top;border:none !important;}
			table[border="0"] {border:none !important;}
			h1 {text-align:center;padding:10px 0;}
		}
	</style>
	
	<!--- Receipt Width: 165px appox. --->
	
	<cfoutput>
		<table width="164px" border="0">
			<tr><th colspan="2" align="center" style="font-size:10pt;"><h1>#application.company.name#</h1></th></tr>
			<tr><td colspan="2" align="center">#application.company.webmaster#</td></tr>
			<tr><td colspan="2" align="center">#application.company.telephone#</td></tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td colspan="2" align="center">Served by: #trans.clerk#</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td colspan="1" align="left">#LSDateFormat(trans.timestamp, "dd/mm/yyyy")#</td>
				<td colspan="1" align="right">#LSTimeFormat(trans.timestamp, "HH:mm")#</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<cfloop array="#trans.list#" index="i">
				<cfif i.qty gt 1>
					<tr><td align="left" colspan="2" valign="top">#i.prodTitle#</td></tr>
					<tr><td align="right" colspan="2" valign="top"><span style="float:left;margin:0 0 0 40px;">#i.qty# @ &pound;#DecimalFormat(i.price)#</span>&pound;#DecimalFormat(i.price * i.qty)#</td></tr>
				<cfelse>
					<tr>
						<td align="left" valign="top">#i.prodTitle#</td>
						<td align="right" valign="top">&pound;#DecimalFormat(i.price * i.qty)#</td>
					</tr>
				</cfif>
			</cfloop>
			<cfif ArrayLen(trans.deals)>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr><td colspan="2"><strong>Offer<cfif ArrayLen(trans.deals) neq 1>s</cfif></strong></td></tr>
				<cfloop array="#trans.deals#" index="i">
					<tr>
						<td align="left" valign="top">#i.recordTitle#</td>
						<td align="right" valign="top">&pound;#DecimalFormat(i.manualprice)#</td>
					</tr>
				</cfloop>
			</cfif>
			<cfif ArrayLen(trans.suppliers)>
				<tr><td colspan="2">&nbsp;</td></tr>
				<cfloop array="#trans.suppliers#" index="i">
					<tr>
						<td align="left" valign="top">Supplier</td>
						<td align="right" valign="top">&pound;#DecimalFormat(i.manualprice)#</td>
					</tr>
				</cfloop>
			</cfif>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<th align="left" colspan="2" style="font-size:12pt;" valign="top">Total <span style="float:right;">&pound;#DecimalFormat(trans.gross)#</span></th>
			</tr>
			<cfset changedue=trans.gross>
			<cfif ArrayLen(trans.payments)>
				<cfloop array="#trans.payments#" index="i">
					<cfset changedue=changedue+i.manualprice>
					<tr>
						<td align="left" valign="top">#UCase(i.subtype)#</td>
						<td align="right" valign="top">&pound;#DecimalFormat(i.manualprice)#</td>
					</tr>
				</cfloop>
			</cfif>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<th align="left" colspan="2" style="font-size:11pt;" valign="top">Change Due <span style="float:right;">&pound;#DecimalFormat(changedue*-1)#</span></th>
			</tr>
			<cfif NOT ArrayLen(trans.suppliers)>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr><td colspan="2" style="border-bottom:2px dashed ##000 !important;"></td></tr>
				<tr>
					<td colspan="2" align="center">
						<h1>Promotion</h1>
						3 x 330ml Cans for £1
					</td>
				</tr>
				<tr><td colspan="2">&nbsp;</td></tr>
				<tr><td colspan="2" style="border-bottom:2px dashed ##000 !important;"></td></tr>
			</cfif>
			<tr><td colspan="2"><br /><br /><br /><br /><br /><span style="color:##666;">.</span></td></tr>
		</table>
	</cfoutput>
</cfif>
