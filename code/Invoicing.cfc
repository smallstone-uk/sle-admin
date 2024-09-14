<cfcomponent displayname="invoicing" extends="core">

	<cffunction name="LoadInvoiceRun" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var charge={}>
		<cfset var r={}>
		<cfset var QClients="">
		<cfset var QCharges="">
		<cfset var QRounds="">
		<cfset var QGetInv="">
		<cfset result.rounds=[]>
		<cfset result.list=[]>
		<cfset result.post=[]>
		<cfset result.email=[]>
		<cfset result.weekly=[]>
		
		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder,tblClients,tblStreets2,tblRoundItems,tblrounds
				WHERE ordActive=1
				<cfif StructKeyExists(args.form,"client") AND val(args.form.client) neq 0>
					AND cltID IN (#args.form.client#)
				<cfelse>
					AND cltAccountType IN ('M','H','W') <!--- Only Monthly, Weekly or On Hold will get an invoice --->
					<!--- AND (cltAccountType='M' OR cltAccountType='W') Only Monthly and Weekly will get an invoice --->
				</cfif>
				AND ordClientID=cltID
				AND ordStreetCode=stID
				AND riOrderID=ordID
				AND riRoundID = rndID
				AND riDay='#DateFormat(args.form.delDate,"DDD")#'
				AND rndActive = 1
				<cfif StructKeyExists(args.form,"accOrder")>ORDER BY cltRef asc<cfelse>ORDER BY riRoundID asc, riOrder asc</cfif>
			</cfquery>
			<cfset result.clientCount=QClients.recordcount>
			<cfquery name="QRounds" datasource="#args.datasource#">
				SELECT *
				FROM tblRounds
				WHERE rndActive=1
			</cfquery>
			<cfloop query="QRounds">
				<cfset r={}>
				<cfset r.RoundID=rndID>
				<cfset r.RoundTitle=rndTitle>
				<cfset ArrayAppend(result.rounds,r)>
			</cfloop>
			<cfloop query="QClients">
				<cfquery name="QGetInv" datasource="#args.datasource#">
					SELECT *
					FROM tblTrans
					WHERE trnClientID=#QClients.cltID#
					AND trnOrderID=#QClients.ordID#
					AND trnDate='#LSDateFormat(args.form.invDate,"yyyy-mm-dd")#'
					AND trnLedger='sales'
					AND trnType='inv'
					LIMIT 1;
				</cfquery>
				<cfquery name="QRounds" datasource="#args.datasource#">
					SELECT rndTitle
					FROM tblRounds
					WHERE rndID=#riRoundID#
					LIMIT 1;
				</cfquery>
				<cfset item={}>
				<cfset item.grandtotal=0>
				<cfset item.debittotal=0>
				<cfset item.credittotal=0>
				<cfset item.debitchargetotal=0>
				<cfset item.creditchargetotal=0>
				<cfset item.debit=[]>
				<cfset item.credit=[]>
				
				<cfset item.ID=cltID>
				<cfset item.ordID=ordID>
				<cfset item.ordContact=ordContact>
				<cfset item.Ref=cltRef>
				<cfset item.cltShowBal=cltShowBal>
				<cfset item.AccountType=cltAccountType>
				<cfset item.PaymentType=cltPaymentType>
				
				<cfset item.InvDeliver=cltInvDeliver>
				<cfset item.PayMethod=cltPayMethod>
				<cfset item.PayType=cltPayType>
				
				<cfset item.InvoiceType=cltInvoiceType>
				<cfset item.InvoiceRef=QGetInv.trnRef>
				<cfif item.InvDeliver is "post">
					<cfset item.RoundID=1>
				<cfelseif item.InvDeliver is "email">
					<cfset item.RoundID=2>
				<cfelse>
					<cfset item.RoundID=riRoundID>
				</cfif>
				<cfset item.rndTitle = rndTitle>
				<cfset item.riOrder = riOrder>
				<cfset item.Dept=cltDept>
				<cfif len(cltName) AND len(cltCompanyName)>
					<cfset item.ClientName="#cltName# #cltCompanyName#">
				<cfelse>
					<cfset item.ClientName="#cltName##cltCompanyName#">
				</cfif>
				<cfset item.Address="#ordHouseNumber# #ordHouseName# #stName#">
				<cfset item.debit=[]>
				<cfset item.credit=[]>
				<cfquery name="QCharges" datasource="#args.datasource#">
					SELECT tblDelItems.*,tblPublication.pubID,tblPublication.pubTitle
					FROM tblDelItems
					INNER JOIN tblPublication ON pubID=diPubID
					WHERE diOrderID = #QClients.ordID#
					AND diDatestamp >= '#args.form.fromDate#'
					AND diDatestamp <= '#args.form.toDate#'
					ORDER BY diDatestamp asc
				</cfquery>
				<cfset item.grandtotal=0>
				<cfset item.debittotal=0>
				<cfset item.credittotal=0>
				<cfset item.debitchargetotal=0>
				<cfset item.creditchargetotal=0>
				<cfloop query="QCharges">
					<cfset charge={}>
					<cfset charge.ID=QCharges.diID>
					<cfset charge.ClientID=QCharges.diClientID>
					<cfset charge.OrderID=QCharges.diOrderID>
					<cfset charge.BatchID=QCharges.diBatchID>
					<cfset charge.Pub=QCharges.pubTitle>
					<cfset charge.Type=QCharges.diType>
					<cfset charge.Date=LSDateFormat(QCharges.diDate,"DD/MM/YYYY")>
					<cfset charge.Qty=QCharges.diQty>
					<cfset charge.Price=QCharges.diPrice>
					<cfset charge.Charge=QCharges.diCharge>
					<cfset charge.Voucher=QCharges.diVoucher>
					<cfset charge.Test=QCharges.diTest>
					<cfif charge.type is "debit">
						<cfset item.debittotal=item.debittotal+(charge.Price*charge.Qty)>
						<cfset item.debitchargetotal=item.debitchargetotal+charge.Charge>
						<cfset ArrayAppend(item.debit,charge)>
					<cfelse>
						<cfset item.credittotal=item.credittotal+charge.Price>
						<cfset item.creditchargetotal=item.creditchargetotal+charge.Charge>
						<cfset ArrayAppend(item.credit,charge)>
					</cfif>
				</cfloop>
				
				<cfset item.grandtotal=item.debittotal+item.credittotal+item.debitchargetotal+item.creditchargetotal>
				<cfif item.grandtotal neq 0 AND ArrayLen(item.debit) OR ArrayLen(item.credit)>
					<cfif item.InvDeliver neq "none">
						<cfif item.InvDeliver is "deliver">
							<cfset ArrayAppend(result.list,item)>
						<cfelseif item.InvDeliver is "post">
							<cfset ArrayAppend(result.post,item)>
						<cfelse>
							<cfset ArrayAppend(result.email,item)>
						</cfif>
					<cfelse>
						<cfset ArrayAppend(result.weekly,item)>
					</cfif>
				</cfif>
			</cfloop>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="LoadInvoiceRun" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="CheckDaysCharged" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.Charges" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT DATE_FORMAT(diDate,'%y%U') AS weekNo, DATE_FORMAT(diDate,'%a') AS dayName,diDate, sum( diPrice ) AS price, sum( diCharge ) AS charge, count(diID) AS num
				FROM `tbldelitems`
				WHERE `diDate`
				BETWEEN '#args.form.fromDate#'
				AND '#args.form.toDate#'
				GROUP BY diDate
			</cfquery>
			<cfset loc.result.Charges = loc.Charges>
			<cfset loc.result.grid = {}>
			<cfloop query="loc.Charges">
				<cfif NOT StructKeyExists(loc.result.grid,weekNo)>
					<cfset StructInsert(loc.result.grid,weekNo,{"theDate" = diDate})>
				</cfif>
				<cfset loc.thisWeek = StructFind(loc.result.grid,weekNo)>
				<cfset StructInsert(loc.thisWeek,dayName,{
					"Price" = price,
					"Charge" = charge,
					"Count" = num,
					"Date" = diDate
				})>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="CheckDaysCharged" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadStatement" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.cltShowBal = args.cltShowBal>
		<cfset loc.result.bfwd = 0>
		<cfset loc.result.balance = 0>
		<cfif args.cltShowBal>
			<cfquery name="loc.QTrans" datasource="#args.datasource#">
				SELECT trnID,trnRef,trnType,trnDate,trnAmnt1,trnAmnt2
				FROM tblTrans
				WHERE trnClientRef=#val(args.Ref)#
				AND trnAlloc=0
				AND trnDate < '#args.invDate#'
				ORDER BY trnDate ASC, trnID ASC
			</cfquery>
			<cfif loc.QTrans.recordCount gt 0>
				<cfset loc.lineCount = 0>
				<cfset loc.result.trans = []>
				<cfset loc.lastRec = loc.QTrans.recordCount - 5>
				<cfloop query="loc.QTrans">
					<cfif loc.lineCount lt loc.lastRec>
						<cfset loc.result.bfwd += (trnAmnt1+trnAmnt2)>
						<cfset loc.result.bfDate = trnDate>
					<cfelse>
						<cfset ArrayAppend(loc.result.trans,{
							"trnID" = trnID,
							"trnType" = trnType,
							"trnDate" = trnDate,
							"trnRef" = trnRef,
							"trnAmnt1" = trnAmnt1,
							"trnAmnt2" = trnAmnt2
						})>
						<cfset loc.result.balance += (trnAmnt1+trnAmnt2)>
					</cfif>
					<cfset loc.lineCount++>
				</cfloop>
			</cfif>
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadInvoice" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var charge={}>
		<cfset var set={}>
		<cfset var vset={}>
		<cfset var re={}>
		<cfset var QClients="">
		<cfset var QOrders="">
		<cfset var QCharges="">
		<cfset var QCredit="">
		<cfset var QDebit="">
		<cfset var QReturns="">
		<cfset var QVoucher="">
		<cfset var QReturnCredit="">
		<cfset var pub="">
		<cfset var vpub="">
		<cfset var pubID="">
		<cfset var vpubID="">
		<cfset var RCpubID="">
		<cfset var qty=0>
		<cfset var RpubID=0>
		<cfset var Rpub=0>
		
		<cfset var loc = {}>
		
		<cfset result.debitGroup={}>
		<cfset result.creditGroup={}>
		<cfset result.voucherGroup={}>
		<cfset result.debit=ArrayNew(1)>
		<cfset result.credit=ArrayNew(1)>
		<cfset result.vouchers=ArrayNew(1)>
		<cfset result.grandtotal=0>
		<cfset result.debittotal=0>
		<cfset result.credittotal=0>
		<cfset result.vouchertotal=0>
		<cfset result.debitchargetotal=0>
		<cfset result.creditchargetotal=0>
		<cfset result.TotalNet=0>
		<cfset result.TotalVAT=0>
		<cfset result.total=0>
		<cfset result.vat0=0>
		<cfset result.vat20=0>
		<cfset result.vat5=0>
		<cfset result.net0=0>
		<cfset result.net20=0>
		<cfset result.net5=0>
		<cfset result.delChargeTotal=0>
		<cfset result.NetDisc=0>
		<cfset result.transType="inv">
		<cfset result.invDate = args.invDate>
		
		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT *
				FROM tblClients
				WHERE cltID=#val(args.clientID)#
				LIMIT 1;
			</cfquery>
			<cfset result.InvoiceType=QClients.cltInvoiceType>
			<cfset result.ID=QClients.cltID>
			<cfset result.Ref=QClients.cltRef>
			<cfset result.Title=QClients.cltTitle>
			<cfset result.Initial=QClients.cltInitial>
			<cfset result.ClientName=QClients.cltName>
			<cfset result.Dept=QClients.cltDept>
			<cfset result.CompanyName=QClients.cltCompanyName>
			<cfset result.Addr1=QClients.cltAddr1>
			<cfset result.Addr2=QClients.cltAddr2>
			<cfset result.Town=QClients.cltTown>
			<cfset result.City=QClients.cltCity>
			<cfset result.County=QClients.cltCounty>
			<cfset result.Postcode=QClients.cltPostCode>
			<cfset result.Discount=QClients.cltDiscount/100>
			<cfset result.cltPayMethod = QClients.cltPayMethod>
			<cfset result.debit=ArrayNew(1)>
			<cfset result.credit=ArrayNew(1)>
			
			<cfset result.datasource = args.datasource>
			<cfset result.cltShowBal = QClients.cltShowBal>
			<cfset result.statement = LoadStatement(result)>
			
			<cfquery name="QOrders" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder
				INNER JOIN tbldelcharges ON delCode = ordDeliveryCode
				INNER JOIN tblstreets2 ON stID = ordStreetCode
				WHERE ordID = #args.ordID#
				AND ordActive=1
				LIMIT 1;
			</cfquery>
			<cfset result.ordID=args.ordID>
			<cfset result.ordRef=QOrders.ordRef>
			<cfset result.ordContact=QOrders.ordContact>
			<cfset result.delPrice = QOrders.delPrice1>
			<cfif QOrders.ordDifferent>
				<cfset result.deliverTo="To: #QOrders.ordHouseName# #QOrders.ordHouseNumber# #QOrders.stName#">
			<cfelse><cfset result.deliverTo=""></cfif>
			<cfquery name="QCharges" datasource="#args.datasource#" result="result.QChargesResult">
				SELECT tblDelItems.*,tblPublication.pubID,tblPublication.pubTitle,tblPublication.pubGroup
				FROM tblDelItems
				INNER JOIN tblPublication ON pubID=diPubID
				WHERE diOrderID=#QOrders.ordID#
				<cfif StructKeyExists(args,"onlycredits") AND args.onlycredits is 1>AND diType='credit'</cfif>
				<cfif StructKeyExists(args,"fixflag") AND args.fixflag is 1>
					AND diDatestamp >= '#LSDateFormat(args.fromDate,"yyyy-mm-dd")#'
					AND diDatestamp <= '#LSDateFormat(args.toDate,"yyyy-mm-dd")#'
				<cfelse>
					<cfif StructKeyExists(args,"InvID") AND args.InvID neq 0>
						AND diInvoiceID=#args.InvID#
					<cfelse>
						AND diDatestamp >= '#LSDateFormat(args.fromDate,"yyyy-mm-dd")#'
						AND diDatestamp <= '#LSDateFormat(args.toDate,"yyyy-mm-dd")#'
						AND diInvoiceID=0
					</cfif>
				</cfif>
				ORDER BY pubGroup asc, pubTitle asc, diPrice asc
			</cfquery>
			<cfset result.QCharges=QCharges>
			<cfloop query="QCharges">
				<cfset charge={}>
				<cfset charge.ID=QCharges.diID>
				<cfset charge.ClientID=QCharges.diClientID>
				<cfset charge.OrderID=QCharges.diOrderID>
				<cfset charge.BatchID=QCharges.diBatchID>
				<cfset charge.PubID=QCharges.pubID>
				<cfset charge.Pub=QCharges.pubTitle>
				<cfset charge.Group=QCharges.pubGroup>
				<cfset charge.Type=QCharges.diType>
				<cfset charge.Date=LSDateFormat(QCharges.diDate,"DD/MM/YYYY")>
				<cfset charge.Qty=QCharges.diQty>
				<cfset charge.Price=QCharges.diPrice>
				<cfset charge.Charge=QCharges.diCharge>
				<cfset charge.Voucher=val(QCharges.diVoucher)>
				<cfset charge.Test=QCharges.diTest>
				<cfset charge.Reason=QCharges.diReason>
				<cfset charge.VATRate=QCharges.diVATAmount>
				<cfset charge.Net=charge.Price/(1+charge.VATRate)>
				<cfset charge.VAT=charge.Price-charge.Net>
				
				<cfif charge.Group is "Magazine"><cfset charge.Group="xx"&charge.Group></cfif>
				<cfset pubID=charge.Group & charge.PubID & charge.Price & charge.VATRate & charge.Reason>
				<cfset set={}>
				<cfset set.sort=charge.Group & charge.Pub>
				<cfset set.title=charge.Pub>
				<cfset set.group=ReReplace(charge.Group,"xx","","all")>
				<cfset set.reason=charge.Reason>
				<cfset set.qty=0>
				<cfset set.Date=charge.Date>
				<cfset set.price=DecimalFormat(charge.Price)>
				<cfset set.vat=charge.VATRate>
				
				<cfswitch expression="#charge.type#">
					<cfcase value="debit">
						<cfif charge.Voucher neq 0>
							<cfquery name="QVoucher" datasource="#args.datasource#">
								SELECT *
								FROM tblVoucher
								WHERE vchID=#charge.Voucher#
								LIMIT 1;
							</cfquery>
							<cfset vset={}>
							<cfset vset.sort=charge.Group & charge.Pub>
							<cfif QVoucher.vchType is "pc">
								<cfif QVoucher.vchDiscount lt 100>
									<cfset vset.title="#charge.Pub# #int(QVoucher.vchDiscount)#% Off">
								<cfelse>
									<cfset vset.title=charge.Pub>
								</cfif>
							<cfelse>
								<cfset vset.title="#charge.Pub# &pound;#QVoucher.vchDiscount# Off">
							</cfif>
							<cfset vset.group=charge.Group>
							<cfset vset.reason=charge.Reason>
							<cfset vset.qty=0>
							<cfset vset.Date=charge.Date>
							<cfif QVoucher.vchType is "pc">
								<cfif QVoucher.vchDiscount lt 100>
									<cfset vset.price=charge.Price*QVoucher.vchDiscount/100>
									<cfset vset.price=charge.Price-vset.price>
								<cfelse>
									<cfset vset.price=charge.Price>
								</cfif>
							<cfelse>
								<cfset vset.price=QVoucher.vchDiscount>	<!--- <cfset vset.price=charge.Price-QVoucher.vchDiscount>--->
							</cfif>
							<cfset vset.price=DecimalFormat(vset.price)>
							<cfset vset.vat=charge.VATRate>
							<cfif StructKeyExists(result.voucherGroup,pubID)>
								<cfset vpub=StructFind(result.voucherGroup,pubID)>
								<cfset vset.qty=charge.qty+vpub.qty>
								<cfset StructUpdate(result.voucherGroup,pubID,vset)>
							<cfelse>
								<cfset vset.qty=charge.Qty>
								<cfset StructInsert(result.voucherGroup,pubID,vset)>
							</cfif>
							<cfset result.vouchertotal=result.vouchertotal+(vset.price*charge.Qty)>
						</cfif>
						<cfif StructKeyExists(result.debitGroup,pubID)>
							<cfset pub=StructFind(result.debitGroup,pubID)>
							<cfset set.qty=charge.qty+pub.qty>
							<cfset StructUpdate(result.debitGroup,pubID,set)>
						<cfelse>
							<cfset set.qty=charge.Qty>
							<cfset StructInsert(result.debitGroup,pubID,set)>
						</cfif>
						<cfset result.debittotal=result.debittotal+(charge.Price*charge.Qty)>
						<cfset result.debitchargetotal=result.debitchargetotal+charge.Charge>
						
						<cfset result.TotalNet=result.TotalNet+(charge.Net*charge.Qty)>
						<cfset result.TotalVAT=0>	<!--- result.TotalVAT+(charge.VAT*charge.Qty)> --->
						<cfif charge.VATRate is 0.2>
							<cfset result.net20=result.net20+(charge.Net*charge.Qty)>
							<cfset result.vat20=result.vat20+(charge.VAT*charge.Qty)>
						<cfelseif charge.VATRate is 0.05>
							<cfset result.net5=result.net5+(charge.Net*charge.Qty)>
							<cfset result.vat5=result.vat5+(charge.VAT*charge.Qty)>
						<cfelse>
							<cfset result.net0=result.net0+(charge.Net*charge.Qty)>
							<cfset result.vat0=result.vat0+(charge.VAT*charge.Qty)>
						</cfif>
					</cfcase>
					<cfcase value="credit">
						<cfquery name="QDebit" datasource="#args.datasource#">
							SELECT *
							FROM tblDelItems
							WHERE diOrderID=#charge.OrderID#
							AND diDate='#LSDateFormat(QCharges.diDate,"yyyy-mm-dd")#'
							AND diType='debit'
						</cfquery>
						<cfquery name="QCredit" datasource="#args.datasource#">
							SELECT *
							FROM tblDelItems
							WHERE diOrderID=#charge.OrderID#
							AND diDate='#LSDateFormat(QCharges.diDate,"yyyy-mm-dd")#'
							AND diType='credit'
						</cfquery>
						<cfif StructKeyExists(result.creditGroup,pubID)>
							<cfset pub=StructFind(result.creditGroup,pubID)>
							<cfset set.qty=charge.qty+pub.qty>
							<cfset StructUpdate(result.creditGroup,pubID,set)>
						<cfelse>
							<cfset set.qty=charge.Qty>
							<cfset StructInsert(result.creditGroup,pubID,set)>
						</cfif>
						<cfset result.credittotal=result.credittotal+(charge.Price*charge.Qty)>
						<cfif QDebit.recordcount is QCredit.recordcount OR Find("Duplicated",QCredit.diReason,1)>
							<cfset result.creditchargetotal=result.creditchargetotal+charge.Charge>
						</cfif>
						
						<cfset result.TotalNet=result.TotalNet+(charge.Net*charge.Qty)>
						<cfset result.TotalVAT=result.TotalVAT+(charge.VAT*charge.Qty)>
						<cfif charge.VATRate is 0.2>
							<cfset result.net20=result.net20+(charge.Net*charge.Qty)>
							<cfset result.vat20=result.vat20+(charge.VAT*charge.Qty)>
						<cfelseif charge.VATRate is 0.05>
							<cfset result.net5=result.net5+(charge.Net*charge.Qty)>
							<cfset result.vat5=result.vat5+(charge.VAT*charge.Qty)>
						<cfelse>
							<cfset result.net0=result.net0+(charge.Net*charge.Qty)>
							<cfset result.vat0=result.vat0+(charge.VAT*charge.Qty)>
						</cfif>
					</cfcase>
				</cfswitch>
				
			</cfloop>
			
			<cfquery name="QReturnCredit" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock,tblPublication
				WHERE psOrderID=#QOrders.ordID#
				AND psPubID=pubID
				AND psType='credited'
				AND psDate >= '#LSDateFormat(args.fromDate,"yyyy-mm-dd")#'
				AND psDate <= '#LSDateFormat(args.toDate,"yyyy-mm-dd")#'
			</cfquery>
			<cfset result.QReturnCredit=QReturnCredit>
			<cfloop query="QReturnCredit">
				<cfset re={}>
				<cfset re.sort=QReturnCredit.pubGroup & QReturnCredit.pubTitle>
				<cfset re.PubID=QReturnCredit.pubID>
				<cfset re.Title=QReturnCredit.pubTitle>
				<cfset re.group=QReturnCredit.pubGroup>
				<cfset re.Price=QReturnCredit.psRetail>
				<cfset re.Qty=QReturnCredit.psQty>
				<cfset re.Date=QReturnCredit.psDate>
				<cfset re.VATRate=QReturnCredit.psVatRate/100>
				<cfset re.Net=re.Price/(1+re.VATRate)>
				<cfset re.VAT=re.Price-re.Net>
				<cfset re.reason="">
				
				<cfset RCpubID=re.group & re.PubID & re.Price & re.VATRate & re.reason>
				
				<cfset result.credittotal=result.credittotal+(re.Price*re.Qty)>
				<cfset result.TotalNet=result.TotalNet+(re.Net*re.Qty)>
				<cfset result.TotalVAT=result.TotalVAT+(re.VAT*re.Qty)>
				<cfif re.VATRate is 0.2>
					<cfset result.net20=result.net20+(re.Net*re.Qty)>
					<cfset result.vat20=result.vat20+(re.VAT*re.Qty)>
				<cfelseif charge.VATRate is 0.05>
					<cfset result.net5=result.net5+(re.Net*re.Qty)>
					<cfset result.vat5=result.vat5+(re.VAT*re.Qty)>
				<cfelse>
					<cfset result.net0=result.net0+(re.Net*re.Qty)>
					<cfset result.vat0=result.vat0+(re.VAT*re.Qty)>
				</cfif>
				
				<cfif StructKeyExists(result.creditGroup,RCpubID)>
					<cfset RCpub=StructFind(result.creditGroup,RCpubID)>
					<cfset re.Qty=re.Qty+RCpub.qty>
					<cfset StructUpdate(result.creditGroup,RCpubID,re)>
				<cfelse>
					<cfset re.Qty=QReturnCredit.psQty>
					<cfset StructInsert(result.creditGroup,RCpubID,re)>
				</cfif>
			</cfloop>
						
			<cfset result.NetDisc=-result.TotalNet*result.Discount>			<!--- discount amount calculated on products only (not delivery) --->
			<cfset result.TotalNet=result.TotalNet+result.NetDisc>			<!--- net total after discount --->
			<cfset result.delChargeTotal=result.debitchargetotal+result.creditchargetotal>	<!--- total delivery charges --->
			<cfset result.TotalNet=result.TotalNet+result.delChargeTotal>	<!--- discounted total plus delivery charges --->
			<cfset result.total=result.TotalNet+result.TotalVAT>			<!--- invoice gross total --->
			<cfset result.grandtotal=result.total-result.vouchertotal>
			
			<cfif result.Discount neq 0>	<!--- adjust VAT analysis --->
				<cfset result.net20=result.net20-(result.net20*result.Discount)>
				<cfset result.net5=result.net5-(result.net5*result.Discount)>
				<cfset result.net0=result.net0-(result.net0*result.Discount)+result.delChargeTotal>	<!--- add in del charges to match net amount (assume all zero VAT) --->
				<cfset result.vat20=result.vat20-(result.vat20*result.Discount)>
				<cfset result.vat5=result.vat5-(result.vat5*result.Discount)>
				<cfset result.vat0=result.vat0-(result.vat0*result.Discount)>
			<cfelse>
				<cfset result.net0=result.net0+result.delChargeTotal>	<!--- add in del charges to match net amount (assume all zero VAT) --->
			</cfif>
			<cfset result.vat0=0> <!--- bug fix --->
			<cfset result.debit=StructSort(result.debitGroup,"textnocase", "asc","sort")>
			<cfset result.credit=StructSort(result.creditGroup,"textnocase", "asc","sort")>
			<cfset result.vouchers=StructSort(result.voucherGroup,"textnocase", "asc","sort")>
			
			<cfif result.debittotal is 0 AND result.credittotal neq 0>
				<cfset result.transType="crn">
			<cfelse>
				<cfset result.transType="inv">
			</cfif>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="LoadInvoice" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
				<!---<cfdump var="#result#" label="LoadInvoice" expand="no" format="html">--->
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="CreateInvoice" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckLastRef="">
		<cfset var QCheckInvItem="">
		<cfset var QUpdateInvItem="">
		<cfset var QAddInvItem="">
		<cfset var QItem="">
		<cfset var QUpdateCharge="">
		<cfset var QUpdateControl="">
		<cfset var QCheckVouchersPay="">
		<cfset var QAddVouchersPay="">
		<cfset var QUpdateTrans="">
		<cfset var loc = {}>
		<cfset result.args=args>
		<cfset result.InvID=0>
		<cftry>
			<cftransaction>
				<cfquery name="QCheckLastRef" datasource="#args.datasource#">	<!--- get next invoice number --->
					SELECT ctlID,ctlNextInvNo
					FROM tblControl
				</cfquery>
				<cfquery name="QCheckInvItem" datasource="#args.datasource#" result="loc.QCheckItemResult">	<!--- check if invoice already exists --->
					SELECT *													<!--- this assumes the client can only have one invoice on that day --->
					FROM tblTrans
					WHERE trnClientID=#val(args.cltID)#
					AND trnOrderID=#args.ordID#
					AND trnDate='#LSDateFormat(args.invDate,"yyyy-mm-dd")#'
					AND trnLedger='sales'
					AND trnType='#args.TransType#'
					LIMIT 1;
				</cfquery>
				<cfif QCheckInvItem.recordcount is 1 AND args.fixflag is 1>	<!--- found the invoice AND we are in (fixflag) mode --->	
					<cfset result.InvoiceRef=QCheckInvItem.trnRef>	<!--- remember invoice number for output later --->
					<cfset result.InvID=val(QCheckInvItem.trnID)>
					<cfif args.testmode is 1>
						<cfquery name="QUpdateCharge" datasource="#args.datasource#">	<!--- mark delItems invoiced with appropriate key --->
							UPDATE tblDelItems
							SET diInvoiceID=0
							WHERE diClientID=#val(args.cltID)#
							AND diInvoiceID=#val(result.InvID)#
						</cfquery>
					</cfif>
					<cfif args.testmode is 0>
						<cfquery name="QUpdateInvItem" datasource="#args.datasource#">
							UPDATE tblTrans
							SET	trnClientRef=#val(args.cltRef)#,
								trnAmnt1=#args.Total#,
								trnTest=#args.testmode#
							WHERE trnID=#QCheckInvItem.trnID#
						</cfquery>
					</cfif>
					<cfif args.fixflag is 1>
						<cfquery name="QUpdateTrans" datasource="#args.datasource#">
							UPDATE tblTrans
							SET	trnAmnt1=#args.Total#
							WHERE trnID=#QCheckInvItem.trnID#
						</cfquery>
					</cfif>
				<cfelse>
					<cfset result.InvoiceRef=QCheckLastRef.ctlNextInvNo>	<!--- use next invoice number --->
					<cfquery name="QAddInvItem" datasource="#args.datasource#" result="QItem">		<!--- create invoice tran --->
						INSERT INTO tblTrans (
							trnLedger,	
							trnAccountID,
							trnClientID,
							trnOrderID,
							trnClientRef,
							trnType,
							trnRef,
							trnDate,
							trnAmnt1,
							trnDesc, 
							trnTest
						) VALUES (
							'sales',
							4,
							#val(args.cltID)#,
							#val(args.ordID)#,
							#val(args.cltRef)#,
							'#args.TransType#',
							#val(result.InvoiceRef)#,
							'#LSDateFormat(args.invDate,"yyyy-mm-dd")#',
							#args.Total#,
							'#args.ordContact#',
							#args.testmode#
						)
					</cfquery>
					<cfset result.InvID=val(QItem.generatedKey)>
					<!--- Insert nom items for invoice --->
					<cfquery name="loc.newItem" datasource="#args.datasource#">
						INSERT INTO tblNomItems (
							niNomID,
							niTranID,
							niAmount,
							niVATAmount,
							niVATRate,
							niActive
						) VALUES
							(1001,#result.InvID#,#-args.Total#,0,0,0),
							(1,#result.InvID#,#args.Total#,0,0,0),
							(21,#result.InvID#,0,0,0,0)
					</cfquery>

					<cfquery name="QUpdateControl" datasource="#args.datasource#">	<!--- increment invoice number --->
						UPDATE tblControl
						SET ctlNextInvNo=#val(result.InvoiceRef+1)#
						WHERE ctlID=#val(QCheckLastRef.ctlID)#
					</cfquery>
				</cfif>
				
				<cfquery name="QUpdateCharge" datasource="#args.datasource#">	<!--- mark delitems invoiced with appropriate key --->
					UPDATE tblDelItems
					SET diInvoiceID=#val(result.InvID)#
					WHERE diClientID=#val(args.cltID)#
					AND diOrderID=#val(args.ordID)#
					AND diDatestamp >= '#LSDateFormat(args.fromDate,"yyyy-mm-dd")#'
					AND diDatestamp <= '#LSDateFormat(args.toDate,"yyyy-mm-dd")#'
					AND diInvoiceID=0
					<cfif StructKeyExists(args,"onlycredits") AND args.onlycredits is 1>AND diType='credit'</cfif>
				</cfquery>
				
				<cfif args.vouchers neq 0>
					<cfquery name="QCheckVouchersPay" datasource="#args.datasource#">
						SELECT *
						FROM tblTrans
						WHERE trnClientID=#val(args.cltID)#
						AND trnOrderID=#val(args.ordID)#
						AND trnDate='#LSDateFormat(args.invDate,"yyyy-mm-dd")#'
						AND trnLedger='sales'
						AND trnType='crn'
						AND trnMethod='sv'
						LIMIT 1;
					</cfquery>
					<cfif QCheckVouchersPay.recordcount is 0>
						<cfquery name="QAddVouchersPay" datasource="#args.datasource#" result="loc.voucher_result">
							INSERT INTO tblTrans (
								trnLedger,
								trnAccountID,
								trnClientID,
								trnOrderID,
								trnClientRef,
								trnType,
								trnRef,
								trnMethod,
								trnDate,
								trnAmnt1,
								trnTest
							) VALUES (
								'sales',
								4,
								#val(args.cltID)#,
								#val(args.ordID)#,
								#val(args.cltRef)#,
								'crn',
								#val(result.InvoiceRef)#,
								'sv',
								'#LSDateFormat(args.invDate,"yyyy-mm-dd")#',
								#-args.vouchers#,
								#args.testmode#
							)
						</cfquery>
						<cfset loc.voucherTranID=val(loc.voucher_result.generatedKey)>
						<!--- Insert nom items for vouchers --->
						<cfquery name="loc.newItem" datasource="#args.datasource#">
							INSERT INTO tblNomItems (
								niNomID,
								niTranID,
								niAmount,
								niVATAmount,
								niVATRate,
								niActive
							) VALUES
								(231,#loc.voucherTranID#,#args.vouchers#,0,0,0),
								(1,#loc.voucherTranID#,#-args.vouchers#,0,0,0),
								(101,#loc.voucherTranID#,0,0,0,0)
						</cfquery>
					<cfelse>
						<cfquery name="QAddVouchersPay" datasource="#args.datasource#">
							UPDATE tblTrans
							SET trnAmnt1=#-args.vouchers#
							WHERE trnID=#QCheckVouchersPay.trnID#
						</cfquery>
					</cfif>
				</cfif>
			</cftransaction>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="CreateInvoice" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
		<cfif args.fixflag is 1><cfdump var="#result#" label="createinvoice" expand="false"></cfif>
	</cffunction>
	
	<cffunction name="LoadFiles" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QLoad="">
		
		<cftry>
			<cfquery name="QLoad" datasource="#args.datasource#">
				SELECT trnID,trnRef,trnType,trnAmnt1,trnDate
				FROM tblTrans
				WHERE trnClientID=#val(args.clientID)#
				AND trnLedger='sales'
				AND (trnType='inv' OR trnType='crn')
				ORDER BY trnDate desc, trnType desc
			</cfquery>
			<cfset result.inv=ArrayNew(1)>
			<cfset result.crn=ArrayNew(1)>
			<cfloop query="QLoad">
				<cfset item={}>
				<cfset item.ID=trnID>
				<cfset item.Ref=trnRef>
				<cfset item.Type=trnType>
				<cfset item.Amount=trnAmnt1>
				<cfset item.Date=trnDate>
				<cfif item.Type is "inv">
					<cfset ArrayAppend(result.inv,item)>
				<cfelse>
					<cfset ArrayAppend(result.crn,item)>
				</cfif>
			</cfloop>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="LoadFiles" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

</cfcomponent>