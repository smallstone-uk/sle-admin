<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/accounts.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/tabs.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/accounts.js" type="text/javascript"></script>
<script src="scripts/checkDates.js"></script>
<script src="scripts/main.js"></script>
<title>Wrapper</title>
<style type="text/css">
	#wrapper {font-family:Arial, Helvetica, sans-serif; font-size:11px;border:solid 1px #000; padding:4px;}
	.element {border:solid 1px #ccc; float:left; padding:2px; min-height:56px;}
	.clear {clear:both}
</style>
</head>

<cfparam name="srchAccount" default="">
<cfobject component="code/accounts" name="accts">
<cfset parm = {}>
<cfset parm.nomType = "">
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>
<cfset acctsList = accts.LoadAccounts(parm)>

<cfoutput>
<body>
	<div id="wrapper">
		<form method="post" enctype="multipart/form-data" id="account-form">
		<div class="element">
			Account: 
			<select name="accountID" data-placeholder="Select..." id="account" tabindex="1">
				<option value="">Select...</option>
				<cfloop array="#acctsList.accounts#" index="item">
					<option value="#item.accID#" <cfif item.accName eq srchAccount>selected="selected"</cfif>>#item.accName#</option>
				</cfloop>
			</select>
			<br />
			Reference: <input type="text" size="10" name="tranRef" value="" tabindex="2" />
		</div>
		<div class="element">
			Date Range:
			<select name="srchRange" data-placeholder="Select..." id="srchRange" tabindex="3">
				<option value="0">All Records</option>
				<option value="1">Last 7 Days</option>
				<option value="2">This Month</option>
				<option value="3">From Last Month</option>
				<option value="4">From Previous Month</option>
				<cfset dateKeys=ListSort(StructKeyList(application.site.FYDates,","),"text","ASC")>
				<cfloop list="#dateKeys#" index="key">
					<cfset item=StructFind(application.site.FYDates,key)>
					<option value="FY-#item.key#">Year #item.title#</option>
				</cfloop>
				<cfloop from="2013" to="#year(Now())#" index="yearNum">
					<option disabled>#yearNum#</option>
					<cfloop from="1" to="12" index="i">
						<option value="#yearNum#-#i#">#yearNum#-#NumberFormat(i,"00")#</option>
					</cfloop>
				</cfloop>
			</select>
			<br />
			Types:
			<select name="srchType" data-placeholder="Select..." id="srchType" tabindex="4">
				<option value="">All Types</option>
				<option value="inv">Invoices</option>
				<option value="crn">Credit Notes</option>
				<option value="ic">Invoices &amp; Credit Notes</option>
				<option value="pay">Payments</option>											
				<option value="jnl">Journals</option>
				<option value="pj">Payments &amp; Journals</option>											
			</select>
		</div>
		<div class="element">
			Sort Order: 
			<select name="sortOrder" data-placeholder="Select..." id="sortOrder" tabindex="5">
				<option value="date" selected="selected">Transaction Date</option>
				<option value="id">Transaction ID</option>
				<option value="ref">Transaction Ref</option>
			</select>
			<br />
			<input type="checkbox" name="srchAllocated" value="1" id="srchAllocChk" tabindex="6"> Show Allocated
		</div>
		<div class="element">
			<input type="submit" value="Search" id="btnSearch" tabindex="7" />
		</div>
		<div class="clear"></div>
		</form>
	</div>
</body>
</cfoutput>
</html>
