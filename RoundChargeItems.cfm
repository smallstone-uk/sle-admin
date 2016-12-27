<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfsetting requesttimeout="300">
<cfset testmode=0>
<cfset GrandTotalQty={}>

<cfobject component="code/rounds" name="rounds">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.form.roundDate=date>
<cfset parm.list=[]>
<cfset parm.dispatch=dispatch>
<cfset parm.roundID=form.rounds>
<cfset parm.showSummaries=showSummaries>
<cfset parm.showOverallSummary=showOverallSummary>
<cfset parm.showRoundOrder=showRoundOrder>
<cfset drops=rounds.LoadRoundDrops(parm)>

<cfset dayYest=DateFormat(DateAdd("d",-1,parm.form.roundDate),"yyyy-mm-dd")>

<cfoutput>
    <cftry>
		<cfloop array="#drops.rounds#" index="rnd">
			<cfif ArrayLen(rnd.list)>
				<cfloop array="#rnd.list#" index="d">
					<cfloop array="#d.houses#" index="h">
						<cfloop array="#h.items#" index="i">
							<cfset charge={}>
							<cfset charge.item=i.ID>
							<cfset charge.orderID=h.OrderID>
							<cfset charge.clientID=h.ClientID>
							<cfset charge.roundID=rnd.roundID>
							<cfset charge.pub=i.pubID>
							<cfset charge.issue=i.issue>
							<cfset charge.type="debit">
							<cfset charge.test=testmode>
							<cfset charge.charge=h.Charge>
							<cfset charge.price=i.Price>
							<cfset charge.vat=i.Vat>
							<cfset charge.qty=i.Qty>
							<cfset charge.holiday=i.Holiday>
							<cfif i.Holiday>
								<cfset charge.reason="On Holiday">
							<cfelse>
								<cfset charge.reason="">
							</cfif>
							
							<cfif i.pubGroup is "Magazine">
								<cfquery name="QStockCheck" datasource="#parm.datasource#">
									SELECT SUM(psQty) AS StockTotal
									FROM tblPubStock
									WHERE psPubID=#i.pubID#
									AND psType='received'
									AND psDate >= '#LSDateFormat(DateAdd("d",-4,dayYest),"yyyy-mm-dd")#'
									AND psDate <= '#LSDateFormat(dayYest,"yyyy-mm-dd")#'
									LIMIT 1;
								</cfquery>
								<cfquery name="QStockCheckClaim" datasource="#parm.datasource#">
									SELECT SUM(psQty) AS StockClaimTotal
									FROM tblPubStock
									WHERE psPubID=#i.pubID#
									AND psType='claim'
									AND psDate >= '#LSDateFormat(DateAdd("d",-4,dayYest),"yyyy-mm-dd")#'
									AND psDate <= '#LSDateFormat(dayYest,"yyyy-mm-dd")#'
									LIMIT 1;
								</cfquery>
								<cfset totReceived=val(QStockCheck.StockTotal)-val(QStockCheckClaim.StockClaimTotal)>
								<cfif StructKeyExists(GrandTotalQty,i.pubID)>
									<cfset qty=StructFind(GrandTotalQty,i.pubID)>
									<cfif qty.Qty gt totReceived>
										<cfset totalUp=false>
										<cfif StructKeyExists(rnd.pubTotalQty,i.pubID)>
											<cfset qty=StructFind(rnd.pubTotalQty,i.pubID)>
											<cfset q.Qty=qty.Qty-i.Qty>
											<cfif q.Qty neq 0>
												<cfset StructUpdate(rnd.pubTotalQty,i.pubID,q)>
											<cfelse>
												<cfset StructDelete(rnd.pubTotalQty,i.pubID)>
											</cfif>
										</cfif>
									<cfelse>
										<cfset totalUp=true>
									</cfif>
								<cfelse>
									<cfif totReceived gte i.Qty>
										<cfset totalUp=true>
									<cfelse>
										<cfset totalUp=false>
									</cfif>
								</cfif>
							<cfelse>
								<cfset totalUp=true>
							</cfif>
							<cfif i.HolidayAction eq "cancel">
								<cfset totalUp=true>
							<cfelseif i.HolidayAction eq "hold">
								<cfset totalUp=true>
							<cfelseif i.HolidayAction eq "Stop">
								<cfset totalUp=false>
							</cfif>
							<cfif totalUp>
								<cfif i.HolidayAction neq "cancel" OR i.HolidayAction neq "Stop">
									<cfif StructKeyExists(GrandTotalQty,i.pubID)>
										<cfset qty=StructFind(GrandTotalQty,i.pubID)>
										<cfset q={}>
										<cfset q.Title=i.Title>
										<cfset q.Qty=qty.Qty+i.Qty>
										<cfset StructUpdate(GrandTotalQty,i.pubID,q)>
									<cfelse>
										<cfset q={}>
										<cfset q.Title=i.Title>
										<cfset q.Qty=i.Qty>
										<cfset StructInsert(GrandTotalQty,i.pubID,q)>
									</cfif>
								</cfif>
							</cfif>
							<cfif totalUp>
								<cfset ArrayAppend(parm.list,charge)>
							</cfif>
						</cfloop>
					</cfloop>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfset addCharges=rounds.ProcessRounds(parm)>
		
		<cfif StructKeyExists(addCharges,"roundstats")>
			<table border="1" class="tableList" width="100%">
				<tr>
					<th width="40">Batch</th>
					<th>Round</th>
					<th width="80">Publication Total</th>
					<th width="80">Delivery Total</th>
					<th width="60">Charged</th>
					<th width="60">Updated</th>
					<th width="60">Skipped</th>
				</tr>
				<cfset pubtotal=0>
				<cfset deltotal=0>
				<cfset Charged=0>
				<cfset Updated=0>
				<cfset Skipped=0>
				<cfloop array="#addCharges.roundstats#" index="item">
					<cfset pubtotal=pubtotal+item.pubtotal>
					<cfset deltotal=deltotal+item.deltotal>
					<cfset Charged=Charged+item.Charged>
					<cfset Updated=Updated+item.Updated>
					<cfset Skipped=Skipped+item.Skipped>
					<tr>
						<td align="center">#item.batch#</td>
						<td>#item.roundID#</td>
						<td align="right">&pound;#DecimalFormat(item.pubtotal)#</td>
						<td align="right">&pound;#DecimalFormat(item.deltotal)#</td>
						<td align="center">#item.Charged#</td>
						<td align="center">#item.Updated#</td>
						<td align="center">#item.Skipped#</td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="2" align="right">Totals</th>
					<td align="right">&pound;#pubtotal#</td>
					<td align="right">&pound;#deltotal#</td>
					<td align="center">#Charged#</td>
					<td align="center">#Updated#</td>
					<td align="center">#Skipped#</td>
				</tr>
			</table>
		<cfelse>
			<cfdump var="#addCharges#" label="addCharges" expand="no">
		</cfif>
		
		<cfif NOT DirectoryExists("D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\rounds\#DateFormat(parm.form.roundDate,'yy-mm')#")>
			<cfdirectory directory="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\rounds\#DateFormat(parm.form.roundDate,'yy-mm')#" action="create">
		</cfif>
		
		<cfset filename="#LSDateFormat(parm.form.roundDate,"yyyy-mm-dd")#.pdf">
		
		<cfdocument 
			orientation="portrait" 
			mimetype="text/html"
			saveAsName="#filename#" 
			filename="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\rounds\#DateFormat(parm.form.roundDate,'yy-mm')#\#filename#"
			overwrite="yes"
			localUrl="yes" 
			format="PDF" 
			fontEmbed="yes" 
			encryption="none" 
			scale="100" 
			pagetype="a4" 
			unit="in" 
			margintop="0.5" 
			marginleft="0.3" 
			marginright="0.3" 
			marginbottom="0.5">
			
			<cfset roundcount=0>
			<cfset totalDrops=0>
			<cfset totalUp=true>
			
			<cfloop array="#drops.rounds#" index="rnd2">
				<cfdocumentsection>
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
						.tableList {font-size:14px;}
						.tableList th {padding:6px 4px 2px 4px;font-size:16px;font-weight:bold;border-bottom:1px solid ##999;}
						.tableList th.subtitle {padding:2px 4px;border-bottom: solid 1px ##ccc;border-right: solid 1px ##ccc;background:##fff;}
						.tableList td {padding:2px 4px;border-bottom:1px solid ##ccc;}
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
						h2 {font-size:16px;font-weight:normal;margin:0;padding:0 0 5px 0;line-height:18px;}
						.holidaytitle {display:block;font-size: 14px;color: ##FFF;font-weight:bold;background: ##666;font-style:normal;padding:0 3px;}
						.holiday-action {display: block;margin:0 0 2px 0;font-style: italic;text-transform: capitalize;font-size: 12px;color:##000;font-weight:bold;}
						.holiday-action i {display:block;font-size: 12px;color: ##FFF;font-weight:bold;background: ##666;font-style:normal;padding:0 3px;}
					-->
					</style>
				<cfset count=0>
				<cfset roundcount=roundcount+1>
				<cfset dayYest=DateFormat(DateAdd("d",-1,parm.form.roundDate),"yyyy-mm-dd")>
				<cfdocumentitem type="header">
					<h2 style="margin:10px 0 0 0;">#rnd2.roundTitle# <span style="float:right;font-size:16px;">#DateFormat(parm.form.roundDate,"DDDD")# - #DateFormat(parm.form.roundDate,"DD/MM/YYYY")#</span></h2>
				</cfdocumentitem>
				<cfdocumentitem type="footer">
					<div style="text-align:right;font-size:14px;font-weight:bold;">#cfdocument.currentsectionpagenumber# of #cfdocument.totalsectionpagecount#</div>
				</cfdocumentitem>			
				<table border="0" cellspacing="0" class="tableList" width="100%">
					<cfif ArrayLen(rnd2.list)>
						<cfloop array="#rnd2.list#" index="d">
							<tr>
								<th colspan="2" align="left">#d.StreetName#</th>
							</tr>
							<cfloop array="#d.houses#" index="h">
								<cfset count=count+1>
								<cfset ic=0>
								<tr>
									<td width="180" align="right">
										<cfif len(h.Name) AND len(h.Number)>
											#h.Name#, #h.Number#
										<cfelse>
											#h.Name##h.Number#
										</cfif>
									</td>
									<td>
										<cfloop array="#h.items#" index="i">											
											<cfif i.pubGroup is "Magazine">
												<cfquery name="QStockCheck" datasource="#parm.datasource#">
													SELECT psQty
													FROM tblPubStock
													WHERE psPubID=#i.pubID#
													AND psType='received'
													AND psDate='#dayYest#'
													LIMIT 1;
												</cfquery>
												<cfquery name="QStockCheckClaim" datasource="#parm.datasource#">
													SELECT psQty
													FROM tblPubStock
													WHERE psPubID=#i.pubID#
													AND psType='claim'
													AND psDate='#dayYest#'
													LIMIT 1;
												</cfquery>
												<cfset totReceived=val(QStockCheck.psQty)-val(QStockCheckClaim.psQty)>
												<cfif StructKeyExists(GrandTotalQty,i.pubID)>
													<cfset qty=StructFind(GrandTotalQty,i.pubID)>
													<cfif qty.Qty gte totReceived>
														<cfset totalUp=false>
														<cfif StructKeyExists(rnd2.pubTotalQty,i.pubID)>
															<cfset qty=StructFind(rnd2.pubTotalQty,i.pubID)>
															<cfset q.Qty=qty.Qty-i.Qty>
															<cfif q.Qty neq 0>
																<cfset StructUpdate(rnd2.pubTotalQty,i.pubID,q)>
															<cfelse>
																<cfset StructDelete(rnd2.pubTotalQty,i.pubID)>
															</cfif>
														</cfif>
													<cfelse>
														<cfset totalUp=true>
													</cfif>
												<cfelse>
													<cfset totalUp=true>
												</cfif>
											<cfelse>
												<cfset totalUp=true>
											</cfif>
											<cfif totalUp>
												<cfset ic=ic+1>
												<cfset style="">
												<cfif h.itemCount is 1 OR h.itemCount gt 3><cfset style=style&" noborder nowidth"></cfif>
												<cfif h.itemCount gt 1 AND h.itemCount eq ic><cfset style=style&" noborder"></cfif>
												<cfif h.itemCount eq 2><cfset style=style&" medwidth"></cfif>
												<div style="float:left;width:225px;padding:2px 0;margin:0 0 0 10px;">
													<span class="<cfif i.Holiday>holidaytitle</cfif>">#i.Title# <cfif i.Qty gt 1>(#i.Qty#)</cfif></span>
													<cfif i.Holiday>
														<span class="holiday-action">
															<cfif i.HolidayAction eq "cancel">
																<i>Cancelled! Do Not Deliver</i>
															<cfelseif i.HolidayAction eq "hold">
																<i>Hold Back! <cfif len(i.HolidayStart)>Deliver on #i.HolidayStart#<cfelse>Until Further Notice</cfif></i>
															<cfelseif i.HolidayAction eq "Stop">
																<i>Stop! Until <cfif len(i.HolidayStart)>#i.HolidayStart#<cfelse>Further Notice</cfif></i>
															</cfif>
														</span>
													<cfelseif i.HolidayAction eq "hold" AND len(i.HolidayStart)>
														<cfif StructKeyExists(GrandTotalQty,i.pubID)>
															<cfset qty=StructFind(GrandTotalQty,i.pubID)>
															<cfset q={}>
															<cfset q.Title=i.Title>
															<cfset q.Qty=qty.Qty+i.Qty>
															<cfset StructUpdate(GrandTotalQty,i.pubID,q)>
														<cfelse>
															<cfset q={}>
															<cfset q.Title=i.Title>
															<cfset q.Qty=i.Qty>
															<cfset StructInsert(GrandTotalQty,i.pubID,q)>
														</cfif>
													<cfelse>
														<cfif StructKeyExists(GrandTotalQty,i.pubID)>
															<cfset qty=StructFind(GrandTotalQty,i.pubID)>
															<cfset q={}>
															<cfset q.Title=i.Title>
															<cfset q.Qty=qty.Qty+i.Qty>
															<cfset StructUpdate(GrandTotalQty,i.pubID,q)>
														<cfelse>
															<cfset q={}>
															<cfset q.Title=i.Title>
															<cfset q.Qty=i.Qty>
															<cfset StructInsert(GrandTotalQty,i.pubID,q)>
														</cfif>
													</cfif>
												</div>
											</cfif>
										</cfloop>
									</td>
								</tr>
							</cfloop>
						</cfloop>
					</cfif>
				</table>
				<h1>#rnd2.roundTitle# Summary</h1>
				<table border="1" class="tableList" width="500" style="font-size: 12px;">
					<tr>
						<th align="left">Title</th>
						<th align="center" width="50">Qty</th>
					</tr>
					<cfset totalQty=0>
					<cfset sumList=StructSort(rnd2.pubTotalQty,"textnocase", "asc", "Title")>
					<cfloop array="#sumList#" index="index">
						<cfset i=StructFind(rnd2.pubTotalQty,index)>
						<cfset totalQty=totalQty+i.Qty>
						<tr>
							<td align="left">#i.Title#</td>
							<td align="center">#i.Qty#</td>
						</tr>
					</cfloop>
					<tr>
						<th align="left">Total Publications</th>
						<td align="center" width="50">#totalQty#</td>
					</tr>
					<tr>
						<th align="left">Total Drops</th>
						<td align="center">#count#<cfset totalDrops=totalDrops+count></td>
					</tr>
				</table>
				</cfdocumentsection>
				<div class="clear" style="page-break-before:always;"></div>
			</cfloop>
		</cfdocument>
		
        <cfcatch type="any">
           <cfdump var="#cfcatch#" label="cfcatch" expand="no">
        </cfcatch>
    </cftry>
		
</cfoutput>












