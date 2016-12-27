<cfcomponent displayname="EPOS" extends="CMSCode/CoreFunctions">
	<cffunction name="FindArrayStruct" access="public" returntype="array">
		<cfargument name="arrayToSearch" type="array" required="yes">
		<cfargument name="structKey" type="string" required="yes">
		<cfargument name="structValue" type="any" required="no">
		<cfset var loc = {}>
		<cfset loc.result = []>
		<cfloop array="#arrayToSearch#" index="loc.i">
			<cfset loc.found = StructFind(loc.i, structKey)>
			<cfif StructKeyExists(arguments, "structValue")>
				<cfif loc.found eq structValue>
					<cfset ArrayAppend(loc.result, loc.i)>
				</cfif>
			<cfelse>
				<cfif loc.found>
					<cfset ArrayAppend(loc.result, loc.i)>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="UpdateProductPrice" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.update" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodOurPrice = #val(args.price)#
			WHERE prodID = #val(args.prodID)#
		</cfquery>
	</cffunction>
	<cffunction name="UpdateProductTitle" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.update" datasource="#args.datasource#">
			UPDATE tblProducts
			SET prodTitle = '#args.title#'
			WHERE prodID = #val(args.prodID)#
		</cfquery>
	</cffunction>
	<cffunction name="RemoveCategory" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.remove" datasource="#args.datasource#">
			DELETE FROM tblEPOSCats
			WHERE epcID = #val(args.catID)#
		</cfquery>
	</cffunction>
	<cffunction name="AddCategory" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.check" datasource="#args.datasource#">
			SELECT epcID
			FROM tblEPOSCats
			WHERE epcTitle = '#args.title#'
		</cfquery>
		
		<cfif loc.check.recordcount is 0>
			<cfquery name="loc.new" datasource="#args.datasource#">
				INSERT INTO tblEPOSCats (
					epcTitle
				) VALUES (
					'#args.title#'
				)
			</cfquery>
		</cfif>

	</cffunction>
	<cffunction name="UpdateUserPin" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.currentPin" datasource="#args.datasource#">
			SELECT empPin
			FROM tblEmployee
			WHERE empID = #val(args.userID)#
		</cfquery>
		
		<cfif VerifyEncryptedString(args.oldpin, loc.currentPin.empPin)>
			<!---VALID--->
			<cfquery name="loc.newPin" datasource="#args.datasource#">
				UPDATE tblEmployee
				SET empPin = DES_ENCRYPT("#args.newpin#")
				WHERE empID = #val(args.userID)#
			</cfquery>
			<cfset loc.result.msg = "Pin number changed">
			<cfset loc.result.error = 0>
		<cfelse>
			<!---INVALID--->
			<cfset loc.result.msg = "Pin number invalid">
			<cfset loc.result.error = 1>
		</cfif>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="UpdateCatTitle" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.update" datasource="#args.datasource#">
			UPDATE tblEPOSCats
			SET epcTitle = '#args.title#'
			WHERE epcID = #val(args.catID)#
		</cfquery>
	</cffunction>
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


	<!-----------------------------------  Functions to fix/redo  ----------------------------------->

	<cffunction name="AddToBasket" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
						
		<cftry>
			<!--- Add Product --->
			<cfset loc.index=args.form.prodID&args.form.type&args.form.Price>
			<cfset loc.item={}>
			<cfset loc.item.index=loc.index>
			<cfset loc.item.prodID=args.form.prodID>
			<cfset loc.item.prodTitle=args.form.prodTitle>
			<cfset loc.item.Qty=args.form.Qty>
			<cfset loc.item.Price=args.form.Price>
			<cfset loc.item.Vat=args.form.Vat>
			<cfset loc.item.TradePrice=args.form.TradePrice>
			<cfset loc.item.Discount=args.form.Discount>
			<cfset loc.item.lineTotal=(val(args.form.Price)*val(args.form.Qty))-val(args.form.Discount)>
			<cfset loc.item.type=args.form.type>
			<cfset loc.item.cashonly=args.form.cashonly>
			<!--- TODO Add basket total limits. --->
			<cfif StructKeyExists(session.epos,loc.index)>
				<cfset loc.prod=StructFind(session.epos,loc.index)>
				<cfset loc.item.row=loc.prod.row>
				<cfset loc.item.Qty=loc.prod.Qty+args.form.Qty>
				<cfset loc.item.lineTotal=(val(loc.item.Price)*val(loc.item.Qty))-val(loc.item.Discount)>
				<cfset StructUpdate(session.epos,loc.index,loc.item)>
			<cfelse>
				<cfset session.eposrows++>
				<cfset loc.item.row=session.eposrows>
				<cfset StructInsert(session.epos,loc.index,loc.item)>
			</cfif>
		
			<!--- Deals --->
			<cfquery name="loc.QDeals" datasource="#args.datasource#">
				SELECT *
				FROM tblDealItems,tblDeals
				WHERE dimProdID=#val(args.form.prodID)#
				AND dimDealID=dealID
				AND dealStarts <= '#LSDateFormat(Now(),"yyyy-mm-dd")#'
				AND dealEnds >= '#LSDateFormat(Now(),"yyyy-mm-dd")#'
				AND dealStatus='active'
			</cfquery>
			<cfloop query="loc.QDeals">
				<cfset loc.deal={}>
				<cfset loc.deal.index=loc.QDeals.dealID>
				<cfset loc.deal.title=loc.QDeals.dealRecordTitle>
				<cfset loc.deal.Amount=loc.QDeals.dealAmount>
				<cfset loc.deal.Type="deal">
				<cfset loc.deal.linetotal=0>
				<cfset loc.deal.lineprice=0>
				<cfif StructKeyExists(session.epos,loc.index)>
					<cfset loc.p=StructFind(session.epos,loc.index)>
					<cfset loc.deal.lineprice=loc.p.lineTotal>
				</cfif>
				<cfif StructKeyExists(session.eposdeals,loc.deal.index)>
					<cfset loc.d=StructFind(session.eposdeals,loc.deal.index)>
					<cfif args.form.qty gt 1>
						<cfset loc.deal.CurrentQty=args.form.qty>
					<cfelse>
						<cfset loc.deal.CurrentQty=loc.d.CurrentQty+1>
					</cfif>
					<cfset loc.deal.row=loc.d.row>
					<cfset loc.deal.TargetQty=loc.d.TargetQty>
					<cfset loc.deal.DealQty=INT(loc.deal.CurrentQty/loc.deal.TargetQty)>
					<cfset loc.deal.linetotal=(loc.deal.Amount*loc.deal.DealQty)-loc.deal.lineprice>
					<cfset StructUpdate(session.eposdeals,loc.deal.index,loc.deal)>
				<cfelse>
					<cfset loc.deal.CurrentQty=args.form.Qty>
					<cfset loc.deal.TargetQty=loc.QDeals.dealQty>
					<cfset loc.deal.DealQty=INT(loc.deal.CurrentQty/loc.deal.TargetQty)>
					<cfset loc.deal.linetotal=(loc.deal.Amount*loc.deal.DealQty)-loc.deal.lineprice>
					<cfset session.eposrows++>
					<cfset loc.deal.row=session.eposrows>
					<cfset StructInsert(session.eposdeals,loc.deal.index,loc.deal)>
				</cfif>
			</cfloop>
				
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="AddPaymentToBasket" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.error1=false>
		<cfset loc.result.transID=0>
		<cfset loc.result.changedue=0>
		
		<cfset loc.basket=LoadBasket()>
		
		<cfset loc.item={}>
		<cfset loc.item.index=args.index>
		<cfset loc.item.type=args.form.type>
		<cfset loc.item.subtype=args.form.subtype>
		<cfset loc.item.amount=args.form.amount>
		<cfif NOT StructKeyExists(session.epospayments,loc.item.index)>
			<cfif NOT StructKeyExists(args.form,"bypass")>
				<cfswitch expression="#args.form.subtype#">
					<cfcase value="card">
						<cfset session.eposrows++>
						<cfset loc.item.row=session.eposrows>
						<cfset loc.item.amount=args.form.amount-loc.basket.cashonlyTotal>
						<cfset StructInsert(session.epospayments,loc.item.index,loc.item)>
						<cfif loc.basket.cashonlyTotal gt 0>
							<cfset session.eposrows++>
							<cfset loc.item={}>
							<cfset loc.item.row=session.eposrows>
							<cfset loc.item.index=RandRange(1024,1220120,'SHA1PRNG')>
							<cfset loc.item.type="payment">
							<cfset loc.item.subtype="cash">
							<cfset loc.item.amount=loc.basket.cashonlyTotal>
							<cfset StructInsert(session.epospayments,loc.item.index,loc.item)>
						</cfif>
					</cfcase>
					<cfcase value="supplier">
					</cfcase>
					<cfdefaultcase>
						<cfset session.eposrows++>
						<cfset loc.item.row=session.eposrows>
						<cfset StructInsert(session.epospayments,loc.item.index,loc.item)>
					</cfdefaultcase>
				</cfswitch>
				
				<cfset loc.basket=LoadBasket()>
			
				<cfif DecimalFormat(loc.basket.total) lte 0>
					<cfset loc.result=CloseTransaction(args)>
				</cfif>
			<cfelse>
				<cfset session.eposrows++>
				<cfset loc.item.row=session.eposrows>
				<cfset StructInsert(session.epospayments,loc.item.index,loc.item)>
			</cfif>
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
		<cfset loc.change=0>
		<cfset loc.result.changedue=0>
		<cfset loc.result.transID=0>
		
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
						<cfif loc.p.type is "refund" OR loc.p.type is "supplier">
							<cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,0,'#loc.p.type#','#loc.p.subtype#',#DecimalFormat(loc.p.Amount)*-1#,0.00,1)
							<cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,0,'payment','cash',#DecimalFormat(loc.p.Amount)#,0.00,1)
						<cfelse>
							<cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,0,'payment','#loc.p.subtype#',#DecimalFormat(loc.p.Amount)*-1#,0.00,1)
						</cfif>
						<cfset loc.change = loc.load.subtotal - loc.paytotal>
					</cfloop>
				</cfif>
				<!---<cfif loc.change lt 0>
					<cfset loc.count++><cfif loc.count neq 1>,</cfif>(#loc.TransID#,0,'payment','cash',#DecimalFormat(loc.change)#,0.00,1)
				</cfif>--->
			</cfquery>
			
			<cfset loc.result.transID=loc.TransID>
			<cfset loc.result.changedue=loc.change>
			<cfset loc.result.cashonly=loc.load.cashonlyTotal>
		
			<cfset StructClear(session.epos)>
			<cfset session.eposeditID=0>
			<cfset session.eposlasttransID=val(loc.TransID)>
			<cfset session.eposrows = 0>
			<cfset session.eposCashonlyTotal=0>
			<cfset session.eposBasketTotal=0>
			<cfset StructClear(session.eposdeals)>
			<cfset StructClear(session.epospayments)>
			
			<cfcatch type="any">
				<cfdump var="#loc.load#" label="loc.load" expand="yes">
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
				
				<cfset loc.result.prodID = val(loc.QProduct.prodID)>
				<cfset loc.result.prodTitle = loc.QProduct.prodTitle>
				<cfif StructKeyExists(args.form,"manualprice") AND args.form.manualprice neq 0>
					<cfset loc.result.price=val(args.form.manualprice)>
				<cfelse>
					<cfset loc.result.price=loc.QProduct.prodOurPrice>
				</cfif>
				<cfset loc.result.Vat = loc.QProduct.prodVatRate>
				<cfset loc.result.TradePrice = loc.QProduct.prodUnitTrade>
				<cfset loc.result.Discount = 0>
				<cfset loc.result.qty = args.form.qty>
				<cfset loc.result.type = args.form.type>
				<cfset loc.result.cashonly = loc.QProduct.prodCashOnly>
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
				<cfset loc.epos=StructSort(session.epos,"numeric","asc","row")>
				<cfloop array="#loc.epos#" index="loc.item">
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
				<cfset loc.eposdeals=StructSort(session.eposdeals,"numeric","asc","row")>
				<cfloop array="#loc.eposdeals#" index="loc.deal">
					<cfset loc.d=StructFind(session.eposdeals,loc.deal)>
					<cfif loc.d.DealQty neq 0>
						<cfset loc.result.subtotal += loc.d.linetotal>
						<cfset loc.result.total += loc.d.linetotal>
						<cfset ArrayAppend(loc.result.deals,loc.d)>
					</cfif>
				</cfloop>
			</cfif>
			<cfif StructKeyExists(session,"epospayments") AND NOT StructIsEmpty(session.epospayments)>
				<cfset loc.epospayments=StructSort(session.epospayments,"numeric","asc","row")>
				<cfloop array="#loc.epospayments#" index="loc.payment">
					<cfset loc.p=StructFind(session.epospayments,loc.payment)>
					<cfset loc.pay={}>
					<cfset loc.pay.index=loc.p.index>
					<cfset loc.pay.type=loc.p.type>
					<cfset loc.pay.subtype=loc.p.subtype>
					<cfset loc.pay.amount=loc.p.amount*-1>
					<cfset loc.result.total += loc.pay.amount>
					<cfset loc.result.paymentsTotal += loc.pay.amount*-1>
					<cfswitch expression="#loc.pay.type#">
						<cfcase value="cash">
							<cfset loc.pay.cat="CASH">
							<cfset loc.result.paymentscashTotal += loc.pay.amount*-1>
							<cfset loc.result.cashonlyTotal -= loc.pay.amount*-1>
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
							<cfset loc.result.cashonlyTotal -= loc.pay.amount*-1>
						</cfcase>
						<cfcase value="supplier">
							<cfset loc.pay.cat="CASH">
							<cfset loc.result.subtotal += loc.pay.amount*-1>
						</cfcase>
						<cfdefaultcase>
							<cfset loc.pay.cat="CASH">
						</cfdefaultcase>
					</cfswitch>
					<cfset ArrayAppend(loc.result.payments,loc.pay)>
				</cfloop>
			</cfif>
		
			<cfset session.eposCashonlyTotal=loc.result.cashonlyTotal>
			<cfset session.eposBasketTotal=loc.result.total>
			
			<cfcatch type="any">
				 <cfset loc.result.error=cfcatch>
			</cfcatch>
		</cftry>	
			
		<cfreturn loc.result>
	</cffunction>
	
	
	<!-----------------------------------  End Functions to fix/redo  ----------------------------------->
	
	
	<cffunction name="DeleteCodeSample" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfquery name="loc.del" datasource="#args.datasource#">
			DELETE FROM tblCodeSamples
			WHERE csID = #val(args.form.id)#
		</cfquery>
	</cffunction>
	
	<cffunction name="SaveCodeSample" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.check" datasource="#args.datasource#">
			SELECT csID
			FROM tblCodeSamples
			WHERE csID = #val(args.form.id)#
			LIMIT 1;
		</cfquery>
		
		<cfif loc.check.recordcount is 1>
			<cfquery name="loc.update" datasource="#args.datasource#">
				UPDATE tblCodeSamples
				SET csCode = '#args.form.code#',
					csItemID = #val(args.form.item)#,
					csItemType = '#args.form.type#',
					csTitle = '#args.form.title#',
					csRegExp = '#args.form.regexp#',
					csExtract = '#args.form.extract#',
					csOperator = '#args.form.operator#',
					csModifier = #val(args.form.modifier)#
				WHERE csID = #val(args.form.id)#
			</cfquery>
		<cfelse>
			<cfquery name="loc.insert" datasource="#args.datasource#">
				INSERT INTO tblCodeSamples (
					csCode,
					csItemID,
					csItemType,
					csTitle,
					csRegExp,
					csExtract,
					csOperator,
					csModifier
				) VALUES (
					'#args.form.code#',
					#val(args.form.item)#,
					'#args.form.type#',
					'#args.form.title#',
					'#args.form.regexp#',
					'#args.form.extract#',
					'#args.form.operator#',
					#val(args.form.modifier)#
				)
			</cfquery>
		</cfif>
		
	</cffunction>
	
	<cffunction name="LoadCodeSamples" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.samples" datasource="#args.datasource#">
			SELECT *
			FROM tblCodeSamples
			ORDER BY csID DESC
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.samples)>
	</cffunction>
	
	<cffunction name="LoadProductDetails" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.args = arguments>
		
		<cfif StructKeyExists(args.form, "barcode")>
			<cfset loc.product = InterrogateBarcode(args.form.barcode)>
			
			<cfif !StructIsEmpty(loc.product)>
				<cfquery name="loc.getProduct" datasource="#args.datasource#">
					SELECT *
					FROM tblProducts
					WHERE prodID = #val(loc.product.id)#
					LIMIT 1;
				</cfquery>
				
				<cfset loc.result = QueryToStruct(loc.getProduct)>
				<cfset loc.result.extract = loc.product.extract>
				<cfset loc.result.extractedValue = loc.product.value>
			</cfif>
		<cfelseif StructKeyExists(args.form, "id")>
			<cfquery name="loc.getProduct" datasource="#args.datasource#">
				SELECT *
				FROM tblProducts
				WHERE prodID = #val(args.form.id)#
				LIMIT 1;
			</cfquery>
			
			<cfset loc.result = QueryToStruct(loc.getProduct)>
		</cfif>
		
		<cfdump var="#loc#" label="loc" expand="yes">
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="xAddToBasket" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.index = "#args.prodID#-#val(args.price * 100)#">
		
		<cfswitch expression="#args.type#">
			<cfcase value="product"></cfcase>
			<cfcase value="deal"></cfcase>
			<cfcase value="publication"></cfcase>
		</cfswitch>
		
		<cfif StructKeyExists(session.epos, loc.index)>
			<cfset loc.item = StructFind(session.epos, loc.index)>
			<cfset loc.item.qty++>
		<cfelse>
			<cfset StructInsert(session.epos, loc.index, {
				index = loc.index,
				prodID = args.prodID,
				prodTitle = args.prodTitle,
				qty = args.qty,
				price = args.price,
				vat = args.vat,
				tradePrice = args.tradePrice,
				discount = args.discount,
				lineTotal = val(val(args.price) * val(args.qty) - val(args.discount)),
				type = args.type,
				cashOnly = args.cashOnly
			})>
		</cfif>
		
		<cfreturn loc>
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
					<cfset loc.parm.index=RandRange(1024,1220120,'SHA1PRNG')>
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
	
	<cffunction name="GetProductWithRegExp" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.product" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodID = #val(args.form.prodID)#
		</cfquery>
		
		
		<cfif loc.product.recordcount gt 0>
			<cfset loc.processed = REFindNoCase(loc.product.prodRegExp, args.form.barcode, 0, true)>
			<cfif ArrayLen(loc.processed.len) eq 2>
				<cfset loc.result.title = loc.product.prodTitle>
				<cfset loc.result.price = val(Mid(args.form.barcode, loc.processed.pos[2], loc.processed.len[2])) / 100>
			</cfif>
		</cfif>
				
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="GetBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.firstLookup" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode = '#args.form.barcode#'
				LIMIT 1;
			</cfquery>
			
			<cfif loc.firstLookup.recordcount is 1>
				<cfset loc.result.ID = val(loc.firstLookup.barProdID)>
				<cfset loc.result.Type = loc.firstLookup.barType>
				<cfset loc.result.price = 0>
				<cfset loc.result.error = false>
			<cfelse>
				<cfset loc.parm={}>
				<cfset loc.parm.datasource=args.datasource>
				<cfset loc.parm.code=args.form.barcode>
				<cfset output=InterrogateBarcode(loc.parm)>
				<cfif output.error is false>
					<cfset loc.result.ID = val(output.ID)>
					<cfset loc.result.Type = output.Type>
					<cfset loc.result.price = output.price>
					<cfset loc.result.error = output.error>
				<cfelse>
					<cfset loc.result.ID = 0>
					<cfset loc.result.Type = "">
					<cfset loc.result.price = 0>
					<cfset loc.result.error = true>
				</cfif>
			</cfif>
		
			<cfcatch type="any">
				 <cfdump var="#cfcatch#" label="cfcatch" expand="yes">
			</cfcatch>
		</cftry>
				
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="InterrogateBarcode" access="public" returntype="struct">
		<cfargument name="barcode" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cfquery name="loc.samples" datasource="#GetDatasource()#">
			SELECT *
			FROM tblCodeSamples
			WHERE csCode = SUBSTRING("#barcode#", 1, LENGTH(csCode))
			LIMIT 1;
		</cfquery>
		
		<cfif loc.samples.recordcount is 1>
			<cfset loc.result.id = val(loc.samples.csItemID)>
			<cfset loc.result.type = loc.samples.csItemType>
			<cfset loc.result.extract = loc.samples.csExtract>
			<cfset loc.result.error = false>
			<cfset loc.result.value = 0>
			
			<cfif Len(loc.samples.csRegExp)>
				<cfset loc.processed = REFindNoCase(loc.samples.csRegExp, barcode, 0, true)>
				<cfif arrayLen(loc.processed.len) eq 2>
					<cfset loc.extracted = mid(barcode, loc.processed.pos[2], loc.processed.len[2])>
					<cfif Len(loc.samples.csOperator)>
						<cfswitch expression="#loc.samples.csOperator#">
							<cfcase value="+"><cfset loc.extracted = val(loc.extracted) + loc.samples.csModifier></cfcase>
							<cfcase value="-"><cfset loc.extracted = val(loc.extracted) - loc.samples.csModifier></cfcase>
							<cfcase value="*"><cfset loc.extracted = val(loc.extracted) * loc.samples.csModifier></cfcase>
							<cfcase value="/"><cfset loc.extracted = val(loc.extracted) / loc.samples.csModifier></cfcase>
							<cfdefaultcase><cfset loc.extracted = loc.extracted></cfdefaultcase>
						</cfswitch>
					</cfif>
					<cfset loc.result.value = val(loc.extracted)>
				</cfif>
			</cfif>
		</cfif>
				
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cfquery name="loc.QDeal" datasource="#args.datasource#">
			SELECT *
			FROM tblDeals
			WHERE dealID=#val(args.form.dealID)#
		</cfquery>
		<cfset loc.result={}>
		<cfset loc.result.ID=loc.QDeal.dealID>
		<cfset loc.result.Qty=loc.QDeal.dealQty>
		<cfset loc.result.Amount=loc.QDeal.dealAmount>
		<cfset loc.result.Type=loc.QDeal.dealType>
		<cfset loc.result.RecordTitle=loc.QDeal.dealRecordTitle>
		<cfset loc.result.Title=loc.QDeal.dealTitle>
		<cfset loc.result.prodIndex=loc.result.ID&loc.result.type&loc.result.Amount>
		
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
			SELECT pubID,pubTitle,pubRoundTitle,pubPrice
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
			AND pubEPOS
			AND pubActive
			ORDER BY pubType asc, pubTitle asc
		</cfquery>
		<cfloop query="loc.QPubs">
			<cfset loc.item={}>
			<cfset loc.item.ID=pubID>
			<cfif len(pubRoundTitle)>
				<cfset loc.item.title=pubRoundTitle>
			<cfelse>
				<cfset loc.item.title=pubTitle>
			</cfif>
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
	
	<cffunction name="LoadProductByID" access="public" returntype="struct">
		<cfargument name="productID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.product" datasource="#GetDatasource()#">
			SELECT *
			FROM tblProducts
			WHERE prodID = #val(productID)#
		</cfquery>
		
		<cfreturn QueryToStruct(loc.product)>
	</cffunction>
	
	<cffunction name="LoadTransaction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.list=[]>
		<cfset loc.result.deals=[]>
		<cfset loc.result.payments=[]>
		<cfset loc.result.suppliers=[]>
		
		<cftry>
			<cfquery name="loc.QTran" datasource="#args.datasource#">
				SELECT *
				FROM tblEPOSTrans,tblEmployee
				WHERE eptID=#val(args.form.transID)#
				AND eptClerkID=empID
				LIMIT 1
			</cfquery>
			<cfquery name="loc.QTranItems" datasource="#args.datasource#">
				SELECT *
				FROM tblEPOSTransItems
				WHERE etiTransID=#val(loc.QTran.eptID)#
				ORDER BY etiID asc
			</cfquery>
			 <cfset loc.result.ID=loc.QTran.eptID>
			 <cfset loc.result.Timestamp=loc.QTran.eptTimestamp>
			 <cfset loc.result.clerk="#loc.QTran.empFirstName# #Left(loc.QTran.empLastName,1)#">
			 <cfset loc.result.Gross=loc.QTran.eptGross>
			<cfloop query="loc.QTranItems">
				<cfset loc.parm={}>
				<cfset loc.parm.datasource=args.datasource>
				<cfset loc.parm.form.type=etiItemType>
				<cfset loc.parm.form.subtype=etiSubType>
				<cfset loc.parm.form.prodID=val(etiItemID)>
				<cfset loc.parm.form.manualprice=etiAmount*-1>
				<cfset loc.parm.form.qty=etiQty>
				<cfswitch expression="#etiItemType#">
					<cfcase value="product">
						<cfset loc.item=LoadProduct(loc.parm)>
						<cfset ArrayAppend(loc.result.list,loc.item)>
					</cfcase>
					<cfcase value="publication">
						<cfset loc.item=LoadProduct(loc.parm)>
						<cfset ArrayAppend(loc.result.list,loc.item)>
					</cfcase>
					<cfcase value="deal">
						<cfset loc.parm.form.DealID=val(etiItemID)>
						<cfset loc.item=LoadDeal(loc.parm)>
						<cfset loc.item.manualprice=loc.parm.form.manualprice*-1>
						<cfset loc.item.qty=loc.parm.form.qty>
						<cfset ArrayAppend(loc.result.deals,loc.item)>
					</cfcase>
					<cfcase value="payment">
						<cfset loc.item={}>
						<cfset loc.item.type=etiItemType>
						<cfset loc.item.subtype=etiSubType>
						<cfset loc.item.prodID=val(etiItemID)>
						<cfset loc.item.manualprice=etiAmount*-1>
						<cfset loc.item.qty=etiQty>
						<cfset ArrayAppend(loc.result.payments,loc.item)>
					</cfcase>
					<cfcase value="supplier">
						<cfset loc.item={}>
						<cfset loc.item.type=etiItemType>
						<cfset loc.item.subtype=etiSubType>
						<cfset loc.item.prodID=val(etiItemID)>
						<cfset loc.item.manualprice=etiAmount*-1>
						<cfset loc.item.qty=etiQty>
						<cfset ArrayAppend(loc.result.suppliers,loc.item)>
					</cfcase>
				</cfswitch>
			</cfloop>
			
			<cfcatch type="any">
				 <cfset loc.result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn loc.result>
	</cffunction>

</cfcomponent>

























