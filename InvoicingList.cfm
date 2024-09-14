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
<cfset chargeCheck = inv.CheckDaysCharged(parm)>
<cfset row=0>
<cfset testmode=0> <!--- DEV USE ONLY. NOT FOR FIXING INVOICES--->
<cfset grandtotal=0>
<cfset overalltotal=0>

<cfoutput>
	<h1>Data Check</h1>
	<cfset keys = ListSort(StructKeyList(chargeCheck.grid,","),"numeric","asc")>
	<table width="700" class="tableList" border="1">
		<tr>
			<th align="right">Date</th>
			<th></th>
			<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="dayName">
				<th align="right">#dayName#</th>
			</cfloop>
			<th align="right">Total</th>
		</tr>
		<cfset mTotal = {price = 0, charge = 0, count = 0}>
		<cfloop list="#keys#" index="i">
			<cfset theWeek = StructFind(chargeCheck.grid,i)>
			<tr>
				<td align="right">#DateFormat(theWeek.theDate,"ddd dd-mmm-yy")#</td>
				<td align="right">
					Media<br />
					Charges<br />
					Count
				</td>
				<cfset wTotal = {price = 0, charge = 0, count = 0}>
				<cfloop list="Sun,Mon,Tue,Wed,Thu,Fri,Sat" index="dayName">
					<cfif StructKeyExists(theWeek,dayName)>
						<cfset theDay = StructFind(theWeek,dayName)>
						<td align="right">
							#theDay.price#<br />
							#theDay.charge#<br />
							#theDay.count#<br />
                            #theDay.date#
						</td>
						<cfset wTotal.price += theDay.price>
						<cfset wTotal.charge += theDay.charge>
						<cfset wTotal.count += theDay.count>
					<cfelse>
						<td class="missing" align="center">MISSING</td>
					</cfif>
				</cfloop>
				<td align="right">
					#DecimalFormat(wTotal.price)#<br />
					#DecimalFormat(wTotal.charge)#<br />
					#wTotal.count#
				</td>
				<cfset mTotal.price += wTotal.price>
				<cfset mTotal.charge += wTotal.charge>
				<cfset mTotal.count += wTotal.count>
			</tr>
			<tr>
				<td colspan="11">&nbsp;</td>
			</tr>
		</cfloop>
		<tr>
			<th></th>
			<th align="right">
				Media<br />
				Charges<br />
				Count
			</th>
			<th colspan="9" align="right">		
				#DecimalFormat(mTotal.price)#<br />
				#DecimalFormat(mTotal.charge)#<br />
				#mTotal.count#
			</th>
		</tr>
	</table>
	
<cfset invoices = inv.LoadInvoiceRun(parm)>
<!---<cfdump var="#invoices#" label="invoices" expand="false">--->
<cfset arraytotal=val(ArrayLen(invoices.list))+val(ArrayLen(invoices.post))+val(ArrayLen(invoices.email))+val(ArrayLen(invoices.weekly))>
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
				<th>Round</th>
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
					<td>#item.rndTitle# #item.riOrder#</td>
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
				<th>Round</th>
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
					<td>#item.rndTitle# #item.riOrder#</td>
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
				<th>Round</th>
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
					<td>#item.rndTitle# #item.riOrder#</td>
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
				<th>Round</th>
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
					<td>#item.rndTitle# #item.riOrder#</td>
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
	Clients found: #invoices.clientCount#<br />
	
	<script type="text/javascript">
		<cfif parm.form.createPDF is 1 AND arraytotal is row>SpoolPDF();</cfif>		
	</script>
</cfoutput>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

