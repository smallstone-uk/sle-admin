<!DOCTYPE html>
<html>
<head>
<title>Rounds</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link rel="stylesheet" type="text/css" href="css/rounds.css"/>
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
</head>

<cfoutput>
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfparam name="roundDate" default="#DateFormat(DateAdd("d",1,Now()),"yyyy-mm-dd")#">
				<cfparam name="roundType" default="morning">
				<cfparam name="roundNo" default="2">
				<cfparam name="roundsTicked" default="">
				<cfif application.site.showdumps><cfdump var="#form#" label="form" expand="no"></cfif>
				<cfobject component="code/functions" name="rnd">
				<cfset roundList={}>
				<cfset parms={}>
				<cfset parms.datasource=application.site.datasource1>
				<cfif StructKeyExists(form,"btnRun")>
					<cfset parms.roundType=form.roundType>
					<cfset roundList=rnd.LoadRoundList(parms)>
				</cfif>
				<cfif StructKeyExists(form,"btnPrint")>
					<cfset parms.roundType=form.roundType>
					<cfset roundList=rnd.LoadRoundList(parms)>
				</cfif>
				<cfif StructKeyExists(form,"btnSetOrder")>
					<cfset parms.form=form>
					<cfset parms.roundType=roundType>
					<cfset saveOrder=rnd.SaveDropOrder(parms)>
					<cfset roundList=rnd.LoadRoundList(parms)>
				</cfif>
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Generate Rounds
							<span>
								<input type="submit" name="btnRun" value="View" />
								<input type="submit" name="btnPrint" value="Print" />
							</span>
						</div>
						<table border="0">
							<tr>
								<td><b>Date</b></td>
								<td>
									<select name="roundDate">
										<cfloop from="-7" to="7" index="i">
											<cfset nextDate=DateAdd("d",i,Now())>
											<cfset dateStr=DateFormat(nextDate,'yyyy-mm-dd')>
											<option value="#dateStr#"<cfif roundDate eq dateStr> selected="selected"</cfif>>#DateFormat(nextDate,"ddd dd-mmm-yyyy")#</option>								
										</cfloop>
									</select>
								</td>
								<td><b>Round Type</b></td>
								<td>
									<select name="roundType">
										<option value="morning"<cfif roundType eq "morning"> selected="selected"</cfif>>Morning</option>
										<option value="evening"<cfif roundType eq "evening"> selected="selected"</cfif>>Evening</option>
										<option value="sunday"<cfif roundType eq "sunday"> selected="selected"</cfif>>Sunday</option>
									</select>
									&nbsp; <input type="checkbox" name="chgAcct" value="1" /> Charge Accounts?
									&nbsp; <input type="checkbox" name="hideRound" value="1" /> Hide Round Report?
								</td>
							</tr>
							<cfif StructKeyExists(roundList,"rounds")>
							<tr>
								<td valign="top"><b>Rounds</b></td>
								<td colspan="3">
									<cfloop array="#roundList.rounds#" index="item">
										<cfset checked=ListFind(roundsTicked,item.rndRef,",")>
										<label><input type="checkbox" name="roundsTicked" value="#item.rndRef#" <cfif checked> checked="checked"</cfif> />#item.rndRef# #item.rndTitle#</label>
									</cfloop>
								</td>
							</tr>
							</cfif>
						</table>
					</form>
				</div>
				<cfif StructKeyExists(form,"btnRun")>
					<form method="post" enctype="multipart/form-data">
						<cfif StructKeyExists(form,"fieldnames") AND StructKeyExists(form,"roundsTicked")>
							<cfif StructKeyExists(form,"roundsTicked")>
								<input type="submit" name="btnSetOrder" value="Save Order" id="SaveOrderBtn" style="display:none;">
								<cfsetting requesttimeout="900">
								<cfloop list="#form.roundsTicked#" index="roundNo">
									<cfset parms.roundNo=roundNo>
									<cfset parms.roundDate=form.roundDate>
									<cfset parms.chargeAccts=StructKeyExists(form,"chgAcct")>
									<cfset parms.dayNo=DayofWeek(parms.roundDate)-1>
									<cfif parms.dayNo eq 0><cfset parms.dayNo=7></cfif>
									<cfif roundType eq "sunday">
										<cfset parms.dayNo=7>
									<cfelseif parms.dayNo eq 7 AND roundType neq "sunday">
										<cfset parms.dayNo=1>
									</cfif>
									<cfif application.site.showdumps><cfdump var="#roundList#" label="roundList" expand="no"></cfif>
									<cfset roundData=rnd.LoadRoundData(parms)>
									<cfif StructKeyExists(roundData,"streets")>
										<cfset streetcount=0>
										<cfset dropcount=0>
										<script type="text/javascript">
											$(document).ready(function() {
												$(".street-#roundData.roundNo#").tableDnD({
													onDrop: function() {
														$('.orderItem').each(function(index) {
															$(this).val(index);
														});
														$("##SaveOrderBtn").show();
													}
												});
												$(".house-#roundData.roundNo#").tableDnD({
													onDrop: function() {
														$('.orderItem').each(function(index) {
															$(this).val(index);
														});
														$("##SaveOrderBtn").show();
													}
												});
											});
										</script>
										<cfif parms.chargeAccts>
											<cfset mode="ACCOUNTS CHARGED">
										<cfelse><cfset mode="LIST ONLY - DO NOT USE ON ROUNDS"></cfif>
										<h1>#roundData.roundNo# - #roundData.roundName# &nbsp - #mode#</h1>
										<cfif NOT StructKeyExists(form,"hideRound")>
											<table border="0" class="roundTable street-#roundData.roundNo#">
												<cfloop array="#roundData.streets#" index="street">
													<cfif street.drops gt 0>
														<cfset streetcount=streetcount+1>
														<tr id="#streetcount#">
															<td>
																<table border="0" class="streetTable house-#roundData.roundNo#">
																	<tr class="nodrag nodrop">
																		<td colspan="2" class="street">
																			#street.name# <span>#street.drops# #Left("drops",4+int(street.drops gt 1))#</span>
																			<div class="drops">
																				<cfloop array="#street.houses#" index="drop">
																					<cfset dropcount=dropcount+1>
																					<tr id="#drop.Order#" class="dropHandle">
																						<td class="house" width="300">
																							<a href="clientEdit.cfm?rec=#drop.HouseID#" target="_blank">#drop.house#</a>
																							<a href="mapview.cfm?drop=#drop.HouseID#" target="_blank" class="map" id="map#drop.ID#" title="Find on map"></a>
																							<input type="hidden" name="riID" value="riOrder_#drop.ID#">
																							<input type="hidden" class="orderItem" name="riOrder_#drop.ID#" value="#drop.Order#" id="ord#drop.Order#"><br>
																						</td>
																						<td class="publication nodrag nodrop" width="500" style="cursor:default !important;">
																							<cfloop array="#drop.cons#" index="media">
																								<span><b><cfif media.qty gt 1>(#media.qty#)</cfif></b>#media.title# (#media.action#)</span>
																							</cfloop>
																						</td>
																					</tr>
																					<script type="text/javascript">
																						$("###drop.Order#").hover(
																						  function () {
																							$("##map#drop.ID#").show();
																						  },
																						  function () {
																							$("##map#drop.ID#").hide();
																						  }
																						);
																					</script>
																				</cfloop>
																			</div>
																		</td>
																	</tr>
																</table>
															</td>
														</tr>
													</cfif>
												</cfloop>
											</table>
										</cfif>
										<h1>Summary</h1>
										<table class="tableList" border="1">
											<tr>
												<th align="left">Title</th>
												<th align="right">Retail</th>
												<th align="right">Count</th>
												<th align="right">Value</th>
												<th align="right">Trade</th>
												<th align="right">Profit</th>
											</tr>
											<cfset totValue=0>
											<cfset totTrade=0>
											<cfset totProfit=0>
											<cfset titles=ListSort(StructKeyList(roundData.pubs,","),"text","asc",",")>
											<cfloop list="#titles#" index="key">
												<cfset pubby=StructFind(roundData.pubs,key)>
												<cfset totValue=totValue+pubby.value>
												<cfset totTrade=totTrade+pubby.trade>
												<cfset totProfit=totProfit+pubby.value-pubby.trade>
												<tr>
													<td align="left">#key#</td>
													<td align="right">#DecimalFormat(pubby.retail)#</td>
													<td align="right">#pubby.qty#</td>
													<td align="right">#DecimalFormat(pubby.value)#</td>
													<td align="right">#DecimalFormat(pubby.trade)#</td>
													<td align="right">#DecimalFormat(pubby.value-pubby.trade)#</td>
												</tr>
											</cfloop>
											<tr>
												<td align="left" colspan="2">TOTALS</td>
												<td align="right"><strong>#roundData.roundTitleCount#</strong></td>
												<td align="right"><strong>#DecimalFormat(totValue)#</strong></td>
												<td align="right"><strong>#DecimalFormat(totTrade)#</strong></td>
												<td align="right"><strong>#DecimalFormat(totProfit)#</strong></td>
											</tr>
											<tr>
												<td colspan="2"><b style="font-size:12px;">#roundData.roundTitleCount# titles for #roundData.dropCount# drops</b></td>
											</tr>
										</table>
										
										<table class="tableList">
											<tr>
												<th align="left">Delivery Code</th>
												<th align="right">Drop Count</th>
												<th align="right">Charge</th>
											</tr>
											<cfset dropCount=0>
											<cfset delIncome=0>
											<cfset titles=ListSort(StructKeyList(roundData.charges,","),"text","asc",",")>
											<cfloop list="#titles#" index="key">
												<cfset delchg=StructFind(roundData.charges,key).charge>
												<cfset delcount=StructFind(roundData.charges,key).count>
												<cfset delIncome=delIncome+delchg>
												<cfset dropCount=dropCount+delcount>
												<tr>
													<td align="center">#key#</td>
													<td align="center">#delcount#</td>
													<td align="right">#DecimalFormat(delchg)#</td>
												</tr>
											</cfloop>
											<tr>
												<td>&nbsp;</td>
												<td align="center"><strong>#dropCount#</strong></td>
												<td align="right"><strong>#DecimalFormat(delIncome)#</strong></td>
											</tr>
										</table>
										<h1>Round Gross Profit for this day: &pound;#DecimalFormat(delIncome+totProfit)#</h1>
									</cfif>
									<cfif application.site.showdumps><cfdump var="#roundData#" label="roundData" expand="false"></cfif>
								</cfloop>
							</cfif>
						</cfif>
					</form>
				</cfif>
				<cfif StructKeyExists(form,"btnPrint")>
					<cfdocument 
						permissions="allowcopy,AllowPrinting" 
						orientation="portrait" 
						mimetype="text/html"
						saveAsName="SLE Round" 
						localUrl="yes" 
						format="PDF" 
						fontEmbed="yes" 
						userpassword=""
						encryption="128-bit" 
						margintop="1.6" 
						marginleft="0" 
						marginright="0" 
						marginbottom="1.6" 
						unit="cm"> 
						<cfif StructKeyExists(form,"fieldnames") AND StructKeyExists(form,"roundsTicked")>
							<cfif StructKeyExists(form,"roundsTicked")>
								<cfloop list="#form.roundsTicked#" index="roundNo">
									<cfset parms.roundNo=roundNo>
									<cfset parms.roundDate=form.roundDate>
									<cfset parms.dayNo=DayofWeek(parms.roundDate)-1>
									<cfif parms.dayNo eq 0><cfset parms.dayNo=7></cfif>
									<cfif roundType eq "sunday">
										<cfset parms.dayNo=7>
									<cfelseif parms.dayNo eq 7 AND roundType neq "sunday">
										<cfset parms.dayNo=1>
									</cfif>
									<cfset roundData=rnd.LoadRoundData(parms)>
									<cfif StructKeyExists(roundData,"streets")>
										<cfset streetcount=0>
										<cfset dropcount=0>
										<cfdocumentsection name="#roundData.roundName#">
											<style type="text/css">
												html, body, div, span, applet, object, iframe, 
												h1, h2, h3, h4, h5, h6, p, blockquote, pre, 
												a, abbr, acronym, address, big, cite, code, 
												del, dfn, em, font, img, ins, kbd, q, s, samp, 
												small, strike, strong, sub, sup, tt, var, 
												dl, dt, dd, ol, ul, li, 
												fieldset, form, label, legend, 
												table, caption, tbody, tfoot, thead, tr, th, td{ 
												  margin:0;padding:0;font-family:Arial, Helvetica, sans-serif;font-size:14px;
												}
												h1 {line-height: 22px;font-size: 18px;margin:0 0 10px 0;padding:0; text-align:center;}
												p {font-size: 12px;padding:0 0 10px 0;line-height: 20px;}
												table.tableList {border: 1px solid ##CCC;font-size: 11px;}
												table.tableList th {padding:4px 5px;background:##eee;border: 1px solid ##CCC;}
												table.tableList td {padding:2px 5px;border: 1px solid ##CCC;}
												th, td {padding:4px;}
												label {display:block;}
												.roundTable {font-size:12px;}
												.streetTable {margin: 0 0 10px 0;}
												.street {font-size:13px;font-weight:bold;padding:4px;border-bottom:2px solid ##666;}
												.street span {float: right;font-size: 12px;text-transform: capitalize;color: ##444;font-weight: normal;}
												.house {font-size: 12px;font-weight: bold;padding: 4px 4px 4px 4px;border-bottom: 1px dashed ##666;border-right: 1px solid ##666;text-align: right;width: 230px;}
												.publication {border-bottom: 1px dashed ##333;padding:0;font-size: 11px;}
												.publication span {display: block;float: left;width: 145px;font-size: 11px;padding:0;margin:0 5px 6px 0;border-right: 1px solid ##666;}
												.publication span b {color: ##000;font-size: 11px;}
											</style>
											<cfdocumentitem type="header">
												<table width="100%" border="0" cellpadding="2" cellspacing="0">
													<tr>
														<td align="left"><b>#DateFormat(parms.roundDate,"DDDD DD MMMM YYYY")#</b></td>
														<td align="right">Page: <b>#cfdocument.currentsectionpagenumber# of #cfdocument.totalsectionpagecount#</b></td>
													</tr>
													<tr>
														<td align="left">Round: <b>#roundData.roundNo#</b></td>
														<td align="right"></td>
													</tr>
												</table>
											</cfdocumentitem>
											<h1>#roundData.roundName# <!---#application.site.days[dayNo]#---></h1>
											<table border="0" class="roundTable street-#roundData.roundNo#">
											<cfloop array="#roundData.streets#" index="street">
												<cfif street.drops gt 0>
													<cfset streetcount=streetcount+1>
													<tr id="#streetcount#">
														<td>
															<table border="0" class="streetTable house-#roundData.roundNo#">
																<tr class="nodrag nodrop">
																	<td colspan="2" class="street">#street.name# <span>#street.drops# #Left("drops",4+int(street.drops gt 1))#</span></td>
																</tr>
																<div class="drops">
																	<cfloop array="#street.houses#" index="drop">
																		<cfset dropcount=dropcount+1>
																		<tr id="#drop.Order#" class="dropHandle">
																			<td class="house" width="300">#drop.house#</td>
																			<td class="publication nodrag nodrop" width="500" style="cursor:default !important;">
																				<cfloop array="#drop.cons#" index="media">
																					<cfif len(media.title)><span>#media.title#<b><cfif media.qty gt 1>&nbsp;(#media.qty#)</cfif></b></span></cfif>
																				</cfloop>
																			</td>
																		</tr>
																	</cfloop>
																</div>
															</table>
														</td>
													</tr>
												</cfif>
											</cfloop>
											</table>
										</cfdocumentsection>
									</cfif>
								</cfloop>
								
								<h1>Summary</h1>
								<table class="tableList">
									<cfset titles=ListSort(StructKeyList(roundData.pubs,","),"text","asc",",")>
									<cfloop list="#titles#" index="key">
										<tr>
											<th align="left">#key#</th>
											<td align="left">#StructFind(roundData.pubs,key)#</td>
										</tr>
									</cfloop>
									<tr>
										<td colspan="2"><b style="font-size:12px;">#roundData.roundTitleCount# titles for #roundData.dropCount# drops</b></td>
									</tr>
								</table>
							</cfif>
						</cfif>
					</cfdocument>
				</cfif>
				<div class="clear"></div>
			</div>
		</div>
		<cfinclude template="sleFooter.cfm">
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
</body>
</cfoutput>
</html>
