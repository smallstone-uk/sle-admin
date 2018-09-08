	
<cftry>
	<cfset callback=1>
	<cfsetting showdebugoutput="no" requesttimeout="300">
	<cfparam name="print" default="false">
	<cfset view="street">
	<cfset roundcount=0>
	<cfset totalDrops=0>
	<cfset GrandTotalDrops=0>
	<cfset totalUp=true>
	<cfset roundPage=0>
	
	<cfobject component="code/rounds6" name="rounds">

	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.roundDate=form.roundDate>
	<cfif StructKeyExists(form,"roundsTicked")><cfset parm.roundID=form.roundsTicked></cfif>
	<cfif StructKeyExists(form,"dispatchTicked")><cfset parm.dispatchTicked=form.dispatchTicked></cfif>
	<cfif StructKeyExists(form,"pubSelect")><cfset parm.pubSelect=form.pubSelect></cfif>
	<cfset parm.dispatch=StructKeyExists(form,"dispatchTicked")>
	<cfset parm.showSummaries=StructKeyExists(form,"showSummaries")>
	<cfset parm.showOverallSummary=StructKeyExists(form,"showOverallSummary")>
	<cfset parm.showRoundOrder=StructKeyExists(form,"showRoundOrder")>
	<cfset parm.showDumps=StructKeyExists(form,"showDumps")>
	
	<cfset roundList=rounds.LoadRoundList(parm)>
	<cfset drops=rounds.LoadRoundDrops(parm)>
	<cfset session.rounds.parms=parm>
	<cfset session.rounds.charges=drops.charge>
	<cfset grid = {}>
	
	<script type="text/javascript">
		$(document).ready(function() {
			$('.print').click(function(e) {
				Print();
				e.preventDefault();
			});
			$('#btnChargeRound').click(function(e) {
				var status=$(this).attr("data-status");
				if (status == "enabled") {
					ChargeRounds();
				}
				e.preventDefault();
			});
			$(function() {
				var $sidebar   = $(".round-btn"), 
					$window    = $(window),
					offset     = $sidebar.offset(),
					topPadding = 55;
			
				$window.scroll(function() {
					if ($window.scrollTop() > offset.top) {
						$sidebar.stop().animate({
							marginTop: $window.scrollTop() - offset.top + topPadding
						});
					} else {
						$sidebar.stop().animate({
							marginTop: 0
						});
					}
				});
			});
			LoadRoundChargedList();
		});
	</script>
	
	<cfoutput>
	<div class="round-btn no-print">
		<div class="rightnav" style="font-family:Arial, Helvetica, sans-serif;">
			<ul>
				<li>
					<a href="##" id="btnChargeRound"<cfif ArrayLen(drops.charge) is 0> data-status="disabled" class="disabled"<cfelse> data-status="enabled"</cfif>>
						<b>Charge Rounds</b>
						<span>#ArrayLen(drops.charge)# <cfif ArrayLen(drops.charge) is 1>charge<cfelse>charges</cfif></span>
					</a>
				</li>
				<li><a href="##" class="print">Quick Print</a></li>
			</ul>
			<div class="clear"></div>
		</div>
		<div id="roundChargedList"></div>
		<div class="clear"></div>
	</div>
	<div id="print-area">
		<cfloop array="#drops.rounds#" index="rounds">
			
			<!--- Round Setup --->
			<cfset count=0>
			<cfset view=rounds.roundview>
			<cfset roundcount=roundcount+1>
			<cfif view is "name">
				<cfset holWord="Hand Out">
				<cfset holCancel="On Holiday! Do Not Hand Out">
				<cfset holHold="Hold Back! Keep Back Until">
				<cfset holStop="Publication has been stopped">
				<cfset totWord="Customers">
			<cfelse>
				<cfset holWord="Deliver">
				<cfset holCancel="Cancelled">
				<cfset holHold="Hold Until ">
				<cfset holStop="Stopped ">
				<cfset totWord="Drops">
			</cfif>
			
			<!--- Round Header --->
			<!---<cfif roundPage gt 0><div style="page-break-before:always;"></div><cfset roundPage++></cfif>--->
			<!---<div id="pageFooter"></div>--->
			<div class="round-header">#DateFormat(parm.roundDate,"DDDD")# - #DateFormat(parm.roundDate,"DD/MM/YYYY")#</div>
			<h1>#rounds.roundTitle#</h1>
			<div style="clear:left;"></div>
			
			<cfif ArrayLen(rounds.list)>
				<cfloop array="#rounds.list#" index="street">
					<div class="street-wrap">
					
						<!--- Street Header --->
						<div class="street-title"><cfif view is "street">#street.StreetName#</cfif></div>
						<div class="street">
						
							<!--- Loop Drops --->
							<cfloop array="#street.houses#" index="house">
								<cfset count=count+1>
								<cfset GrandTotalDrops=GrandTotalDrops+1>
								<cfset countback=false>
								<div class="houses">
									<div id="row#house.ID#" class="house<cfif house.New> new</cfif>">
										<!--- Drop Title --->
										<div class="house-title">
											<cfif len(house.pay)><span class="pay">#house.pay#</span></cfif>
											<a href="clientDetails.cfm?row=0&ref=#house.ClientRef#" target="_blank">
												<cfif len(house.Name) AND len(house.Number)>#house.Name#, #house.Number#<cfelse>#house.Name##house.Number#</cfif>
											</a>
											<cfif len(house.Note)><span style="display:block;font-size:12px;color:##444;">#house.Note#</span></cfif>
										</div>
										
										<!--- Drop Items --->
										<div class="house-items">
											<ul class="<cfif ArrayLen(house.items) gt 3>vlist</cfif>">
												<cfloop array="#house.items#" index="i">
													<cfif len(i.Title) gt 15>
														<cfset cellWidth="220px">
													<cfelse>
														<cfset cellWidth="168px">
													</cfif>
													<li class="<cfif i.Holiday>holiday</cfif> #LCase(i.HolidayAction)#" style="width:#cellWidth#">
														
														<!---Item Title--->
														<span class="<cfif i.Holiday>holidaytitle</cfif>">
															#i.Title# <cfif i.Qty gt 1>(#i.Qty#)</cfif>
														</span>
														
														<!--- Item Holiday --->
														<cfif i.Holiday>
															<span class="holiday-action">
																<cfif i.HolidayAction eq "cancel">
																	<i>#holCancel#</i>
																	<cfif NOT countback>
																		<cfset count=count-1>
																		<cfset GrandTotalDrops=GrandTotalDrops-1>
																		<cfset countback=true>
																	</cfif>
																<cfelseif i.HolidayAction eq "hold">
																	<i>#holHold# <cfif len(i.HolidayStart)>#i.HolidayStart#<cfelse>Further Notice</cfif></i>
																<cfelseif i.HolidayAction eq "stop">
																	<cfif NOT countback>
																		<cfset count=count-1>
																		<cfset GrandTotalDrops=GrandTotalDrops-1>
																		<cfset countback=true>
																	</cfif>
																	<i>#holStop# <cfif len(i.HolidayStart)>Until #i.HolidayStart#</cfif></i>
																<cfelseif i.HolidayAction eq "bhHold">
																	<i>Bank Holiday-Hold</i>
																<cfelseif i.HolidayAction eq "bhCancel">
																	<i>Bank Holiday-Cancelled</i>
																</cfif>
															</span>
														<cfelseif i.HolidayAction eq "hold" AND len(i.HolidayStart)>
															<span class="holiday-action">
																#holWord# all held back #i.Title#'s today
															</span>
														</cfif>
														
													</li>
												</cfloop>											
											</ul>
										</div>
										
									</div>
								</div>
							</cfloop>
							
						</div>
						
						<!--- Street End --->
						<div style="clear:both;"></div>
					</div>
				</cfloop>
			</cfif>
			
			<!--- Round Summary --->
			<div class="clear"></div>
			<div class="summary" style="page-break-inside:avoid;<cfif NOT parm.showSummaries> display:none;</cfif>">
				<h1>#rounds.roundTitle# Summary  #DateFormat(parm.roundDate,"ddd DD/MM/YYYY")#</h1>
				<div class="clear"></div>
				<div class="pubTotalQty" style="text-align:center;">
					<table border="1" class="tableList minimal" width="500" style="font-size: 16px;">
						<tr>
							<th align="center" width="50">Qty</th>
							<th align="left">Title</th>
						</tr>
						<cfset totalQty=0>
						<cfset sumList=StructSort(rounds.TotalQty,"textnocase", "asc", "sort")>
						<cfloop array="#sumList#" index="index">
							<cfset i=StructFind(rounds.TotalQty,index)>
							<cfset totalQty=totalQty+i.Qty>
							<tr>
								<td align="center">#i.Qty#</td>
								<td align="left">#i.Title#</td>
							</tr>
						</cfloop>
						<tr>
							<td colspan="2">
								<table>
									<td align="center" width="50"><b>#totalQty#</b></td>
									<th align="left">Total Publications</th>
									<td align="center"><b>#count#</b><cfset totalDrops=totalDrops+count></td>
									<th align="left">Total #totWord#</th>
								</table>
							</td>
						</tr>
					</table>
				</div>
			</div>
			<cfset rounds.dropTotal = count>
			<cfset rounds.pubTotal = totalQty>
			<div style="page-break-before:always;"></div><cfif parm.showSummaries></cfif>
			<!--- Round End --->
		</cfloop>

		<!--- Overall Summary --->
		<!---<div style="page-break-before:always;"></div>--->
		<div class="summary" style="page-break-inside:avoid;<cfif NOT parm.showOverallSummary> display:none;</cfif>">
			<h1>Overall Summary  #DateFormat(parm.roundDate,"ddd DD/MM/YYYY")#</h1>
			<div class="clear"></div>
			<div class="pubTotalQty" style="text-align:center;">
				<table border="1" class="tableList minimal" width="500" style="font-size: 16px;">
					<tr>
						<th align="center" width="50">Qty</th>
						<th align="left">Title</th>
					</tr>
					<cfset totalQty=0>
					<cfset sumList=StructSort(drops.GrandTotalQty,"textnocase", "asc", "sort")>
					<cfloop array="#sumList#" index="index">
						
						<cfset i=StructFind(drops.GrandTotalQty,index)>
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
						<td align="center"><b>#GrandTotalDrops#</b></td>
						<th align="left">Total Customers</th>
					</tr>
				</table>
			</div>
		</div>
		
		<!--- Consolidated Summary --->
		<cfset pubArray = []>
		<cfloop collection="#drops.grandtotalQty#" item="pubkey">
			<cfset pub = StructFind(drops.grandtotalQty,pubkey)>
			<cfset ArrayAppend(pubArray,"#pub.sort#_#pubkey#")>
		</cfloop>
		<cfset ArraySort(pubArray,"text","asc")>
		<div class="summary" style="page-break-before:always;">
			<table border="1" class="tableList" width="700" style="font-size: 18px;">
				<tr>
					<th colspan="8" align="center">Publication Summary  #DateFormat(parm.roundDate,"ddd DD/MM/YYYY")#</th>
				</tr>
				<tr>
					<th>Publication</th>
					<cfloop array="#drops.rounds#" index="round">
						<th align="center">#round.roundTitle#</th>
					</cfloop>
					<th>Total</th>
					<th>Round<br />Shortages</th>
				</tr>
				<cfloop array="#pubArray#" index="pub">
					<cfset pubID = ListLast(pub,"_")>
					<tr>
						<td height="30">#ListFirst(ListRest(pub,"_"),"_")#</td><!---#ListFirst(ListRest(pub,"_"),"_")#--->
						<cfloop array="#drops.rounds#" index="round">
							<cfset rndPub = "#round.roundID#-#pubID#">
							<cfif StructKeyExists(round.totalQty,rndPub)>
								<cfset pubQty = StructFind(round.totalQty,rndPub).qty>
							<cfelse><cfset pubQty = ""></cfif>
							<td align="center">#pubQty#</td>
						</cfloop>
						<td align="center">
							<cfset grandQty = StructFind(drops.grandTotalQty,pubID).qty>
							#grandQty#
						</td>
						<td></td>
					</tr>
				</cfloop>
				<cfset grandTotPubs = 0>
				<cfset grandTotDrops = 0>
				<tr>
					<th>Total Publications</th>
					<cfloop array="#drops.rounds#" index="round">
						<cfset grandTotPubs += round.pubTotal>
						<th align="center">#round.pubTotal#</th>
					</cfloop>
					<th>#grandTotPubs#</th>
					<th></th>
				</tr>
				<tr>
					<th>Total Drops</th>
					<cfloop array="#drops.rounds#" index="round">
						<cfset grandTotDrops += round.droptotal>
						<th align="center">#round.droptotal#</th>
					</cfloop>
					<th>#grandTotDrops#</th>
					<th></th>
				</tr>
			</table>
			<h3>
				<br />
				<strong>Drivers:</strong> If any round is short, please make a note in the shortages column.<br />
				<strong>Shop Staff:</strong> Please claim for any round shortages as well.
			</h3>
		</div>
		
		<!--- include shop stock sheet if all rounds printed--->
		<cfif roundcount eq ArrayLen(roundList.rounds)>
			<cfinclude template="pubNewsPrices.cfm">
		<cfelse>
			<h1>STOCK MOVEMENT REPORT WAS NOT PRINTED</h1>
			<p>All rounds must be included in the print run for this report to be included.</p>
		</cfif>
		<cfset dayNo=DayofWeek(parm.roundDate)-1>
		<cfif dayNo eq 0>
			<div style="page-break-before:always;"></div>
			<cfinclude template="rounds5ShopSaveSheet.cfm">
		</cfif>
		</div>
	</div>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
