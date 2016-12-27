<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<title>Fix Sales VAT</title>
	<link rel="stylesheet" type="text/css" href="css/main3.css"/>
	<style>
		.red {color:#FF0000;}
		.blue {color:#00F;}
		.header {background-color:#CCCCCC;}
		.tranheader {background-color:#eee;}
		.vatTable {
			border-spacing: 0px;
			border-collapse: collapse;
			border: 1px solid #CCC;
			font-size: 14px;
		}
		.vatTable th {padding: 5px; background:#eee; border-color: #ccc;}
		.vatTable td {padding: 5px; border-color: #ccc;}
	</style>
</head>

<cfset PRD = {}>
<cfset process = 0>
<cfflush interval="200">
<cfsetting requesttimeout="300">
<cfparam name="doUpdate" default="false">
<cfparam name="dateFrom" default="2015-01-01">
<cfparam name="dateTo" default="2015-03-31">

<cfquery name="QSalesTrans" datasource="#application.site.datasource1#">
    SELECT nomClass,nomType,SUM(niAmount) AS gross, 
		year(trnDate) as DA, month(trnDate) As DB, count(*) AS trans
    FROM ((tblNominal INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
    INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
    WHERE trnLedger='sales' 
    AND nomType='sales'
	AND nomClass <> 'other'	<!--- exclude news account payments & owners account --->
    AND trnDate BETWEEN '#dateFrom#' AND '#dateTo#' 
    GROUP BY DA,DB,nomClass
</cfquery>

<cfloop query="QSalesTrans">
	<cfset yymm = "#DA#-#NumberFormat(DB,"00")#">
	<cfif NOT StructKeyExists(PRD,yymm)>
    	<cfset StructInsert(PRD,yymm,{"SALES" = {"zgrand" = {}}, "PURCH" = {"zgrand" = {}} })>
    </cfif>
	<cfset ledger = StructFind(PRD,yymm).SALES>
	<cfif NOT StructKeyExists(ledger,nomClass)>
        <cfset StructInsert(ledger,nomClass,{})>
    </cfif>
    <cfset class = StructFind(ledger,nomClass)>
    <cfif StructKeyExists(class,"total")>
    	<cfset rec = StructFind(class,"total")>
        <cfset rec.gross += gross>
        <cfset rec.trans += trans>
    <cfelse>
    	<cfset StructInsert(class,"total",{"gross" = gross, "net" = 0, "VAT" = 0, "trans" = trans, "rate" = "Total", "prop" = 1})>
    </cfif>
	
	<cfif NOT StructKeyExists(ledger.zgrand,"total")>
    	<cfset StructInsert(ledger.zgrand,"total",{"gross" = 0, "net" = 0, "VAT" = 0, "trans" = trans, "rate" = "Total", "prop" = 1})>
	</cfif>
</cfloop>

<cfquery name="QPurTrans" datasource="#application.site.datasource1#">
	SELECT nomClass,nomVATCode, vatRate, SUM(niAmount) AS net, round(SUM(niAmount)*vatRate/100,2) AS vatAmnt, 
		year(trnDate) as DA, month(trnDate) As DB, count(*) AS trans
	FROM (((tblNominal 
	INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
	INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode) 
	INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
	WHERE trnClientRef=0 
	AND trnLedger='purch' 
	AND nomType='purch' 
    AND trnDate BETWEEN '#dateFrom#' AND '#dateTo#' 
	GROUP BY DA,DB,nomClass,nomVATCode
</cfquery>
<cfloop query="QPurTrans">
	<cfset yymm = "#DA#-#NumberFormat(DB,"00")#">
	<cfif NOT StructKeyExists(PRD,yymm)>
    	<cfset StructInsert(PRD,yymm,{"SALES" = {}, "PURCH" = {} })>
    </cfif>
	<cfset ledger = StructFind(PRD,yymm).PURCH>
	<cfif NOT StructKeyExists(ledger,nomClass)>
        <cfset StructInsert(ledger,nomClass,{})>
    </cfif>
    <cfset class = StructFind(ledger,nomClass)>
    <cfif NOT StructKeyExists(class,nomVATCode)>
    	<cfset StructInsert(class,nomVATCode,{"gross" = net + vatAmnt, "net" = net, "VAT" = vatAmnt, "trans" = trans, "rate" = vatRate})>
    </cfif>
    <cfif NOT StructKeyExists(class,"total")>
    	<cfset StructInsert(class,"total",{"gross" = net + vatAmnt, "net" = net, "VAT" = vatAmnt, "trans" = trans, "rate" = "Total", "prop" = 1})>
    <cfelse>
    	<cfset rec = StructFind(class,"total")>
        <cfset rec.gross += (net + vatAmnt)>
        <cfset rec.net += net>
        <cfset rec.VAT += vatAmnt>
        <cfset rec.trans += trans>
    </cfif>
	
	<cfif NOT StructKeyExists(ledger.zgrand,"total")>
    	<cfset StructInsert(ledger.zgrand,"total",{"gross" = net + vatAmnt, "net" = net, "VAT" = vatAmnt, "trans" = trans, "rate" = "Total", "prop" = 1})>
	<cfelse>
    	<cfset rec = StructFind(ledger.zgrand,"total")>
        <cfset rec.gross += (net + vatAmnt)>
        <cfset rec.net += net>
        <cfset rec.VAT += vatAmnt>
        <cfset rec.trans += trans>		
	</cfif>
</cfloop>

<cfset periodKeys = ListSort(StructKeyList(PRD,","),"numeric","asc",",")>
<cfloop list="#periodKeys#" index="prdKey">
	<cfset period = StructFind(PRD,prdKey)>
	<cfset ledgerKeys = ListSort(StructKeyList(period,","),"text","asc",",")>
	<cfloop list="#ledgerKeys#" index="ledgerKey">
		<cfset ledger = StructFind(period,ledgerKey)>
		<cfif ledgerKey eq "PURCH">
			<cfset deptKeys = ListSort(StructKeyList(ledger,","),"text","asc",",")>
			<cfloop list="#deptKeys#" index="deptKey">
				<cfif deptKey neq "total">
					<cfset dept = StructFind(ledger,deptKey)>
					<cfset netTotal = dept.total.net>
					<cfloop collection="#dept#" item="vatKey">
						<cfset vatRate = StructFind(dept,vatKey)>
						<cfset StructInsert(vatRate,"prop",vatRate.net / netTotal,true)>
					</cfloop>
				</cfif>
			</cfloop>
		<cfelse>
			<cfloop collection="#ledger#" item="deptKey">
				<cfset salesDept = StructFind(ledger,deptKey)>
				<cfif StructKeyExists(period.PURCH,deptKey) AND deptKey neq "total">
					<cfset purDept = StructFind(period.PURCH,deptKey)>
					<cfloop collection="#purDept#" item="vatKey">
						<cfset vatRec = StructFind(purDept,vatKey)>
						<cfif vatKey neq "total">
							<cfset sgross = int(salesDept.total.gross * vatRec.prop * 100) / 100>
							<cfset snet = sgross / (1 + (vatRec.rate / 100))>
							<cfset svat = sgross - snet>
							<cfset StructInsert(salesDept,vatKey,{
								"gross" = sgross,
								"net" = snet,
								"vat" = svat,
								"rate" = vatRec.rate,
								"prop" = vatRec.prop
							},true)>
							<cfset salesDept.total.net += snet>
							<cfset salesDept.total.vat += svat>
							<cfset ledger.zgrand.total.VAT += svat>
							<cfset ledger.zgrand.total.gross += sgross>
							<cfset ledger.zgrand.total.net += snet>
						</cfif>
					</cfloop>
				<cfelse>
					<cfset salesDept.total.net = salesDept.total.gross>
					<cfset ledger.zgrand.total.gross += salesDept.total.gross>
					<cfset ledger.zgrand.total.net += salesDept.total.net>
				</cfif>
			</cfloop>
		</cfif>
	</cfloop>
</cfloop>
<!---<cfdump var="#PRD#" label="PRD" expand="no">--->

<cfset summary = {
	"box1" = {"title" = "VAT due on sales and other outputs", "value" = 0},
	"box2" = {"title" = "VAT due on acquisitions from other EC States", "value" = 0},
	"box3" = {"title" = "Total VAT due (sum of boxes 1 & 2)", "value" = 0},
	"box4" = {"title" = "VAT reclaimed on purchases", "value" = 0},
	"box5" = {"title" = "Net VAT payable or repayable", "value" = 0},
	"box6" = {"title" = "Total value of sales", "value" = 0},
	"box7" = {"title" = "Total value of purchases", "value" = 0},
	"box8" = {"title" = "Total value of supplies from EC States", "value" = 0},
	"box9" = {"title" = "Total value of acquisitions from EC States", "value" = 0}
}>
<body>
	<cfoutput>
		<table class="tableList" border="1">
		<cfset periodKeys = ListSort(StructKeyList(PRD,","),"numeric","asc",",")>
		<cfloop list="#periodKeys#" index="prdKey">
			<cfset period = StructFind(PRD,prdKey)>
			<tr>
				<td colspan="5">#prdKey#</td>
			</tr>
			<cfset ledgerKeys = ListSort(StructKeyList(period,","),"text","asc",",")>
			<cfloop list="#ledgerKeys#" index="ledgerKey">
				<cfset ledger = StructFind(period,ledgerKey)>
				<cfif ledgerKey eq "PURCH">
					<cfset summary.box4.value += ledger.zgrand.total.vat>
					<cfset summary.box7.value += ledger.zgrand.total.net>				
				<cfelse>
					<cfset summary.box1.value += ledger.zgrand.total.vat>				
					<cfset summary.box3.value += ledger.zgrand.total.vat>				
					<cfset summary.box6.value += ledger.zgrand.total.net>				
				</cfif>
				<cfset summary.box5.value += ledger.zgrand.total.vat>
				<tr>
					<td colspan="5" class="header">#ledgerKey#</td>
				</tr>
				<tr>
					<th>Rate</th>
					<th>Prop</th>
					<th>Gross</th>
					<th>VAT</th>
					<th>Net</th>
				</tr>
				<cfset deptKeys = ListSort(StructKeyList(ledger,","),"text","asc",",")>
				<cfloop list="#deptKeys#" index="deptKey">
					<cfset dept = StructFind(ledger,deptKey)>
					<tr>
						<td colspan="5" class="header">#deptKey#</td>
					</tr>
					<cfset vatKeys = ListSort(StructKeyList(dept,","),"text","asc",",")>
					<cfloop list="#vatKeys#" index="vatKey">
						<cfset rec = StructFind(dept,vatKey)>
						<cfif IsStruct(rec)>
							<tr>
								<td align="right">#rec.rate#</td>
								<td align="right">#DecimalFormat(rec.prop)#</td>
								<td align="right">#DecimalFormat(rec.gross)#</td>
								<td align="right">#DecimalFormat(rec.vat)#</td>
								<td align="right">#DecimalFormat(rec.net)#</td>
							</tr>
						<cfelse>
							<tr>
								<td><cfdump var="#rec#" label="rec" expand="no"></td>
							</tr>
						</cfif>
					</cfloop>
				</cfloop>
			</cfloop>
		</cfloop>
		</table>
		<h1>VAT Summary</h1>
		<table class="vatTable" border="1">
			<cfset boxKeys = ListSort(StructKeyList(summary,","),"text","asc",",")>
			<cfloop list="#boxKeys#" index="boxKey">
				<cfset box = StructFind(summary,boxKey)>
				<tr>
					<td>#box.title#</td><td align="right">#DecimalFormat(box.value)#</td>
				</tr>
			</cfloop>
		</table>
		<br /><br />
	</cfoutput>
</body>
</html>