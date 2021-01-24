<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>EPOS Accounts</title>
</head>

<cfparam name="accountID" default="0">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.accountID = accountID>
<cfsetting requesttimeout="30">
<cfflush interval="200">
<cfquery name="QAccountNames" datasource="#parm.datasource#">
	SELECT *
	FROM `tblepos_account`
	WHERE `eaMenu` = 'Yes'
</cfquery>
<cfif parm.accountID gt 0>
	<cfquery name="QAccountPayments" datasource="#parm.datasource#">
		SELECT eiParent
		FROM `tblepos_items`
		WHERE `eiAccID` = #parm.accountID#
	</cfquery>
	<cfset parm.aIDs = QuotedValueList(QAccountPayments.eiParent,",")>
	<cfset parm.aIDs = Replace(parm.aIDs,"'","","all")>
</cfif>

<body>
	<cfoutput>
		<form method="post" enctype="multipart/form-data">
			Choose Account:
			<select name="accountID" id="accountID">
				<option value="">Select account...</option>
				<cfloop query="QAccountNames">
				<option value="#eaID#" <cfif eaID eq accountID> selected</cfif>>#eaID# #eaTitle#</option>
				</cfloop>
			</select>
			<input type="submit" name="btnGo" value="Go">
		</form>
		<cfif parm.accountID gt 0>
			<cfdump var="#parm#" label="parm" expand="false">
			<cfset DumpTrans(parm)>
		</cfif>
	</cfoutput>
</body>
</html>

	<cffunction name="DumpTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QTrans" datasource="#args.datasource#" result="loc.qtrandump">
				SELECT tblEPOS_Items.*,ehMode, empFirstName,
				IF (eiClass='DISC',
					(SELECT edTitle FROM tblEPOS_Deals WHERE edID=eiDealID),
					IF (eiType='MEDIA',
						(SELECT pubTitle FROM tblPublication WHERE pubID=eiPubID),
						IF (eiClass='pay',
							(SELECT eaTitle FROM tblEPOS_Account WHERE eaID=eiPayID),
								(SELECT prodTitle FROM tblProducts WHERE prodID=eiProdID)
						)
					)
				) title,
				tblProducts.prodCatID, tblproductcats.pcatTitle
				FROM tblEPOS_Items
				INNER JOIN tblEPOS_Header ON ehID = eiParent
				INNER JOIN tblemployee ON empID = ehEmployee
				INNER JOIN tblProducts ON prodID=eiProdID
				INNER JOIN tblproductcats ON prodCatID=pcatID
				WHERE 1
				<cfif len(args.reportDate)>AND DATE(ehTimeStamp) = '#args.reportDate#' </cfif>
				<cfif StructKeyExists(args,"aIDs")>
					AND eiParent IN (#args.aIDs#)
				</cfif>
			</cfquery>
			<cfdump var="#loc.QTrans#" label="QTrans" expand="false">
			<cfset loc.result.QTrans = loc.QTrans>
			<cfset loc.net = 0>
			<cfset loc.vat = 0>
			<cfset loc.profit = 0>
			<cfset loc.cr = 0>
			<cfset loc.dr = 0>
			<cfset loc.tran = 0>
			<cfoutput>
			<table class="tableList">
				<tr>
					<th align="left" colspan="18"><input type="text" id="quicksearch" value="" placeholder="Search list"></th>
				</tr>
				<tr>
					<th>Tran</th>
					<th>Mode</th>
					<th>ID</th>
					<th>User</th>
					<th width="80">Timestamp</th>
					<th>Class</th>
					<th>Type</th>
					<th>Method</th>
					<th>Qty</th>
					<th width="120">Category</th>
					<th>Description</th>
					<th align="right">Net</th>
					<th align="right">VAT</th>
					<th align="right">DR</th>
					<th align="right">CR</th>
					<th align="right">Trade</th>
					<th align="right">Retail</th>
					<th align="right">Profit</th>
				</tr>
				<cfset loc.balance = 0>
				<cfloop query="loc.QTrans">
					<cfif loc.tran gt 0 AND loc.tran neq eiParent>
						<cfif abs(loc.balance) gt 0.001>
							<tr class="searchrow" data-title="#title#" data-prodID="#eiProdID#">
								<td colspan="15" align="right" class="balError">#DecimalFormat(loc.balance)#</td>
								<td colspan="3" class="balError"></td>
							</tr>
						<cfelse>
							<tr class="searchrow" data-title="#title#" data-prodID="#eiProdID#">
								<td colspan="18">&nbsp;</td>
							</tr>
						</cfif>
						<cfset loc.balance = 0>
					</cfif>
					<cfset loc.gross = eiNet + eiVAT>
					<cfset loc.net += eiNet>
					<cfset loc.vat += eiVAT>
					<tr class="searchrow" data-title="#pcatTitle# #title#" data-prodID="#eiProdID#">
						<td>#eiParent#</td>
						<td>#ehMode#</td>
						<td>#eiID#</td>
						<td>#empFirstName#</td>
						<td nowrap>#LSDateFormat(eiTimestamp,"dd-mmm")# #LSTimeFormat(eiTimestamp)#</td>
						<td>#eiClass#</td>
						<td>#eiType#</td>
						<td>#eiPayType#</td>
						<td align="center">#eiQty#</td>
						<td><span title="#pcatTitle#">#Left(pcatTitle,20)#</span></td>
						<td>#title#</td>
						<td align="right">#eiNet#</td>
						<td align="right">#eiVAT#</td>
						<cfif loc.gross gt 0>
							<cfset loc.dr += loc.gross>
							<td align="right">#DecimalFormat(loc.gross)#</td>
							<td align="right"></td>
						<cfelse>
							<cfset loc.cr -= loc.gross>
							<td align="right"></td>
							<td align="right">#DecimalFormat(-loc.gross)#</td>
						</cfif>
						<td align="right"><cfif eiTrade neq 0>#eiTrade#</cfif></td>
						<td align="right"><cfif eiRetail neq 0>#eiRetail#</cfif></td>
						<td align="right"><cfif eiClass eq 'sale'>#DecimalFormat(eiNet+eiTrade)#</cfif></td>
					</tr>
					<cfif eiClass eq 'sale'>
						<cfset loc.profit += (eiNet+eiTrade)>
					</cfif>
					<cfset loc.tran = eiParent>
					<cfset loc.balance += loc.gross>
				</cfloop>
				<tr id="pagetotals">
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th></th>
					<th align="right">#DecimalFormat(loc.net)#</th>
					<th align="right">#DecimalFormat(loc.vat)#</th>
					<th align="right">#DecimalFormat(loc.dr)#</th>
					<th align="right">#DecimalFormat(loc.cr)#</th>
					<th></th>
					<th></th>
					<th align="right">#DecimalFormat(loc.profit)#</th>
				</tr>
			</table>
			</cfoutput>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="DumpTrans" expand="yes" format="html"
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
