<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfsetting requesttimeout="3600">
<cftry>
<cfobject component="code/Invoicing" name="inv">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset invoices=inv.LoadInvoiceRun(parm)>

<cfset row=0>
<cfset testmode=0> <!--- DEV USE ONLY. NOT FOR FIXING INVOICES--->
<cfset grandtotal=0>
<cfset overalltotal=0>
<cfset arraytotal=val(ArrayLen(invoices.list))+val(ArrayLen(invoices.post))+val(ArrayLen(invoices.email))+val(ArrayLen(invoices.weekly))>
<cfoutput>
	Clients found: #invoices.clientCount#<br />
	<cfif ArrayLen(invoices.list)>
		<cfset grandtotal=0>
		<h1>Deliver</h1>
		<table border="1" class="tableList trhover" width="100%">
			<tr>
				<th width="80"><cfif parm.form.createPDF is 1>View<cfelse>Preview</cfif></th>
				<th width="40">Ref</th>
				<th width="60">Total</th>
				<th width="60">Voucher</th>
				<th width="60">Type</th>
				<th width="200">Client</th>
				<th>Address</th>
			</tr>
			<cfloop array="#invoices.list#" index="item">
				<cfset row=row+1>
				<cfset set={}>
				<cfset set.datasource=parm.datasource>
				<cfset set.clientID=item.ID>
				<cfset set.ordID=item.ordID>
				<cfset set.ordContact=item.ordContact>
				<cfif StructKeyExists(parm.form,"fixflag")>
					<cfset set.fixflag=1>
				<cfelse>
					<cfset set.fixflag=0>
				</cfif>
				<cfif StructKeyExists(parm.form,"onlycredits")>
					<cfset set.onlycredits=1>
				<cfelse>
					<cfset set.onlycredits=0>
				</cfif>
				<cfset set.fromDate=parm.form.fromDate>
				<cfset set.toDate=parm.form.toDate>
				<cfset set.invDate=parm.form.invDate>
				<cfset set.delDate=parm.form.delDate>
				<cfset invoice=inv.LoadInvoice(set)>

				<cfset set.cltID=invoice.ID>
				<cfset set.cltRef=invoice.Ref>
				<cfset set.cltShowBal=item.cltShowBal>
				<cfset set.Total=invoice.total>
				<cfset set.TransType=invoice.TransType>
				<cfset set.vouchers=invoice.vouchertotal>
				<cfset set.testmode=testmode>
				<cfset preTot = invoice.debitTotal + invoice.debitChargeTotal + invoice.creditTotal + invoice.creditChargeTotal - invoice.vouchertotal>
				<cfset grandtotal=grandtotal+preTot>
				<cfif parm.form.createPDF is 1>
					<cfset create=inv.CreateInvoice(set)>
					<cfset set.InvID=create.InvID>
					<cfset set.InvRef=create.InvoiceRef>
					<script type="text/javascript">
						var item = {
							"row": "#row#",
							"total": "#arraytotal#",
							"clientID": "#item.ID#",
							"ordID": "#item.ordID#",
							"fixflag": "#set.fixflag#",
							"onlycredits": "#set.onlycredits#",
							"fromDate": "#parm.form.fromDate#",
							"toDate": "#parm.form.toDate#",
							"invDate": "#parm.form.invDate#",
							"delDate": "#parm.form.delDate#",
							"TransType": "#set.TransType#",
							"invRef": "#set.InvRef#",
							"InvID": "#set.InvID#",
							"InvTotal": "#preTot#",
							"testmode": "#testmode#"
						};
						//console.log(item);
						ArrayOfStructs.push(item);
						
					</script>
				</cfif>
				<tr>
					<td align="center">
						<cfif parm.form.createPDF is 1>
							<cfif FileExists("#application.site.dir_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#\inv-#set.InvRef#.pdf")>
								<a href="#application.site.url_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#/inv-#set.InvRef#.pdf" target="_blank">View</a>
							<cfelse>
								<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
									invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
							</cfif>
						<cfelse>
							<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
								invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
						</cfif>
					</td>
					<td align="center"><a href="clientDetails.cfm?row=0&ref=#item.Ref#" target="_blank">#item.Ref#</a></td>
					<td align="right"<cfif preTot is 0> style="background:red;color:white;"</cfif>>&pound;#DecimalFormat(preTot)#</td>
					<td align="center"><cfif invoice.vouchertotal neq 0>Yes</cfif></td>
					<td align="center">#item.invoiceType#</td>
					<td>#item.ClientName#</td>
					<td>#item.Address#</td>
				</tr>
			</cfloop>
			<cfset overalltotal=overalltotal+grandtotal>
			<tr>
				<th colspan="2">Grand Total</th>
				<td align="right">&pound;#DecimalFormat(grandtotal)#</td>
				<th colspan="4"></th>
			</tr>
		</table>
	</cfif>
	
	<cfif ArrayLen(invoices.post)>
		<cfset grandtotal=0>
		<h1>Post</h1>
		<table border="1" class="tableList trhover" width="100%">
			<tr>
				<th width="80"><cfif parm.form.createPDF is 1>View<cfelse>Preview</cfif></th>
				<th width="40">Ref</th>
				<th width="60">Total</th>
				<th width="60">Voucher</th>
				<th width="60">Type</th>
				<th width="200">Client</th>
				<th>Address</th>
			</tr>
			<cfloop array="#invoices.post#" index="item">
				<cfset row=row+1>
				<cfset set={}>
				<cfset set.datasource=parm.datasource>
				<cfset set.clientID=item.ID>
				<cfset set.ordID=item.ordID>
				<cfset set.ordContact=item.ordContact>
				<cfif StructKeyExists(parm.form,"fixflag")>
					<cfset set.fixflag=1>
				<cfelse>
					<cfset set.fixflag=0>
				</cfif>
				<cfif StructKeyExists(parm.form,"onlycredits")>
					<cfset set.onlycredits=1>
				<cfelse>
					<cfset set.onlycredits=0>
				</cfif>
				<cfset set.fromDate=parm.form.fromDate>
				<cfset set.toDate=parm.form.toDate>
				<cfset set.invDate=parm.form.invDate>
				<cfset set.delDate=parm.form.delDate>
				<cfset invoice=inv.LoadInvoice(set)>
				<cfset set.cltID=invoice.ID>
				<cfset set.cltRef=invoice.Ref>
				<cfset set.cltShowBal=item.cltShowBal>
				<cfset set.Total=invoice.total>
				<cfset set.TransType=invoice.TransType>
				<cfset set.vouchers=invoice.vouchertotal>
				<cfset set.testmode=testmode>
				<cfset preTot=invoice.total-invoice.vouchertotal>
				<cfset grandtotal=grandtotal+preTot>
				<cfif parm.form.createPDF is 1>
					<cfset create=inv.CreateInvoice(set)>
					<cfset set.InvID=create.InvID>
					<cfset set.InvRef=create.InvoiceRef>
					<script type="text/javascript">
						var item = {
							"row": "#row#",
							"total": "#arraytotal#",
							"clientID": "#item.ID#",
							"ordID": "#item.ordID#",
							"fixflag": "#set.fixflag#",
							"onlycredits": "#set.onlycredits#",
							"fromDate": "#parm.form.fromDate#",
							"toDate": "#parm.form.toDate#",
							"invDate": "#parm.form.invDate#",
							"delDate": "#parm.form.delDate#",
							"TransType": "#set.TransType#",
							"invRef": "#set.InvRef#",
							"InvID": "#set.InvID#",
							"InvTotal": "#preTot#",
							"testmode": "#testmode#"
						};
						//console.log(item);
						ArrayOfStructs.push(item);
						
					</script>
				</cfif>
				<tr>
					<td align="center">
						<cfif parm.form.createPDF is 1>
							<cfif FileExists("#application.site.dir_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#\inv-#set.InvRef#.pdf")>
								<a href="#application.site.url_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#/inv-#set.InvRef#.pdf" target="_blank">View</a>
							<cfelse>
								<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
									invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
							</cfif>
						<cfelse>
							<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
								invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
						</cfif>
					</td>
					<td align="center"><a href="clientDetails.cfm?row=0&ref=#item.Ref#" target="_blank">#item.Ref#</a></td>
					<td align="right"<cfif preTot is 0> style="background:red;color:white;"</cfif>>&pound;#DecimalFormat(preTot)#</td>
					<td align="center"><cfif invoice.vouchertotal neq 0>Yes</cfif></td>
					<td align="center">#item.invoiceType#</td>
					<td>#item.ClientName#</td>
					<td>#item.Address#</td>
				</tr>
			</cfloop>
			<cfset overalltotal=overalltotal+grandtotal>
			<tr>
				<th colspan="2">Grand Total</th>
				<td align="right">&pound;#DecimalFormat(grandtotal)#</td>
				<th colspan="4"></th>
			</tr>
		</table>
	</cfif>
	
	<cfif ArrayLen(invoices.weekly)>
		<cfset grandtotal=0>
		<h1>Weekly</h1>
		<table border="1" class="tableList trhover" width="100%">
			<tr>
				<th width="80"><cfif parm.form.createPDF is 1>View<cfelse>Preview</cfif></th>
				<th width="40">Ref</th>
				<th width="60">Total</th>
				<th width="60">Voucher</th>
				<th width="60">Type</th>
				<th width="200">Client</th>
				<th>Address</th>
			</tr>
			<cfloop array="#invoices.weekly#" index="item">
				<cfset row=row+1>
				<cfset set={}>
				<cfset set.datasource=parm.datasource>
				<cfset set.clientID=item.ID>
				<cfset set.ordID=item.ordID>
				<cfset set.ordContact=item.ordContact>
				<cfif StructKeyExists(parm.form,"fixflag")>
					<cfset set.fixflag=1>
				<cfelse>
					<cfset set.fixflag=0>
				</cfif>
				<cfif StructKeyExists(parm.form,"onlycredits")>
					<cfset set.onlycredits=1>
				<cfelse>
					<cfset set.onlycredits=0>
				</cfif>
				<cfset set.fromDate=parm.form.fromDate>
				<cfset set.toDate=parm.form.toDate>
				<cfset set.invDate=parm.form.invDate>
				<cfset set.delDate=parm.form.delDate>
				<cfset invoice=inv.LoadInvoice(set)>
				<cfset set.cltID=invoice.ID>
				<cfset set.cltRef=invoice.Ref>
				<cfset set.Total=invoice.total>
				<cfset set.cltShowBal=item.cltShowBal>
				<cfset set.TransType=invoice.TransType>
				<cfset set.vouchers=invoice.vouchertotal>
				<cfset set.testmode=testmode>
				<cfset preTot=invoice.total-invoice.vouchertotal>
				<cfset grandtotal=grandtotal+preTot>
				<cfif parm.form.createPDF is 1>
					<cfset create=inv.CreateInvoice(set)>
					<cfset set.InvID=create.InvID>
					<cfset set.InvRef=create.InvoiceRef>
					<script type="text/javascript">
						var item = {
							"row": "#row#",
							"total": "#arraytotal#",
							"clientID": "#item.ID#",
							"ordID": "#item.ordID#",
							"fixflag": "#set.fixflag#",
							"onlycredits": "#set.onlycredits#",
							"fromDate": "#parm.form.fromDate#",
							"toDate": "#parm.form.toDate#",
							"invDate": "#parm.form.invDate#",
							"delDate": "#parm.form.delDate#",
							"TransType": "#set.TransType#",
							"invRef": "#set.InvRef#",
							"InvID": "#set.InvID#",
							"InvTotal": "#preTot#",
							"testmode": "#testmode#"
						};
						//console.log(item);
						ArrayOfStructs.push(item);
						
					</script>
				</cfif>
				<tr>
					<td align="center">
						<cfif parm.form.createPDF is 1>
							<cfif FileExists("#application.site.dir_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#\inv-#set.InvRef#.pdf")>
								<a href="#application.site.url_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#/inv-#set.InvRef#.pdf" target="_blank">View</a>
							<cfelse>
								<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
									invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
							</cfif>
						<cfelse>
							<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
								invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
						</cfif>
					</td>
					<td align="center"><a href="clientDetails.cfm?row=0&ref=#item.Ref#" target="_blank">#item.Ref#</a></td>
					<td align="right"<cfif preTot is 0> style="background:red;color:white;"</cfif>>&pound;#DecimalFormat(preTot)#</td>
					<td align="center"><cfif invoice.vouchertotal neq 0>Yes</cfif></td>
					<td align="center">#item.invoiceType#</td>
					<td>#item.ClientName#</td>
					<td>#item.Address#</td>
				</tr>
			</cfloop>
			<cfset overalltotal=overalltotal+grandtotal>
			<tr>
				<th colspan="2">Grand Total</th>
				<td align="right">&pound;#DecimalFormat(grandtotal)#</td>
				<th colspan="4"></th>
			</tr>
		</table>
	</cfif>
	
	<cfif ArrayLen(invoices.email)>
		<cfset grandtotal=0>
		<h1>Email</h1>
		<table border="1" class="tableList trhover" width="100%">
			<tr>
				<th width="80"><cfif parm.form.createPDF is 1>View<cfelse>Preview</cfif></th>
				<th width="40">Ref</th>
				<th width="60">Total</th>
				<th width="60">Voucher</th>
				<th width="60">Type</th>
				<th width="200">Client</th>
				<th>Address</th>
			</tr>
			<cfloop array="#invoices.email#" index="item">
				<cfset row=row+1>
				<cfset set={}>
				<cfset set.datasource=parm.datasource>
				<cfset set.clientID=item.ID>
				<cfset set.ordID=item.ordID>
				<cfset set.ordContact=item.ordContact>
				<cfif StructKeyExists(parm.form,"fixflag")>
					<cfset set.fixflag=1>
				<cfelse>
					<cfset set.fixflag=0>
				</cfif>
				<cfif StructKeyExists(parm.form,"onlycredits")>
					<cfset set.onlycredits=1>
				<cfelse>
					<cfset set.onlycredits=0>
				</cfif>
				<cfset set.fromDate=parm.form.fromDate>
				<cfset set.toDate=parm.form.toDate>
				<cfset set.invDate=parm.form.invDate>
				<cfset set.delDate=parm.form.delDate>
				<cfset invoice=inv.LoadInvoice(set)>
				<cfset set.cltID=invoice.ID>
				<cfset set.cltRef=invoice.Ref>
				<cfset set.cltShowBal=item.cltShowBal>
				<cfset set.createPDF=parm.form.createPDF>
				<cfset set.Total=invoice.total>
				<cfset set.TransType=invoice.TransType>
				<cfset set.vouchers=invoice.vouchertotal>
				<cfset set.testmode=testmode>
				<cfset preTot=invoice.total-invoice.vouchertotal>
				<cfset grandtotal=grandtotal+preTot>
				<cfif parm.form.createPDF is 1>
					<cfset create=inv.CreateInvoice(set)>
					<cfset set.InvID=create.InvID>
					<cfset set.InvRef=create.InvoiceRef>
					<script type="text/javascript">
						var item = {
							"row": "#row#",
							"total": "#arraytotal#",
							"clientID": "#item.ID#",
							"ordID": "#item.ordID#",
							"fixflag": "#set.fixflag#",
							"onlycredits": "#set.onlycredits#",
							"fromDate": "#parm.form.fromDate#",
							"toDate": "#parm.form.toDate#",
							"invDate": "#parm.form.invDate#",
							"delDate": "#parm.form.delDate#",
							"TransType": "#set.TransType#",
							"invRef": "#set.InvRef#",
							"InvID": "#set.InvID#",
							"InvTotal": "#preTot#",
							"testmode": "#testmode#"
						};
						//console.log(item);
						ArrayOfStructs.push(item);
					</script>
				</cfif>
				<tr>
					<td align="center">
						<cfif parm.form.createPDF is 1>
							<cfif FileExists("#application.site.dir_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#\inv-#set.InvRef#.pdf")>
								<a href="#application.site.url_invoices##DateFormat(parm.form.invDate,'yy-mm-dd')#/inv-#set.InvRef#.pdf" target="_blank">View</a>
							<cfelse>
								<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
									invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
							</cfif>
						<cfelse>
							<a href="InvoicingSinglePDF.cfm?clientID=#item.ID#&ordID=#item.ordID#&fromDate=#parm.form.fromDate#&toDate=#parm.form.toDate#&
								invDate=#parm.form.invDate#&multiple=false&onlycredits=#set.onlycredits#&fixflag=#set.fixflag#" target="_blank">Preview</a>
						</cfif>
					</td>
					<td align="center"><a href="clientDetails.cfm?row=0&ref=#item.Ref#" target="_blank">#item.Ref#</a></td>
					<td align="right"<cfif preTot is 0> style="background:red;color:white;"</cfif>>&pound;#DecimalFormat(preTot)#</td>
					<td align="center"><cfif invoice.vouchertotal neq 0>Yes</cfif></td>
					<td align="center">#item.invoiceType#</td>
					<td>#item.ClientName#</td>
					<td>#item.Address#</td>
				</tr>
			</cfloop>
			<cfset overalltotal=overalltotal+grandtotal>
			<tr>
				<th colspan="2">Grand Total</th>
				<td align="right">&pound;#DecimalFormat(grandtotal)#</td>
				<th colspan="4"></th>
			</tr>
			<tr>
				<th colspan="2">Overall Total</th>
				<td align="right">&pound;#DecimalFormat(overalltotal)#</td>
				<th colspan="4"></th>
			</tr>
		</table>
	</cfif>
	
	<script type="text/javascript">
		<cfif parm.form.createPDF is 1 AND arraytotal is row>SpoolPDF();</cfif>		
	</script>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

