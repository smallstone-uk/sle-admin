<cfcomponent displayname="deals" extends="core">
    <cffunction name="DeleteDeal" access="public" returntype="void">
		<cfargument name="dealID" type="numeric" required="yes">
        <cfset var loc = {}>
    
        <cfquery name="loc.delete" datasource="#GetDatasource()#">
			DELETE FROM tblEPOS_Deals
			WHERE edID = #val(dealID)#
			AND edID != 1
            LIMIT 1
		</cfquery>
    
    </cffunction>
    
    <cffunction name="SaveClub" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
        <cfset var loc = {}>

        <cfquery name="loc.save" datasource="#GetDatasource()#">
			UPDATE tblEPOS_RetailClubs
			SET ercTitle = '#args.erc_title#',
				ercIssue = '#args.erc_issue#',
				ercStarts = '#args.erc_starts#',
				ercEnds = '#args.erc_ends#'
			WHERE ercID = #val(args.erc_id)#
		</cfquery>
    
    </cffunction>

    <cffunction name="LoadClubByID" access="public" returntype="struct">
		<cfargument name="clubID" type="numeric" required="yes">
        <cfset var loc = {}>
    
        <cfquery name="loc.club" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_RetailClubs
			WHERE ercID = #val(clubID)#
			LIMIT 1
		</cfquery>
    
        <cfreturn QueryToStruct(loc.club)>
    </cffunction>

    <cffunction name="CreateClub" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
        <cfset var loc = {}>
    
        <cfquery name="loc.addClub" datasource="#GetDatasource()#">
			INSERT INTO tblEPOS_RetailClubs (
				ercTitle,
				ercIssue,
				ercStarts,
				ercEnds
			) VALUES (
				'#args.erc_title#',
				'#args.erc_issue#',
				'#args.erc_starts#',
				'#args.erc_ends#'
			)
		</cfquery>
    
    </cffunction>

    <cffunction name="LoadRetailClubs" access="public" returntype="array">
        <cfset var loc = {}>
    
        <cfquery name="loc.clubs" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_RetailClubs
			ORDER BY ercTimestamp DESC
		</cfquery>
    
        <cfreturn QueryToArrayOfStruct(loc.clubs)>
    </cffunction>

    <cffunction name="CreateDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
        <cfset var loc = {}>
    
		<cfset loc.edType = ""/>

		<cfswitch expression="#args.header.ed_dealtype#">
			<cfcase value="twofor">
				<cfset loc.edType = "Quantity"/>
			</cfcase>
			<cfcase value="bogof">
				<cfset loc.edType = "Discount"/>
			</cfcase>
			<cfcase value="anyfor">
				<cfset loc.edType = "Discount"/>
			</cfcase>
			<cfcase value="mealdeal">
				<cfset loc.edType = "Discount"/>
			</cfcase>
			<cfcase value="halfprice">
				<cfset loc.edType = "Discount"/>
			</cfcase>
			<cfcase value="nodeal">
				<cfset loc.edType = "Quantity"/>
			</cfcase>
			<cfcase value="only">
				<cfset loc.edType = "Quantity"/>
			</cfcase>
			<cfcase value="b1g1hp">
				<cfset loc.edType = "Discount"/>
			</cfcase>
		</cfswitch>

		<cfquery name="loc.getClubIndex" datasource="#GetDatasource()#">
			SELECT ercIndex FROM tblepos_retailclubs WHERE ercID=#val(args.header.ed_retailclub)#
		</cfquery>
		<cfset loc.dealIndex = loc.getClubIndex.ercIndex + 1>
		<cfquery name="loc.putClubIndex" datasource="#GetDatasource()#">
			UPDATE tblepos_retailclubs
			SET  ercIndex = #loc.dealIndex#
			WHERE ercID=#val(args.header.ed_retailclub)#
		</cfquery>
		
		<cfquery name="loc.addHeader" datasource="#GetDatasource()#" result="loc.addHeader_result">
			INSERT INTO tblEPOS_Deals (
				edTitle,
				edStarts,
				edEnds,
				edDealType,
				edType,
				edAmount,
				edQty,
				edStatus,
				edRetailClub,
				edIndex
			) VALUES (
				'#args.header.ed_title#',
				'#args.header.ed_starts#',
				'#args.header.ed_ends#',
				'#args.header.ed_dealtype#',
				'#loc.edType#',
				#val(args.header.ed_amount)#,
				#val(args.header.ed_quantity)#,
				'#args.header.ed_active#',
				#val(args.header.ed_retailclub)#,
				#val(loc.dealIndex)#
			)
		</cfquery>

		<cfif NOT ArrayIsEmpty(args.items)>
			<cfquery name="loc.addItems" datasource="#GetDatasource()#">
				INSERT INTO tblEPOS_DealItems (
					ediParent,
					ediProduct,
					ediMinQty,
					ediMaxQty
				) VALUES
				<cfset loc.counter = 1>
				<cfloop array="#args.items#" index="item">
					(
						#val(loc.addHeader_result.generatedKey)#,
						#val(item.id)#,
						#val(item.minqty)#,
						#val(item.maxqty)#
					)<cfif loc.counter neq ArrayLen(args.items) AND ArrayLen(args.items) gt 1>,</cfif>
					<cfset loc.counter++>
				</cfloop>
			</cfquery>
		</cfif>
    
        <cfreturn loc>
    </cffunction>

    <cffunction name="UpdateDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
        <cfset var loc = {}>
    
        <!---Check if the deal exists--->
        <cfquery name="loc.check" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_Deals
			WHERE edID = #val(args.header.ed_id)#
			LIMIT 1
		</cfquery>

		<cfif loc.check.recordcount is 1>
			<cfset loc.edType = ""/>

			<cfswitch expression="#args.header.ed_dealtype#">
				<cfcase value="twofor">
					<cfset loc.edType = "Quantity"/>
				</cfcase>
				<cfcase value="bogof">
					<cfset loc.edType = "Discount"/>
				</cfcase>
				<cfcase value="anyfor">
					<cfset loc.edType = "Discount"/>
				</cfcase>
				<cfcase value="mealdeal">
					<cfset loc.edType = "Discount"/>
				</cfcase>
				<cfcase value="halfprice">
					<cfset loc.edType = "Discount"/>
				</cfcase>
				<cfcase value="nodeal">
					<cfset loc.edType = "Quantity"/>
				</cfcase>
				<cfcase value="only">
					<cfset loc.edType = "Quantity"/>
				</cfcase>
				<cfcase value="b1g1hp">
					<cfset loc.edType = "Discount"/>
				</cfcase>
			</cfswitch>

			<cfquery name="loc.updateHeader" datasource="#GetDatasource()#">
				UPDATE tblEPOS_Deals
				SET edTitle = '#args.header.ed_title#',
					edStarts = '#args.header.ed_starts#',
					edEnds = '#args.header.ed_ends#',
					edDealType = '#args.header.ed_dealtype#',
					edType = '#loc.edType#',
					edAmount = #val(args.header.ed_amount)#,
					edQty = #val(args.header.ed_quantity)#,
					edStatus = '#args.header.ed_active#',
					edRetailClub = #val(args.header.ed_retailclub)#
				WHERE edID = #val(args.header.ed_id)#
				LIMIT 1
			</cfquery>

			<cfquery name="loc.delItems" datasource="#GetDatasource()#">
				DELETE FROM tblEPOS_DealItems
				WHERE ediParent = #val(args.header.ed_id)#
			</cfquery>

			<cfif NOT ArrayIsEmpty(args.items)>
				<cfquery name="loc.addItems" datasource="#GetDatasource()#">
					INSERT INTO tblEPOS_DealItems (
						ediParent,
						ediProduct,
						ediMinQty,
						ediMaxQty
					) VALUES
					<cfset loc.counter = 1>
					<cfloop array="#args.items#" index="item">
						(
							#val(args.header.ed_id)#,
							#val(item.id)#,
							#val(item.minqty)#,
							#val(item.maxqty)#
						)<cfif loc.counter neq ArrayLen(args.items) AND ArrayLen(args.items) gt 1>,</cfif>
						<cfset loc.counter++>
					</cfloop>
				</cfquery>
			</cfif>
		</cfif>
    
        <cfreturn loc>
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
			 <cf_dumptofile var="#cfcatch#">
		</cfcatch>
		</cftry>
				
		<cfreturn loc.result>
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
			<cf_dumptofile var="#cfcatch#">
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
			INNER JOIN tblProductCats ON pcatID = prodCatID
			INNER JOIN tblProductGroups ON pcatGroup = pgID
			WHERE prodID = #val(productID)#
			GROUP BY pcatID
			ORDER BY prodTitle ASC
		</cfquery>

		<cfcatch type="any">
			 <cf_dumptofile var="#cfcatch#">
		</cfcatch>
		</cftry>
		
		<cfreturn QueryToStruct(loc.product)>
	</cffunction>

	<cffunction name="LoadProductByBarcode" access="public" returntype="struct">
		<cfargument name="barcode" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
		
		<cfquery name="loc.barcode" datasource="#GetDatasource()#" result="loc.barcodeResult">
			SELECT barCode, barType, barProdID
			FROM tblBarcodes
			WHERE barCode = '#barcode#'
			LIMIT 1
		</cfquery>
		<cfdump var="#loc.barcodeResult#" label="LoadProductByBarcode" expand="yes" format="html" 
			output="#application.site.dir_logs#bar-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">		
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
			 <cf_dumptofile var="#cfcatch#">
		</cfcatch>
		</cftry>

		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="RemoveProductFromDeal" access="public" returntype="void">
		<cfargument name="dealID" type="numeric" required="yes">
		<cfargument name="prodID" type="numeric" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.remove" datasource="#GetDatasource()#">
			DELETE FROM tblEPOS_DealItems
			WHERE ediProduct = #val(prodID)#
			AND ediParent = #val(dealID)#
		</cfquery>

	</cffunction>
	<cffunction name="SearchProductsByName" access="public" returntype="array">
		<cfargument name="srchQuery" type="string" required="yes">
		<cfset var loc = {}>

		<cfquery name="loc.prods" datasource="#GetDatasource()#">
			SELECT tblProducts.*, tblStockItem.*
			FROM tblProducts
			LEFT JOIN tblStockItem ON prodID = siProduct
			AND tblStockItem.siID = (
				SELECT MAX(siID)
				FROM tblStockItem
				WHERE prodID = siProduct
			)
			WHERE prodTitle LIKE '%#srchQuery#%'
			LIMIT 16

			<!---SELECT *
			FROM tblProducts
			WHERE prodTitle LIKE '%#srchQuery#%'
			LIMIT 16--->
		</cfquery>

		<cfreturn QueryToArrayOfStruct(loc.prods)>
	</cffunction>

	<cffunction name="LoadDealItems" access="public" returntype="array">
		<cfargument name="dealID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.items" datasource="#GetDatasource()#">
			SELECT tblEPOS_DealItems.*, tblProducts.prodTitle
			FROM tblEPOS_DealItems, tblProducts
			WHERE ediParent = #val(dealID)#
			AND ediProduct = prodID
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.items)>
	</cffunction>
	
	<cffunction name="LoadDealByID" access="public" returntype="struct">
		<cfargument name="dealID" type="numeric" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.deal" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_Deals
			WHERE edID = #val(dealID)#
			LIMIT 1
		</cfquery>
		
		<cfreturn QueryToStruct(loc.deal)>
	</cffunction>
	
	<cffunction name="LoadAllDeals" access="public" returntype="array">
		<cfargument name="retailClub" type="numeric" required="no" default="-1">
		<cfset var loc = {}>
		
		<cfquery name="loc.deals" datasource="#GetDatasource()#">
			SELECT *
			FROM tblEPOS_Deals
			<cfif arguments.retailClub gt -1>
				WHERE edRetailClub = #val(arguments.retailClub)#
			</cfif>
			ORDER BY edRetailClub DESC, edEnds DESC
		</cfquery>
		
		<cfreturn QueryToArrayOfStruct(loc.deals)>
	</cffunction>
	
	<cffunction name="StructToDataAttributes" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = "">
		
		<cfloop collection="#args#" item="loc.key">
			<cfset loc.item = StructFind(args, loc.key)>
			<cfif IsValid("string", loc.item) OR IsValid("boolean", loc.item) OR IsValid("float", loc.item)>
				<cfset loc.result = loc.result & " data-#LCase(loc.key)#='#loc.item#'">
			</cfif>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
</cfcomponent>
