<cftry>
<cfset callback=1>
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/rounds6" name="rounds">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<!DOCTYPE html>
<html>
<cfoutput><title>Rounds #DateFormat(Now(),"yyyy-mm-dd")# #TimeFormat(Now(),"HH:MM:SS")#</title></cfoutput>
<head>
	<style type="text/css">
		.tableDetail {border:solid 1px #ccc; border-collapse:collapse;}
		.tableDetail th {border:solid 1px #ccc; padding:4px;}
		.tableDetail td {border:solid 1px #ccc; padding:4px;}
		.tableSimple {border:solid 1px #ccc; border-collapse:collapse;}
		.tableSimple td {border:solid 1px #ccc; padding:4px;}
		.tableSign {border:none;}
		.tableSign td {border:none;}
		.qtySupplied {font-size:24px; font-weight:bold;}
		.qtyReturnable {font-size:20px; font-weight:bold;}
	</style>
</head>
<body>
<cfif StructKeyExists(session.rounds.parms,"dispatchTicked")><cfdump var="#session.rounds.parms#" label="rounds" expand="false">
	<cfoutput>
		<cfset parm.form=session.rounds.parms>
		<cfif StructKeyExists(url,"roundDate")>
			<cfset parm.form.roundDate=url.roundDate>
		<cfelse>
			<!---<cfset parm.form.roundDate=DateFormat(DateAdd('d',-1,Now()),'yyyy-mm-dd')>--->
		</cfif>
		<cfset dispatch=rounds.LoadDispatchNotes(parm)>
		<div id="dispatchnotes">
			<cfset delCount = 0>
			<cfloop array="#dispatch#" index="i">
				<div class="clear" style="page-break-before:always;"></div>
				<h1 style="display:block;">
					<cfif len(i.ordContact)>#i.ordContact#<br></cfif>
					<cfif len(i.cltDelHouseNumber)>#i.cltDelHouseNumber#<br></cfif>
					#i.Name# Despatch Note</h1>
				<div class="clear" style="padding:4px 0;"></div>
				<cfif i.Type is "Detail">
					<cfset tableClass="tableDetail">
				<cfelse>
					<cfset tableClass="tableSimple">
				</cfif>
				<table border="1" class="#tableClass#">
					<tr>
						<cfif i.Type is "Detail">
							<th align="right">Date Supplied</th>
							<td colspan="2"><strong>#LSDateFormat(parm.form.roundDate,"dd/mm/yyyy")#</strong></td>
							<th colspan="5">Stock Management</th>
						<cfelse>
							<td colspan="3">Date Supplied : <strong>#LSDateFormat(parm.form.roundDate,"dd/mm/yyyy")#</strong></td>
						</cfif>
					</tr>
					<tr>
						<cfif i.Type is "Detail">
							<th width="300" align="left">Publication</th>
							<th width="50" align="right">Price</th>
							<th width="50" align="center">Supplied</th>
							<th width="70" align="center">Returnable</th>
							<th width="70">Returned</th>
							<th width="50">Waste</th>
							<th width="50">Sold</th>
							<th width="50">Total</th>
						<cfelse>
							<td width="50">&nbsp;</td>
							<td width="50" align="center">Qty</td>
							<td width="300" align="left">Publication</td>
						</cfif>
					</tr>
					<cfif ArrayLen(i.list) IS 0>
						<cfloop from="1" to="10" index="row">
							<tr>
								<td>&nbsp;#row#</td>
								<td>&nbsp;</td>
								<td>&nbsp;</td>
							</tr>
						</cfloop>
					<cfelse>
						<cfif i.Type is "Detail">
							<cfset colspan=8>
						<cfelse>
							<cfset colspan=2>
						</cfif>
						<cfset group="">
						<cfloop array="#i.list#" index="item">
							<cfif i.Type is "Detail">
								<cfif item.group neq group>
									<cfset group=item.group>
									<tr>
										<td align="left" colspan="#colspan#" style="background:##ccc;"><strong>#item.group#</strong></td>
									</tr>
								</cfif>
							</cfif>
							<tr>
								<cfif i.Type is "Detail">
									<cfif item.group eq "news">
										<cfset returnable = int(item.Qty/2)>
										<cfif returnable LT 1><cfset returnable = 1></cfif>
									<cfelse>
										<cfset returnable = item.Qty>
									</cfif>
									<td align="left" height="30">#item.Title#</td>
									<td align="right">&pound;#DecimalFormat(item.Price)#</td>
									<td align="center" width="50" class="qtySupplied">#item.Qty#</td>
									<td align="center" width="50" class="qtyReturnable">#returnable#</td>
									<td>&nbsp; </td><!---<cfif item.Group is "News" AND item.Type neq "Weekly"> style="background:##999;"</cfif>--->
									<td>&nbsp; </td>
									<td>&nbsp; </td>
									<td>&nbsp; </td>
								<cfelse>
									<td>&nbsp;</td>
									<td align="center" height="30" class="qtySupplied">#item.Qty#</td>
									<td align="left">#item.Title#</td>
								</cfif>
							</tr>
						</cfloop>
						<cfif i.Type neq "Detail">
							<cfloop from="1" to="5" index="j">
								<tr>
									<td height="30">&nbsp;</td>
									<td>&nbsp;</td>
									<td>&nbsp;</td>
								</tr>					
							</cfloop>
						</cfif>
						<cfif i.Type is "Detail">
							<tr>
								<th align="right"><strong>Total</strong></th>
								<td align="right"><strong>&pound;#DecimalFormat(i.totalDis)#</strong></td>
								<td align="center" class="qtySupplied">#i.totalDisQty#</td>
								<th colspan="4"></th>
							</tr>
						</cfif>
						<cfif i.ordSignDesp>
							<tr>
								<td colspan="3">
									<table class="tableSign" border="0">
										<tr>
											<td colspan="2">&nbsp;</td>
										</tr>
										<tr>
											<th width="150">Checked by: </th>
											<td width="150" style="border-bottom:solid 1px ##000;"></td>
										</tr>
										<tr>
											<td>&nbsp;</td>
										</tr>
										<tr>
											<th>Checked by: </th>
											<td style="border-bottom:solid 1px ##000;"></td>
										</tr>
									</table>
								</td>
							</tr>
						</cfif>
					</cfif>
				</table>
			</cfloop>
		</div>
	</cfoutput>
</cfif>
</body>
</html>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>


