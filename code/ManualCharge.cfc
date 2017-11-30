<cfcomponent displayname="manualcharge" extends="core">

	<cffunction name="LoadManualCharges" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelItems="">
		
		<cfset result.list=[]>
		<cfset result.pubTotal=0>
		<cfset result.delTotal=0>
		<cfset result.qtyTotal=0>
		
		<cftry>
			<cfquery name="QDelItems" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems,tblPublication
				WHERE diDate='#LSDateFormat(args.form.date,"yyyy-mm-dd")#'
				AND diOrderID=#args.form.orderID#
				AND diPubID=pubID
				ORDER BY pubGroup, pubTitle
			</cfquery>
			<cfset item.lineTotal=0>
			<cfloop query="QDelItems">
				<cfset item={}>
				<cfset item.ID=diID>
				<cfset item.BatchID=diBatchID>
				<cfset item.OrderID=diOrderID>
				<cfset item.PubID=pubTitle>
				<cfset item.Group=pubGroup>
				<cfset item.Qty=diQty>
				<cfset item.Price=diPrice>
				<cfset item.Charge=diCharge>
				<cfset item.Test=diTest>
	
				<cfset item.lineTotal=item.Price*item.Qty>
				<cfset result.pubTotal=result.pubTotal+item.lineTotal>
				<cfset result.delTotal=result.delTotal+item.Charge>
				<cfset result.qtyTotal=result.qtyTotal+item.Qty>
				
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="LoadCustomOrders" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var QOrder="">
		
		<cfquery name="QOrder" datasource="#args.datasource#">
			SELECT ordID,ordHouseName,ordHouseNumber, cltID,cltName,cltCompanyName
			FROM tblOrder,tblClients
			WHERE ordType='Custom'
			AND ordClientID=cltID
			<cfif StructKeyExists(args,"AllowReturns")>AND ordAllowReturns=1</cfif>
			AND ordActive
			ORDER BY cltCompanyName, cltName
		</cfquery>
		<cfloop query="QOrder">
			<cfset item={}>
			<cfset item.ID=ordID>
			<cfset item.ClientID=cltID>
			<cfif NOT len(cltName)>
				<cfif len(ordHouseName) AND len(ordHouseNumber)>
					<cfset item.ClientName="#ordHouseName# #ordHouseNumber#">
				<cfelse>
					<cfset item.ClientName="#ordHouseName##ordHouseNumber#">
				</cfif>
			<cfelse>
				<cfif len(cltName) AND len(cltCompanyName)>
					<cfset item.ClientName="#cltCompanyName# - #cltName# ">
				<cfelse>
					<cfset item.ClientName="#cltCompanyName##cltName#">
				</cfif>
			</cfif>
			<cfset ArrayAppend(result,item)>
		</cfloop>

		<cfreturn result>
	</cffunction>

	<cffunction name="LoadCustomOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QOrder="">
		<cfset var QRound="">
		<cfset var ChargeDay=DateFormat(Now(),"DDD")>
		
		<cfquery name="QOrder" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder,tblDelCharges,tblClients
			WHERE ordID=#args.form.orderID#
			AND ordDeliveryCode=delCode
			AND ordClientID=cltID
		</cfquery>
		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT riRoundID
			FROM tblRoundItems
			WHERE riOrderID=#args.form.orderID#
			AND riDay='#ChargeDay#'
		</cfquery>
		<cfset ChargeDay=DateFormat(args.form.date,"DDD")>
		<cfset result.cltID=val(QOrder.cltID)>
		<cfset result.roundID=val(QRound.riRoundID)>
		<cfif QOrder.delPrice2 neq 0>
			<cfif ChargeDay is "Sat">
				<cfset result.charge=QOrder.delPrice2>
			<cfelseif ChargeDay is "Sun">
				<cfset result.charge=QOrder.delPrice3>
			<cfelse>
				<cfset result.charge=QOrder.delPrice1>
			</cfif>
		<cfelseif QOrder.delType is "Per Day">
			<cfset result.charge=QOrder.delPrice1>
		<cfelseif QOrder.delType is "Per Week">
			<cfset result.charge=QOrder.delPrice1/7>
		<cfelse>
			<cfset result.charge=QOrder.delPrice1>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPub" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		
		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT pubPrice
			FROM tblPublication
			WHERE pubID=#args.form.PubID#
		</cfquery>
		<cfset result.price=QPub.pubPrice>

		<cfreturn result>
	</cffunction>

	<cffunction name="AddCharge" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelPub="">
		<cfset var QDelCharge="">
		<cfset var QAddDelItem="">
		<cfset var QUpdateDelItem="">
		<cfset var QBatch="">
		<cfset var QCreateBatch="">
		<cfset var QNewBatch="">
		<cfset var QNewItem="">
		<cfset var QBatchTotals="">
		<cfset var QUpdateBatch="">
		<cfset var QCheckIssue="">
		<cfset var QBarcode="">
		<cfset var QPub="">
		<cfset var qty=0>
		<cfset var qtySum=0>
		<cfset var BatchID=0>
		<cfset var delCharge=0>
		<cfset var pubID=0>
		<cfset var price=0>
		<cfset var loc = {}>

		<cftry>
			<cfquery name="loc.QBatch" datasource="#args.datasource#">
				SELECT *
				FROM tblDelBatch
				WHERE dbRef='#LSDateFormat(args.form.date,"yyyy-mm-dd")#'
				AND dbRound=#args.form.roundID#
				LIMIT 1;
			</cfquery>
			<cfif loc.QBatch.recordcount eq 0>
				<cfquery name="loc.QBatch" datasource="#args.datasource#" result="loc.QResult">
					INSERT INTO tblDelBatch (
					dbRef,dbRound) VALUES ('#args.form.date#',#args.form.roundID#)
				</cfquery>
				<cfset loc.batchID=loc.QResult.generatedKey>
			<cfelse><cfset loc.batchID=loc.QBatch.dbID></cfif>

			<cfquery name="loc.QPub" datasource="#args.datasource#">
				SELECT pubTitle,pubPrice,pubTradePrice
				FROM tblPublication
				WHERE pubID=#val(args.form.pubID)#
			</cfquery>
			<cfquery name="loc.QDelPub" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems
				WHERE diDate='#LSDateFormat(args.form.date,"yyyy-mm-dd")#'
				AND diOrderID=#args.form.orderID#
				AND diPubID=#val(args.form.pubID)#
				AND diType='debit'
				LIMIT 1;
			</cfquery>
			<cfquery name="loc.QDelCharge" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems
				WHERE diDate='#LSDateFormat(args.form.date,"yyyy-mm-dd")#'
				AND diOrderID=#args.form.orderID#
				AND diType='debit'
				AND diCharge>0
				LIMIT 1;
			</cfquery>
			
			<cfset price=loc.QPub.pubPrice>
			<cfif loc.QDelCharge.recordcount is 0>
				<cfset delCharge=args.form.delCharge>
			<cfelse>
				<cfset delCharge=0.00>
			</cfif>
			
			<cfif loc.QDelPub.recordcount is 0>
				<cfquery name="loc.QCheckIssue" datasource="#args.datasource#">
					SELECT *
					FROM tblPubStock
					WHERE psPubID=#args.form.pubID#
					AND psType='received'
					AND psDate='#LSDateFormat(args.form.date,"YYYY-MM-DD")#'
					LIMIT 1;
				</cfquery>
				<cfquery name="loc.QAddDelItem" datasource="#args.datasource#">
					INSERT INTO tblDelItems (
						diClientID,
						diOrderID,
						diBatchID,
						diPubID,
						diIssue,
						diType,
						diDatestamp,
						diDate,
						diQty,
						diPrice,
						diPriceTrade,
						diCharge
					) VALUES (
						#args.form.cltID#,
						#args.form.orderID#,
						#loc.batchID#,
						#val(args.form.pubID)#,
						<cfif loc.QCheckIssue.recordcount is 1>'#loc.QCheckIssue.psIssue#',<cfelse>'',</cfif>
						'debit',
						'#LSDateFormat(now(),"YYYY-MM-DD")#',
						'#LSDateFormat(args.form.date,"YYYY-MM-DD")#',
						#val(args.form.qty)#,
						#DecimalFormat(price)#,
						#val(loc.QPub.pubTradePrice)#,
						#DecimalFormat(delCharge)#
					)
				</cfquery>
			<cfelse>
				<cfset qtySum=loc.QDelPub.diQty+args.form.qty>
				<cfquery name="loc.QUpdateDelItem" datasource="#args.datasource#">
					UPDATE tblDelItems
					SET diQty=#qtySum#
					WHERE diID=#loc.QDelPub.diID#
				</cfquery>
			</cfif>
			<cfquery name="loc.QBatchTotals" datasource="#args.datasource#">
				SELECT *
				FROM tblDelBatch
				WHERE dbID=#loc.batchID#
			</cfquery>

			<cfquery name="loc.QUpdateBatch" datasource="#args.datasource#">
				UPDATE tblDelBatch
				SET dbPubTotal=#loc.QBatchTotals.dbPubTotal+(price*args.form.qty)#,
					dbDelTotal=#loc.QBatchTotals.dbDelTotal+delCharge#
				WHERE dbID=#loc.batchID#
			</cfquery>
			<cfset result.msg="#loc.QPub.pubTitle# Added">
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteManualCharges" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelPub="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"line")>
				<cfloop list="#args.form.line#" delimiters="," index="i">
					<cfquery name="QDelPub" datasource="#args.datasource#">
						DELETE FROM tblDelItems
						WHERE diID=#i#
					</cfquery>
				</cfloop>
				<cfset result.msg="Items deleted">
			<cfelse>
				<cfset result.msg="Select items to delete">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

</cfcomponent>