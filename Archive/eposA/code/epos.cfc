<cfcomponent displayname="EPOS">
	<cffunction name="DeleteProduct" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.del" datasource="#args.datasource#">
			DELETE FROM tblProducts
			WHERE prodID = #val(args.prodID)#
		</cfquery>
	</cffunction>
	<cffunction name="SearchProducts" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.prods" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodTitle LIKE '%#args.title#%'
			ORDER BY prodTitle ASC
		</cfquery>
		
		<cfloop query="loc.prods">
			<cfset loc.item = {}>
			<cfset loc.item.id = prodID>
			<cfset loc.item.ref = prodRef>
			<cfset loc.item.title = prodTitle>
			<cfset loc.item.price = prodOurPrice>
			<cfset loc.item.size = prodUnitSize>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="VerifyEncryptedString" access="public" returntype="boolean">
		<cfargument name="stringToTest" type="string" required="yes">
		<cfargument name="originalString" type="binary" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.Encrypt" datasource="#application.site.datasource1#">
			SELECT (DES_ENCRYPT("#stringToTest#")) AS EncryptedString
		</cfquery>
		
		<cfif toString(loc.Encrypt.EncryptedString) eq toString(originalString)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>
	
	<cffunction name="VerifyPin" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.password" datasource="#args.datasource#">
			SELECT empPin
			FROM tblEmployee
			WHERE empID = #val(args.user)#
		</cfquery>
		
		<cfif NOT Len(ToString(loc.password.empPin)) gt 0>
			<cfquery name="loc.update" datasource="#args.datasource#">
				UPDATE tblEmployee
				SET empPin = DES_ENCRYPT("#args.pin#")
				WHERE empID = #val(args.user)#
			</cfquery>
		</cfif>
		<cfquery name="loc.user" datasource="#args.datasource#">
			SELECT *
			FROM tblEmployee
			WHERE empID = #val(args.user)#
		</cfquery>
		<cfif Len(ToString(loc.user.empPin)) gt 0>
			<cfif VerifyEncryptedString(args.pin, loc.user.empPin)>
				<!---USER LOGIN VALID--->
				<cfset session.user.id = loc.user.empID>
				<cfset session.user.loggedIn = true>
				<cfset session.user.firstname = loc.user.empFirstName>
				<cfset session.user.lastname = loc.user.empLastName>
			<cfelse>
				<!---USER LOGIN INVALID--->
				<cfset session.user.id = 0>
				<cfset session.user.loggedIn = false>
				<cfset session.user.firstname = "">
				<cfset session.user.lastname = "">
			</cfif>
		</cfif>
		
		<cfreturn session.user>
	</cffunction>

	<cffunction name="LoadEmployees" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.employees" datasource="#args.datasource#">
			SELECT *
			FROM tblEmployee
			WHERE empStatus = 'active'
			AND empEPOS = 'Yes'
		</cfquery>
		
		<cfloop query="loc.employees">
			<cfset loc.item = {}>
			<cfset loc.item.id = empID>
			<cfset loc.item.firstName = empFirstName>
			<cfset loc.item.lastName = empLastName>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadBasket" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="no">
		<cfset var loc={}>
		<cfset loc.result.basket=[]>
		<cfset loc.result.deals=[]>
		<cfset loc.result.payments=[]>
		<cfset loc.result.subtotal=0>
		<cfset loc.result.total=0>
		<cfset loc.result.paymentsTotal=0>
		<cfset loc.result.paymentscashTotal=0>
		<cfset loc.result.cashonlyTotal=0>
		<cfset loc.result.couponTotal=0>
		<cfset loc.result.editID=0>
		
		<cftry>
			<cfset loc.result.editID=session.eposeditID>
			<cfif StructKeyExists(session,"epos")>
				<cfloop collection="#session.epos#" item="loc.item">
					<cfset loc.i=StructFind(session.epos,loc.item)>
					<cfset loc.result.subtotal += loc.i.linetotal>
					<cfset loc.result.total += loc.i.linetotal>
					<cfif loc.i.cashonly is 1>
						<cfset loc.result.cashonlyTotal += loc.i.linetotal>
					</cfif>
					<cfset ArrayAppend(loc.result.basket,loc.i)>
				</cfloop>
			</cfif>
			<cfif StructKeyExists(session,"eposdeals")>
				<cfloop collection="#session.eposdeals#" item="loc.deal">
					<cfset loc.d=StructFind(session.eposdeals,loc.deal)>
					<cfset loc.result.subtotal += loc.d.linetotal>
					<cfset loc.result.total += loc.d.linetotal>
					<cfset ArrayAppend(loc.result.deals,loc.d)>
				</cfloop>
			</cfif>
			<cfif StructKeyExists(session,"epospayments") AND ArrayLen(session.epospayments)>
				<cfloop array="#session.epospayments#" index="loc.p">
					<cfset loc.pay={}>
					<cfset loc.pay.type=loc.p.type>
					<cfset loc.pay.subtype=loc.p.subtype>
					<cfset loc.pay.amount=loc.p.amount*-1>
					<cfset loc.result.total += loc.pay.amount>
					<cfset loc.result.paymentsTotal += loc.pay.amount*-1>
					<cfswitch expression="#loc.pay.type#">
						<cfcase value="cash">
							<cfset loc.pay.cat="CASH">
							<cfset loc.result.paymentscashTotal += loc.pay.amount*-1>
						</cfcase>
						<cfcase value="card">
							<cfset loc.pay.cat="CARD">
						</cfcase>
						<cfcase value="cheque">
							<cfset loc.pay.cat="CHQ">
						</cfcase>
						<cfcase value="voucher">
							<cfset loc.pay.cat="VCH">
						</cfcase>
						<cfcase value="coupon">
							<cfset loc.pay.cat="VCH">
							<cfset loc.result.couponTotal += loc.pay.amount*-1>
						</cfcase>
						<cfdefaultcase>
							<cfset loc.pay.cat="CASH">
						</cfdefaultcase>
					</cfswitch>
					<cfset ArrayAppend(loc.result.payments,loc.pay)>
				</cfloop>
			</cfif>
		
			<cfcatch type="any">
				 <cfset loc.result.error=cfcatch>
			</cfcatch>
		</cftry>	
			
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddToBasket" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
						
		<cftry>
			<!--- Add Product --->
			<cfset loc.index=args.prodID&args.type&args.Price>
			<cfset loc.item={}>
			<cfset loc.item.index=loc.index>
			<cfset loc.item.prodID=args.prodID>
			<cfset loc.item.prodTitle=args.prodTitle>
			<cfset loc.item.Qty=args.Qty>
			<cfset loc.item.Price=args.Price>
			<cfset loc.item.Vat=args.Vat>
			<cfset loc.item.TradePrice=args.TradePrice>
			<cfset loc.item.Discount=args.Discount>
			<cfset loc.item.lineTotal=(val(args.Price)*val(args.Qty))-val(args.Discount)>
			<cfset loc.item.type=args.type>
			<cfset loc.item.cashonly=args.cashonly>
			<cfif StructKeyExists(session.epos,loc.index)>
				<cfset loc.prod=StructFind(session.epos,loc.index)>
				<cfset loc.item.Qty=loc.prod.Qty+args.Qty>
				<cfset loc.item.lineTotal=(val(loc.item.Price)*val(loc.item.Qty))-val(loc.item.Discount)>
				<cfset StructUpdate(session.epos,loc.index,loc.item)>
			<cfelse>
				<cfset StructInsert(session.epos,loc.index,loc.item)>
			</cfif>
		
			<!--- Deals --->
			<cfif StructKeyExists(args,"deals")>
				<cfloop array="#args.deals#" index="i">
					<cfset loc.deal={}>
					<cfset loc.deal.index=i.ID>
					<cfset loc.deal.title=i.RecordTitle>
					<cfset loc.deal.Amount=i.Amount>
					<cfset loc.deal.Type="deal">
					<cfset loc.deal.linetotal=0>
					<cfif StructKeyExists(session.epos,i.prodIndex)>
						<cfset loc.p=StructFind(session.epos,i.prodIndex)>
						<cfset loc.deal.lineprice=loc.p.lineTotal>
					</cfif>
					<cfif StructKeyExists(session.eposdeals,loc.deal.index)>
						<cfset loc.d=StructFind(session.eposdeals,loc.deal.index)>
						<cfif args.qty gt 1>
							<cfset loc.deal.CurrentQty=args.qty>
						<cfelse>
							<cfset loc.deal.CurrentQty=loc.d.CurrentQty+1>
						</cfif>
						<cfset loc.deal.TargetQty=loc.d.TargetQty>
						<cfset loc.deal.DealQty=INT(loc.deal.CurrentQty/loc.deal.TargetQty)>
						<cfset loc.deal.linetotal=(loc.deal.Amount*loc.deal.DealQty)-loc.deal.lineprice>
						<cfset StructUpdate(session.eposdeals,loc.deal.index,loc.deal)>
					<cfelse>
						<cfset loc.deal.CurrentQty=args.Qty>
						<cfset loc.deal.TargetQty=i.Qty>
						<cfset loc.deal.DealQty=INT(loc.deal.CurrentQty/loc.deal.TargetQty)>
						<cfset loc.deal.linetotal=(loc.deal.Amount*loc.deal.DealQty)-loc.deal.lineprice>
						<cfset StructInsert(session.eposdeals,loc.deal.index,loc.deal)>
					</cfif>
				</cfloop>
			</cfif>
				
			<cfcatch type="any">
				 <cfdump var="#cfcatch#" label="cfcatch" expand="yes">
			</cfcatch>
		</cftry>
				
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddPaymentToBasket" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.error1=false>
		<cfset loc.result.changedue=0>
		
		<cfset loc.basket=LoadBasket()>
		
		<cfset loc.item={}>
		<cfset loc.item.type=args.form.type>
		<cfset loc.item.subtype=args.form.subtype>
		<cfset loc.item.amount=args.form.amount>
		<cfif NOT StructKeyExists(args.form,"bypass")>
			<cfif args.form.subtype is "card">
				<cfif DecimalFormat((loc.basket.subtotal-loc.basket.paymentsTotal-loc.basket.couponTotal-loc.item.amount)*-1) gte DecimalFormat(loc.basket.cashonlyTotal-loc.basket.paymentsCashTotal)>
					<cfset ArrayAppend(session.epospayments,loc.item)>
				<cfelse>
					<cfset loc.result.error1=true>
				</cfif>
			<cfelse>
				<cfset ArrayAppend(session.epospayments,loc.item)>
			</cfif>
			
			<cfset loc.basket=LoadBasket()>
		
			<cfif DecimalFormat(loc.basket.total) lte 0>
				<cfset loc.result=CloseTransaction(args)>
			</cfif>
		<cfelse>
			<cfset ArrayAppend(session.epospayments,loc.item)>
		</cfif>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CloseTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.count=0>
		<cfset loc.paytotal=0>
		<cfset loc.TransID=0>
		
		<cfset loc.load=LoadBasket()>
		
		<cftry>
			<cfif val(loc.load.editID) is 0>
				<cfquery name="loc.QInsertTran" datasource="#args.datasource#" result="loc.QResult">
					INSERT INTO tblEPOSTrans (eptClerkID,eptGross) VALUES (#val(args.clerkID)#,#DecimalFormat(loc.load.subtotal)#)
				</cfquery>
				<cfset loc.TransID=loc.QResult.generatedKey>
			<cfelse>
				<cfset loc.TransID=val(loc.load.editID)>
				<cfquery name="loc.QUpdateTran" datasource="#args.datasource#">
					UPDATE tblEPOSTrans SET eptGross=#DecimalFormat(loc.load.subtotal)# WHERE eptID=#val(loc.TransID)#
				</cfquery>
				<cfquery name="loc.QDeleteTranItems" datasource="#args.datasource#">
					DELETE FROM tblEPOSTransItems
					WHERE etiTransID=#val(loc.TransID)#
				</cfquery>
			</cfif>
			<cfquery name="loc.QInsertTranItems" datasource="#args.datasource#">
				INSERT INTO tblEPOSTransItems (
					etiTransID,
					etiItemID,
					etiItemType,
					etiSubType,
					etiAmount,
					etiVat,
					etiQty
				) VALUES
				<cfif ArrayLen(loc.load.basket)>
					<cfloop array="#loc.load.basket#" index="loc.i">
						<cfset loc.count++>
						<cfif loc.count neq 1>,</cfif>(#loc.TransID#,#loc.i.prodID#,'#loc.i.type#','none',#DecimalFormat(loc.i.price)*-1#,0.00,#loc.i.qty#)
					</cfloop>
				</cfif>
				<cfif ArrayLen(loc.load.deals)>
					<cfloop array="#loc.load.deals#" index="loc.d">
						<cfif loc.d.DealQty neq 0><cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,#loc.d.index#,'#loc.d.type#','none',#DecimalFormat(loc.d.linetotal)#,0.00,#loc.d.DealQty#)</cfif>
					</cfloop>
				</cfif>
				<cfif ArrayLen(loc.load.payments)>
					<cfloop array="#loc.load.payments#" index="loc.p">
						<cfset loc.paytotal += loc.p.Amount*-1>
						<cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,0,'payment','#loc.p.subtype#',#DecimalFormat(loc.p.Amount)*-1#,0.00,1)
					</cfloop>
				</cfif>
				<cfset loc.change=loc.load.subtotal-loc.paytotal>
				<cfif loc.change lt 0>
					<cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,0,'payment','cash',#DecimalFormat(loc.change)#,0.00,1)
				</cfif>
			</cfquery>
			
			<cfset loc.result.changedue=loc.change>
		
			<cfset StructClear(session.epos)>
			<cfset session.eposeditID=0>
			<cfset StructClear(session.eposdeals)>
			<cfset ArrayClear(session.epospayments)>
			
			<cfcatch type="any">
				 <cfdump var="#loc.load#" label="basket" expand="yes">
				 <cfdump var="#cfcatch#" label="cfcatch" expand="yes">
			</cfcatch>
		</cftry>		

		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadPrevTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QTran" datasource="#args.datasource#">
				SELECT *
				FROM tblEPOSTrans
				WHERE 1
				ORDER BY eptID desc
				LIMIT 1
			</cfquery>
			<cfquery name="loc.QTranItems" datasource="#args.datasource#">
				SELECT *
				FROM tblEPOSTransItems
				WHERE etiTransID=#val(loc.QTran.eptID)#
				ORDER BY etiID asc
			</cfquery>
			<cfset loc.result.Tran=loc.QTran>
			<cfset loc.result.TranItems=loc.QTranItems>
			<cfloop query="loc.QTranItems">
				<cfset loc.parm={}>
				<cfset loc.parm.datasource=args.datasource>
				<cfset loc.parm.form.type=etiItemType>
				<cfset loc.parm.form.subtype=etiSubType>
				<cfset loc.parm.form.prodID=val(etiItemID)>
				<cfset loc.parm.form.manualprice=etiAmount*-1>
				<cfset loc.parm.form.qty=etiQty>
				<cfif etiItemType is "product" OR etiItemType is "publication">
					<cfset loc.result.load=LoadProduct(loc.parm)>
					<cfset AddToBasket(loc.result.load)>
				<cfelseif etiItemType is "payment">
					<cfset loc.parm.form.type=etiSubType>
					<cfset loc.parm.form.amount=etiAmount>
					<cfset loc.parm.form.bypass=true>
					<cfset AddPaymentToBasket(loc.parm)>
				</cfif>
			</cfloop>
			<cfset session.eposeditID=loc.QTran.eptID>
			
			<cfcatch type="any">
				 <cfset loc.result.error=cfcatch>
			</cfcatch>
		</cftry>		
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="GetBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QBarcode" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode='#args.form.barcode#'
				LIMIT 1;
			</cfquery>
			<cfif loc.QBarcode.recordcount is 1>
				<cfset loc.result.ID=val(loc.QBarcode.barProdID)>
				<cfset loc.result.Type=loc.QBarcode.barType>
				<cfset loc.result.error=false>
			<cfelse>
				<cfset loc.result.ID=0>
				<cfset loc.result.Type="none">
				<cfset loc.result.error=true>
			</cfif>
		
			<cfcatch type="any">
				 <cfdump var="#cfcatch#" label="cfcatch" expand="yes">
			</cfcatch>
		</cftry>
				
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cfswitch expression="#args.form.type#">
			<cfcase value="product">
				<cfquery name="loc.QProduct" datasource="#args.datasource#">
					SELECT *
					FROM tblProducts
					WHERE prodID=#val(args.form.prodID)#
					LIMIT 1;
				</cfquery>
				<cfquery name="loc.QDeal" datasource="#args.datasource#">
					SELECT *
					FROM tblDealItems,tblDeals
					WHERE dimProdID=#val(args.form.prodID)#
					AND dimDealID=dealID
					AND dealStatus='active'
					AND dealStarts <= '#LSDateFormat(now(),"yyyy-mm-dd")#'
					AND dealEnds >= '#LSDateFormat(now(),"yyyy-mm-dd")#'
				</cfquery>
				<cfset loc.result.prodID=loc.QProduct.prodID>
				<cfset loc.result.prodTitle=loc.QProduct.prodTitle>
				<cfif StructKeyExists(args.form,"manualprice") AND args.form.manualprice neq 0>
					<cfset loc.result.price=args.form.manualprice>
				<cfelse>
					<cfset loc.result.price=loc.QProduct.prodOurPrice>
				</cfif>
				<cfset loc.result.Vat=loc.QProduct.prodVatRate>
				<cfset loc.result.TradePrice=loc.QProduct.prodUnitTrade>
				<cfset loc.result.Discount=0>
				<cfset loc.result.qty=args.form.qty>
				<cfset loc.result.type=args.form.type>
				<cfset loc.result.cashonly=loc.QProduct.prodCashOnly>
				<cfset loc.result.deals=[]>
				<cfloop query="loc.QDeal">
					<cfset loc.deal={}>
					<cfset loc.deal.prodIndex=loc.result.prodID&loc.result.type&loc.result.Price>
					<cfset loc.deal.ID=dealID>
					<cfset loc.deal.Qty=dealQty>
					<cfset loc.deal.Amount=dealAmount>
					<cfset loc.deal.Type=dealType>
					<cfset loc.deal.RecordTitle=dealRecordTitle>
					<cfset loc.deal.Title=dealTitle>
					<cfset ArrayAppend(loc.result.deals,loc.deal)>
				</cfloop>
			</cfcase>
			<cfcase value="publication">
				<cfquery name="loc.QPub" datasource="#args.datasource#">
					SELECT *
					FROM tblPublication
					WHERE pubID=#val(args.form.prodID)#
					LIMIT 1;
				</cfquery>
				<cfset loc.result.prodID=loc.QPub.pubID>
				<cfset loc.result.prodTitle=loc.QPub.pubTitle>
				<cfif StructKeyExists(args.form,"manualprice") AND args.form.manualprice neq 0>
					<cfset loc.result.price=args.form.manualprice>
				<cfelse>
					<cfset loc.result.price=loc.QPub.pubPrice>
				</cfif>
				<cfset loc.result.Vat=0>
				<cfset loc.result.TradePrice=loc.QPub.pubTradePrice>
				<cfset loc.result.Discount=0>
				<cfset loc.result.qty=args.form.qty>
				<cfset loc.result.type=args.form.type>
				<cfset loc.result.cashonly=0>
				<cfset loc.result.deals=[]>
			</cfcase>
		</cfswitch>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadCats" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result=[]>
		
		<cfquery name="loc.QCats" datasource="#args.datasource#">
			SELECT *
			FROM tblEPOSCats
			ORDER BY epcOrder asc
		</cfquery>
		<cfloop query="loc.QCats">
			<cfset loc.item={}>
			<cfset loc.item.ID=epcID>
			<cfset loc.item.order=epcOrder>
			<cfset loc.item.title=epcTitle>
			<cfset loc.item.file=epcFile>
			<cfset ArrayAppend(loc.result,loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadCatsProducts" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result=[]>
		
		<cfquery name="loc.QProduct" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodEposCatID=#val(args.form.id)#
		</cfquery>
		<cfloop query="loc.QProduct">
			<cfset loc.item={}>
			<cfset loc.item.ID=prodID>
			<cfset loc.item.title=prodTitle>
			<cfset loc.item.price=prodOurPrice>
			<cfset loc.item.cashonly=loc.QProduct.prodCashOnly>
			<cfset ArrayAppend(loc.result,loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadNewspapers" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result=[]>
		
		<cfquery name="loc.QPubs" datasource="#args.datasource#">
			SELECT pubID,pubTitle,pubPrice
			FROM tblPublication
			WHERE pubGroup='news'
			<cfif args.daynow is "saturday">
				AND pubType IN ('saturday','weekly')
			<cfelseif args.daynow is "sunday">
				AND pubType IN ('sunday','weekly')
			<cfelse>
				AND pubType IN ('morning','weekly')
			</cfif>
			AND pubSaleType='variable'
			AND pubActive
			ORDER BY pubType asc, pubTitle asc
		</cfquery>
		<cfloop query="loc.QPubs">
			<cfset loc.item={}>
			<cfset loc.item.ID=pubID>
			<cfset loc.item.title=pubTitle>
			<cfset loc.item.price=pubPrice>
			<cfset ArrayAppend(loc.result,loc.item)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cfquery name="loc.QProduct" datasource="#args.datasource#">
			INSERT INTO tblProducts (
				prodSuppID,
				prodDealID,
				prodCatID,
				prodEposCatID,
				prodRecordTitle,
				prodTitle,
				prodOurPrice,
				prodCashOnly
			) VALUES (
				0,
				0,
				0,
				#val(args.form.catID)#,
				'#args.form.Title#',
				'#args.form.Title#',
				#DecimalFormat(val(args.form.Price))#,
				<cfif StructKeyExists(args.form,"cashonly")>1<cfelse>0</cfif>
			)
		</cfquery>
		
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>

























