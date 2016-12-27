<!DOCTYPE html>
<html>
<head>
<title>Admin</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<script type="text/javascript" src="common/scripts/common.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
</head>

<cfset search={}>
<cfif StructKeyExists(URL,"restartForm")>
	<cfset StructDelete(session,"pubSearch")>
</cfif>
<cfif StructKeyExists(form,"fieldnames") AND StructKeyExists(form,"srchRefFrom")>	<!--- is pubsearch form--->
	<cfset search=Duplicate(form)>
	<cfset search.skipUnordered=StructKeyExists(form,"skipUnordered")>
	<cfset search.blockEdit=StructKeyExists(form,"blockEdit")>
	<cfset search.simpleList=StructKeyExists(form,"simpleList")>
	<cfset session.pubSearch=search>
<cfelseif StructKeyExists(session,"pubSearch")>
	<cfset search=session.pubSearch>
<cfelse>
	<cfset search.srchRefFrom="">
	<cfset search.srchRefTo="">
	<cfset search.srchTitle="">
	<cfset search.srchType="">
	<cfset search.srchCategory="">
	<cfset search.srchArrival="">
	<cfset search.srchGroup="">
	<cfset search.srchSort="">
	<cfset search.skipUnordered=0>
	<cfset search.blockEdit=0>
	<cfset search.simpleList=0>
	<cfset session.pubSearch=search>
</cfif>

<cfobject component="code/functions" name="pubs">
<cfset parms.datasource=application.site.datasource1>
<cfset pubdata=pubs.LoadPublicationOptions(parms)>

<cftry>
<cfoutput>#search.srchRefFrom#
<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<div class="form-wrap">
					<form method="post">
						<div class="form-header">
							Publication Search
							<span><input type="submit" name="btnSearch" value="Search..." /></span>
						</div>
						<table>
							<tr>
								<td>Search by Publication Ref From</td>
								<td><input type="text" name="srchRefFrom" size="5" value="#search.srchRefFrom#" /> 
								To: <input type="text" name="srchRefTo" size="5" value="#search.srchRefTo#" /></td>
							</tr>
							<tr>
								<td>Search by Title</td>
								<td><input type="text" name="srchTitle" size="20" value="#search.srchTitle#" /></td>
							</tr>
							<tr>
								<td>Search by Type</td>
								<td>
									<select name="srchType">
										<option value="">any type</option>
										<cfloop array="#pubdata.types#" index="item">
											<option value="#item#"<cfif search.srchType eq item> selected="selected"</cfif>>#item#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>Search by Category</td>
								<td>
									<select name="srchCategory">
										<option value="">any category</option>
										<cfloop array="#pubdata.categories#" index="item">
											<option value="#item#"<cfif search.srchCategory eq item> selected="selected"</cfif>>#item#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>Group</td>
								<td>
									<select name="srchGroup">
										<option value=""<cfif search.srchGroup eq ""> selected="selected"</cfif>>Select...</option>
										<option value="News"<cfif search.srchGroup eq "News"> selected="selected"</cfif>>News</option>
										<option value="Magazine"<cfif search.srchGroup eq "Magazine"> selected="selected"</cfif>>Magazine</option>
										<option value="Unknown"<cfif search.srchGroup eq "Unknown"> selected="selected"</cfif>>Unknown</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Arrival</td>
								<td>
									<select name="srchArrival">
										<option value="0"<cfif search.srchArrival eq 0> selected="selected"</cfif>>Not Set</option>
										<option value="1"<cfif search.srchArrival eq 1> selected="selected"</cfif>>Monday</option>
										<option value="2"<cfif search.srchArrival eq 2> selected="selected"</cfif>>Tuesday</option>
										<option value="3"<cfif search.srchArrival eq 3> selected="selected"</cfif>>Wednesday</option>
										<option value="4"<cfif search.srchArrival eq 4> selected="selected"</cfif>>Thursday</option>
										<option value="5"<cfif search.srchArrival eq 5> selected="selected"</cfif>>Friday</option>
										<option value="6"<cfif search.srchArrival eq 6> selected="selected"</cfif>>Saturday</option>
										<option value="7"<cfif search.srchArrival eq 7> selected="selected"</cfif>>Sunday</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Sort By</td>
								<td>
									<select name="srchSort">
										<option value="pubRef"<cfif search.srchSort eq "pubRef"> selected="selected"</cfif>>Reference</option>
										<option value="pubTitle"<cfif search.srchSort eq "pubTitle"> selected="selected"</cfif>>Publication Title</option>
									</select>
								</td>
							</tr>
							<tr>
								<td>Options</td>
								<td>
									<input type="checkbox" name="skipUnordered"<cfif search.skipUnordered> checked="checked"</cfif> />Skip titles with no orders?<br />
									<input type="checkbox" name="blockEdit"<cfif search.blockEdit> checked="checked"</cfif> />Edit records?<br />
									<input type="checkbox" name="simpleList"<cfif search.simpleList> checked="checked"</cfif> />Simple List?<br />
								</td>
							</tr>
						</table>
					</form>
				</div>
				<cfif StructKeyExists(form,"fieldnames")>
					<cfif StructKeyExists(form,"btnSave")>
						<cfset parms.form=form>
						<cfset pubdata=pubs.SavePubs(parms)>
						<cfif application.site.showdumps><cfdump var="#pubdata#" label="pubdata" expand="no"></cfif>
					<cfelse>
						<cfset parms.form=form>
						<cfset pubdata=pubs.LoadPublicationList(parms)>
						<table border="1" class="tableList" width="100%">
							<tr>
								<th>Line</th>
								<th>Reference</th>
								<th>Title</th>
								<th>Category</th>
								<th>Type</th>
								<cfif NOT StructKeyExists(form,"simpleList")>
									<th>Price1</th>
									<th>Price2</th>
									<th>Price3</th>
									<th>Price4</th>
									<th>Price5</th>
									<th>Price6</th>
									<th>Price7</th>
									<th>VAT</th>
									<th>Arrival</th>
									<th>Wholesaler</th>
									<th>Orders</th>
									<th>View</th>
								</cfif>
							</tr>
							<cfset lineCount=0>
							<cfif pubdata.pubs.recordcount gt 0>
								<cfif StructKeyExists(form,"blockEdit")>
									<form method="post">
										<cfloop query="pubdata.pubs">
											<cfif NOT StructKeyExists(form,"skipUnordered") OR ordCount gt 0>
												<cfset lineCount++>
												<input type="hidden" name="ID" value="#pubID#" />
												<tr>
													<td>#lineCount#</td>
													<td>#pubRef#</td>
													<td>#pubTitle#</td>
													<td>#pubCategory#</td>
													<td>#pubType#</td>
													<td class="price"><input type="text" name="pubPrice1" value="#pubPrice1#" size="4" /></td>
													<td class="price"><input type="text" name="pubPrice2" value="#pubPrice2#" size="4" /></td>
													<td class="price"><input type="text" name="pubPrice3" value="#pubPrice3#" size="4" /></td>
													<td class="price"><input type="text" name="pubPrice4" value="#pubPrice4#" size="4" /></td>
													<td class="price"><input type="text" name="pubPrice5" value="#pubPrice5#" size="4" /></td>
													<td class="price"><input type="text" name="pubPrice6" value="#pubPrice6#" size="4" /></td>
													<td class="price"><input type="text" name="pubPrice7" value="#pubPrice7#" size="4" /></td>
													<td>#pubVATCode#</td>
													<td>
														<select name="pubArrival">
															<option value="0"<cfif pubArrival eq 0> selected="selected"</cfif>>Not Set</option>
															<option value="1"<cfif pubArrival eq 1> selected="selected"</cfif>>Monday</option>
															<option value="2"<cfif pubArrival eq 2> selected="selected"</cfif>>Tuesday</option>
															<option value="3"<cfif pubArrival eq 3> selected="selected"</cfif>>Wednesday</option>
															<option value="4"<cfif pubArrival eq 4> selected="selected"</cfif>>Thursday</option>
															<option value="5"<cfif pubArrival eq 5> selected="selected"</cfif>>Friday</option>
															<option value="6"<cfif pubArrival eq 6> selected="selected"</cfif>>Saturday</option>
															<option value="7"<cfif pubArrival eq 7> selected="selected"</cfif>>Sunday</option>
														</select>
													</td>
													<td>#pubWholesaler#</td>
													<td>#ordCount#</td>
													<td><a href="pubOrders.cfm?ref=#pubRef#">Orders</a></td>
												</tr>
											</cfif>
										</cfloop>
										<input type="hidden" name="recordCount" value="#lineCount#" />
										<input type="submit" name="btnSave" value="Save Changes" />
									</form>
								<cfelse>
									<cfloop query="pubdata.pubs">
										<cfif NOT StructKeyExists(form,"skipUnordered") OR ordCount gt 0>
											<cfset lineCount++>
											<tr>
												<td>#lineCount#</td>
												<td>#pubRef#</td>
												<td>#pubTitle#</td>
												<td>#pubCategory#</td>
												<td>#pubType#</td>
												<cfif NOT StructKeyExists(form,"simpleList")>
													<td class="price">#pubPrice1#</td>
													<td class="price">#pubPrice2#</td>
													<td class="price">#pubPrice3#</td>
													<td class="price">#pubPrice4#</td>
													<td class="price">#pubPrice5#</td>
													<td class="price">#pubPrice6#</td>
													<td class="price">#pubPrice7#</td>
													<td>#pubVATCode#</td>
													<td>
														<cfswitch expression="#pubArrival#">
															<cfcase value="0">N/A</cfcase>
															<cfcase value="1">Mon</cfcase>
															<cfcase value="2">Tue</cfcase>
															<cfcase value="3">Wed</cfcase>
															<cfcase value="4">Thu</cfcase>
															<cfcase value="5">Fri</cfcase>
															<cfcase value="6">Sat</cfcase>
															<cfcase value="7">Sun</cfcase>
														</cfswitch>
														#DateFormat(pubNextIssue,"dd-mmm-yy")#
													</td>
													<td>#pubWholesaler#</td>
													<td>#ordCount#</td>
													<td><a href="pubOrders.cfm?ref=#pubRef#">Orders</a></td>
												</cfif>
											</tr>
										</cfif>
									</cfloop>
								</cfif>
							<cfelse>
								<tr><td colspan="17">No publications found.</td></tr>
							</cfif>
						</table>
					</cfif>
				</cfif>
				<div class="clear" style="height:300px;"></div>
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
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="no" abort="true">
</cfcatch>
</cftry>
</html>

