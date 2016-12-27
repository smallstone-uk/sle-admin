<cfcomponent displayname="products" extends="core">

	<cffunction name="LoadProductList" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var code={}>
		<cfset var QProducts="">
		<cfset var QBarcodes="">
		<cfset var QUpdate="">
		
		<cfquery name="QProducts" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE <cfif StructKeyExists(args.form,"selectitem")>prodID IN (#args.form.selectitem#)<cfelse>1</cfif>
			ORDER BY prodTitle asc
		</cfquery>
		<cfloop query="QProducts">
			<cfquery name="QBarcodes" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barProdID=#prodID#
				AND barType='product'
				ORDER BY barID desc
			</cfquery>
			<cfset item={}>
			<cfset item.ID=prodID>
			<cfset item.Title=prodTitle>
			<cfset item.UnitSize=prodUnitSize>
			<cfset item.Price=prodOurPrice>
			<cfset item.Barcodes=[]>
			<cfloop query="QBarcodes">
				<cfif item.Price neq QBarcodes.barPrice>
					<cfquery name="QUpdate" datasource="#args.datasource#">
						UPDATE tblBarcodes
						SET barPrice=#item.Price#
						WHERE barID=#QBarcodes.barID#
					</cfquery>
				</cfif>
				<cfset code={}>
				<cfset code.Barcode=QBarcodes.barCode>
				<cfset code.Price=QBarcodes.barPrice>
				<cfset code.VAT=QBarcodes.barVAT>
				<cfset code.Issue=QBarcodes.barIssue>
				<cfset ArrayAppend(item.Barcodes,code)>
			</cfloop>
			<cfset ArrayAppend(result,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>

	<cffunction name="SendBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">
		<cfset var QProduct="">
		<cfset result.error="">

		<cfif StructKeyExists(args.form,"barcode")>
			<cfquery name="QBarcode" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode LIKE '%#args.form.barcode#%'	<!--- was = --->
				LIMIT 1;
			</cfquery>
			<cfif QBarcode.recordcount is 1>
				<cfset parm={}>
				<cfset parm.datasource=args.datasource>
				<cfset parm.ID=QBarcode.barProdID>
				<cfset parm.Price=QBarcode.barPrice>
				<cfset result.data=CheckProduct(parm)>
				<cfif StructKeyExists(args.form,"supp") AND args.form.supp is result.data.SuppID>
					<cfset result.mode=2>
				<cfelse>
					<cfset result.error="">
					<cfset result.mode=3>
				</cfif>
			<cfelse>
				<cfset result.error="Product not found">
				<cfset result.mode=1>
			</cfif>
		<cfelse>
			<cfquery name="QProduct" datasource="#args.datasource#">
				SELECT *
				FROM tblProducts,tblAccount
				WHERE prodID=#val(args.form.ID)#
				AND prodSuppID=accID
				LIMIT 1;
			</cfquery>
			<cfif QProduct.recordcount is 1>
				<cfif args.form.supp is QProduct.prodSuppID>
					<cfset parm={}>
					<cfset parm.datasource=args.datasource>
					<cfset parm.ID=QProduct.prodID>
					<cfset parm.Price=QProduct.prodOurPrice>
					<cfset result.data=CheckProduct(parm)>
					<cfset result.mode=2>
				<cfelse>
					<cfset result.error="#QProduct.prodTitle# is a #QProduct.accName# product.">
					<cfset result.mode=3>
				</cfif>
			<cfelse>
				<cfset result.error="Product not found">
				<cfset result.mode=1>
			</cfif>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="CheckProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProducts="">

		<cfquery name="QProducts" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodID=#val(args.ID)#
		</cfquery>
		<cfset result.ID=QProducts.prodID>
		<cfset result.SuppID=QProducts.prodSuppID>
		<cfset result.CatID=QProducts.prodCatID>
		<cfset result.Title=QProducts.prodTitle>
		<cfset result.Price=args.Price>
		<cfset result.PackQty=QProducts.prodPackQty>
		<cfset result.PackPrice=QProducts.prodPackPrice>
		<cfset result.UnitSize=QProducts.prodUnitSize>
		<cfset result.VatRate=QProducts.prodVatRate>

		<cfreturn result>
	</cffunction>

	<cffunction name="LoadProducts" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QProducts="">

		<cfquery name="QProducts" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE 1
			<cfif StructKeyExists(args.form,"supp")>AND prodSuppID=#args.form.supp#</cfif>
			ORDER BY prodID asc
		</cfquery>
		<cfloop query="QProducts">
			<cfset item={}>
			<cfset item.ID=prodID>
			<cfset item.SuppID=prodSuppID>
			<cfset item.CatID=prodCatID>
			<cfset item.Title=prodTitle>
			<cfset item.Price=prodOurPrice>
			<cfset item.PackQty=prodPackQty>
			<cfset item.PackPrice=prodPackPrice>
			<cfset item.UnitSize=prodUnitSize>
			<cfset item.VatRate=prodVatRate>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadSuppiers" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QSupps="">

		<cfquery name="QSupps" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accStockControl=1
			AND accType='purch'
			ORDER BY accName asc
		</cfquery>
		<cfloop query="QSupps">
			<cfset item={}>
			<cfset item.ID=accID>
			<cfset item.Code=accCode>
			<cfset item.Type=accStockControlType>
			<cfset item.Name=accName>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadProductBarcodes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QBarcodes="">

		<cfquery name="QBarcodes" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barProdID=#val(args.form.id)#
			AND barType='#args.form.type#'
		</cfquery>
		<cfloop query="QBarcodes">
			<cfset item={}>
			<cfset item.ID=barID>
			<cfset item.Code=barCode>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AddBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parm={}>
		<cfset var data={}>
		<cfset var QBarcode="">
		<cfset var QProduct="">
		
		<cftry>
			<cfquery name="QProduct" datasource="#args.datasource#">
				SELECT *
				FROM tblProducts
				WHERE prodID=#val(args.form.ID)#
				LIMIT 1;
			</cfquery>
			
			<cfquery name="QCheck" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode='#args.form.barcode#'
				LIMIT 1;
			</cfquery>
			<cfif QCheck.recordcount is 0>
				<cfquery name="QBarcode" datasource="#args.datasource#">
					INSERT INTO tblBarcodes (
						barCode,
						barType,
						barProdID,
						barPrice,
						barVat
					) VALUES (
						'#args.form.barcode#',
						'#args.form.type#',
						#val(args.form.ID)#,
						#DecimalFormat(QProduct.prodOurPrice)#,
						#DecimalFormat(QProduct.prodVatRate)#
					)
				</cfquery>
			<cfelse>
				<cfquery name="QBarcode" datasource="#args.datasource#">
					UPDATE tblBarcodes
					SET barCode='#args.form.barcode#',
						barType='#args.form.type#',
						barProdID=#val(args.form.ID)#,
						barPrice=#DecimalFormat(QProduct.prodOurPrice)#,
						barVat=#DecimalFormat(QProduct.prodVatRate)#
					WHERE barID=#QCheck.barID#
				</cfquery>
			</cfif>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelete="">

		<cftry>
			<cfif StructKeyExists(args.form,"selectcode")>
				<cfquery name="QDelete" datasource="#args.datasource#">
					DELETE FROM tblBarcodes
					WHERE barID IN (#args.form.selectcode#)
				</cfquery>
			<cfelse>
				<cfset result.error.message="no barcodes selected">
			</cfif>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AddStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">
		<cfset var QNewProd="">
		<cfset var QBarcode="">
		<cfset var QInsertBarcode="">
		<cfset var QUpdateBarcode="">
		<cfset var QProductStock="">
		<cfset var QProductStockCheck="">
		<cfset productID=val(args.form.prodID)>

		<cftry>
			<cfif args.form.mode is 1 AND productID is 0>
				<cfquery name="QProduct" datasource="#args.datasource#" result="QNewProd">
					INSERT INTO tblProducts (
						prodSuppID,
						prodTitle,
						prodCatID,
						prodUnitSize,
						prodPackPrice,
						prodOurPrice,
						prodPackQty,
						prodVatRate
					) VALUES (
						#args.form.supp#,
						'#args.form.prodTitle#',
						#val(args.form.catID)#,
						'#args.form.prodSize#',
						#DecimalFormat(val(args.form.pskPackPrice))#,
						#DecimalFormat(val(args.form.pskShelfPrice))#,
						#val(args.form.pskPack)#,
						#val(args.form.pskVatRate)#
					)
				</cfquery>
				<cfset productID=QNewProd.generatedKey>
			<cfelse>
				<cfquery name="QProduct" datasource="#args.datasource#">
					UPDATE tblProducts
					SET prodSuppID=#args.form.supp#,
						prodTitle='#args.form.prodTitle#',
						prodCatID=#val(args.form.catID)#,
						prodUnitSize='#args.form.prodSize#',
						prodPackPrice=#DecimalFormat(val(args.form.pskPackPrice))#,
						prodOurPrice=#DecimalFormat(val(args.form.pskShelfPrice))#,
						prodPackQty=#val(args.form.pskPack)#,
						prodVatRate=#val(args.form.pskVatRate)#
					WHERE prodID=#productID#
				</cfquery>
			</cfif>
			
			<cfquery name="QBarcode" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode='#args.form.barcode#'
				LIMIT 1;
			</cfquery>
			<cfif QBarcode.recordcount is 0>
				<cfquery name="QInsertBarcode" datasource="#args.datasource#">
					INSERT INTO tblBarcodes (
						barCode,
						barType,
						barProdID,
						barPrice,
						barVat
					) VALUES (
						'#args.form.barcode#',
						'product',
						#productID#,
						#args.form.pskShelfPrice#,
						#args.form.pskVatRate#
					)
				</cfquery>
			<cfelse>
				<cfquery name="QUpdateBarcode" datasource="#args.datasource#">
					UPDATE tblBarcodes
					SET	barPrice=#args.form.pskShelfPrice#,
						barVat=#args.form.pskVatRate#
					WHERE barID=#QBarcode.barID#
				</cfquery>
			</cfif>
			
			<cfquery name="QProductStockCheck" datasource="#args.datasource#">
				SELECT pskID
				FROM tblProductStock
				WHERE pskProdID=#val(productID)#
				AND pskTimestamp='#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#'
				LIMIT 1;
			</cfquery>
			<cfif QProductStockCheck.recordcount is 0>
				<cfquery name="QProductStock" datasource="#args.datasource#">
					INSERT INTO tblProductStock (
						pskProdID,
						pskTimestamp,
						pskPack,
						pskPackPrice,
						pskShelfPrice,
						pskVatRate
					) VALUES (
						#productID#,
						'#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#',
						#val(args.form.pskPack)#,
						#DecimalFormat(val(args.form.pskPackPrice))#,
						#DecimalFormat(val(args.form.pskShelfPrice))#,
						#DecimalFormat(val(args.form.pskVatRate))#
					)
				</cfquery>
			<cfelse>
				<cfquery name="QProductStock" datasource="#args.datasource#">
					UPDATE tblProductStock
					SET pskPack=#val(args.form.pskPack)#,
						pskPackPrice=#DecimalFormat(val(args.form.pskPackPrice))#,
						pskShelfPrice=#DecimalFormat(val(args.form.pskShelfPrice))#,
						pskVatRate=#DecimalFormat(val(args.form.pskVatRate))#
					WHERE pskID=#val(QProductStockCheck.pskID)#
				</cfquery>
			</cfif>
			
			<cfset result.msg="#args.form.prodTitle# has been added.">
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddMultiStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">
		<cfset var QProductStock="">
		<cfset var QNewProd="">
		<cfset var QProductStockCheck="">

		<cftry>
			<cfif StructKeyExists(args.form,"row")>
				<cfloop list="#args.form.row#" delimiters="," index="row">
					<cfset ID=StructFind(args.form,"prodID#row#")>
					<cfset title=StructFind(args.form,"prodTitle#row#")>
					<cfset CatID=StructFind(args.form,"catID#row#")>
					<cfset UnitSize=StructFind(args.form,"prodSize#row#")>
					<cfset PackPrice=StructFind(args.form,"pskPackPrice#row#")>
					<cfset UnitPrice=StructFind(args.form,"pskShelfPrice#row#")>
					<cfset PackQty=StructFind(args.form,"pskPack#row#")>
					<cfset VatRate=StructFind(args.form,"pskVatRate#row#")>
					
					<cfif len(title)>
						<cfif ID is 0>
							<cfquery name="QProduct" datasource="#args.datasource#" result="QNewProd">
								INSERT INTO tblProducts (
									prodSuppID,
									prodTitle,
									prodCatID,
									prodUnitSize,
									prodPackPrice,
									prodOurPrice,
									prodPackQty,
									prodVatRate
								) VALUES (
									#args.form.supp#,
									'#Title#',
									#val(catID)#,
									'#UnitSize#',
									#DecimalFormat(PackPrice)#,
									#DecimalFormat(UnitPrice)#,
									#PackQty#,
									#VatRate#
								)
							</cfquery>
							<cfset ID=QNewProd.generatedKey>
						<cfelse>
							<cfquery name="QProduct" datasource="#args.datasource#">
								UPDATE tblProducts
								SET prodTitle='#Title#',
									prodCatID=#val(catID)#,
									prodUnitSize='#UnitSize#',
									prodPackPrice=#DecimalFormat(PackPrice)#,
									prodOurPrice=#DecimalFormat(UnitPrice)#,
									prodPackQty=#PackQty#,
									prodVatRate=#VatRate#
								WHERE prodID=#ID#
							</cfquery>
						</cfif>
						
						<!---<cfquery name="QProductStockCheck" datasource="#args.datasource#">
							SELECT pskID
							FROM tblProductStock
							WHERE pskProdID=#val(ID)#
							AND pskTimestamp='#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#'
							LIMIT 1;
						</cfquery>
						<cfif QProductStockCheck.recordcount is 0>
							<cfquery name="QProductStock" datasource="#args.datasource#">
								INSERT INTO tblProductStock (
									pskProdID,
									pskTimestamp,
									pskPack,
									pskPackPrice,
									pskShelfPrice,
									pskVatRate
								) VALUES (
									#ID#,
									'#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#',
									#PackQty#,
									#DecimalFormat(PackPrice)#,
									#DecimalFormat(UnitPrice)#,
									#DecimalFormat(VatRate)#
								)
							</cfquery>
						<cfelse>
							<cfquery name="QProductStock" datasource="#args.datasource#">
								UPDATE tblProductStock
								SET pskPack=#PackQty#,
									pskPackPrice=#DecimalFormat(PackPrice)#,
									pskShelfPrice=#DecimalFormat(UnitPrice)#,
									pskVatRate=#DecimalFormat(VatRate)#
								WHERE pskID=#val(QProductStockCheck.pskID)#
							</cfquery>
						</cfif>--->
					</cfif>
				</cfloop>
				
				<cfset result.msg="Saved">
			<cfelse>
				<cfset result.error="Not a multi form">
			</cfif>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadStockByDate" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var b={}>
		<cfset var QProductStock="">
		<cfset var QBarcodes="">
		<cfset var QDeals="">
		
		<cfquery name="QProductStock" datasource="#args.datasource#">
			SELECT *
			FROM tblProductStock,tblProducts
			WHERE pskTimestamp='#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#'
			<cfif NOT StructKeyExists(args.form,"showAllStock")>AND prodSuppID=#args.form.supp#</cfif>
			AND pskProdID=prodID
		</cfquery>
		<cfloop query="QProductStock">
			<cfquery name="QBarcodes" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barProdID=#pskProdID#
				AND barType='product'
				ORDER BY barID desc
			</cfquery>
			<cfquery name="QDeals" datasource="#args.datasource#">
				SELECT *
				FROM tblDealItems,tblDeals
				WHERE dimProdID=#prodID#
				AND dimDealID=dealID
			</cfquery>
			<cfset item={}>
			<cfset item.ID=pskID>
			<cfset item.prodID=prodID>
			<cfset item.Title="#prodTitle# #prodUnitSize#">
			<cfset item.Pack=pskPack>
			<cfset item.PackPrice=pskPackPrice>
			<cfset item.ShelfPrice=pskShelfPrice>
			<cfset item.VatRate=pskVatRate>
			<cfset item.SV=item.PackPrice + (item.PackPrice / 100) * (item.VatRate*100)>
			<cfset item.POR=(((item.ShelfPrice * item.Pack) - item.SV) / (item.ShelfPrice * item.Pack) * 100)>
			<cfset item.barcodes=[]>
			<cfloop query="QBarcodes">
				<cfset b={}>
				<cfset b.Code=QBarcodes.barCode>
				<cfset b.Price=QBarcodes.barPrice>
				<cfset ArrayAppend(item.barcodes,b)>
			</cfloop>
			<cfset item.deals=[]>
			<cfloop query="QDeals">
				<cfset d={}>
				<cfset d.Title=QDeals.dealTitle>
				<cfset d.Type=QDeals.dealType>
				<cfset d.Qty=QDeals.dealQty>
				<cfset d.Price=QDeals.dealAmount>
				<cfset ArrayAppend(item.deals,d)>
			</cfloop>
			<cfset ArrayAppend(result,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddProductCat" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProductCat="">
		
		<cftry>
			<cfquery name="QProductCat" datasource="#args.datasource#">
				INSERT INTO tblProductCats (
					pcatTitle
				) VALUES (
					'#args.form.catTitle#'
				)
			</cfquery>
			<cfset result.msg="Added">
		
			<cfcatch type="any">
				 <cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadProductCats" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var item={}>
		<cfset var QProductCats="">
		
		<cfquery name="QProductCats" datasource="#args.datasource#">
			SELECT *
			FROM tblProductCats
			ORDER BY pcatTitle asc
		</cfquery>
		<cfloop query="QProductCats">
			<cfset item={}>
			<cfset item.ID=pcatID>
			<cfset item.title=pcatTitle>
			<cfset ArrayAppend(result,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="CheckProductExists" access="public" returntype="boolean">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=false>
		<cfset var QProduct="">
		
		<cfquery name="QProduct" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodBarcode='#args.form.barcodeCheck#'
			LIMIT 1;
		</cfquery>
		<cfif QProduct.recordcount is 1>
			<cfset result=true>
		<cfelse>
			<cfset result=false>
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="CheckProductStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">
		<cfset var QProduct="">
		<cfset var QProductStock="">
		
		<cfquery name="QBarcode" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barCode='#args.form.barcodeCheck#'
			AND barType='product'
			LIMIT 1;
		</cfquery>
		<cfif QBarcode.recordcount is 1>
			<cfquery name="QProduct" datasource="#args.datasource#">
				SELECT *
				FROM tblProducts,tblProductCats
				WHERE prodID=#QBarcode.barProdID#
				AND prodCatID=pcatID
				LIMIT 1;
			</cfquery>
			<cfquery name="QProductStock" datasource="#args.datasource#">
				SELECT *
				FROM tblProductStock
				WHERE pskProdID=#val(QProduct.prodID)#
				AND pskTimestamp='#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#'
				LIMIT 1;
			</cfquery>
			<cfif QProductStock.recordcount is 1>
				<cfset result.mode=2>
				<cfset result.ID=QProduct.prodID>
				<cfset result.StockID=QProductStock.pskID>
				<cfset result.Title=QProduct.prodTitle>
				<cfset result.CatID=QProduct.pcatID>
				<cfset result.CatTitle=QProduct.pcatTitle>
				<cfset result.Price=QProductStock.pskShelfPrice>
				<cfset result.PackPrice=QProductStock.pskPackPrice>
				<cfset result.Pack=QProductStock.pskPack>
				<cfset result.Size=QProduct.prodUnitSize>
				<cfset result.VatRate=QProductStock.pskVatRate>
			<cfelse>
				<cfset result.mode=1>
				<cfset result.ID=QProduct.prodID>
				<cfset result.StockID=0>
				<cfset result.Title=QProduct.prodTitle>
				<cfset result.CatID=QProduct.pcatID>
				<cfset result.CatTitle=QProduct.pcatTitle>
				<cfset result.Price=QProduct.prodOurPrice>
				<cfset result.PackPrice=QProduct.prodPackPrice>
				<cfset result.Pack=QProduct.prodPackQty>
				<cfset result.Size=QProduct.prodUnitSize>
				<cfset result.VatRate=QProduct.prodVatRate>
			</cfif>
		<cfelse>
			<cfset result.mode=3>
			<cfset result.ID="">
			<cfset result.StockID=0>
			<cfset result.Title="">
			<cfset result.CatID=0>
			<cfset result.CatTitle="">
			<cfset result.Price="">
			<cfset result.PackPrice="">
			<cfset result.Pack="">
			<cfset result.Size="">
			<cfset result.VatRate="">
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadProductCache" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QProductStock="">
		
		<cftry>
			<cfquery name="QProductStock" datasource="#args.datasource#">
				SELECT *
				FROM tblProductStock,tblProducts
				WHERE pskTimestamp='#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#'
				AND pskProdID=prodID
			</cfquery>
			<cfloop query="QProductStock">
				<cfset item={}>
				<cfset item.Title=prodTitle>
				<cfset item.Pack=pskPack>
				<cfset item.PackPrice=pskPackPrice>
				<cfset item.Price=pskShelfPrice>
				<cfset item.VatRate=pskVatRate>
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
		
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">
		
		<cfquery name="QProduct" datasource="#args.datasource#">
			SELECT *
			FROM tblProducts
			WHERE prodBarcode=#args.form.barcodeCheck#
			LIMIT 1;
		</cfquery>
		<cfset result.ID=QProduct.prodID>
		<cfset result.Type=QProduct.prodCatID>
		<cfset result.Title=QProduct.prodTitle>
		<cfset result.Price=QProduct.prodOurPrice>
		<cfset result.UnitSize=QProduct.prodUnitSize>
		<cfset result.Class=QProduct.prodClass>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">
		
		<cftry>
			<cfquery name="QProduct" datasource="#args.datasource#" result="QResult">
				INSERT INTO tblProducts (
					prodBarcode,
					prodTitle,
					prodOurPrice,
					prodClass,
					prodCatID,
					prodUnitSize
				) VALUES (
					'#args.form.barcode#',
					'#args.form.title#',
					#DecimalFormat(args.form.price)#,
					'#args.form.class#',
					#val(args.form.type)#,
					'#args.form.UnitSize#'
				)
			</cfquery>
			<cfset result.msg="Product Added">
			<cfset parm={}>
			<cfset parm.ID=QResult.generatedKey>
			<cfset cache=ProductCache(parm)>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddProductStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QProductStock="">
		<cfset var QProduct="">
		<cfset var QUpdate="">
		<cfset var QInsert="">
		
		<cftry>
			<cfset productID=val(args.form.prodID)>
			<cfif args.form.mode is 1 OR args.form.mode is 2>
				<cfquery name="QUpdate" datasource="#args.datasource#">
					UPDATE tblProducts
					SET prodTitle='#args.form.prodtitle#',
						prodCatID=#args.form.catID#,
						prodUnitSize='#args.form.prodSize#',
						prodPackPrice=#DecimalFormat(args.form.pskPackPrice)#,
						prodOurPrice=#DecimalFormat(args.form.pskShelfPrice)#,
						prodPackQty=#args.form.pskPack#,
						prodVatRate=#args.form.pskVatRate#
					WHERE prodID=#productID#
				</cfquery>
			<cfelseif args.form.mode is 3>
				<cfquery name="QInsert" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblProducts (
						prodBarcode,
						prodTitle,
						prodCatID,
						prodUnitSize,
						prodPackPrice,
						prodOurPrice,
						prodPackQty,
						prodVatRate
					) VALUES (
						'#args.form.barcodeCheck#',
						'#args.form.prodtitle#',
						#args.form.catID#,
						'#args.form.prodSize#',
						#DecimalFormat(args.form.pskPackPrice)#,
						#DecimalFormat(args.form.pskShelfPrice)#,
						#args.form.pskPack#,
						#args.form.pskVatRate#
					)
				</cfquery>
				<cfset productID=QResult.generatedKey>
			</cfif>
			
			<cfquery name="QProduct" datasource="#args.datasource#">
				SELECT *
				FROM tblProducts
				WHERE prodID=#productID#
				LIMIT 1;
			</cfquery>
			<cfif QProduct.recordcount is 1>
				<cfif args.form.mode neq 2>
					<cfquery name="QProductStock" datasource="#args.datasource#">
						INSERT INTO tblProductStock (
							pskProdID,
							pskTimestamp,
							pskPack,
							pskPackPrice,
							pskShelfPrice,
							pskVatRate
						) VALUES (
							#val(QProduct.prodID)#,
							'#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#',
							#int(args.form.pskPack)#,
							#DecimalFormat(args.form.pskPackPrice)#,
							#DecimalFormat(args.form.pskShelfPrice)#,
							#DecimalFormat(args.form.pskVatRate)#
						)
					</cfquery>
					<cfset result.msg="Saved">
				<cfelse>
					<cfif args.form.stockID neq 0>
						<cfquery name="QProductStock" datasource="#args.datasource#">
							UPDATE tblProductStock
							SET pskProdID=#val(QProduct.prodID)#,
								pskTimestamp='#LSDateFormat(args.form.pskDate,"yyyy-mm-dd")#',
								pskPack=#args.form.pskPack#,
								pskPackPrice=#DecimalFormat(args.form.pskPackPrice)#,
								pskShelfPrice=#DecimalFormat(args.form.pskShelfPrice)#,
								pskVatRate=#DecimalFormat(args.form.pskVatRate)#
							WHERE pskID=#val(args.form.stockID)#
						</cfquery>
						<cfset result.msg="Updated">
					</cfif>
				</cfif>
			<cfelse>
				<cfset result.msg="Product not found">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateProduct" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parm={}>
		<cfset var QProduct="">
		
		<cftry>
			<cfquery name="QProduct" datasource="#args.datasource#">
				UPDATE tblProducts
				SET
					prodBarcode='#args.form.barcode#',
					prodCatID=#val(args.form.type)#,
					prodTitle='#args.form.title#',
					prodOurPrice=#DecimalFormat(args.form.price)#,
					prodClass='#args.form.class#',
					prodUnitSize='#args.form.UnitSize#'
				WHERE prodID=#args.form.productID#
			</cfquery>
			<cfset result.msg="Product Updated">
			<cfset parm={}>
			<cfset parm.ID=args.form.productID>
			<cfset cache=ProductCache(parm)>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="ProductCache" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var item={}>
		
		<cfif NOT StructKeyExists(session,"productcache")>
			<cfset session.productcache=ArrayNew(1)>
		</cfif>
		
		<cfset item={}>
		<cfset item.ID=args.ID>
		<cfset ArrayAppend(session.productcache,item)>

		<cfreturn>
	</cffunction>
	
	<cffunction name="LoadDeals" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var i={}>
		<cfset var QDeals="">
		<cfset var QDealItems="">

		<cfquery name="QDeals" datasource="#args.datasource#">
			SELECT *
			FROM tblDeals
		</cfquery>
		<cfloop query="QDeals">
			<cfquery name="QDealItems" datasource="#args.datasource#">
				SELECT *
				FROM tblDealItems,tblProducts
				WHERE dimDealID=#dealID#
				AND dimProdID=prodID
			</cfquery>
			<cfset item={}>
			<cfset item.ID=dealID>
			<cfset item.Title=dealTitle>
			<cfset item.Type=dealType>
			<cfset item.Amount=dealAmount>
			<cfset item.Qty=dealQty>
			<cfset item.Status=dealStatus>
			<cfset item.items=[]>
			<cfloop query="QDealItems">
				<cfset i={}>
				<cfset i.ID=dimID>
				<cfset i.dealID=dimDealID>
				<cfset i.prodID=dimProdID>
				<cfset i.Title=prodTitle>
				<cfset ArrayAppend(item.items,i)>
			</cfloop>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AddDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDeal="">
		<cfset var QResult="">

		<cfquery name="QDeal" datasource="#args.datasource#" result="QResult">
			INSERT INTO tblDeals (
				dealRecordTitle,
				dealTitle,
				dealStarts,
				dealEnds,
				dealType,
				dealAmount,
				dealQty,
				dealStatus
			) VALUES (
				'#args.form.dealRecordTitle#',
				'#args.form.dealTitle#',
				'#LSDateFormat(args.form.dealStarts,"yyyy-mm-dd")#',
				'#LSDateFormat(args.form.dealEnds,"yyyy-mm-dd")#',
				'#args.form.dealType#',
				#val(args.form.dealAmount)#,
				#val(args.form.dealQty)#,
				'#args.form.dealStatus#'
			)
		</cfquery>
		<cfset result.ID=val(QResult.generatedKey)>
		<cfset result.RecordTitle=args.form.dealRecordTitle>
		<cfset result.Title=args.form.dealTitle>
		<cfset result.Starts=LSDateFormat(args.form.dealStarts,"yyyy-mm-dd")>
		<cfset result.Ends=LSDateFormat(args.form.dealEnds,"yyyy-mm-dd")>
		<cfset result.Type=args.form.dealType>
		<cfset result.Amount=val(args.form.dealAmount)>
		<cfset result.Qty=val(args.form.dealQty)>
		<cfset result.Status=args.form.dealStatus>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AssignToDeal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDealItems="">
		<cfset var count=0>

		<cfif StructKeyExists(args.form,"selectprod") AND StructKeyExists(args.form,"selectdeal")>
			<cfquery name="QDealItems" datasource="#args.datasource#">
				INSERT INTO tblDealItems (dimDealID,dimProdID) VALUES 
				<cfloop list="#args.form.selectprod#" delimiters="," index="i">
					<cfset count=count+1>
					<cfif count neq 1>,</cfif>(#val(args.form.selectdeal)#,#val(i)#)
				</cfloop>
			</cfquery>
		</cfif>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="GetProductBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">

		<cfquery name="QBarcode" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barProdID=#val(args.ID)#
			AND barType='product'
			LIMIT 1;
		</cfquery>
		<cfset result.code=QBarcode.barCode>

		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPriceList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var cat={}>
		<cfset var prod={}>
		<cfset var c={}>
		<cfset var d={}>
		<cfset var QProduct="">
		<cfset var QDeals="">
		<cfset var cat=0>
		<cfset result.cats={}>

		<cfquery name="QProduct" datasource="#args.datasource#">
			SELECT tblProductCats.*,prodID,prodTitle,prodOurPrice,prodUnitSize,prodPriceMarked
			FROM tblProducts,tblProductCats
			WHERE 1
			AND prodCatID=pcatID
			ORDER BY pcatTitle asc, prodTitle asc 
		</cfquery>
		<cfloop query="QProduct">
			<cfquery name="QDeals" datasource="#args.datasource#">
				SELECT *
				FROM tblDealItems,tblDeals
				WHERE dimProdID=#prodID#
				AND dimDealID=dealID
			</cfquery>
			<cfset cat={}>
			<cfset cat.ID=pcatID>
			<cfset cat.Title=pcatTitle>
			<cfset cat.items=[]>
			
			<cfif StructKeyExists(result.cats,pcatID)>
				<cfset c=StructFind(result.cats,pcatID)>
				<cfset prod={}>
				<cfset prod.ID=prodID>
				<cfset prod.Title=prodTitle>
				<cfset prod.UnitSize=prodUnitSize>
				<cfset prod.Price=val(prodOurPrice)>
				<cfset prod.PM=prodPriceMarked>
				<cfset prod.Deals=[]>
				<cfloop query="QDeals">
					<cfset d={}>
					<cfset d.Title=QDeals.dealTitle>
					<cfset d.Type=QDeals.dealType>
					<cfset d.Qty=QDeals.dealQty>
					<cfset d.Price=QDeals.dealAmount>
					<cfset ArrayAppend(prod.Deals,d)>
				</cfloop>
				<cfset ArrayAppend(c.items,prod)>
			<cfelse>
				<cfset prod={}>
				<cfset prod.ID=prodID>
				<cfset prod.Title=prodTitle>
				<cfset prod.UnitSize=prodUnitSize>
				<cfset prod.Price=val(prodOurPrice)>
				<cfset prod.PM=prodPriceMarked>
				<cfset prod.Deals=[]>
				<cfloop query="QDeals">
					<cfset d={}>
					<cfset d.Title=QDeals.dealTitle>
					<cfset d.Type=QDeals.dealType>
					<cfset d.Qty=QDeals.dealQty>
					<cfset d.Price=QDeals.dealAmount>
					<cfset ArrayAppend(prod.Deals,d)>
				</cfloop>
				<cfset ArrayAppend(cat.items,prod)>
				<cfset StructInsert(result.cats,pcatID,cat)>
			</cfif>
		</cfloop>
		
		<cfset result.ordered=StructSort(result.cats,"textnocase","asc","title")>

		<cfreturn result>
	</cffunction>

	<cffunction name="SaveTitle" access="remote" returntype="struct">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="title" type="string" required="yes">
		<cfargument name="datasource" type="string" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">

		<cfquery name="QProduct" datasource="#datasource#">
			UPDATE tblProducts
			SET	prodTitle='#title#'
			WHERE prodID=#val(ID)#
		</cfquery>

		<cfreturn result>
	</cffunction>

	<cffunction name="SavePrice" access="remote" returntype="struct">
		<cfargument name="id" type="numeric" required="yes">
		<cfargument name="price" type="numeric" required="yes">
		<cfargument name="datasource" type="string" required="yes">
		<cfset var result={}>
		<cfset var QProduct="">

		<cfquery name="QProduct" datasource="#datasource#">
			UPDATE tblProducts
			SET	prodOurPrice=#val(price)#
			WHERE prodID=#val(ID)#
		</cfquery>

		<cfreturn result>
	</cffunction>

</cfcomponent>




