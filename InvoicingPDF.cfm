	<!--- AJAX call - check client do not show debug data at all --->
<cftry>
	<cfset callback=1><!--- force exit of onrequestend.cfm --->
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	<cfsetting requesttimeout="1200">
	<cfset error="">
	<cfset headerHeight=70>
	<cfset titleHeight=80>
	<cfset rowHeight=15>
	<cfset totalTableHeight=105>
	<cfset footerHeight=190>
	<cfset HeightTotal=footerHeight>
	<cfset HeightLimit=780>			
	
	<cfobject component="code/core" name="core">
	<cfobject component="code/Invoicing" name="inv">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.testmode=testmode>
	<cfset parm.fixflag=fixflag>
	<cfset parm.onlycredits=onlycredits>
	<cfset parm.clientID=clientID>
	<cfset parm.ordID=ordID>
	<cfset parm.fromDate=fromDate>
	<cfset parm.toDate=toDate>
	<cfset parm.invDate=invDate>
	
	<cfset parm.InvID=InvID>
	<cfset parm.InvRef=InvRef>
	<cfset parm.delDate=delDate>
	<cfset parm.TransType=TransType>
	
	<cfset invoice=inv.LoadInvoice(parm)>
	
	<cfset parm.cltID=invoice.ID>
	<cfset parm.cltRef=invoice.Ref>
	<cfset parm.orderID=invoice.ordID>
	<cfset parm.ordRef=invoice.ordRef>
	<cfset parm.ordContact=invoice.ordContact>
	<cfset parm.Date=parm.toDate>
	<cfset parm.Total=invoice.total>
	
	<cfset parm.hideOld = true>
	<cfset expiring=core.ExpiringVouchers(parm)>
		
	<cfquery name="QHeader" datasource="#application.site.dataSource0#">
		SELECT *
		FROM cmsclients
		WHERE cltSiteID=#application.site.clientID#
		LIMIT 1;
	</cfquery>
	<cfquery name="QControl" datasource="#application.site.dataSource1#">
		SELECT *
		FROM tblControl
		WHERE ctlID=1
		LIMIT 1;
	</cfquery>
<!---	<cfdump var="#invoice#" label="invoice" expand="yes" format="html" 
	output="#application.site.dir_logs#inv-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->
	<cfoutput>
	<cfif NOT DirectoryExists("#application.site.dir_invoices##DateFormat(parm.invDate,'yy-mm-dd')#")>
		<cfdirectory directory="#application.site.dir_invoices##DateFormat(parm.invDate,'yy-mm-dd')#" action="create">
	</cfif>
	<cfif parm.fixflag is 0 AND FileExists("#application.site.dir_invoices##DateFormat(parm.invDate,'yy-mm-dd')#\#parm.TransType#-#parm.InvRef#.pdf")>
		<cfset error="Invoice already exists for #invoice.ClientName#">
	<cfelse>
		<cfdocument 
			orientation="portrait" 
			mimetype="text/html"
			saveAsName="#parm.TransType#-#parm.InvRef#" 
			filename="#application.site.dir_invoices##DateFormat(parm.invDate,'yy-mm-dd')#\#parm.TransType#-#parm.InvRef#.pdf"
			overwrite="yes"
			localUrl="yes" 
			format="PDF" 
			fontEmbed="yes" 
			encryption="none" 
			scale="100" 
			pagetype="A4" 
			margintop="1.5" 
			marginbottom="1.5" 
			unit="in">
			<style type="text/css">
			<!--
				html, body, div, span, applet, object, iframe, 
				h2, h3, h4, h5, h6, p, blockquote, pre, 
				a, abbr, acronym, address, big, cite, code, 
				del, dfn, em, font, img, ins, kbd, q, s, samp, 
				small, strike, strong, sub, sup, tt, var, 
				dl, dt, dd, ol, ul, li, 
				fieldset, form, label, legend, 
				table, caption, tbody, tfoot, thead, tr, th, td{ 
				  font-family: Arial, Helvetica, sans-serif;
				}
				.tableList {font-size:11px;border-left: solid 1px ##ccc;border-top: solid 1px ##ccc;}
				.tableList th {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
				.tableList th.subtitle {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
				.tableList td {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
				.clienthead {background:##ddd;font-weight:bold;font-size:11px;}
				.client {background:##eee;}
				.normal {background:##fff;}
				.warning {background:##FFD7D7;}
				.freedel {background:##B3F4EC}
				.amount {text-align:right !important;padding:2px;}
				.credit {text-align:right !important;padding:2px;color:##ff0000;}
				.accNum {font-size:12px;}
				.amountTotal {text-align:right !important;padding:2px;font-weight:bold;}
				.amountTotal-box {text-align:right !important;padding:2px;font-weight:bold;font-size: 18px;}
				.centre {text-align:center !important;text-transform: uppercase;}
				.ref {font-size:12px;font-weight:bold;color:##00C;}
				.ordertotal {font-weight:bold;}
				.address td {border:none;font-size:13px;}
				.compTable td {border:none;padding:0px 4px;;}
				.compName {font-family:"Arial Black";font-size:24px;font-weight:bold;color:##075086;}
				.compAddr {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;color:##075086;}
				.compDetailTitle {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;color:##075086;text-align:right !important;}
				.compDetail {font-family:Arial, Helvetica, sans-serif;font-size:12px;font-weight:bold;}
				.clientHeader-nav ul {list-style:none;}
				.clientHeader-nav li {display:inline;}
				.message{width:300px; height:150px; border:none 1px ##075086; padding:10px; font-style:italic; font-size:12px;}
				h2 {font-size:16px;font-weight:normal;margin:0;padding:0 0 5px 0;line-height:18px;}
				.address td {font-size:14px;}
			-->
			</style>
			
			<cfdocumentitem type="header" evalAtPrint="true">
				<cfif cfdocument.currentpagenumber is 1>
					<table border="0" cellspacing="0" cellpadding="0" style="margin:20px 0 0 0 ;font-family:Arial, Helvetica, sans-serif;line-height:22px;" width="100%">
						<tr>
							<td width="50%" style="margin:20px 0 0 0 ;font-size:32px;font-weight:bold;color:##075086;padding:10px 0;" align="left">#QHeader.cltCompanyName#</td>
							<td width="50%" style="font-size:22px;font-weight:normal;color:##333;" align="right">
								<cfif parm.TransType is "crn">
									<span style="color:##ff0000;">Credit Note</span>
								<cfelse>
									Newspaper Delivery Invoice
								</cfif>
							</td>
						</tr>
						<tr>
							<td align="left" style="font-size:14px;color:##333;line-height:16px;" rowspan="2">
								<strong>#QHeader.cltAddress1#<br />#QHeader.cltAddress2#<br />#QHeader.cltTown#<br />#QHeader.cltPostcode#</strong></td>
							<td align="right"><strong style="font-size:16px;color:##333;">Telephone: #QHeader.cltTel1#</strong></td>
						</tr>
						<tr>
							<td align="right" style="font-size:13px;color:##333;line-height:16px;">Email: #QHeader.cltMailOffice#<br />Website: #QHeader.cltWebSite#</td>
						</tr>
					</table>
					<div style="border-bottom:1px solid ##999;">&nbsp;</div>
				<cfelse>
					<table border="0" cellspacing="0" cellpadding="0" style="margin:20px 0 0 0 ;font-family:Arial, Helvetica, sans-serif;line-height:22px;" width="100%">
						<tr>
							<td width="50%" style="margin:20px 0 0 0 ;font-size:22px;font-weight:bold;color:##075086;padding:5px 0;" align="left">#QHeader.cltCompanyName#</td>
							<td width="50%" style="font-size:18px;font-weight:normal;color:##333;" align="right">Newspaper Delivery Invoice</td>
						</tr>
					</table>
					<div style="border-bottom:1px solid ##999;">&nbsp;</div>
				</cfif>
			</cfdocumentitem>
			<cfset HeightTotal=HeightTotal+headerHeight>
			
			<div style="float:left;width:310px;margin:20px 0 0 30px;">
				<cfset ln=0>
				<table border="0" cellspacing="0" cellpadding="1" class="address" width="100%">
					<cfif len(invoice.ClientName)>
						<cfset ln++>
						<tr>
							<td valign="top">
								<cfif len(invoice.Title)>#invoice.title#</cfif>
								<cfif len(invoice.Initial)>#invoice.Initial#</cfif>
								#invoice.ClientName#
							</td>
						</tr>
					</cfif>
					<cfif len(invoice.Dept)><cfset ln++><tr><td valign="top">#invoice.Dept#</td></tr></cfif>
					<cfif len(invoice.CompanyName)><cfset ln++><tr><td valign="top">#invoice.CompanyName#</td></tr></cfif>
					<cfif len(invoice.Addr1)><cfset ln++><tr><td valign="top">#invoice.Addr1#</td></tr></cfif>
					<cfif len(invoice.Addr2)><cfset ln++><tr><td valign="top">#invoice.Addr2#</td></tr></cfif>
					<cfif len(invoice.Town)><cfset ln++><tr><td valign="top">#invoice.Town#</td></tr></cfif>
					<cfif len(invoice.City)><cfset ln++><tr><td valign="top">#invoice.City#</td></tr></cfif>
					<cfif len(invoice.County)><cfset ln++><tr><td valign="top">#invoice.County#</td></tr></cfif>
					<cfif len(invoice.Postcode)><cfset ln++><tr><td valign="top">#invoice.Postcode#</td></tr></cfif>
					<cfloop from="#ln+1#" to="9" index="i">
						<tr><td>&nbsp;</td></tr>
					</cfloop>
				</table>
			</div>
			<div style="float:right;width:280px;margin:20px 0 0 0;">
				<table border="0" cellspacing="0" class="tableList" width="100%">
					<tr><th width="110" align="left">Account Reference</th><td><strong>#invoice.Ref#</strong></td></tr>
					<tr><th width="110" align="left">Invoice No.</th><td>#parm.InvRef#</td></tr>
					<tr><th width="110" align="left">Invoice Date</th><td>#LSDateFormat(parm.invDate,"DD/MM/YYYY")#</td></tr>
					<tr><th width="110" align="left">Invoice Period</th><td>#LSDateFormat(parm.fromDate,"DD/MM/YYYY")# to #LSDateFormat(parm.toDate,"DD/MM/YYYY")#</td></tr>
					<cfif len(parm.ordRef)>
						<tr><th width="110" align="left">Your Reference</th><td>#parm.ordRef#</td></tr>
					</cfif>
					<cfif len(parm.ordContact)>
						<tr><th width="110" align="left">Order Contact</th><td>#parm.ordContact#</td></tr>
					</cfif>
				</table>
			</div>
			<div style="clear:both;margin:-15px 0 0 0;"></div>
					
			<cfif HeightTotal gte HeightLimit><div style="page-break-before:always;"></div><cfset HeightTotal=footerHeight></cfif>
			
			<cfif ArrayLen(invoice.debit)>
				<cfset HeightTotal=HeightTotal+titleHeight>
				<cfif HeightTotal gte HeightLimit><div style="page-break-before:always;"></div><cfset HeightTotal=footerHeight></cfif>
				<div style="padding:5px 0;"></div>
				<h2>Publications Delivered #invoice.deliverTo#</h2>
				<table border="0" cellspacing="0" class="tableList" width="100%" style="font-size:11px;">
					<tr>
						<th align="left" width="600">Publication</th>
						<th align="center" width="100">Quantity</th>
						<th align="right" width="100">Price</th>
						<th align="right" width="100">Line Total</th>
					</tr>
					<cfset lineGroup="">
					<cfloop array="#invoice.debit#" index="index">
						<cfset i=StructFind(invoice.debitGroup,index)>
						<cfif HeightTotal gte HeightLimit>
							<cfset HeightTotal=footerHeight>
							</table>
							<div style="page-break-before:always;"></div>
							<h2>Publications Delivered</h2>
							<table border="0" cellspacing="0" class="tableList" width="100%">
								<tr>
									<th align="left" width="600">Publication</th>
									<th align="center" width="100">Quantity</th>
									<th align="right" width="100">Price</th>
									<th align="right" width="100">Line Total</th>
								</tr>
						</cfif>
						<cfif ArrayLen(invoice.debit) gte 20>
							<cfif i.Group neq lineGroup>
								<tr><th colspan="5" align="left" class="subtitle"><cfif i.Group is "Magazine">Magazines<cfelse>Newspapers</cfif></th></tr>
								<cfset lineGroup=i.Group>
								<cfset HeightTotal=HeightTotal+rowHeight>
							</cfif>
						</cfif>
						<cfset HeightTotal=HeightTotal+rowHeight>
						<tr <cfif i.price is 0> style="color:##ff0000;"</cfif>>
							<td align="left">#i.title#</td>
							<td align="center">#i.qty#</td>
							<td align="right">&pound;#DecimalFormat(i.price)#</td>
							<td align="right">&pound;#DecimalFormat(i.price*i.qty)#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="3" align="right">Total</th>
						<td align="right">&pound;#DecimalFormat(invoice.debittotal)#</td>
					</tr>
				</table>
			</cfif>
			
			<cfif ArrayLen(invoice.credit)>
				<cfset HeightTotal=HeightTotal+titleHeight>
				<cfif HeightTotal gte HeightLimit><div style="page-break-before:always;"></div><cfset HeightTotal=footerHeight></cfif>
				<div style="padding:5px 0;"></div>
				<h2>Publications Credited</h2>
				<table border="0" cellspacing="0" class="tableList" width="100%" style="font-size:11px;">
					<tr>
						<th align="left" width="600">Publication</th>
						<th align="center" width="100">Quantity</th>
						<th align="right" width="100">Price</th>
						<th align="right" width="100">Line Total</th>
					</tr>
					<cfset lineGroup="">
					<cfloop array="#invoice.credit#" index="index">
						<cfset i=StructFind(invoice.creditGroup,index)>
						<cfif HeightTotal gte HeightLimit>
							<cfset HeightTotal=footerHeight>
							</table>
							<div style="page-break-before:always;"></div>
							<h2>Publications Credited</h2>
							<table border="0" cellspacing="0" class="tableList" width="100%">
								<tr>
									<th align="left" width="600">Publication</th>
									<th align="center" width="100">Quantity</th>
									<th align="right" width="100">Price</th>
									<th align="right" width="100">Line Total</th>
								</tr>
						</cfif>
						<cfif ArrayLen(invoice.credit) gte 20>
							<cfif i.Group neq lineGroup>
								<tr><th colspan="5" align="left" class="subtitle"><cfif i.Group is "Magazine">Magazines<cfelse>Newspapers</cfif></th></tr>
								<cfset lineGroup=i.Group>
								<cfset HeightTotal=HeightTotal+rowHeight>
							</cfif>
						</cfif>
						<cfset HeightTotal=HeightTotal+rowHeight>
						<tr>
							<td align="left"><span style="float:right;color:##333;">#i.reason#</span>#i.title#</td>
							<td align="center">#i.qty#</td>
							<td align="right">-&pound;#DecimalFormat(i.price)#</td>
							<td align="right">-&pound;#DecimalFormat(i.price*i.qty)#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="3" align="right">Total</th>
						<td align="right">-&pound;#DecimalFormat(invoice.credittotal)#</td>
					</tr>
				</table>
			</cfif>
			
			<cfif ArrayLen(invoice.vouchers)>
				<cfset HeightTotal=HeightTotal+titleHeight>
				<cfif HeightTotal gte HeightLimit><div style="page-break-before:always;"></div><cfset HeightTotal=footerHeight></cfif>
				<div style="padding:5px 0;"></div>
				<h2>Vouchers Supplied</h2>
				<table border="0" cellspacing="0" class="tableList" width="100%" style="font-size:11px;">
					<tr>
						<th align="left" width="600">Publication</th>
						<th align="center" width="100">Quantity</th>
						<th align="right" width="100">Price</th>
						<th align="right" width="100">Line Total</th>
					</tr>
					<cfloop array="#invoice.vouchers#" index="item">
						<cfset i=StructFind(invoice.voucherGroup,item)>
						<cfif HeightTotal gte HeightLimit>
							<cfset HeightTotal=footerHeight>
							</table>
							<div style="page-break-before:always;"></div>
							<h2>Vouchers Supplied</h2>
							<table border="0" cellspacing="0" class="tableList" width="100%">
								<tr>
									<th align="left" width="600">Publication</th>
									<th align="center" width="100">Quantity</th>
									<th align="right" width="100">Price</th>
									<th align="right" width="100">Line Total</th>
								</tr>
						</cfif>
						<cfset HeightTotal=HeightTotal+rowHeight>
						<tr>
							<td align="left">#i.title#</td>
							<td align="center">#i.qty#</td>
							<td align="right">-&pound;#DecimalFormat(i.price)#</td>
							<td align="right">-&pound;#DecimalFormat(i.price*i.qty)#</td>
						</tr>
					</cfloop>
					<tr>
						<th colspan="3" align="right">Total</th>
						<td align="right">-&pound;#DecimalFormat(invoice.vouchertotal)#</td>
					</tr>
				</table>
			</cfif>
							
			<cfif ArrayLen(expiring)>
				<cfset HeightTotal=HeightTotal+titleHeight>
				<cfif HeightTotal gte HeightLimit><div style="page-break-before:always;"></div><cfset HeightTotal=footerHeight></cfif>
				<div style="padding:5px 0;"></div>
				<h2>Voucher Information</h2>
				<table border="0" cellspacing="0" class="tableList" width="100%">
					<tr>
						<th align="left">Publication</th>
						<th width="80" align="left">Status</th>
						<th width="80" align="left">Expires</th>
					</tr>
					<cfloop array="#expiring#" index="item">
						<cfif HeightTotal gte HeightLimit>
							<cfset HeightTotal=footerHeight>
							</table>
							<div style="page-break-before:always;"></div>
							<h2>Voucher Information</h2>
							<table border="0" cellspacing="0" class="tableList" width="100%">
								<tr>
									<th align="left">Publication</th>
									<th width="80" align="left">Status</th>
									<th width="80" align="left">Expires</th>
								</tr>
						</cfif>
						<cfset HeightTotal=HeightTotal+rowHeight>
						<tr>
							<td>#item.pub#</td>
							<td>
								<cfif item.stop lte parm.Date>
									<i class="expired" style="float:left;">Expired</i>
								<cfelse>
									<i style="float:left;"<cfif item.reDays lte 3> class="expiring"</cfif>>
										<cfif item.reDays gt 0>#item.reDays# <cfif item.reDays neq 1>days<cfelse>day</cfif><cfelse>Expired</cfif> left
									</i>
								</cfif>
							</td>
							<td>
								<cfif item.stop lte parm.Date>
									<b class="expired">#LSDateFormat(item.stop,"dd-mmm-yyyy")#</b>
								<cfelse>
									<b>#LSDateFormat(item.stop,"dd-mmm-yyyy")#</b>
								</cfif>
							</td>
						</tr>
					</cfloop>
				</table>
			</cfif>
	
			<cfif invoice.InvoiceType is "detail">
				<cfset HeightTotal=HeightTotal+totalTableHeight+30>
			<cfelse>
				<cfset HeightTotal=HeightTotal+totalTableHeight>
			</cfif>
			<cfif HeightTotal gte HeightLimit><div style="page-break-before:always;"></div><cfset HeightTotal=footerHeight></cfif>
			<div style="padding:10px 0;"></div>
			<cfif invoice.InvoiceType is "detail">
				<cfset rowspan=5>
			<cfelse>
				<cfset rowspan=7>
			</cfif>
			<cfset subTotal=invoice.debittotal-invoice.credittotal>
			<cfset vatNet=invoice.net0+invoice.net20+invoice.net5>
			<cfset vatVat=invoice.vat0+invoice.vat20+invoice.vat5>
	
			<table border="0" cellspacing="0" class="tableList" width="100%" style="font-size:11px;">
				<tr>
					<td width="50%">	<!--- left --->

						<cfset balanceDue = invoice.statement.balance + invoice.statement.BFwd>
						<cfif invoice.statement.cltShowBal AND balanceDue neq 0>
							<h2>Account Statement</h2>
							<table border="0" cellspacing="0" class="tableList" width="100%" style="font-size:11px;">
								<tr>
									<th>Reference</th>
									<th>Type</th>
									<th>Date</th>
									<th>Amount</th>
								</tr>
								<cfif invoice.statement.bFwd neq 0>
									<tr>
										<td colspan="2">Brought Forward</td>
										<td align="right">#DateFormat(invoice.statement.bfDate,"dd-mmm-yy")#</td>
										<td align="right">#DecimalFormat(invoice.statement.bFwd)#</td>
									</tr>
								</cfif>
								<cfset tranValue = 0>
								<cfloop array="#invoice.statement.trans#" index="tran">
									<cfset tranValue += (tran.trnAmnt1 + tran.trnAmnt2)>
									<cfif tran.trnDate lt parm.invDate>
										<tr>
											<td>#tran.trnRef#</td>
											<td>
												<cfswitch expression="#tran.trnType#">
													<cfcase value="inv">invoice</cfcase>
													<cfcase value="crn">credit note</cfcase>
													<cfcase value="pay">payment</cfcase>
													<cfcase value="jnl">adjustment</cfcase>
													<cfdefaultcase>#tran.trnType#</cfdefaultcase>
												</cfswitch>
											</td>
											<td align="right">#DateFormat(tran.trnDate,"dd-mmm-yy")#</td>
											<td align="right">#DecimalFormat(tran.trnAmnt1 + tran.trnAmnt2)#</td>
										</tr>
									</cfif>
								</cfloop>
								<tr>
									<td colspan="3"><strong>Account Balance as at #DateFormat(Now(),"dd-mmm-yyyy")#</strong></td>
									<td align="right"><strong>#DecimalFormat(invoice.statement.bFwd + tranValue)#</strong></td>
								</tr>
							</table>
						<cfelse>
							<div class="message">#QControl.ctlInvMessage#</div>
						</cfif>
					</td>
					<td width="50%">	<!--- right --->
						<h2>Invoice Summary</h2>
						<cfset totalToPay = invoice.debittotal - invoice.credittotal - invoice.vouchertotal + invoice.DelChargeTotal>
						<table border="0" cellspacing="0" class="tableList" width="100%">
							<tr>
								<th width="250" align="left" valign="middle"> Publications Total</th>
								<td width="150" align="right" valign="middle">&pound;#DecimalFormat(invoice.debittotal)#</td>
							</tr>
							<cfif invoice.vouchertotal neq 0>
							<tr>
								<th align="left" valign="middle">Less Vouchers Redeemed</th>
								<td align="right" valign="middle">-&pound;#DecimalFormat(invoice.vouchertotal)#</td>
							</tr>
							</cfif>
							<cfif invoice.credittotal neq 0>
							<tr>
								<th width="250" align="left" valign="middle"> Less Credits</th>
								<td width="150" align="right" valign="middle">-&pound;#DecimalFormat(invoice.credittotal)#</td>
							</tr>
							</cfif>
							<cfif invoice.NetDisc neq 0>
							<tr>
								<th align="left" valign="middle">Less Discount @ #invoice.Discount*100#%</th>
								<td align="right" valign="middle">&pound;#DecimalFormat(invoice.NetDisc)#</td>
							</tr>
							</cfif>
							<tr>
								<th width="250" align="left" valign="middle">Delivery Charge</th>
								<td align="right" valign="middle">&pound;#DecimalFormat(invoice.DelChargeTotal)#</td>
							</tr>
							<tr>
								<th align="left" valign="middle">Sub-Total</th>
								<td align="right" valign="middle"><strong>&pound;#DecimalFormat(totalToPay)#</strong></td>
							</tr>
							<tr>
								<th>&nbsp;</th>
								<td>&nbsp;</td>
							</tr>
							<cfif balanceDue neq 0>
								<tr>
									<th align="left" valign="middle">
										<cfif balanceDue lt 0>Less Credit Balance
											<cfelse>Plus Account Balance</cfif>
									</th>
									<td align="right" valign="middle">&pound;#DecimalFormat(balanceDue)#</td>
								</tr>
							</cfif>
							<cfset grandTotal = balanceDue + totalToPay>
							<cfif grandTotal gt 0>
								<tr>
									<th align="left" valign="middle" style="font-size:14px;"><strong>Amount To Pay</strong></th>
									<td align="right" valign="middle" style="font-size:14px;"><strong>&pound;#DecimalFormat(balanceDue + totalToPay)#</strong></td>
								</tr>
							<cfelseif grandTotal lte 0>
								<tr>
									<th align="left" valign="middle" style="font-size:14px;"><strong>Account in credit<br />(nothing to pay)</strong></th>
									<td align="right" valign="middle" style="font-size:14px;"><strong>&pound;#DecimalFormat(balanceDue + totalToPay)#</strong></td>
								</tr>
							<cfelse>
								<tr>
									<th align="left" valign="middle" style="font-size:14px;"><strong>Amount To Pay</strong></th>
									<td align="right" valign="middle" style="font-size:14px;"><strong>&pound;#DecimalFormat(totalToPay)#</strong></td>
								</tr>
							</cfif>
						</table>
					</td>
				</tr>
			</table>
			
			<cfdocumentitem type="footer" evalAtPrint="true">
				<div style="font-size:11px;font-family: Arial, Helvetica, sans-serif;padding:10px 0 0 0;line-height:16px;border-top:1px solid ##999;">
					<div style="float:right;font-size:12px;line-height:18px;font-weight:bold; text-align:left; width:300px;">
						Please quote your account reference "#invoice.Ref#" with your payment.<br />
						Any discrepancies must be reported within seven days of the invoice date.
					</div>
					<b>Terms</b><br />
					Payment of this invoice is due within 14 days.<br />
					Please make cheques payable to <b>Shortlanesend Store</b>.<br />
					Bank: Lloyds Bank plc. Sort Code: <b>30-98-76</b> Account: <b>3534 5860</b><br />
					VAT Registration: GB 152 5803 21
				</div>
				<div style="font-size:12px;font-family: Arial, Helvetica, sans-serif;text-align:right;">#cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</div>
			</cfdocumentitem>
			
		</cfdocument>
	</cfif>
	<h1>Creating Invoices</h1>
	<cfif NOT len(error)>
		<cfif row neq total>
			<p>Created PDF for #invoice.ClientName#</p>
		<cfelse>
			<p>Invoice run complete.</p>
		</cfif>
	<cfelse>
		<p>#error#</p>
	</cfif>
	<p></p>
	<div class="progress-box">
		<div class="progress-bar" style="width:#int(row/total*100)#%;"></div>
		<cfif row is total>
			<cfset comp={}>
			<cfset comp.datasource=parm.datasource>
			<cfset comp.form.delDate=parm.delDate>
			<cfset comp.form.fromDate=parm.fromDate>
			<cfset comp.form.invDate=parm.invDate>
			<cfset comp.form.toDate=LSDateFormat(parm.toDate,"yyyy-mm-dd")>
			<cfset comp.form.folderDate=LSDateFormat(parm.invDate,"yy-mm-dd")>
			<cfset compile=inv.LoadInvoiceRun(comp)>
<!---	<cfdump var="#compile#" label="compile" expand="false">
--->
			<cfloop array="#compile.rounds#" index="r">
				<cfdocument format="PDF" name="cfdoc#r.RoundID#" pagetype="A4" margintop="1.5" marginbottom="1.5" unit="in">
					<h1 style="text-align:center;margin:150px 0 0 0;">#r.roundTitle#</h1>
					<h1>Please ensure all invoices are delivered within 7 days</h1>
					<h1>Thank you</h1>
				</cfdocument>
			</cfloop>
			<cfdocument format="PDF" name="cfdocPost" pagetype="A4" margintop="1.5" marginbottom="1.5" unit="in">
				<h1 style="text-align:center;margin:250px 0 0 0;">Post</h1>
			</cfdocument>
			<cfdocument format="PDF" name="cfdocEmail" pagetype="A4" margintop="1.5" marginbottom="1.5" unit="in">
				<h1>Email</h1>
				<table>
					<tr>
						<th width="30">Ref</th>
						<th width="300">Name</th>
						<th width="150" align="right">Invoice</th>
					</tr>
					<cfloop array="#compile.email#" index="e">
						<tr>
							<td>#e.ref#</td>
							<td>#e.clientname#</td>
							<td align="right">#e.InvoiceRef#</td>
						</tr>
					</cfloop>
				</table>
			</cfdocument>
				
			<cfpdf action="merge" destination="#application.site.dir_invoices#compiled/#comp.form.folderDate#.pdf" overwrite="yes">
				<cfset roundID=0>
				<cfloop array="#compile.list#" index="item">
					<cfif roundID neq item.RoundID>
						<cfpdfparam source="cfdoc#item.RoundID#">
						<cfset roundID=item.RoundID>
					</cfif>
					<cfif FileExists("#application.site.dir_invoices##comp.form.folderDate#/inv-#item.InvoiceRef#.pdf")>
						<cfpdfparam source="#application.site.dir_invoices##comp.form.folderDate#/inv-#item.InvoiceRef#.pdf">
					</cfif>
				</cfloop>
				<cfset roundID=0>
				<cfloop array="#compile.post#" index="p">
					<cfif roundID neq p.RoundID>
						<cfpdfparam source="cfdocPost">
						<cfset roundID=p.RoundID>
					</cfif>
					<cfif FileExists("#application.site.dir_invoices##comp.form.folderDate#/inv-#p.InvoiceRef#.pdf")>
						<cfpdfparam source="#application.site.dir_invoices##comp.form.folderDate#/inv-#p.InvoiceRef#.pdf">
					</cfif>
				</cfloop>
				<cfpdfparam source="cfdocEmail">
			</cfpdf>
			<div class="progress-text"><a href="#application.site.url_invoices#/compiled/#comp.form.folderDate#.pdf" target="_blank" class="button" style="float:none;">View</a></div>
		<cfelse>
			<cfif row is total-1>
				<div class="progress-text"><img src='images/loading_2.gif' class='loadingGif' style="float:none;">&nbsp;Compiling...</div>
			<cfelse>
				<div class="progress-text">#row# of #total# #int(row/total*100)#%</div>
			</cfif>
		</cfif>
	</div>
	</cfoutput>
	
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
	output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
