<!DOCTYPE HTML>
<html>
<head>
	<meta charset="utf-8">
	<title>Import Bank Statement</title>
	<link rel="stylesheet" type="text/css" href="css/main.css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 0, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
		});
	</script>
	<style type="text/css">
		.title {font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold;}
		.tableStyle {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		.tableFiles {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		.tableStyle th, .tableStyle td {
			border: 1px solid #ccc;
			padding: 2px 4px;
		}
		.blue {background-color:#0000FF; color:#FFFFFF}
		.green {background-color:#0F0;}
		.red {background-color:#FF0000;}
		.fuschia {background-color:#FF33FF;}
		.insert {font-weight:bold; color:#FF00FF;}
	</style>
</head>

<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchFile" default="">
<cfparam name="srchSuppliers" default="on">
<cfparam name="srchNominal" default="on">
<cfparam name="srchCustomers" default="on">
<cfparam name="srchUnknown" default="">
<cfparam name="srchFilter" default="">

<body>
	<cfset refs={}>
	<cfset refs.customers={}>
	<cfset refs.suppliers={}>
	<cfset refs.cheques={}>
	<cfset refs.nominal={}>
	<cfset refs.skipped=[]>
	<cfset insertCount=0>
	
	<cfobject component="code/accounts" name="acc">
	
	<cffunction name="ExtractRef" access="public" returntype="numeric">
		<cfargument name="keyStruct" type="struct" required="yes">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result=0>
		<cfset loc.re="((?:(?![0-9]{5,}|(\d\d[A-Z]{3}\d\d)|(\d\d-\d\d-\d\d)).)*)">
		<cfset loc.words=ReFindNoCase(loc.re,args.description,1,true)>
		<cfif ArrayLen(loc.words.pos) AND loc.words.len[1] GT 0>
			<cfset loc.newRef=trim(Mid(args.description,loc.words.pos[1],loc.words.len[1]))>
		<cfelse>
			<cfset loc.newRef=args.description>
		</cfif>
		<cfif NOT StructKeyExists(keyStruct,loc.newRef)>
			<cfset StructInsert(keyStruct,loc.newRef,{"count"=1,"entries"=[args]})>
		<cfelse>
			<cfset loc.rec=StructFind(keyStruct,loc.newRef)>
			<cfset ArrayAppend(loc.rec.entries,args)>
			<cfset loc.rec.count++>
			<cfset StructUpdate(keyStruct,loc.newRef,loc.rec)>
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="GetPostingAccount" access="public" returntype="struct">
		<cfargument name="key" type="string" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.ID=0>
		<cfset loc.result.postType="unknown #key#">
		<cfset loc.result.ignore=false>
		<cfset loc.keywords=ListToArray(key," ",false)>
		<cfset loc.index="">
		<cfset loc.newIndex=key>
		<cfset loc.tries=[]>
		<cfset loc.lengths=[]>
		<cfif len(key)>
			<cfloop condition="len(loc.newIndex) gt 0">
				<cfset ArrayAppend(loc.tries,loc.newIndex)>
				<cfquery name="loc.QAccount" datasource="#application.site.datasource1#">
					SELECT accID,accCode,accGroup,accName,accType,accPayAcc,accNomAcct
					FROM tblAccount
					WHERE accIndex LIKE '#trim(loc.newIndex)#'
				</cfquery>
				<cfif loc.QAccount.recordcount IS 0>
					<cfquery name="loc.QNominal" datasource="#application.site.datasource1#">
						SELECT *
						FROM tblNominal
						WHERE nomKey LIKE '#trim(loc.newIndex)#'
					</cfquery>
					<cfif loc.QNominal.recordcount EQ 1>
						<cfbreak>
					</cfif>
					<cfif loc.QNominal.recordcount IS 0>
						<cfquery name="loc.QClient" datasource="#application.site.datasource1#">
							SELECT cltID,cltRef,cltName,cltCompanyName
							FROM tblClients
							WHERE cltKey LIKE '#trim(loc.newIndex)#'
						</cfquery>					
						<cfif loc.QClient.recordcount EQ 1>
							<cfbreak>
						</cfif>
					</cfif>
				<cfelse>
					<cfbreak>
				</cfif>
				<cfset loc.newIndex=ListDeleteAt(loc.newIndex,ListLen(loc.newIndex," .")," .")>
				<cfset ArrayAppend(loc.lengths,ListLen(loc.newIndex," "))>
			</cfloop>
			<cfif loc.QAccount.recordcount EQ 1>
				<cfset loc.result.class="blue">
				<cfset loc.result.postType="account">
				<cfset loc.result.ID=loc.QAccount.accID>
				<cfset loc.result.Code=loc.QAccount.accCode>
				<cfset loc.result.clientID=0>
				<cfset loc.result.Group=loc.QAccount.accGroup>
				<cfset loc.result.Name=loc.QAccount.accName>
				<cfset loc.result.Type=loc.QAccount.accType>
				<cfset loc.result.PayAcc=loc.QAccount.accPayAcc>
				<cfset loc.result.NomAcct=loc.QAccount.accNomAcct>
			<cfelseif loc.QNominal.recordcount EQ 1>
				<cfset loc.result.class="green">
				<cfset loc.result.postType="nom">
				<cfset loc.result.ID=loc.QNominal.nomID>
				<cfset loc.result.Code=loc.QNominal.nomCode>
				<cfset loc.result.clientID=0>
				<cfset loc.result.Group=loc.QNominal.nomGroup>
				<cfset loc.result.Name=loc.QNominal.nomTitle>
				<cfset loc.result.Type=loc.QNominal.nomType>
				<cfset loc.result.NomAcct=loc.QNominal.nomBalAcct>
				<cfset loc.result.NomSign=loc.QNominal.nomSign>
			<cfelseif loc.QClient.recordcount EQ 1>
				<cfset loc.result.class="fuschia">
				<cfset loc.result.postType="client">
				<cfset loc.result.ID=4>
				<cfset loc.result.clientID=loc.QClient.cltID>
				<cfset loc.result.Code=loc.QClient.cltRef>
				<cfset loc.result.Group="">
				<cfset loc.result.Name="#loc.QClient.cltName# #loc.QClient.cltCompanyName#">
				<cfset loc.result.Type="sales">
				<cfset loc.result.PayAcc=41>
				<cfset loc.result.NomAcct=1>
			<cfelseif loc.QAccount.recordcount EQ 0 OR loc.QNominal.recordcount EQ 0>
				<cfset loc.result.class="red">
				<cfset loc.result.postType="nom">
				<cfquery name="loc.QNominal" datasource="#application.site.datasource1#">
					SELECT *
					FROM tblNominal
					WHERE nomCode='SUSP'
				</cfquery>
				<cfset loc.result.ignore=srchUnknown IS "on">
				<cfset loc.result.ID=loc.QNominal.nomID>
				<cfset loc.result.Code=loc.QNominal.nomCode>
				<cfset loc.result.Group=loc.QNominal.nomGroup>
				<cfset loc.result.Name=loc.QNominal.nomTitle>
				<cfset loc.result.Type=loc.QNominal.nomType>
				<cfset loc.result.NomAcct=loc.QNominal.nomBalAcct>
				<cfset loc.result.NomSign=loc.QNominal.nomSign>
			</cfif>
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="processSheet" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset var rec={}>
		<cfset loc.result={}>
		<cfset loc.accountRef="">
		<cfset loc.inFilter=true>
		
		<cfspreadsheet action="read" src="#args.fileName#" name="spready">
		<cfset SpreadsheetSetActiveSheet(spready,"Bank Recon")>
		<cfset reconInfo=SpreadsheetRead(args.fileName,"Bank Recon")>
		<cfloop from="1" to="#reconInfo.rowCount#" index="i" step="50">
			<cfspreadsheet action="read" src="#args.fileName#" sheetname="Bank Recon" query="QRecon"
				columns="1-6" rows="#i#-#i+49#" headerrow="1" excludeHeaderRow="false">
			<!---<cfoutput>#args.fileName#<br>Lines #i# to #i+49# of #reconInfo.rowCount#<br></cfoutput>--->
			<cfloop query="QRecon">
				<cfif len(TYPE) AND Left(DESCRIPTION,4) NEQ "SKIP">
					<cfset rec={}>
					<cfif ListLen(DATE,"/") IS 3>
						<cfset loc.dateStr=ListToArray(DATE,"/")>
						<cfset rec.date=LSDateFormat(CreateDate(loc.dateStr[3],loc.dateStr[1],loc.dateStr[2]),"yyyy-mm-dd")>
					<cfelse>
						<cfset rec.date=DATE>
					</cfif>
					<cfset rec.Balance=BALANCE>
					<cfset rec.cr=val(CR)>
					<cfset rec.description=Left(DESCRIPTION,50)>
					<cfset rec.dr=val(DR)>
					<cfset rec.type=TYPE>

				<!---	<cfif Find("_",TYPE,1)>	--->
						<cfswitch expression="#TYPE#"><!--- fix lloyds tinkering - arseholes! --->
							<cfcase value="FASTER_PAYMENTS_INCOMING">
								<cfset rec.type = "FPI">
							</cfcase>
							<cfcase value="BANK_GIRO_CREDIT">
								<cfset rec.type = "BGC">
							</cfcase>
							<cfcase value="DIRECT_DEBIT">
								<cfset rec.type = "DD">
							</cfcase>
							<cfcase value="FASTER_PAYMENTS_OUTGOING">
								<cfset rec.type = "FPO">
							</cfcase>
							<cfcase value="DEBIT_CARD">
								<cfset rec.type = "DEB">
							</cfcase>
							<cfcase value="PAYMENT">
								<cfset rec.type = "PAY">
							</cfcase>
							<cfcase value="BILL_PAYMENT">
								<cfset rec.type = "BP">
							</cfcase>
							<cfcase value="STANDING_ORDER">
								<cfset rec.type = "STO">
							</cfcase>
							<cfcase value="DEPOSIT">
								<cfset rec.type = "DEP">
							</cfcase>
							<cfcase value="TRANSFER">
								<cfset rec.type = "TRN">
							</cfcase>
							<cfdefaultcase>
								<cfset rec.type=Left(TYPE,10)>
							</cfdefaultcase>
						</cfswitch>
					<!---<cfelse>
						<cfset rec.type=TYPE>
					</cfif>--->

					<cfif StructKeyExists(args,"form")>
						<cfset loc.inRange=rec.date GTE args.form.srchDateFrom AND (rec.date LTE args.form.srchDateTo OR len(args.form.srchDateTo) IS 0)>
					<cfelse>
						<cfset loc.inRange=true>
					</cfif>
					<cfif len(args.form.srchFilter)>
						<cfset loc.inFilter = Find(args.form.srchFilter,rec.description,1) GT 0>
					</cfif>
					<cfif loc.inRange AND loc.inFilter>
						<cfswitch expression="#rec.TYPE#">
							<cfcase value="FPI|BGC|BP|DEP|COR|SO" delimiters="|">
								<cfif Find("CARDNET",rec.description)>	<!--- Card Receipts --->
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
									<cfset rec.description=ListDeleteAt(rec.description,2," ")>
									<cfset rec.description=ListDeleteAt(rec.description,2," ")>
								<cfelseif Left(rec.description,3) EQ "500">		<!--- Banking --->
									<cfset rec.description="DEPOSIT #rec.description#">
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelseif Find("PAYPOINT COLLECTIO",rec.description)>	<!--- PayPoint commission --->
									<cfset rec.description="PPCOMM">
									<cfset loc.accountRef=ExtractRef(refs.suppliers,rec)>
								<cfelseif ReFindNoCase("REFUND",rec.description,1,false)>
									<cfset rec.description="CHARGES #rec.description#">
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelseif Find("AGENT COLLECTIONS",rec.description)>	<!--- Simple Payments --->
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelseif Find("HMRC",rec.description)>	<!--- HMRC VAT --->
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelseif rec.cr GT 0>
									<cfset loc.accountRef=ExtractRef(refs.customers,rec)>
								<cfelse>
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								</cfif>
							</cfcase>
							<cfcase value="FPO|DD|DEB|PAY|DC|CHG" delimiters="|">
								<cfif Find("LOAN",rec.description)> <!--- bank loan --->
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelseif Find("PAYPOINT COLLECTIO",rec.description)>
									<cfset rec.description="#rec.description#-#rec.dr#">	<!--- paypoint collections --->
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelseif ReFindNoCase("Fee|Interest",rec.description,1,false)>
									<cfset rec.description="CHARGES #rec.description#">
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								<cfelse>
									<cfset loc.accountRef=ExtractRef(refs.suppliers,rec)>
								</cfif>
							</cfcase>
							<cfcase value="CHQ">
								<cfif rec.dr GT 900>
									<cfset rec.description="SMITHS #NumberFormat(Replace(rec.description,"_",""),'000000')#">
									<cfset loc.accountRef=ExtractRef(refs.suppliers,rec)>
								<cfelseif len(rec.description) gt 3>
									<cfset loc.accountRef=ExtractRef(refs.suppliers,rec)>
								<cfelse>
									<cfset loc.accountRef=ExtractRef(refs.cheques,rec)>
								</cfif>
							</cfcase>
							<cfdefaultcase>
								<cfif rec.TYPE eq "TFR">	<!--- transfers can be dr or cr --->
									<cfif rec.cr GT 0>
										<cfif ReFindNoCase("KCC LOAN|LISA SHOP|QUICKSTOP",rec.description)> <!--- bank loan --->
											<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
										<cfelse>
											<cfset loc.accountRef=ExtractRef(refs.customers,rec)>
										</cfif>
										<!---<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>--->
									<cfelse>
										<cfset loc.accountRef=ExtractRef(refs.suppliers,rec)>								
									</cfif>
								<cfelse>
									<cfset loc.accountRef=ExtractRef(refs.nominal,rec)>
								</cfif>
							</cfdefaultcase>
						</cfswitch>
						<!---<cfdump var="#rec#" label="rec" expand="true">--->
					<cfelse>
						<!---<cfset ArrayAppend(refs.skipped,rec)>--->
					</cfif>
				</cfif>
				<cfif Find("Balance Brought Forward",DESCRIPTION)><cfbreak></cfif>
			</cfloop>
		</cfloop>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="checkClientTran" access="public" returntype="string">
		<cfargument name="acct" type="struct" required="yes">
		<cfargument name="tran" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result="checkClientTran">
		<cfset loc.trnTotalNum=tran.cr-tran.dr>
		<cfset loc.tranType="pay">
		<cfquery name="loc.QCheckExists" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblTrans,tblAccount
			WHERE trnAccountID=accID
			AND trnAccountID=4
			AND trnClientID=#acct.clientID#
			AND trnDate='#tran.date#'
			AND trnLedger='sales'
			AND trnType='pay'
		<!--- 	AND trnDesc='#tran.description#'	added to fix a/c 217 2 payments on same day --->
		</cfquery>
		<cfif loc.QCheckExists.recordcount IS 0>
			<cfset loc.parm.database=application.site.datasource1>
			<cfset loc.parm.header.trnID=0>
			<cfset loc.parm.header.allocate=false>
			<cfset loc.parm.header.accID=acct.ID>
			<cfset loc.parm.header.trnClientID=acct.clientID>
			<cfset loc.parm.header.trnClientRef=acct.Code>
			<cfset loc.parm.header.accType=acct.Type>
			<cfset loc.parm.header.PaymentAccounts=acct.PayAcc>
			<cfset loc.parm.header.accNomAcct=acct.NomAcct>
			<cfset loc.parm.header.tranType=loc.tranType>
			<cfset loc.parm.header.trnType=loc.tranType>
			<cfset loc.parm.header.trnAmnt1=abs(loc.trnTotalNum)>
			<cfset loc.parm.header.trnAmnt2=0>
			<cfset loc.parm.header.trnRef=tran.type>
			<cfset loc.parm.header.trnMethod="ib">
			<cfset loc.parm.header.trnDesc=tran.description>
			<cfset loc.parm.header.trnDate=tran.date>
			<cfset loc.parm.items=[]>
			<cfif acct.process>
				<cfset insertCount++>
				<cfset loc.paymentRecord = acc.SaveAccountTransRecord(loc.parm)>
				<!---<cfdump var="#loc.paymentRecord#" label="paymentRecord" expand="no">--->
				<cfset loc.result='<span class="insert">Created: #loc.paymentRecord.tranID#</span>'>
			<cfelse>
				<!---<cfdump var="#loc#" label="INSERT" expand="false">--->
				<cfset insertCount++>
				<cfset loc.result='<span class="insert">to be inserted</span>'>
			</cfif>
		<cfelseif loc.QCheckExists.recordcount GT 1>
			<cfset loc.result="Ambiguous">
			<cfdump var="#loc.QCheckExists#" label="checkClientTran" expand="no">
		<cfelse>
			<cfset loc.result="Found: #loc.QCheckExists.trnID#">
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="checkAccountTran" access="public" returntype="string">
		<cfargument name="acct" type="struct" required="yes">
		<cfargument name="tran" type="struct" required="yes">
		<!---<cfdump var="#arguments#" label="checkAccountTran" expand="false">--->
		<cfset var loc={}>
		<cfset loc.result="checkAccountTran">
		<cfset loc.trnTotalNum=tran.dr-tran.cr>
		
		<cfif acct.Type eq "sales">
			<cfif loc.trnTotalNum LT 0><cfset loc.tranType="pay"><cfelse><cfset loc.tranType="rfd"></cfif>		
		<cfelse>
			<cfif loc.trnTotalNum LT 0><cfset loc.tranType="rfd"><cfelse><cfset loc.tranType="pay"></cfif>
		</cfif>
		
		<cfquery name="loc.QCheckExists" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblTrans,tblAccount
			WHERE trnAccountID=accID
			AND trnAccountID=#acct.ID#
			AND trnDate='#tran.date#'
			AND trnRef='#tran.type#'
			AND trnDesc='#tran.description#'
		</cfquery>
		<cfif loc.QCheckExists.recordcount IS 0>
			<cfset loc.parm.database=application.site.datasource1>
			<cfset loc.parm.header.trnID=0>
			<cfset loc.parm.header.allocate=false>
			<cfset loc.parm.header.accID=acct.ID>
			<cfset loc.parm.header.accType=acct.Type>
			<cfset loc.parm.header.trnClientID=0>
			<cfset loc.parm.header.trnClientRef="">
			<cfset loc.parm.header.PaymentAccounts=acct.PayAcc>
			<cfset loc.parm.header.accNomAcct=acct.NomAcct>
			<cfset loc.parm.header.tranType=loc.tranType>
			<cfset loc.parm.header.trnType=loc.tranType>
			<cfset loc.parm.header.trnAmnt1=abs(loc.trnTotalNum)>
			<cfset loc.parm.header.trnAmnt2=0>
			<cfset loc.parm.header.trnRef=tran.type>
			<cfset loc.parm.header.trnMethod="ib">
			<cfset loc.parm.header.trnDesc=tran.description>
			<cfset loc.parm.header.trnDate=tran.date>
			<cfset loc.parm.items=[]>
			<cfif acct.process>
				<cfset insertCount++>
				<cfset loc.paymentRecord = acc.SaveAccountTransRecord(loc.parm)>
				<!---<cfdump var="#loc.paymentRecord#" label="paymentRecord" expand="no">--->
				<cfset loc.result='<span class="insert">Created: #loc.paymentRecord.tranID#</span>'>
			<cfelse>
				<cfset insertCount++>
				<cfset loc.result='<span class="insert">to be inserted</span>'>
			</cfif>
		<cfelseif loc.QCheckExists.recordcount GT 1>
			<cfset loc.result="Ambiguous">
			<!---<cfdump var="#loc.QCheckExists#" label="checkAccountTran" expand="no">--->
		<cfelse>
			<cfset loc.result="Found: #loc.QCheckExists.trnID#">
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="checkNominalTran" access="public" returntype="string">
		<cfargument name="acct" type="struct" required="yes">
		<cfargument name="tran" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result="checkNominalTran">
		<!---<cfdump var="#acct#" label="acct" expand="no">
		<cfdump var="#tran#" label="tran" expand="no">--->
		<cfquery name="loc.QCheckExists" datasource="#application.site.datasource1#">
			SELECT trnID,niAmount
			FROM tblTrans,tblNominal,tblNomItems
			WHERE nomID=#acct.ID#
			AND niTranID=trnID
			AND niNomID=nomID
			AND trnDate='#tran.date#'
			AND trnRef='#tran.type#'
			AND trnDesc='#tran.description#'
			AND trnLedger='nom'
		</cfquery>
		<cfif loc.QCheckExists.recordcount IS 0>
			<cfset loc.parm.items=[]>
			<cfset loc.parm.database=application.site.datasource1>
			<cfset loc.parm.header.trnID=0>
			<cfset loc.parm.header.trnClientID=0>
			<cfset loc.parm.header.trnClientRef="">
			<cfset loc.parm.header.allocate=true>
			<cfset loc.parm.header.accType='nom'>
			<cfset loc.parm.header.trnType='nom'>
			<cfset loc.parm.header.tranType='nom'>
			<cfset loc.parm.header.trnAmnt1=0>
			<cfset loc.parm.header.trnAmnt2=0>
			<cfset loc.parm.header.trnRef=tran.type>
			<cfset loc.parm.header.trnMethod="ib">
			<cfset loc.parm.header.trnDesc=tran.description>
			<cfset loc.parm.header.trnDate=tran.date>
			<cfset ArrayAppend(loc.parm.items,{
				"nomID"=acct.id,
				"nomCode"=acct.code,
				"nomAmount"=tran.dr-tran.cr
			})>
			<cfset ArrayAppend(loc.parm.items,{
				"nomID"=41,
				"nomCode"="BANK",
				"nomAmount"=tran.cr-tran.dr
			})>
			<cfif NOT acct.ignore>
				<cfif acct.process>
					<cfset insertCount++>
					<cfset loc.nominalRecord = acc.SaveNominalTransRecord(loc.parm)>
					<!---<cfdump var="#loc.nominalRecord#" label="nominalRecord" expand="no">--->
					<cfset loc.result='<span class="insert">Created: #loc.nominalRecord.tranID#</span>'>
				<cfelse>
					<cfset insertCount++>
					<cfset loc.result='<span class="insert">to be inserted</span>'>
				</cfif>
			<cfelse>
				<cfset loc.result='<span class="insert">to be IGNORED</span>'>			
			</cfif>
		<cfelseif loc.QCheckExists.recordcount GT 1>
			<cfset loc.result="Ambiguous">
		<cfelse>
			<cfset loc.result="Found: #loc.QCheckExists.trnID#">
		</cfif>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="outputData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="data" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cftry>
			<cfoutput>
			<table class="tableStyle" border="1">
				<cfloop collection="#data#" item="loc.key">
					<cfset loc.tran=StructFind(data,loc.key)>
					<cfset loc.rec=GetPostingAccount(loc.key)>
					<cfset loc.rec.process=args.process>
					<cfif NOT StructKeyExists(loc.rec,"Code")>
						<cfdump var="#loc.rec#" label="GetPostingAccount" expand="false">
					<cfelse>
						<tr class="#loc.rec.class#">
							<!--- account header --->
							<cfif loc.rec.class IS "fuschia">
								<th><a href="clientPayments.cfm?rec=#loc.rec.Code#" target="payments">#loc.rec.Code#</a></th>
							<cfelseif loc.rec.class IS "blue">
								<th><a href="tranMain2.cfm?acc=#loc.rec.ID#" target="purtrans" style="color:##fff">#loc.rec.Code#</a></th>
							<cfelse>
								<th>#loc.rec.Code#</th>
							</cfif>
							<th>#loc.rec.Group#</th>
							<th>#loc.rec.Name#</th>
							<th>#loc.rec.Type#</th>
							<th>(#loc.key#)</th>
						</tr>
						<tr>
							<!--- entries --->
							<td colspan="6">
								<table class="tableStyle" border="1">
									<tr>
										<th>type</th>
										<th>date</th>
										<th>description</th>
										<th align="right" width="80">dr</th>
										<th align="right" width="80">cr</th>							
										<th>status</th>
									</tr>
									<cfset loc.loopcount=0>
									<cfloop array="#loc.tran.entries#" index="loc.item">
										<cfset loc.loopcount++>
										<tr>
											<td>#loc.item.type#</td>
											<td>#loc.item.date#</td>
											<td width="250">#loc.item.description#</td>
											<td align="right">#loc.item.dr#</td>
											<td align="right">#loc.item.cr#</td>
											<td>
												<cfif loc.rec.posttype eq "client">
													#checkClientTran(loc.rec,loc.item)#
												<cfelseif loc.rec.posttype eq "account">
													#checkAccountTran(loc.rec,loc.item)#
												<cfelseif loc.rec.posttype eq "nom">
													#checkNominalTran(loc.rec,loc.item)#
												</cfif>
											</td>
										</tr>
									</cfloop>
								</table>
							</td>
						</tr>
					</cfif>
				</cfloop>
			</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="outputData cfcatch" expand="no">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
<!--- main --->
<cftry>
	<cfflush interval="200">
	<cfsetting requesttimeout="900">
	<cfset dataDir="#application.site.dir_data#spreadsheets\">
	<cfif StructKeyExists(form,"fieldnames")>
		<cfif StructKeyExists(form,"srchFile")AND ListLen(form.srchFile,",") GT 0>
			<cfloop list="#form.srchFile#" index="fileSrc">
				<cfset parm={}>
				<cfset parm.form=form>
				<cfset parm.process=form.srchMode EQ 2>
				<cfset parm.fileName="#application.site.dir_data#spreadsheets\#fileSrc#">
				<cfoutput><p class="title">#parm.fileName#</p></cfoutput>
				<cfset processSheet(parm)>
				<cfif StructKeyExists(form,"srchSuppliers")><cfset outputData(parm,refs.suppliers)></cfif>
				<cfif StructKeyExists(form,"srchNominal")><cfset outputData(parm,refs.nominal)></cfif>
				<cfif StructKeyExists(form,"srchCustomers")><cfset outputData(parm,refs.customers)></cfif>
			</cfloop>
			<cfoutput>
				<cfif form.srchMode eq "2">
					<p>#insertCount# records inserted.</p>
				<cfelse>
					<p>#insertCount# records to insert.</p>
				</cfif>
			</cfoutput>
			<cfset fileSrc="">
			<!---<cfdump var="#refs#" label="refs" expand="false">--->
		<cfelse>
			No files selected.
		</cfif>
	</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

<cfdirectory directory="#dataDir#" action="list" name="QDir">
<h2><a href="spread.cfm">Import Spreadsheet</a></h2>
<cfoutput>
<form name="processForm" method="post" enctype="multipart/form-data">
	<table class="tableStyle" border="1" width="500">
		<tr>
			<th colspan="2" align="left">Import Settings</th>
		</tr>
		<tr>
			<td>Transaction Dates From</td>
			<td><input type="text" name="srchDateFrom" value="#srchDateFrom#" size="15" class="datepicker" /></td>
		</tr>
		<tr>
			<td>Transaction Dates To</td>
			<td><input type="text" name="srchDateTo" value="#srchDateTo#" size="15" class="datepicker" /></td>
		</tr>
		<tr>
			<td>Filter Key</td>
			<td><input type="text" name="srchFilter" value="#srchFilter#" size="15" /></td>
		</tr>
		<tr>
			<td>Processing Mode</td>
			<td>
				<input type="radio" name="srchMode" value="1" checked="checked" /> View Only
				<input type="radio" name="srchMode" value="2" /> Import Data
			</td>
		</tr>
		<tr>
			<td>Include types:</td>
			<td>
				<input type="checkbox" name="srchSuppliers"<cfif srchSuppliers eq "on"> checked="checked"</cfif> /> Suppliers &nbsp;
				<input type="checkbox" name="srchNominal"<cfif srchNominal eq "on"> checked="checked"</cfif> /> Nominal &nbsp;
				<input type="checkbox" name="srchCustomers"<cfif srchCustomers eq "on"> checked="checked"</cfif> /> Customers &nbsp;
			</td>
		</tr>
		<tr>
			<td>Options:</td>
			<td>
				<input type="checkbox" name="srchUnknown"<cfif srchUnknown eq "on"> checked="checked"</cfif> /> Ignore Unknown Trans?
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table width="100%" class="tableFiles">
					<tr>
						<th align="left">##</th>
						<th align="left">Select</th>
						<th align="left">File</th>
						<th align="left">Date Modified</th>
						<th align="right">Size</th>
					</tr>
					<cfloop query="QDir">
						<cfif type eq "file">
							<tr>
								<td>#currentrow#</td>
								<td><input type="checkbox" name="srchFile" value="#name#" <cfif ListFind(srchFile,name,",")> checked </cfif> /></td>
								<td><a href="#application.site.url_data#spreadsheets/#name#" title="download spreadsheet">#name#</a></td>
								<td>#LSDateFormat(datelastmodified,"dd-mmm-yyyy")#</td>
								<td align="right">#FormatBytes(size)#</td>
							</tr>
						</cfif>
					</cfloop>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="submit" name="btnSubmit" value="Process selected files" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>
</body>
</html>