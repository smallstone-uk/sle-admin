<cfcomponent displayname="epos" extends="CMSCode/CoreFunctions">
	<cffunction name="LoadNewsStoriesIntoSession" access="public" returntype="struct">
		<cfset var loc = {}>
		<cfset loc.bbcNewsResult = []>
		<cfset loc.grocerResult = []>
		<cfset loc.bbcrssfeed = "http://feeds.bbci.co.uk/news/world/rss.xml">
		<cfset loc.grocerfeed = "http://www.thegrocer.co.uk/XmlServers/navsectionRSS.aspx?navsectioncode=33">
		
		<cftry>
		
		<cffeed action="read" source="#loc.bbcrssfeed#" query="loc.newsQuery">
		<cffeed action="read" source="#loc.grocerfeed#" query="loc.grocerQuery">
		
		<cfloop query="loc.newsQuery">
			<cfset ArrayAppend(loc.bbcNewsResult, {
				title = title,
				content = content
			})>
		</cfloop>
		
		<cfloop query="loc.grocerQuery">
			<cfset ArrayAppend(loc.grocerResult, {
				title = title,
				content = content
			})>
		</cfloop>
		
		<cfset session.news_stories = loc.bbcNewsResult>
		<cfset session.grocer_stories = loc.grocerResult>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc>
	</cffunction>
	<cffunction name="LoadPayments" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.payments" datasource="#args.datasource#">
			SELECT *
			FROM tblEPOS_Account
			WHERE eaTillPayment = 'Yes'
			ORDER BY eaID ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToArrayOfStruct(loc.payments)>
	</cffunction>
	<cffunction name="DeclareCash" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.insertHeader" datasource="#args.datasource#">
			INSERT INTO tblEPOS_DayHeader (
				<!---CASH IN DRAWER--->
				dhCID_5000,
				dhCID_2000,
				dhCID_1000,
				dhCID_0500,
				dhCID_0200,
				dhCID_0100,
				dhCID_0050,
				dhCID_0020,
				dhCID_0010,
				dhCID_0005,
				dhCID_0002,
				dhCID_0001,
				
				<!---SCRATCH CARDS--->
				dhSC_G1_Start,
				dhSC_G1_End,
				dhSC_G2_Start,
				dhSC_G2_End,
				dhSC_G3_Start,
				dhSC_G3_End,
				dhSC_G4_Start,
				dhSC_G4_End,
				dhSC_G5_Start,
				dhSC_G5_End,
				dhSC_G6_Start,
				dhSC_G6_End,
				dhSC_G7_Start,
				dhSC_G7_End,
				dhSC_G8_Start,
				dhSC_G8_End<!---,
				dhSC_G9_Start,
				dhSC_G9_End,
				dhSC_G10_Start,
				dhSC_G10_End,
				dhSC_G11_Start,
				dhSC_G11_End,
				dhSC_G12_Start,
				dhSC_G12_End--->
			) VALUES (
				<!---CASH IN DRAWER--->
				#val(args.form.50pound_cid)#,
				#val(args.form.20pound_cid)#,
				#val(args.form.10pound_cid)#,
				#val(args.form.5pound_cid)#,
				#val(args.form.2pound_cid)#,
				#val(args.form.1pound_cid)#,
				#val(args.form.50pence_cid)#,
				#val(args.form.20pence_cid)#,
				#val(args.form.10pence_cid)#,
				#val(args.form.5pence_cid)#,
				#val(args.form.2pence_cid)#,
				#val(args.form.1pence_cid)#,
				
				<!---SCRATCH CARDS--->
				#val(args.form.scgame_1_start)#,
				#val(args.form.scgame_1_end)#,
				#val(args.form.scgame_2_start)#,
				#val(args.form.scgame_2_end)#,
				#val(args.form.scgame_3_start)#,
				#val(args.form.scgame_3_end)#,
				#val(args.form.scgame_4_start)#,
				#val(args.form.scgame_4_end)#,
				#val(args.form.scgame_5_start)#,
				#val(args.form.scgame_5_end)#,
				#val(args.form.scgame_6_start)#,
				#val(args.form.scgame_6_end)#,
				#val(args.form.scgame_7_start)#,
				#val(args.form.scgame_7_end)#,
				#val(args.form.scgame_8_start)#,
				#val(args.form.scgame_8_end)#<!---,
				#val(args.form.scgame_9_start)#,
				#val(args.form.scgame_9_end)#,
				#val(args.form.scgame_10_start)#,
				#val(args.form.scgame_10_end)#,
				#val(args.form.scgame_11_start)#,
				#val(args.form.scgame_11_end)#,
				#val(args.form.scgame_12_start)#,
				#val(args.form.scgame_12_end)#--->
			)
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc>
	</cffunction>
	<cffunction name="AddProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.addproduct" datasource="#GetDatasource()#">
			INSERT INTO tblProducts (
				prodRecordTitle,
				prodTitle,
				prodPackQty,
				prodOurPrice,
				prodValidTo,
				prodUnitSize,
				prodUnitTrade
			) VALUES (
				'#args.title#',
				#val(args.quantity)#,
				#val(args.ourprice)#,
				'#LSDateFormat(args.expirydate, "yyyy-mm-dd")#',
				'#args.unitsize#',
				#val(args.tradeprice)#
			)
		</cfquery>
		
		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc>
	</cffunction>
	<cffunction name="ParseToJava" access="public" returntype="string">
		<cfargument name="dataToParse" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = "">
		
		<cftry>
		
		<cfloop collection="#dataToParse#" item="loc.key">
			<cfset loc.value = StructFind(dataToParse, loc.key)>
			<cfif IsStruct(loc.value)>
				<cfset loc.result &= ParseToJava(loc.value)>
			<cfelse>
				<cfset loc.hasSpaces = REMatchNoCase("[\s]", toString(loc.value))>
				<cfset loc.hasBinds = REMatchNoCase("[=&]", toString(loc.value))>
				
				<cfif ArrayIsEmpty(loc.hasSpaces) AND !ArrayIsEmpty(loc.hasBinds)>
					<cfset loc.strSplit = ListToArray(loc.value, "&")>
					<cfloop array="#loc.strSplit#" index="loc.part">
						<cfset loc.partSplit = ListToArray(loc.part, "=")>
						<cfset loc.result &= "@#LCase(loc.partSplit[1])#: #URLDecode(toString(loc.partSplit[2]))#">
					</cfloop>
				<cfelse>
					<cfset loc.result &= "@#LCase(loc.key)#: #toString(loc.value)#">
				</cfif>
			</cfif>
		</cfloop>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="LoadDataForSpeedTest" access="public" returntype="any">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.data" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.data>
	</cffunction>
	<cffunction name="CheckProductExistsByTitle" access="public" returntype="string">
		<cfargument name="checkThisTitle" type="string" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.product" datasource="#GetDatasource()#">
			SELECT prodID
			FROM tblProducts
			WHERE prodTitle = '#checkThisTitle#'
			LIMIT 1;
		</cfquery>
		
		<cfif loc.product.recordcount is 1>
			<cfreturn "true">
		<cfelse>
			<cfreturn "false">
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
	</cffunction>
	<cffunction name="LoadZReading" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.groups = {}>
		<cfset loc.dayStart = "#LSDateFormat(Now(), 'yyyy-mm-dd')# 07:00:00">
		<cfset loc.dayEnd = "#LSDateFormat(Now(), 'yyyy-mm-dd')# 19:00:00">
		
		<cfquery name="loc.loadGroups" datasource="#args.datasource#">
			SELECT *
			FROM tblProductGroups
		</cfquery>
		
		<cfloop query="loc.loadGroups">
			<cfset loc.grp = {}>
			<cfset loc.grp.title = pgTitle>
			<cfset loc.grp.qty = 0>
			<cfset loc.grp.total = 0>
			<cfset StructInsert(loc.groups, pgID, loc.grp)>
		</cfloop>
		
		<cfset StructInsert(loc.groups, "newsmags", {
			title = "News & Mags",
			qty = 0,
			total = 0
		})>
		
		<cfset StructInsert(loc.groups, "unknown", {
			title = "Unknown",
			qty = 0,
			total = 0
		})>
		
		<cfquery name="loc.headers" datasource="#args.datasource#">
			SELECT tblEPOS_Header.*, empFirstName, empLastName
			FROM tblEPOS_Header, tblEmployee
			WHERE ehStatus = 'Active'
			AND ehTimestamp >= '#loc.dayStart#'
			AND ehTimestamp <= '#loc.dayEnd#'
			AND ehEmployee = empID
			ORDER BY ehTimestamp ASC
		</cfquery>
		
		<cfloop query="loc.headers">
			<cfset loc.row = {}>
			<cfset loc.row.id = ehID>
			<cfset loc.row.items = []>
			
			<cfquery name="loc.items" datasource="#args.datasource#">
				SELECT *
				FROM tblEPOS_Items
				WHERE eiParent = #val(loc.row.id)#
			</cfquery>
			
			<cfloop query="loc.items">
				<cfif eiProdID gt 1>
					<cfquery name="loc.group" datasource="#args.datasource#">
						SELECT pcatGroup, prodEposCatID, prodCatID, epcTitle
						FROM tblProducts, tblProductCats, tblEPOSCats
						WHERE prodID = #val(eiProdID)#
						AND (prodCatID = pcatID OR prodEposCatID = epcID)
						LIMIT 1;
					</cfquery>
					<cfif loc.group.recordcount is 1>
						<cfif loc.group.prodCatID is 0>
							<cfif loc.group.prodEposCatID is 0>
								<cfset StructUpdate(loc.groups, "unknown", {
									qty = loc.groups.unknown.qty + 1,
									total = loc.groups.unknown.total + val(eiNet + eiDiscount)
								})>
							<cfelse>
								<cfif StructKeyExists(loc.groups, loc.group.epcTitle)>
									<cfset StructUpdate(loc.groups, loc.group.epcTitle, {
										title = loc.group.epcTitle,
										qty = loc.groups[loc.group.epcTitle].qty + 1,
										total = loc.groups[loc.group.epcTitle].total + val(eiNet + eiDiscount)
									})>
								<cfelse>
									<cfset StructInsert(loc.groups, loc.group.epcTitle, {
										title = loc.group.epcTitle,
										qty = 1,
										total = val(eiNet + eiDiscount)
									})>
								</cfif>
							</cfif>
						<cfelse>
							<cfset loc.groups[loc.group.pcatGroup].qty++>
							<cfset loc.groups[loc.group.pcatGroup].total += val(eiNet + eiDiscount)>
						</cfif>
					</cfif>
				</cfif>
				
				<cfif eiPubID gt 1>
					<cfset loc.groups.newsmags.qty++>
					<cfset loc.groups.newsmags.total += val(eiNet + eiDiscount)>
				</cfif>
				
				<cfif eiNomID gt 1>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn loc>
	</cffunction>
	<cffunction name="LoadTransactions" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cfquery name="loc.header" datasource="#args.datasource#">
			SELECT tblEPOS_Header.*, empFirstName, empLastName
			FROM tblEPOS_Header, tblEmployee
			WHERE ehEmployee = empID
			ORDER BY ehTimestamp DESC
		</cfquery>
		
		<cfloop query="loc.header">
			<cfset loc.row = {}>
			<cfset loc.row.id = ehID>
			<cfset loc.row.timestamp = "#LSDateFormat(ehTimestamp, 'dd/mm/yyyy')# @ #LSTimeFormat(ehTimestamp, 'HH:mm')#">
			<cfset loc.row.employee = "#empFirstName# #Left(empLastName, 1)#">
			<cfset loc.row.net = DecimalFormat(ehNet)>
			<cfset loc.row.vat = DecimalFormat(ehVAT)>
			<cfset loc.row.status = ehStatus>
			<cfset loc.row.mode = ehMode>
			<cfset loc.row.items = []>
			
			<cfquery name="loc.items" datasource="#args.datasource#">
				SELECT tblEPOS_Items.*, prodTitle, pubTitle, eaTitle
				FROM tblEPOS_Items, tblProducts, tblPublication, tblEPOS_Account
				WHERE eiParent = #val(loc.row.id)#
				AND eiProdID = prodID
				AND eiPubID = pubID
				AND eiNomID = eaID
			</cfquery>
			
			<cfloop query="loc.items">
				<cfset loc.item = {}>
				<cfset loc.item.id = eiID>
				<cfset loc.item.type = eiType>
				<cfset loc.item.product = prodTitle>
				<cfset loc.item.publication = pubTitle>
				<cfset loc.item.account = eaTitle>
				<cfset loc.item.qty = eiQty>
				<cfset loc.item.net = DecimalFormat(eiNet)>
				<cfset loc.item.discount = DecimalFormat(eiDiscount)>
				<cfset loc.item.vat = DecimalFormat(eiVAT)>
				<cfset ArrayAppend(loc.row.items, loc.item)>
			</cfloop>
			<cfset ArrayAppend(loc.result, loc.row)>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="GetEPOSAccount" access="public" returntype="numeric">
		<cfargument name="type" type="string" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.account" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_Account
			WHERE eaCode = '#UCase(type)#'
		</cfquery>
		
		<cfreturn loc.account.eaID>
	</cffunction>
	<cffunction name="GetVATOfProduct" access="public" returntype="numeric">
		<cfargument name="prodID" type="numeric" required="yes">
		<cfargument name="prodGross" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cfset prodGross = val(abs(prodGross))>
		
		<cfquery name="loc.prod" datasource="#GetDatasource()#">
			SELECT prodVatRate
			FROM tblProducts
			WHERE prodID = #val(prodID)#
		</cfquery>
		
		<cfif val(loc.prod.prodVatRate) gt 0>
			<cfset loc.net = val(prodGross) - (val(prodGross) / (1 + (val(loc.prod.prodVatRate) / 100)))>
			<cfset loc.vat = val(prodGross) - val(loc.net)>
		<cfelse>
			<cfset loc.vat = 0>
		</cfif>
		
		<cfdump var="#loc#" label="loc" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\log-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		
		<cfreturn loc.vat>
	</cffunction>
	<cffunction name="IsPayingSupplier" access="public" returntype="boolean">
		<cfset var loc = {}>
		<cfset loc.result = false>
		
		<cftry>
		
		<cfset loc.productCount = StructCount(session.epos_frame.basket.product)>
		<cfset loc.publicationCount = StructCount(session.epos_frame.basket.publication)>
		<cfset loc.dealCount = StructCount(session.epos_frame.basket.deal)>
		<cfset loc.paypointCount = StructCount(session.epos_frame.basket.paypoint)>
		<cfset loc.paymentCount = StructCount(session.epos_frame.basket.payment)>
		<cfset loc.supplierCount = StructCount(session.epos_frame.basket.supplier)>
		
		<cfif loc.productCount is 0 AND loc.publicationCount is 0 AND loc.dealCount is 0 AND loc.paypointCount is 0>
			<cfif loc.supplierCount gt 0>
				<cfset loc.result = true>
			</cfif>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	<cffunction name="CloseTransaction" access="public" returntype="numeric">
		<cfset var loc = {}>
		<cfset loc.frame = StructCopy(session.epos_frame)>
		
		<cftry>
		
		<!---WRITE HEADER RECORD--->
		<cfquery name="loc.insertHeader" datasource="#GetDatasource()#" result="loc.insertHeader_result">
			INSERT INTO tblEPOS_Header (
				ehEmployee,
				ehNet,
				ehVAT,
				ehStatus,
				ehMode
			) VALUES (
				#val(session.user.id)#,
				#val(loc.frame.result.balanceDue)#,
				0.00,<!---VAT TODO--->
				'Active',
				'#loc.frame.mode#'
			)
		</cfquery>
		
		<!---WRITE PRODUCT RECORDS--->
		<cfif StructCount(loc.frame.basket.product) gt 0>
			<cfquery name="loc.insertProduct" datasource="#GetDatasource()#">
				INSERT INTO tblEPOS_Items (
					eiParent,
					eiType,
					eiProdID,
					eiNomID,
					eiQty,
					eiNet,
					eiDiscount,
					eiVAT
				) VALUES
					<cfset loc.counter = 0>
					<cfloop collection="#loc.frame.basket.product#" item="loc.key">
						<cfset loc.counter++>
						<cfset loc.item = StructFind(loc.frame.basket.product, loc.key)>
						<cfset loc.countSaving = (StructKeyExists(loc.item, "saving") AND StructKeyExists(loc.item, "eligibleQty") AND loc.item.eligibleQty gt 0) ? val(loc.item.saving) : 0.00>
						(
							#val(loc.insertHeader_result.generatedkey)#,
							'Sale',
							#val(loc.item.id)#,
							'#GetEPOSAccount("Sale")#',
							#val(loc.item.qty)#,
							#val(loc.item.qty) * val(loc.item.price) + val(loc.countSaving)#,
							#val(loc.countSaving)#,
							#val(GetVATOfProduct(loc.item.id, (val(loc.item.qty) * val(loc.item.price) + val(loc.countSaving))))#
						)<cfif loc.counter neq StructCount(loc.frame.basket.product)>,</cfif>
					</cfloop>
			</cfquery>
		</cfif>

		<!---WRITE SUPPLIER RECORDS--->
		<cfif StructCount(loc.frame.basket.supplier) gt 0>
			<cfquery name="loc.insertSupplier" datasource="#GetDatasource()#">
				INSERT INTO tblEPOS_Items (
					eiParent,
					eiType,
					eiAccID,
					eiQty,
					eiNet,
					eiDiscount,
					eiVAT
				) VALUES
					<cfset loc.counter = 0>
					<cfloop collection="#loc.frame.basket.supplier#" item="loc.key">
						<cfset loc.counter++>
						<cfset loc.item = StructFind(loc.frame.basket.supplier, loc.key)>
						<cfset loc.countSaving = (StructKeyExists(loc.item, "saving") AND StructKeyExists(loc.item, "eligibleQty") AND loc.item.eligibleQty gt 0) ? val(loc.item.saving) : 0.00>
						(
							#val(loc.insertHeader_result.generatedkey)#,
							'Sale',
							#val(loc.item.id)#,
							#val(loc.item.qty)#,
							#val(loc.item.qty) * val(loc.item.price) + val(loc.countSaving)#,
							#val(loc.countSaving)#,
							#val(GetVATOfProduct(loc.item.id, (val(loc.item.qty) * val(loc.item.price) + val(loc.countSaving))))#
						)<cfif loc.counter neq StructCount(loc.frame.basket.supplier)>,</cfif>
					</cfloop>
			</cfquery>
		</cfif>

		<!---WRITE PUBLICATION RECORDS--->
		<cfif StructCount(loc.frame.basket.publication) gt 0>
			<cfquery name="loc.insertPublication" datasource="#GetDatasource()#">
				INSERT INTO tblEPOS_Items (
					eiParent,
					eiType,
					eiPubID,
					eiNomID,
					eiQty,
					eiNet
				) VALUES
					<cfset loc.counter = 0>
					<cfloop collection="#loc.frame.basket.publication#" item="loc.key">
						<cfset loc.counter++>
						<cfset loc.item = StructFind(loc.frame.basket.publication, loc.key)>
						(
							#val(loc.insertHeader_result.generatedkey)#,
							'Sale',
							#val(loc.item.id)#,
							'#GetEPOSAccount("Sale")#',
							#val(loc.item.qty)#,
							#val(loc.item.qty) * val(loc.item.price)#
						)<cfif loc.counter neq StructCount(loc.frame.basket.publication)>,</cfif>
					</cfloop>
			</cfquery>
		</cfif>

		<!---WRITE PAYMENT RECORDS--->
		<cfif StructCount(loc.frame.basket.payment) gt 0>
			<cfquery name="loc.insertPayment" datasource="#GetDatasource()#">
				INSERT INTO tblEPOS_Items (
					eiParent,
					eiType,
					eiNomID,
					eiQty,
					eiNet
				) VALUES
					<cfset loc.counter = 0>
					<cfloop collection="#loc.frame.basket.payment#" item="loc.key">
						<cfset loc.counter++>
						<cfset loc.item = StructFind(loc.frame.basket.payment, loc.key)>
						(
							#val(loc.insertHeader_result.generatedkey)#,
							'Payment',
							'#GetEPOSAccount("#loc.item.title#")#',
							1,
							#val(loc.item.value) - val(loc.frame.result.changeDue)#
						)<cfif loc.counter neq StructCount(loc.frame.basket.payment)>,</cfif>
					</cfloop>
			</cfquery>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn val(loc.insertHeader_result.generatedkey)>
	</cffunction>
	<cffunction name="UpdateReminderStatus" access="public" returntype="void">
		<cfargument name="remID" type="numeric" required="yes">
		<cfargument name="newStatus" type="string" required="yes">
		<cfargument name="remScope" type="string" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfif remScope eq "global">
			<cfquery name="loc.update" datasource="#GetDatasource()#">
				UPDATE tblEPOS_GlobalReminders
				SET egrStatus = '#newStatus#'
				WHERE egrID = #val(remID)#
			</cfquery>
		<cfelseif remScope eq "local">
			<cfquery name="loc.update" datasource="#GetDatasource()#">
				UPDATE tblEPOS_LocalReminders
				SET elrStatus = '#newStatus#'
				WHERE elrID = #val(remID)#
			</cfquery>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
	</cffunction>
	<cffunction name="LoadGlobalReminders" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.globalReminders" datasource="#args.datasource#">
			SELECT *
			FROM tblEPOS_GlobalReminders
			WHERE (
				(egrStart >= '#LSDateFormat(Now()-1, "yyyy-mm-dd")#' AND egrEnd >= '#LSDateFormat(Now(), "yyyy-mm-dd")#')
				OR
				(egrRecurring = 'hourly' OR egrRecurring = 'daily' OR egrRecurring = 'weekly')
			)
			ORDER BY egrStart ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn (loc.globalReminders.recordcount gt 0) ? QueryToArrayOfStruct(loc.globalReminders) : []>
	</cffunction>
	<cffunction name="LoadLocalReminders" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.localReminders" datasource="#args.datasource#">
			SELECT *
			FROM tblEPOS_LocalReminders
			WHERE (
				(elrStart >= '#LSDateFormat(Now()-1, "yyyy-mm-dd")#' AND elrEnd >= '#LSDateFormat(Now(), "yyyy-mm-dd")#')
				OR
				(elrRecurring = 'hourly' OR elrRecurring = 'daily' OR elrRecurring = 'weekly')
			)
			ORDER BY elrStart ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn (loc.localReminders.recordcount gt 0) ? QueryToArrayOfStruct(loc.localReminders) : []>
	</cffunction>
	<cffunction name="LoadHomeFunctions" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.homeFunctions" datasource="#args.datasource#">
			SELECT *
			FROM tblEPOS_Home
			ORDER BY ehOrder ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToArrayOfStruct(loc.homeFunctions)>
	</cffunction>
	<cffunction name="ProcessDiscounts" access="public" returntype="string">
		<cfset var loc = {}>
		<cfset loc.sign = (2 * int(session.epos_frame.mode eq "reg")) - 1>
		<cfset loc.grossValue = 0>
		<cfset loc.discount = 0>
		<cfset loc.message = "">
		
		<cftry>
		
		<cfloop collection="#session.epos_frame.basket.product#" item="loc.key">
			<cfset loc.item = StructFind(session.epos_frame.basket.product, loc.key)>
			<cfset loc.product = LoadProductByID(loc.item.id)>
			
			<cfif StructKeyExists(loc.product, "prodStaffDiscount")>
				<cfif loc.product.prodStaffDiscount eq "Yes">
					<cfset loc.grossValue += ( loc.item.price * loc.item.qty )>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfset loc.dcCount = StructCount(session.epos_frame.basket.discount)>
		<cfif loc.dcCount gt 1>
			<cfif StructKeyExists(session.epos_frame.basket.discount, "staffdiscount")>
				<cfset StructDelete(session.epos_frame.basket.discount, "staffdiscount")>
				<cfset loc.message = "Staff Discount Removed">
			</cfif>
		</cfif>
		
		<cfloop collection="#session.epos_frame.basket.discount#" item="loc.key">
			<cfset loc.dItem = StructFind(session.epos_frame.basket.discount, loc.key)>
			<cfif abs(loc.grossValue) gte abs(loc.dItem.minbalance)>
				<cfset loc.dItem.value = abs(loc.dItem.value)>
				<cfif loc.dItem.unit eq "pound">
					<cfset loc.dItem.amount = -val(loc.dItem.value)>
					<cfset loc.discount += -val(loc.dItem.value)>
				<cfelse>
					<cfset loc.dItem.amount = (val(loc.dItem.value) / 100) * loc.grossValue>
					<cfset loc.discount += (val(loc.dItem.value) / 100) * loc.grossValue>
				</cfif>
			<cfelse>
				<cfset loc.message = "Balance must be greater than &pound;#DecimalFormat(abs(loc.dItem.minbalance))# for voucher to apply">
				<cfset StructDelete(session.epos_frame.basket.discount, loc.key)>
			</cfif>
		</cfloop>
		
		<cfset session.epos_frame.result.discount = NumberFormat(loc.discount, "0.00")>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.message>
	</cffunction>
	<cffunction name="LoadDealsIntoSession" access="public" returntype="struct">
		<cfset var loc = {}>
		<cfset loc.deals = []>
		
		<cfquery name="loc.allValidDeals" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_Deals
			WHERE edStarts <= '#LSDateFormat(Now(), "yyyy-mm-dd")#'
			AND edEnds >= '#LSDateFormat(Now(), "yyyy-mm-dd")#'
			AND edStatus = 'Active'
			AND edType != 'Selection'<!---TEMP--->
		</cfquery>
		
		<cfloop query="loc.allValidDeals">
			<cfset loc.i = {}>
			<cfset loc.i.edID = edID>
			<cfset loc.i.edTitle = edTitle>
			<cfset loc.i.edStarts = edStarts>
			<cfset loc.i.edEnds = edEnds>
			<cfset loc.i.edType = edType>
			<cfset loc.i.edAmount = -val(edAmount)>
			<cfset loc.i.edQty = edQty>
			<cfset loc.i.edStatus = edStatus>
			<cfset loc.i.children = []>
			<cfquery name="loc.dealChildren" datasource="#GetDatasource()#">
				SELECT *
				FROM tblEPOS_DealItems
				WHERE ediParent = #val(loc.i.edID)#
			</cfquery>
			<cfloop query="loc.dealChildren">
				<cfset loc.c = {}>
				<cfset loc.c.ediID = ediID>
				<cfset loc.c.ediParent = ediParent>
				<cfset loc.c.ediProduct = ediProduct>
				<cfset loc.c.ediMinQty = ediMinQty>
				<cfset loc.c.ediMaxQty = ediMaxQty>
				<cfset ArrayAppend(loc.i.children, loc.c)>
			</cfloop>
			<cfset ArrayAppend(loc.deals, loc.i)>
		</cfloop>
		
		<cfset session.epos_frame.deals = loc.deals>
		
		<cfreturn loc>
	</cffunction>
	<cffunction name="ProcessDeals" access="public" returntype="struct">
		<cfset var loc = {}>
		<cfset loc.sign = (2 * int(session.epos_frame.mode eq "reg")) - 1>
		<cfset loc.basket = session.epos_frame.basket>
		
		<cftry>
		
		<cfif StructCount(session.epos_frame.basket.product) gt 0>
			<cfloop array="#session.epos_frame.deals#" index="loc.deal">
				<cfset loc.selRating = 0>
				<cfset loc.selGrouped = false>
				<cfset loc.grpTotal = 0>
				<cfset loc.grpEligibleQty = 0>
				<cfloop collection="#session.epos_frame.basket.product#" item="loc.key">
					<cfset loc.item = StructFind(session.epos_frame.basket.product, loc.key)>
					<cfloop array="#loc.deal.children#" index="loc.child">
						<cfif loc.item.id is loc.child.ediProduct>
							<cfset loc.grpTotal += loc.item.price>
							<cfswitch expression="#loc.deal.edType#">
								<cfcase value="Quantity">
									<cfset loc.item.eligibleQty = int(loc.item.qty / loc.deal.edQty)>
									<cfset loc.item.saving = -((loc.deal.edQty * loc.item.price) - loc.deal.edAmount * loc.sign)>
									<cfset loc.item.dealTitle = loc.deal.edTitle>
									<cfset loc.item.grossSaving = loc.item.eligibleQty * loc.item.saving>
									<cfif loc.item.eligibleQty gt 0>
										<cfif StructKeyExists(session.epos_frame.basket.deal, loc.item.id)>
											<cfset StructUpdate(session.epos_frame.basket.deal, loc.item.id, {
												title = loc.deal.edTitle,
												price = loc.item.saving,
												qty = loc.item.eligibleQty,
												product = loc.item.id,
												index = loc.item.id
											})>
										<cfelse>
											<cfset StructInsert(session.epos_frame.basket.deal, loc.item.id, {
												title = loc.deal.edTitle,
												price = loc.item.saving,
												qty = loc.item.eligibleQty,
												product = loc.item.id,
												index = loc.item.id
											})>
										</cfif>
									</cfif>
								</cfcase><!---Quantity--->
								<cfcase value="Discount">
									<cfset loc.item.eligibleQty = int(loc.item.qty / loc.deal.edQty)>
									<cfset loc.item.saving = -(loc.deal.edAmount * loc.sign)>
									<cfset loc.item.dealTitle = loc.deal.edTitle>
									<cfset loc.item.grossSaving = loc.item.eligibleQty * loc.item.saving>
									<cfif loc.item.eligibleQty gt 0>
										<cfif StructKeyExists(session.epos_frame.basket.deal, loc.item.id)>
											<cfset StructUpdate(session.epos_frame.basket.deal, loc.item.id, {
												title = loc.deal.edTitle,
												price = loc.item.saving,
												qty = loc.item.eligibleQty,
												product = loc.item.id,
												index = loc.item.id
											})>
										<cfelse>
											<cfset StructInsert(session.epos_frame.basket.deal, loc.item.id, {
												title = loc.deal.edTitle,
												price = loc.item.saving,
												qty = loc.item.eligibleQty,
												product = loc.item.id,
												index = loc.item.id
											})>
										</cfif>
									</cfif>
								</cfcase><!---Discount--->
								<!---<cfcase value="Selection">
									<cfset loc.location = "0">
									<!---<cfif loc.item.qty gt ArrayLen(loc.deal.children)>
										<cfset loc.selRating++>
										<cfset loc.location = loc.location & "A">
									<cfelse>--->
										<!---<cfif loc.item.qty gte loc.child.ediMinQty AND loc.item.qty lte loc.child.ediMaxQty>--->
										<cfif loc.item.qty MOD loc.child.ediMinQty is 0 AND loc.item.qty MOD loc.child.ediMaxQty is 0>
											<cfset loc.selRating++>
											<cfset loc.location = loc.location & "1">
											
											<!---<cfset loc.selDivided = loc.item.qty / loc.child.ediMinQty>
											<cfset loc.grpEligibleQty = loc.selDivided>--->
										<cfelse>
											<cfset loc.qtyMinMultiple = loc.child.ediMinQty MOD loc.item.qty>
											<cfset loc.qtyMaxMultiple = loc.child.ediMaxQty MOD loc.item.qty>
											<cfif loc.qtyMinMultiple is loc.child.ediMinQty AND loc.qtyMaxMultiple is loc.child.ediMaxQty>
												<cfset loc.selRating++>
												<cfset loc.grpEligibleQty++>
												<cfset loc.selGrouped = true>
												<cfset loc.location = loc.location & "2">
											</cfif>
										</cfif>
									<!---</cfif>--->
									
									<cfset loc.location = loc.location & "~SELRAT:#loc.selRating#~">
									
									<cfif loc.selRating is ArrayLen(loc.deal.children) OR loc.selRating MOD ArrayLen(loc.deal.children) is ArrayLen(loc.deal.children)>
										<cfif NOT loc.selGrouped>
											<cfset loc.grpEligibleQty++>
											<cfset loc.location = loc.location & "4">
										</cfif>
										<cfset loc.item.eligibleQty = loc.grpEligibleQty>
										<cfset loc.location = loc.location & "~ELIQTY:#loc.item.eligibleQty#~">
										<cfset loc.item.saving = -((abs(loc.grpTotal) - abs(loc.deal.edAmount)) * loc.sign)>
										<cfset loc.item.dealTitle = loc.deal.edTitle>
										<cfset loc.item.grossSaving = loc.item.eligibleQty * loc.item.saving>
										<cfif loc.item.eligibleQty gt 0>
											<cfif StructKeyExists(session.epos_frame.basket.deal, loc.item.id)>
												<cfset StructUpdate(session.epos_frame.basket.deal, loc.item.id, {
													title = loc.deal.edTitle,
													price = -loc.item.saving,
													qty = loc.item.eligibleQty,
													product = loc.item.id,
													index = loc.item.id
												})>
												<cfset loc.location = loc.location & "5">
											<cfelse>
												<cfset StructInsert(session.epos_frame.basket.deal, loc.item.id, {
													title = loc.deal.edTitle,
													price = -loc.item.saving,
													qty = loc.item.eligibleQty,
													product = loc.item.id,
													index = loc.item.id
												})>
												<cfset loc.location = loc.location & "6">
											</cfif><!---StructKeyExists(session.epos_frame.basket.deal, loc.item.id)--->
										</cfif><!---loc.item.eligibleQty gt 0--->
									</cfif><!---loc.selRating is ArrayLen(loc.deal.children) OR loc.selRating MOD ArrayLen(loc.deal.children) is 0--->
								</cfcase>---><!---Selection--->
							</cfswitch><!---loc.deal.edType--->
						</cfif><!---loc.item.id is loc.child.ediProduct--->
					</cfloop><!---loc.deal.children--->
				</cfloop><!---session.epos_frame.basket.product--->
			</cfloop><!---loc.deals--->
		<cfelse>
			<cfset StructClear(session.epos_frame.basket.deal)>
		</cfif>
		
		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc>
	</cffunction>

	<cffunction name="CheckUserPin" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.currentPin" datasource="#args.datasource#">
			SELECT empPin
			FROM tblEmployee
			WHERE empID = #val(args.userID)#
		</cfquery>
		
		<cfif VerifyEncryptedString(args.pin, loc.currentPin.empPin)>
			<cfreturn "true">
		<cfelse>
			<cfreturn "false">
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
	</cffunction>
	
	<cffunction name="UpdateUserPin" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.currentPin" datasource="#args.datasource#">
			SELECT empPin
			FROM tblEmployee
			WHERE empID = #val(args.userID)#
		</cfquery>
		
		<cfif VerifyEncryptedString(args.oldpin, loc.currentPin.empPin)>
			<cfquery name="loc.newPin" datasource="#args.datasource#">
				UPDATE tblEmployee
				SET empPin = DES_ENCRYPT("#args.newpin#")
				WHERE empID = #val(args.userID)#
			</cfquery>
			<cfset loc.result.msg = "Pin number changed">
			<cfset loc.result.error = 0>
		<cfelse>
			<cfset loc.result.msg = "Pin number invalid">
			<cfset loc.result.error = 1>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="UpdateAccentColour" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cftry>
		
		<cfquery name="loc.update" datasource="#args.datasource#">
			UPDATE tblEmployee
			SET empAccent = '#args.form.colour#'
			WHERE empID = #val(args.form.employee)#
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="LoadUserPreferencesMinimal" access="public" returntype="struct">
		<cfargument name="userID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.user" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEmployee
			WHERE empID = #val(userID)#
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToStruct(loc.user)>
	</cffunction>

	<cffunction name="LoadUserPreferences" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.user" datasource="#args.datasource#">
			SELECT *
			FROM tblEmployee
			WHERE empID = #val(args.userID)#
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToStruct(loc.user)>
	</cffunction>
	
	<cffunction name="LoadSuppliers" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cftry>
		
		<cfquery name="loc.suppliers" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accType = 'purch'
			AND accPayAcc = 181
		</cfquery>
		
		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToArrayOfStruct(loc.suppliers)>
	</cffunction>

	<cffunction name="LoadNewspapers" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = []>
		
		<cftry>
		
		<cfquery name="loc.pubs" datasource="#args.datasource#">
			SELECT pubID, pubTitle, pubRoundTitle, pubPrice
			FROM tblPublication
			WHERE pubGroup = 'news'
			<cfif args.daynow is "saturday">
				AND pubType IN ('saturday', 'weekly')
			<cfelseif args.daynow is "sunday">
				AND pubType IN ('sunday', 'weekly')
			<cfelse>
				AND pubType IN ('morning', 'weekly')
			</cfif>
			AND pubSaleType = 'variable'
			AND pubEPOS
			AND pubActive
			ORDER BY pubType ASC, pubTitle ASC
		</cfquery>
		
		<cfloop query="loc.pubs">
			<cfset loc.item = {}>
			<cfset loc.item.id = pubID>
			<cfset loc.item.title = (Len(pubRoundTitle)) ? pubRoundTitle : pubTitle>
			<cfset loc.item.price = pubPrice>
			<cfset ArrayAppend(loc.result, loc.item)>
		</cfloop>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="BasketItemCount" access="public" returntype="numeric">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfset loc.productCount = StructCount(session.epos_frame.basket.product)>
		<cfset loc.publicationCount = StructCount(session.epos_frame.basket.publication)>
		<cfset loc.dealCount = StructCount(session.epos_frame.basket.deal)>
		<cfset loc.paypointCount = StructCount(session.epos_frame.basket.paypoint)>
		<cfset loc.paymentCount = StructCount(session.epos_frame.basket.payment)>
		<cfset loc.supplierCount = StructCount(session.epos_frame.basket.supplier)>
		
		<cfset loc.totalCount = loc.productCount + loc.publicationCount + loc.dealCount + loc.paypointCount + loc.paymentCount + loc.supplierCount>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.totalCount>
	</cffunction>

	<cffunction name="SearchProductByName" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.prods" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodTitle LIKE '%#args.form.title#%'
			ORDER BY prodTitle ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfif loc.prods.recordcount gt 0>
			<cfreturn QueryToArrayOfStruct(loc.prods)>
		<cfelse>
			<cfreturn []>
		</cfif>
	</cffunction>

	<cffunction name="LoadPublicationByID" access="public" returntype="struct">
		<cfargument name="publicationID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.publication" datasource="#GetDatasource()#">
			SELECT *
			FROM tblPublication
			WHERE pubID = #val(publicationID)#
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToStruct(loc.publication)>
	</cffunction>

	<cffunction name="LoadProductByID" access="public" returntype="struct">
		<cfargument name="productID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.product" datasource="#GetDatasource()#">
			SELECT *
			FROM tblProducts
			WHERE prodID = #val(productID)#
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToStruct(loc.product)>
	</cffunction>

	<cffunction name="CheckBarcodeExists" access="public" returntype="struct">
		<cfargument name="barcode" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {
			signal = false,
			data = {}
		}>
		
		<cftry>
		
		<cfquery name="loc.barcode" datasource="#GetDatasource()#">
			SELECT barCode, barType, barProdID
			FROM tblBarcodes
			WHERE barCode = '#barcode#'
			LIMIT 1;
		</cfquery>
		
		<cfif loc.barcode.recordcount gt 0>
			<cfquery name="loc.product" datasource="#GetDatasource()#">
				SELECT *
				FROM tblProducts
				WHERE prodID = #val(loc.barcode.barProdID)#
			</cfquery>
			
			<cfset loc.result.signal = true>
			<cfset loc.result.data = QueryToStruct(loc.product)>
		<cfelse>
			<cfset loc.ibResult = InterrogateBarcode(barcode)>
			<cfif StructKeyExists(loc.ibResult, "id")>
				<cfswitch expression="#loc.ibResult.type#">
					<cfcase value="product">
						<cfset loc.result.data = LoadProductByID(loc.ibResult.id)>
					</cfcase>
					<cfcase value="publication">
						<cfset loc.result.data = LoadPublicationByID(loc.ibResult.id)>
					</cfcase>
				</cfswitch>
				<cfset loc.result.signal = true>
				<cfset loc.result.data.type = loc.ibResult.type>
				<cfset loc.result.data.encodedValue = loc.ibResult.value>
				<cfset loc.result.data.minBalance = loc.ibResult.minBalance>
			<cfelse>
				<cfset loc.result.signal = false>
				<cfset loc.result.data = {}>
			</cfif>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>

		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProductByBarcode" access="public" returntype="struct">
		<cfargument name="barcode" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
		
		<cfquery name="loc.barcode" datasource="#GetDatasource()#">
			SELECT barCode, barType, barProdID
			FROM tblBarcodes
			WHERE barCode = '#barcode#'
			LIMIT 1;
		</cfquery>
		
		<cfif loc.barcode.recordcount gt 0>
			<cfloop query="loc.barcode">
				<cfswitch expression="#barType#">
					<cfcase value="product">
						<cfset loc.result = LoadProductByID(barProdID)>
					</cfcase>
					<cfcase value="publication">
						<cfset loc.result = LoadPublicationByID(barProdID)>
					</cfcase>
				</cfswitch>
				<cfset loc.result.type = barType>
				<cfset loc.result.minBalance = 0>
			</cfloop>
		<cfelse>
			<cfset loc.ibResult = InterrogateBarcode(barcode)>
			<cfif StructKeyExists(loc.ibResult, "id")>
				<cfswitch expression="#loc.ibResult.type#">
					<cfcase value="product">
						<cfset loc.result = LoadProductByID(loc.ibResult.id)>
					</cfcase>
					<cfcase value="publication">
						<cfset loc.result = LoadPublicationByID(loc.ibResult.id)>
					</cfcase>
				</cfswitch>
				<cfset loc.result.type = loc.ibResult.type>
				<cfset loc.result.encodedValue = loc.ibResult.value>
				<cfset loc.result.minBalance = loc.ibResult.minBalance>
			</cfif>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>

		<cfreturn loc.result>
	</cffunction>

	<cffunction name="InterrogateBarcode" access="public" returntype="struct">
		<cfargument name="barcode" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
		
		<cfquery name="loc.samples" datasource="#GetDatasource()#">
			SELECT *
			FROM tblCodeSamples
			WHERE csCode = SUBSTRING("#barcode#", 1, LENGTH(csCode))
			AND (	(csStart <= '#LSDateFormat(Now(), "yyyy-mm-dd")#' AND csEnd >= '#LSDateFormat(Now(), "yyyy-mm-dd")#')
					OR csDateRestrict = 'No'	)
			LIMIT 1;
		</cfquery>
		
		<cfif loc.samples.recordcount is 1>
			<cfset loc.result.id = val(loc.samples.csItemID)>
			<cfset loc.result.type = loc.samples.csItemType>
			<cfset loc.result.extract = loc.samples.csExtract>
			<cfset loc.result.minBalance = val(loc.samples.csMinBalance)>
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
					
					<cfif loc.samples.csSign eq "negative">
						<cfif loc.result.value gt 0>
							<cfset loc.result.value = -loc.result.value>
						</cfif>
					</cfif>
				</cfif>
			</cfif>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
				
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadProductsByCategory" access="public" returntype="array">
		<cfargument name="catID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.products" datasource="#GetDatasource()#">
			SELECT *
			FROM tblProducts
			WHERE prodEposCatID = #val(catID)#
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToArrayOfStruct(loc.products)>
	</cffunction>

	<cffunction name="LoadCategoriesForEmployee" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.cats" datasource="#args.datasource#">
			SELECT epcID, epcTitle, epcFile
			FROM tblEPOSCats, tblEPOS_EmpCats
			WHERE eecCategory = epcID
			AND eecEmployee = #val(session.user.id)#
			ORDER BY epcOrder ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToArrayOfStruct(loc.cats)>
	</cffunction>

	<cffunction name="VerifyEncryptedString" access="public" returntype="boolean">
		<cfargument name="stringToTest" type="string" required="yes">
		<cfargument name="originalString" type="binary" required="yes">
		<cfset var loc = {}>
		<cftry>
		
		<cfquery name="loc.enc" datasource="#GetDatasource()#">
			SELECT (DES_ENCRYPT("#stringToTest#")) AS encryptedString
		</cfquery>
		<cfset loc.result = (ToString(loc.enc.encryptedString) eq ToString(originalString)) ? true : false>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="Login" access="public" returntype="boolean">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = false>
		
		<cftry>
		
		<cfquery name="loc.employee" datasource="#args.datasource#">
			SELECT empID, empFirstName, empLastName, empPin, empEPOSLevel
			FROM tblEmployee
			WHERE empID = #val(args.form.employee)#
		</cfquery>
		
		<cfif VerifyEncryptedString(args.form.pin, loc.employee.empPin)>
			<cfset session.user.id = loc.employee.empID>
			<cfset session.user.firstName = loc.employee.empFirstName>
			<cfset session.user.lastName = loc.employee.empLastName>
			<cfset session.user.eposLevel = loc.employee.empEPOSLevel>
			<cfset session.user.loggedin = true>
			<cfset session.user.prefs = LoadUserPreferencesMinimal(loc.employee.empID)>
			<cfset loc.result = true>
		</cfif>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="LoadEmployees" access="public" returntype="array">
		<cfset var loc = {}>
		
		<cftry>
		
		<cfquery name="loc.employees" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEmployee
			WHERE empEPOS = 'Yes'
			AND empStatus = 'active'
			ORDER BY empFirstName ASC
		</cfquery>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToArrayOfStruct(loc.employees)>
	</cffunction>
	
	<cffunction name="MonthName" access="public" returntype="string">
		<cfargument name="int" type="numeric" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = "">
		
		<cfswitch expression="#int#">
			<cfcase value="1"><cfset loc.result = "January"></cfcase>
			<cfcase value="2"><cfset loc.result = "Febuary"></cfcase>
			<cfcase value="3"><cfset loc.result = "March"></cfcase>
			<cfcase value="4"><cfset loc.result = "April"></cfcase>
			<cfcase value="5"><cfset loc.result = "May"></cfcase>
			<cfcase value="6"><cfset loc.result = "June"></cfcase>
			<cfcase value="7"><cfset loc.result = "July"></cfcase>
			<cfcase value="8"><cfset loc.result = "August"></cfcase>
			<cfcase value="9"><cfset loc.result = "September"></cfcase>
			<cfcase value="10"><cfset loc.result = "October"></cfcase>
			<cfcase value="11"><cfset loc.result = "November"></cfcase>
			<cfcase value="12"><cfset loc.result = "December"></cfcase>
		</cfswitch>
		
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CleanUpSession" access="public" returntype="void">
		<cftry>
		
		<cfset var loc = {}>
		
		<cfset loc.requiredKeys = ["product", "publication", "paypoint", "deal", "payment", "discount", "supplier"]>
		
		<cfif NOT StructKeyExists(session.epos_frame, "basket")>
			<cfset StructInsert(session.epos_frame, "basket", {})>
		</cfif>
		
		<cfloop array="#loc.requiredKeys#" index="loc.key">
			<cfif NOT StructKeyExists(session.epos_frame.basket, loc.key)>
				<cfset StructInsert(session.epos_frame.basket, loc.key, {})>
			</cfif>
		</cfloop>

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="GetVersion" access="public" returntype="string">
		<cftry>
		
		<cfreturn "1.0.0.0">

		<cfcatch type="any">
			 <cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>