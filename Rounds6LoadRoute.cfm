<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">
<cfset testmode=0>
<cfset showPayDetails=false>
<cfset view="street">
<cfset GrandTotalQty={}>
<cfset StructClear(GrandTotalQty)>

<cfobject component="code/rounds" name="rounds">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.roundID=form.roundsTicked>
<cfset parm.dispatch=StructKeyExists(form,"dispatchTicked")>
<cfset parm.showSummaries=StructKeyExists(form,"showSummaries")>
<cfset parm.showOverallSummary=StructKeyExists(form,"showOverallSummary")>
<cfset parm.showRoundOrder=StructKeyExists(form,"showRoundOrder")>
<cfset drops=rounds.LoadRoundDrops(parm)>

<!---<cfdump var="#parm#" label="parm" expand="no">
<cfdump var="#drops#" label="drops" expand="no"><cfexit>--->

<script type="text/javascript">
	$(document).ready(function() {
		function PrintArea() {
			$('#print-area').printArea();
		};
		function LoadRoundChargedList() {
			$.ajax({
				type: 'GET',
				url: 'RoundLoadCharged.cfm',
				success:function(data){
					$('#roundChargedList').html(data);
				}
			});
		};
		$('#btnChargeRound').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'Rounds6ChargeItems.cfm',
				<cfoutput>
				data : {
					"date":"#LSDateFormat(parm.form.roundDate,'yyyy-mm-dd')#",
					"rounds":"#parm.form.roundsTicked#",
					"dispatch":"#parm.dispatch#",
					"showSummaries":"#parm.showSummaries#",
					"showOverallSummary":"#parm.showOverallSummary#",
					"showRoundOrder":"#parm.showRoundOrder#"
				},
				</cfoutput>
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Charging rounds, please wait...").fadeIn();
					$('#btnChargeRound').prop("disabled",true);
				},
				success:function(data){
					$('#chargedump').html(data);
					$('#loading').fadeOut();
					$('#btnChargeRound').prop("disabled",false);
					LoadRoundChargedList();
					PrintArea();
				},
				error:function(data){
					$('#chargedump').html(data);
					$('#loading').fadeOut();
					$('#btnChargeRound').prop("disabled",false);
				}
			});
			event.preventDefault();
		});
		$('.print').click(function(event) {
			PrintArea();
			event.preventDefault();
		});
		LoadRoundChargedList();
	});
</script>

<cfoutput>
    <cftry>
		<div id="chargedump" style="margin:10px 0;"></div>
		<div id="print-area">
			<input type="hidden" name="date" id="date" value="#LSDateFormat(parm.form.roundDate,'yyyy-mm-dd')#" />
			<input type="hidden" name="rounds" id="rounds" value="#parm.form.roundsTicked#" />
			<div class="round-btn no-print">
				<div class="rightnav" style="font-family:Arial, Helvetica, sans-serif;">
					<ul>
						<li><a href="##" id="btnChargeRound"><b>Charge Rounds</b><cfif testmode is 1><span>Test Mode</span><cfelse><span>Automatically prints rounds</span></cfif></a></li>
						<li><a href="##" class="print">Quick Print</a></li>
					</ul>
				</div>
				<div id="roundChargedList"></div>
			</div>
			<cfset roundcount=0>
			<cfset totalDrops=0>
			<cfset totalUp=true>
			<cfloop array="#drops.rounds#" index="rnd">
				<cfset count=0>
				<cfset view=rnd.roundview>
				
				<cfif view is "name">
					<cfset holWord="Hand Out">
					<cfset holCancel="On Holiday! Do Not Hand Out">
					<cfset holHold="Hold Back! Keep Back Until">
					<cfset holStop="Stop! Publication has been permanently stopped">
					<cfset totWord="Customers">
				<cfelse>
					<cfset holWord="Deliver">
					<cfset holCancel="Cancelled! Do Not Deliver">
					<cfset holHold="Hold Back! Deliver on ">
					<cfset holStop="Stop! Publication has been permanently stopped">
					<cfset totWord="Customers">
				</cfif>
				<cfset roundcount=roundcount+1>
				<cfset dayYest=DateFormat(DateAdd("d",-1,parm.form.roundDate),"yyyy-mm-dd")>
				<div class="round-header">
					#DateFormat(parm.form.roundDate,"DDDD")# - #DateFormat(parm.form.roundDate,"DD/MM/YYYY")#
				</div>
				<h1>#rnd.roundTitle#</h1>
				<div style="clear:left;"></div>
				<cfif ArrayLen(rnd.list)>
					<cfloop array="#rnd.list#" index="d">
						<div style="float:left;page-break-inside:avoid;">
						<span class="pageNumber"></span>
							<div class="street-title"><cfif view is "street">#d.StreetName#</cfif></div>
							<div class="street" style="page-break-inside:avoid;">
								<cfloop array="#d.houses#" index="h">
									<cfset count=count+1>
									<div class="houses">
										<div id="row#h.ID#" style="float:left;"<cfif h.New> class="new"</cfif>>
											<div class="house-title">
												<cfif len(h.pay)><span style="float: left;font-size: 11px;width: 96px;text-align: left;line-height: 18px;">#h.pay#</span></cfif>
												<a href="clientDetails.cfm?row=0&ref=#h.ClientRef#" target="_blank">
													<cfif len(h.Name) AND len(h.Number)>
														#h.Name#, #h.Number#
													<cfelse>
														#h.Name##h.Number#
													</cfif>
												</a>
												<cfif len(h.Note)><span style="display:block;font-size:12px;color:##444;">#h.Note#</span></cfif>
											</div>
											<div class="house-items">
												<ul class="<cfif h.itemCount gt 3>vlist</cfif>">
													<cfset ic=0>
													<cfloop array="#h.items#" index="i">											
														<cfif i.pubGroup is "Magazine">
															<cfset sortGroup="x#i.pubGroup#">
														<cfelse>
															<cfset sortGroup=i.pubGroup>
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
														<cfif totalUp>
															<cfset ic=ic+1>
															<cfset style="">
															<cfif h.itemCount is 1 OR h.itemCount gt 3><cfset style=style&" noborder nowidth"></cfif>
															<cfif h.itemCount gt 1 AND h.itemCount eq ic><cfset style=style&" noborder"></cfif>
															<cfif h.itemCount eq 2><cfset style=style&" medwidth"></cfif>
															<li class="<cfif i.Holiday>holiday</cfif>#style# #LCase(i.HolidayAction)#">
																<span class="<cfif i.Holiday>holidaytitle</cfif>">#i.Title# <cfif i.Qty gt 1>(#i.Qty#)</cfif></span>
																<cfif i.Holiday>
																	<span class="holiday-action">
																		<cfif i.HolidayAction eq "cancel">
																			<i>#holCancel#</i>
																		<cfelseif i.HolidayAction eq "hold">
																			<i>#holHold# <cfif len(i.HolidayStart)>#i.HolidayStart#<cfelse>Further Notice</cfif></i>
																		<cfelseif i.HolidayAction eq "Stop">
																			<i>#holStop# <cfif len(i.HolidayStart)>Until #i.HolidayStart#</cfif></i>
																		</cfif>
																	</span>
																<cfelseif i.HolidayAction eq "hold" AND len(i.HolidayStart)>
																	<span class="holiday-action">
																		#holWord# all held back #i.Title#'s today
																	</span>
																	<cfif StructKeyExists(GrandTotalQty,i.pubID)>
																		<cfset qty=StructFind(GrandTotalQty,i.pubID)>
																		<cfset q={}>
																		<cfset q.Sort="#sortGroup##i.Title#">
																		<cfset q.Title=i.Title>
																		<cfset q.Qty=qty.Qty+i.Qty>
																		<cfset StructUpdate(GrandTotalQty,i.pubID,q)>
																	<cfelse>
																		<cfset q={}>
																		<cfset q.Sort="#sortGroup##i.Title#">
																		<cfset q.Title=i.Title>
																		<cfset q.Qty=i.Qty>
																		<cfset StructInsert(GrandTotalQty,i.pubID,q)>
																	</cfif>
																<cfelse>
																	<cfif StructKeyExists(GrandTotalQty,i.pubID)>
																		<cfset qty=StructFind(GrandTotalQty,i.pubID)>
																		<cfset q={}>
																		<cfset q.Sort="#sortGroup##i.Title#">
																		<cfset q.Title=i.Title>
																		<cfset q.Qty=qty.Qty+i.Qty>
																		<cfset StructUpdate(GrandTotalQty,i.pubID,q)>
																	<cfelse>
																		<cfset q={}>
																		<cfset q.Sort="#sortGroup##i.Title#">
																		<cfset q.Title=i.Title>
																		<cfset q.Qty=i.Qty>
																		<cfset StructInsert(GrandTotalQty,i.pubID,q)>
																	</cfif>
																</cfif>
															</li>
														</cfif>
													</cfloop>
												</ul>
											</div>
										</div>
									</div>
								</cfloop>
								<div class="clear"></div>
							</div>
						</div>
					</cfloop>
					<div class="clear"></div>
					
					<div class="summary" style="page-break-inside:avoid;<cfif NOT parm.showSummaries> display:none;</cfif>">
						<h1>#rnd.roundTitle# Summary</h1>
						<div class="clear"></div>
						<div class="pubTotalQty" style="text-align:center;">
							<table border="1" class="tableList minimal" width="500" style="font-size: 16px;">
								<tr>
									<th align="center" width="50">Qty</th>
									<th align="left">Title</th>
								</tr>
								<cfset totalQty=0>
								<cfset sumList=StructSort(rnd.pubTotalQty,"textnocase", "asc", "sort")>
								<cfloop array="#sumList#" index="index">
									<cfset i=StructFind(rnd.pubTotalQty,index)>
									<cfset totalQty=totalQty+i.Qty>
									<tr>
										<td align="center">#i.Qty#</td>
										<td align="left">#i.Title#</td>
									</tr>
								</cfloop>
								<tr>
									<td align="center" width="50"><b>#totalQty#</b></td>
									<th align="left">Total Publications</th>
								</tr>
								<tr>
									<td align="center"><b>#count#</b><cfset totalDrops=totalDrops+count></td>
									<th align="left">Total #totWord#</th>
								</tr>
								<cfif showPayDetails>
									<cfif view is "street">
										<tr>
											<td align="right" style="font-weight:bold;"><b>&pound;#DecimalFormat(rnd.roundTotal)#</b></td>
											<th align="left">Delivery Total</th>
										</tr>
									</cfif>
									<tr>
										<td align="right" style="font-weight:bold;"><b>&pound;#DecimalFormat(rnd.pubTotal)#</b></td>
										<th align="left">Publication Total</th>
									</tr>
								</cfif>
							</table>
						</div>
					</div>
					<!---<cfif view is "name">
						<div style="clear: both;text-align: center;font-weight: bold;font-size: 16px;padding: 10px 0;">
							<h3>Pay on Collect Customers</h3>
							Please make sure all Pay on Collect customers pay for thier publication(s).<br />Accepted payment is Voucher, Cash or Card.
						</div>
					</cfif>--->
				<cfelse>
					<p>No drops found</p>
				</cfif>
				<cfif parm.showSummaries><div class="clear" style="page-break-before:always;"></div></cfif>
			</cfloop>
			
			<cfif parm.showOverallSummary>
				<div class="summary" style="page-break-inside:avoid;">
					<h1>Overall Delivery Summary</h1>
					<div class="clear"></div>
					<div class="pubTotalQty" style="text-align:center;">
						<table border="1" class="tableList minimal" width="500" style="font-size: 16px;">
							<tr>
								<th align="center" width="50">Qty</th>
								<th align="left">Title</th>
							</tr>
							<cfset totalQty=0>
							<cfset totList=StructSort(GrandTotalQty,"textnocase", "asc", "sort")>
							<cfloop array="#totList#" index="index">
								<cfset i=StructFind(GrandTotalQty,index)>
								<cfset totalQty=totalQty+i.Qty>
								<tr>
									<td align="center">#i.Qty#</td>
									<td align="left">#i.Title#</td>
								</tr>
							</cfloop>
							<tr>
								<td align="center" width="50"><b>#totalQty#</b></td>
								<th align="left">Total Publications</th>
							</tr>
							<tr>
								<td align="center" width="50"><b>#totalDrops#</b></td>
								<th align="left">Total Drops</th>
							</tr>
						</table>
					</div>
				</div>
			</cfif>
			
			<cfif parm.dispatch>
				<cfloop list="#form.dispatchTicked#" delimiters="," index="dis">
					<div class="clear" style="page-break-before:always;"></div>
					<cfset parm.Date=LSDateFormat(parm.form.roundDate,"yyyy-mm-dd")>
					<cfset parm.ID=dis>
					<cfset Load=rounds.LoadDispatchNote(parm)>
					
					<cfif NOT ArrayLen(Load.list) AND dis is 6391 OR dis is 2291><cfelse>
						<h1 style="display:block;">#Load.ClientName# Dispatch Note</h1>
						<div class="clear" style="padding:4px 0;"></div>
						<table<cfif dis is 6391> border="1"</cfif> class="<cfif dis is 6391>tableList</cfif> morespace" style="font-size:14px;">
							<tr>
								<cfif dis is 6391>
									<th align="right">Date Supplied</th>
									<td colspan="2"><strong>#LSDateFormat(parm.Date,"dd/mm/yyyy")#</strong></td>
									<th colspan="6">Stock Management</th>
								<cfelse>
									<td colspan="2"><strong>#LSDateFormat(parm.Date,"dd/mm/yyyy")#</strong></td>
								</cfif>
							</tr>
							<tr>
								<cfif dis is 6391>
									<th width="200" align="left">Publication</th>
									<th width="50" align="right">Price</th>
									<th width="50" align="center">Qty<br>Supplied</th>
									<th width="60">&nbsp;</th>
									<th width="60">&nbsp;</th>
									<th width="50">Qty<br>Returned</th>
									<th width="50">Qty<br>Wasted</th>
									<th width="50">Qty<br>Sold</th>
									<th width="50">Value<br>Sold</th>
								<cfelse>
									<th width="50" align="center">Qty</th>
									<th width="200" align="left">Publication</th>
								</cfif>
							</tr>
							<cfif dis is 6391>
								<cfset colspan=9>
							<cfelse>
								<cfset colspan=2>
							</cfif>
							<cfset group="">
							<cfset totalDis=0>
							<cfset totalDisQty=0>
							<cfloop array="#Load.list#" index="item">
								<cfset i=StructFind(load.group,item)>
								<cfif dis is 6391>
									<cfif i.group neq group>
										<cfset group=i.group>
										<tr>
											<td align="left" colspan="#colspan#" style="background:##ccc;"><strong>#i.group#</strong></td>
										</tr>
									</cfif>
								</cfif>
								<cfset totalDis=totalDis+(i.Price*i.Qty)>
								<cfset totalDisQty=totalDisQty+i.Qty>
								<tr>
									<cfif dis is 6391>
										<td align="left">#i.Title#</td>
										<td align="right">&pound;#DecimalFormat(i.Price)#</td>
										<td align="center">#i.Qty#</td>
										<td>&nbsp;</td>
										<td>&nbsp;</td>
										<td<cfif i.Group is "News" AND i.Type neq "Weekly"> style="background:##999;"</cfif>>&nbsp;</td>
										<td>&nbsp;</td>
										<td>&nbsp;</td>
										<td>&nbsp;</td>
									<cfelse>
										<td align="center">#i.Qty#</td>
										<td align="left">#i.Title#</td>
									</cfif>
								</tr>
							</cfloop>
							<cfif dis is 6391>
								<tr>
									<th align="right"><strong>Total</strong></th>
									<td align="right"><strong>&pound;#DecimalFormat(totalDis)#</strong></td>
									<td align="center"><strong>#totalDisQty#</strong></td>
									<th colspan="6"></th>
								</tr>
							</cfif>
						</table>
					</cfif>
				</cfloop>
			</cfif>
		</div>
		<div class="clear"></div>

        <cfcatch type="any">
            <cfdump var="#cfcatch#" label="cfcatch" expand="no">
        </cfcatch>
    </cftry>
</cfoutput>
