<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<link href="css/main4.css" rel="stylesheet" type="text/css">
	<title>Delete Duplicates</title>
	<script src="scripts/jquery-1.9.1.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 1 - 1, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
		});
	</script>
</head>

<cfparam name="delDate" default="">
<cfparam name="doUpdate" default="false">

<body>
<p>This function deletes duplicate delivery items for the selected day</p>
<cfoutput>
<form method="post" name="search">
	<table class="tableList">
		<tr>
			<td><b>Delivery Date</b></td>
			<td>
				<input type="text" name="delDate" value="#delDate#" class="datepicker" />
			</td>
		</tr>
		<tr>
			<td><b>Show All Records</b></td>
			<td><input type="checkbox" name="srchShowAll" value="1" /></td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="submit" name="btnGo" value="Go" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>
<cfif StructKeyExists(form,"doUpdate")>
	<cfflush interval="200">
	<p>Updating...</p>
	<cfquery name="QDelItems" datasource="#application.site.datasource1#">
		SELECT pubTitle, cltName,cltRef,cltAccountType,cltEmail, tbldelitems.*  
		FROM tbldelitems 
		INNER JOIN tblClients ON cltID = diClientID
		INNER JOIN tblPublication ON pubID = diPubID
		WHERE diDate = '#delDate#'
		GROUP BY diClientID, diOrderID, diPubID, diType
		HAVING count(*) > 1
		ORDER BY diClientID ASC
	</cfquery>
	<cfset loopCount = 0>
	<cfoutput>
		<cfloop query="QDelItems">
			<cfset loopCount++>
			<cfset thisID = diID>
			<cfquery name="QDelete" datasource="#application.site.datasource1#">
				DELETE FROM tbldelitems
				WHERE diID = #thisID#
			</cfquery>
			<p>Deleted record: #thisID#</p>
			<!---<cfbreak>--->
		</cfloop>
	</cfoutput>
	<cfset StructInsert(form,"btnGo",1)>
</cfif>
<cfif StructKeyExists(form,"btnGo")>
	<cfif len(delDate)>
		<cfquery name="QItems" datasource="#application.site.datasource1#">
			SELECT pubTitle, cltName,cltRef,cltAccountType,cltEmail, tbldelitems.*  
			FROM tbldelitems 
			INNER JOIN tblClients ON cltID = diClientID
			INNER JOIN tblPublication ON pubID = diPubID
			WHERE diDate = '#delDate#'
			<cfif !StructKeyExists(form,"srchShowAll")>
				GROUP BY diClientID, diOrderID, diPubID, diType
				HAVING count(*) > 1
			</cfif>
			ORDER BY diClientID ASC
		</cfquery>
		<!---<cfdump var="#QItems#" label="QItems" expand="false">--->
		<cfset lineCount = 0>
		<cfset errorCount = 0>
		<cfset totValue = 0>
		<cfoutput>
			<p>
				<form method="post" name="run">
					<input type="submit" name="doUpdate" value="Run" />
					<input type="hidden" name="delDate" value="#delDate#" />
				</form>
			</p>
			<table class="tableList" border="1">
				<tr class="header">
					<th colspan="12"><cfif StructKeyExists(form,"srchShowAll")>All<cfelse>Duplicate</cfif> Delivery Items for #DateFormat(delDate,"ddd dd-mmm-yyyy")#</th>
				</tr>
				<tr>
					<th align="right">##</th>
					<th align="right">Item ID</th>
					<th align="right">Reference</th>
					<th>Name</th>
					<th>Account Type</th>
					<th>EMail</th>
					<th align="right">Title</th>
					<th align="right">Invoice ID</th>
					<th align="right">Voucher ID</th>
					<th align="right">Qty</th>
					<th align="right">Price</th>
					<th align="right">Type</th>
				</tr>
				<cfloop query="QItems">
					<cfset lineCount++>
					<cfset totValue += diPrice>
					<tr>
						<td align="right">#lineCount#</td>
						<td align="right">#diID#</td>
						<td align="right"><a href="clientDetails.cfm?row=0&ref=#cltRef#" target="_blank">#cltRef#</a></td>
						<td>#cltName#</td>
						<td>#cltAccountType#</td>
						<td>#cltEmail#</td>
						<td>#pubTitle#</td>
						<td align="right">#diInvoiceID#</td>
						<td align="right">#diVoucher#</td>
						<td align="right">#diQty#</td>
						<td align="right">#diPrice#</td>
						<td align="right">#diType#</td>
					</tr>
				</cfloop>
				<tr>
					<th colspan="10"></th>
					<th align="right">#DecimalFormat(totValue)#</th>
					<th></th>
				</tr>
			</table>
		</cfoutput>
	<cfelse>
		Please select a date first
	</cfif>
</cfif>
</body>
</html>