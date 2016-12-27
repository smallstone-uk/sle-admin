<!DOCTYPE html>
<html>
<head>
<title>Customer Search</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/rounds2.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.tablednd.js"></script>
<script type="text/javascript">
	$(document).ready(function() {
	});
</script>
</head>

	<!---<cfset StructDelete(session,"clientSearch")>--->
<cfset search={}>
<cfif StructKeyExists(form,"btnSearch")>
	<cfset search=Duplicate(form)>
	<cfset session.clientSearch=search>
<cfelseif StructKeyExists(session,"clientSearch")>
	<cfset search=session.clientSearch>
<cfelse>
	<cfset search.srchRefFrom="">
	<cfset search.srchRefTo="">
	<cfset search.srchName="">
	<cfset search.srchAddr="">
	<cfset search.srchLastDel="">
	<cfset search.srchType="">
	<cfset search.limitRecs="">
	<cfset search.srchSort="">
	<cfset search.srchDelDate="">
	<cfset session.clientSearch=search>
</cfif>

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfoutput>
					<div class="form-wrap">
						<form method="post" enctype="multipart/form-data">
							<input type="hidden" name="srchDelDate" value="" />
							<div class="form-header">
								Customer Search
								<span><input type="submit" name="btnSearch" value="Search" /></span>
							</div>
							<div class="form-col1">
								<table border="0">
									<tr>
										<td width="25%"><strong>Account</strong></td>
										<td>
											<span id="from">From: <input type="text" name="srchRefFrom" size="5" value="#search.srchRefFrom#" /></span>
											<span id="to">To: <input type="text" name="srchRefTo" size="5" value="#search.srchRefto#" /></span>
										</td>
									</tr>
									<tr>
										<td><strong>Name</strong></td>
										<td><input type="text" name="srchName" size="20" value="#search.srchName#" /></td>
									</tr>
									<tr>
										<td><strong>Address</strong></td>
										<td><input type="text" name="srchAddr" size="20" value="#search.srchAddr#" /></td>
									</tr>
									<tr>
										<td><strong>Last Delivery</strong></td>
										<td><input type="text" name="srchLastDel" size="10" value="#search.srchLastDel#" placeholder="YYYY-MM-DD" /></td>
									</tr>
								</table>
							</div>
							<div class="form-col2">
								<table border="0">
									<tr>
										<td width="25%"><strong>Account Type</strong></td>
										<td>
											<select name="srchType" multiple="multiple" id="srchType">
												<option value="M"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "M"> selected="selected"</cfif>>Monthly</option>
												<option value="W"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "W"> selected="selected"</cfif>>Weekly</option>
												<option value="C"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "C"> selected="selected"</cfif>>Pay on Collection</option>
												<option value="H"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "H"> selected="selected"</cfif>>Account Hold</option>
												<option value="X"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "X"> selected="selected"</cfif>>Special</option>
												<option value="N"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "N"> selected="selected"</cfif>>Inactive</option>
												<option value="Z"<cfif StructKeyExists(search,"srchType") AND search.srchType eq "Z"> selected="selected"</cfif>>Unknown</option>
											</select>
										</td>
									</tr>
									<tr>
										<td><strong>Sort By</strong></td>
										<td>
											<select name="srchSort">
												<option value="cltRef"<cfif search.srchSort eq "cltRef"> selected="selected"</cfif>>Reference</option>
												<option value="cltName"<cfif search.srchSort eq "cltName"> selected="selected"</cfif>>Name</option>
												<option value="cltStreetCode"<cfif search.srchSort eq "cltStreetCode"> selected="selected"</cfif>>Street</option>
											</select>
										</td>
									</tr>
									<tr>
										<td><strong>Limit Results</strong></td>
										<td><input type="text" name="limitRecs" size="5" value="#search.limitRecs#" /></td>
									</tr>
								</table>
							</div>
						</form>
						<div class="clear"></div>
					</div>
				</cfoutput>
				<cfif StructKeyExists(form,"fieldnames")>
					<cfoutput>
						<cfsetting requesttimeout="900">
						<cfobject component="code/functions" name="cust">
						<cfset parms.datasource=application.site.datasource1>
						<cfset parms.search=search>
						<cfset customers=cust.ClientSearch(parms)>
						<cfdump var="#customers#" label="customers" expand="false">
						<cfset session.clientSearch.sql=customers.sql>
						<cfset session.clientSearch.rowMax=customers.rowMax>
						<div id="customer-search">
							<table border="0" class="tableList">
								<tr class="clienthead">
									<td class="row" width="10">##</td>
									<td class="ref" align="center" width="40">Account</td>
									<td class="name" width="220">Name</td>
									<td class="address" width="300">Address</td>
									<td class="tel" width="80">Tel</td>
									<td class="type" width="120">Type</td>
									<td class="lastdel" width="60">Last Del</td>
									<td class="lastpaid" width="60">Last Paid</td>
								</tr>
								<cfif IsQuery(customers.records)>
									<!--- reset del charge counters --->
									<cfloop collection="#application.site.delCharges#" item="key">
										<cfset delchg=StructFind(application.site.delCharges,key)>
										<cfset delchg.delCount=0>
										<cfset StructUpdate(application.site.delCharges,key,delchg)>
									</cfloop>
									<cfloop query="customers.records">
										<cfif StructKeyExists(application.site.delCharges,cltDelCode)>
											<cfset delchg=StructFind(application.site.delCharges,cltDelCode)>
											<cfif StructKeyExists(delchg,"delCount")>
												<cfset delchg.delCount++>
												<cfset StructUpdate(application.site.delCharges,cltDelCode,delchg)>
											<cfelse>
												<cfset delchg.delCount=1>
												<cfset StructUpdate(application.site.delCharges,cltDelCode,delchg)>
											</cfif>
										</cfif>
										<tr class="client">
											<td class="row">#currentrow#</td>
											<td class="ref" align="center">#cltRef#</td>
											<td class="name">
												<a href="clientDetails.cfm?row=#currentrow-1#" target="_blank">
													<cfif len(cltTitle)>#cltTitle#&nbsp;</cfif>
													<cfif len(cltInitial)>#cltInitial#&nbsp;</cfif>
													<cfif len(cltName) AND len(cltCompanyName)>#cltName# - #cltCompanyName#<cfelse>#cltName##cltCompanyName#</cfif>
												</a>
											</td>
											<td class="address">
												<cfif len(cltDelHouseName) AND len(cltDelHouseNumber)>
													#cltDelHouseNumber#, #cltDelHouseName#&nbsp;
												<cfelse>
													#cltDelHouseName##cltDelHouseNumber#&nbsp;
												</cfif>
												<cfif len(stName)>#stName#&nbsp;</cfif>
												<cfif len(cltTown)>#cltTown#&nbsp;</cfif>
												<cfif len(cltPostcode)>#cltPostcode#&nbsp;</cfif>
											</td>
											<td class="tel">#cltDelTel#</td>
											<td class="type">
												<cfif cltAccountType eq "m">Monthly</cfif>
												<cfif cltAccountType eq "w">Weekly</cfif>
												<cfif cltAccountType eq "n">Inactive</cfif>
												<cfif cltAccountType eq "h">Account Hold</cfif>
												<cfif cltAccountType eq "c">Pay on Collection</cfif>
												<cfif cltAccountType eq "x">Special</cfif>
												<cfif cltAccountType eq "z">Unknown</cfif>
											</td>
											<td class="lastdel" align="center"><cfif len(cltLastDel)>#DateFormat(cltLastDel,"dd-mmm-yy")#<cfelse>-</cfif></td>
											<td class="lastpaid" align="center"><cfif len(cltLastPaid)>#DateFormat(cltLastPaid,"dd-mmm-yy")#<cfelse>-</cfif></td>
										</tr>
									</cfloop>
								</cfif>
							</table>
							<div class="quick-bar">
								<div class="quick-bar-inner">
									<div class="quick-bar-tab"><a id="ShowQuickDetail">Delivery Charges</a></div>
									<div class="quick-bar-detail" id="DelCharges">
										<table>
											<cfset delKeys=ListSort(StructKeyList(application.site.delCharges,","),"numeric","asc")>
											<tr>
												<th>Code</th>
												<th>Mon-Fri</th>
												<th>Sat</th>
												<th>Sun</th>
												<th>Type</th>
												<th>Count</th>
											</tr>
											<cfloop list="#delKeys#" index="key">
												<cfset delItem=StructFind(application.site.delCharges,key)>
												<tr>
													<td align="center">#delItem.delCode#</td>
													<td align="center">£#delItem.delPrice1#</td>
													<td align="center">£#delItem.delPrice2#</td>
													<td align="center">£#delItem.delPrice3#</td>
													<td align="center">#delItem.delType#</td>
													<td align="center"><cfif StructKeyExists(delItem,"delCount")>#delItem.delCount#<cfelse>0</cfif></td>
												</tr>
											</cfloop>
										</table>
									</div>
								</div>
							</div>
							<script type="text/javascript">
								$('##ShowQuickDetail').click(function (event) {
									$('##ShowQuickDetail').toggleClass('active')
									$('##DelCharges').toggle();
									event.preventDefault();
								});
							</script>
						</div>
					</cfoutput>
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
	<script type="text/javascript">
		$("#srchType").chosen({width: "150px"});
	</script>
</body>
</html>
