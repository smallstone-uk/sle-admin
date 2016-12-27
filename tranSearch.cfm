<!DOCTYPE html>
<html>
<head>
	<title>Transaction Search</title>
	<meta name="viewport" content="width=device-width,initial-scale=1.0">
	<link href="css/main3.css" rel="stylesheet" type="text/css">
	<link rel="stylesheet" type="text/css" href="css/rounds.css"/>
	<script type="text/javascript" src="common/scripts/common.js"></script>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js"></script>
	<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
	<script src="scripts/jquery.hoverIntent.minified.js"></script>
	<script src="scripts/jquery.bxslider.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('#banner-slider').bxSlider({mode:'fade',controls:false,auto:true,pause:2000,speed:1000,autoHover:true,pager:true});
			$('.bx-controls').addClass("display");
			});
	</script>
</head>

<cfset search={}>		<!--- create new struct --->
<cfif StructKeyExists(form,"srchButton")>	<!--- new search started --->
	<cfset search=Duplicate(form)>			<!--- copy form values --->
	<cfset session.tranSearch=search>		<!--- store in session  overwriting previous if any --->
<cfelseif StructKeyExists(session,"tranSearch")> <!--- restore previously saved search --->
	<cfset search=session.tranSearch>	<!--- populate struct --->
<cfelse>	<!--- first time in with new session --->
	<cfset search.srchDateFrom="">	<!--- populate with default values --->
	<cfset search.srchDateTo="">
	<cfset search.srchAccountID="">
	<cfset search.srchName="">
	<cfset search.limitRecs="">
	<cfset search.srchSort="">
	<cfset session.tranSearch=search>
</cfif>
<cfif application.site.showdumps><cfdump var="#search#" label="search" expand="no"></cfif>

<cfobject component="code/accounts" name="trans">
<cfset parms.datasource=application.site.datasource1>
<cfset parms.nomType="">
<cfset list=trans.LoadAccounts(parms)>

<body>
	<div id="wrapper">
		<cfinclude template="sleHeader.cfm">
		<div id="content">
			<div id="content-inner">
				<cfoutput>
					<div class="form-wrap">
						<form method="post" enctype="multipart/form-data">
							<div class="form-header">
								Transaction Search
								<span><input type="submit" name="srchButton" value="Search" /></span>
							</div>
							<div class="form-col1">
								<table border="0">
									<tr>
										<td width="25%"><strong>Date</strong></td>
										<td>
											<span id="from">From: <input type="text" name="srchDateFrom" size="12" value="#search.srchDateFrom#" /></span>
											<span id="to">To: <input type="text" name="srchDateTo" size="12" value="#search.srchDateTo#" /></span>
										</td>
									</tr>
									<tr>
										<td><strong>Account</strong></td>
										<td>
											<select name="srchAccountID" data-placeholder="Select..." id="Supplier">
												<option value=""></option>
												<cfloop array="#list.accounts#" index="item">
													<option value="#item.accID#"<cfif item.accID eq search.srchAccountID>selected="selected"</cfif>>#item.accName#</option>
												</cfloop>
											</select>
										</td>
									</tr>
									<tr>
										<td><strong>Name</strong></td>
										<td><input type="text" name="srchName" size="20" value="#search.srchName#" /></td>
									</tr>
								</table>
							</div>
							<div class="form-col2">
								<table border="0">
									<tr>
										<td><strong>Sort By</strong></td>
										<td>
											<select name="srchSort">
												<option value="trnAccountID,trnID"<cfif search.srchSort eq "trnAccountID"> selected="selected"</cfif>>Account</option>
												<option value="trnDate,trnID"<cfif search.srchSort eq "trnDate"> selected="selected"</cfif>>Date</option>
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
						<cfset parms.search=search>
						<cfset transactions=trans.TranSearch(parms)>
						<cfset session.tranSearch.sql=transactions.sql>
						<cfset session.tranSearch.rowMax=transactions.rowMax>
						<cfset total1=0>
						<cfset total2=0>
						<cfdump var="#transactions#" label="transactions" expand="no">
						<div id="transaction-search">
							<table border="0" class="tableList">
								<tr class="clienthead">
									<td class="row">##</td>
									<td class="ref" align="center">Code</td>
									<td class="name">Account Name</td>
									<td class="address">Type</td>
									<td class="town">ID</td>
									<td class="town">Type</td>
									<td class="postcode">Date</td>
									<td class="tel">Reference</td>
									<td class="delivery">Description</td>
									<td class="streetcode" align="right">Amount 1</td>
									<td class="round" align="right">Amount 2</td>
									<td class="type">Allocated</td>
								</tr>
								<cfif IsQuery(transactions.records)>
									<cfloop query="transactions.records">
										<cfset total1=total1+trnAmnt1>
										<cfset total2=total2+trnAmnt2>
										<tr class="client">
											<td class="row">#currentrow#</td>
											<td class="ref" align="center">#accCode#</td>
											<td class="name"><a href="tranDetail.cfm?row=#currentrow-1#"><cfif len(accName) gt 25>#Left(accName,23)#..<cfelse>#accName#</cfif></a></td>
											<td class="town">#accType#</td>
											<td class="town">#trnID#</td>
											<td class="town">#trnType#</td>
											<td class="postcode">#DateFormat(trnDate,"dd-mmm-yyyy")#</td>
											<td class="tel">#trnRef#</td>
											<td class="delivery">#trnDesc#</td>
											<td class="streetcode" align="right">#trnAmnt1#</td>
											<td class="round" align="right">#trnAmnt2#</td>
											<td class="type" align="center">#trnAlloc#</td>
										</tr>
									</cfloop>
								</cfif>
								<tr>
									<td colspan="9" align="right">Totals</td>
									<td align="right">#total1#</td>
									<td align="right">#total2#</td>
									<td></td>
								</tr>
							</table>
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
</body>
</html>
