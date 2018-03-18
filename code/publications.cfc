<cfcomponent displayname="publications" extends="core">

	<cffunction name="PubMovementReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.pubs={}>
		<cfset loc.result.QPubStock=[]>
		<cfset loc.months="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec">
		<cftry>
			<cfquery name="loc.QPubStockReceived" datasource="#args.datasource#" result="loc.result.QPubStockReceivedResult">
				SELECT pubID,psDate,psIssue,psTradePrice
				FROM tblPubStock INNER JOIN tblPublication ON psPubID=pubID
				WHERE psType='received'
				AND psDate >= '#LSDateFormat(args.form.from,"yyyy-mm-dd")#'
				AND psDate <= '#LSDateFormat(args.form.to,"yyyy-mm-dd")#'
				AND psOrderID=#val(args.form.customer)#
				<cfif StructKeyExists(args.form,"pub") AND args.form.pub gt 0>AND psPubID IN (#args.form.pub#)</cfif>
				ORDER by pubTitle asc, psDate, psIssue desc, psDate asc				
			</cfquery>
			<cfset loc.result.QPubStockReceived=loc.QPubStockReceived>
			<cfloop query="loc.QPubStockReceived">
				<cfset loc.itemDate=psDate>
				<cfset loc.itemIssue=psIssue>
				<cfset loc.itempubID=pubID>
				<cfset loc.psTradePrice=psTradePrice>
				<cfquery name="loc.QPubStock" datasource="#args.datasource#">
					SELECT psID,psURN,psClaimRef,psSupID,psType,psStatus,psDate,psIssue,psArrivalDay,psQty,psRetail,psPWRetail,psTradePrice,psDiscount,psDiscountType,psVatRate,psVat,
						pubID,pubTitle
					FROM tblPubStock INNER JOIN tblPublication ON psPubID=pubID
					WHERE pubID=#loc.itempubID#
					AND psDate>='#loc.itemDate#'
					AND psIssue='#loc.itemIssue#'
				</cfquery>
				<cfloop query="loc.QPubStock">
					<cfif ReFind("[a-zA-Z]",psIssue,1,false)>
						<cfset loc.monthNo = ListFindNoCase(loc.months,Right(psIssue,3),",")>
						<cfset loc.key="#pubID#-#loc.monthNo#-#Left(psIssue,2)#">
					<cfelse>
						<cfset loc.key="#pubID#-#NumberFormat(psIssue,'00000')#">
					</cfif>
					
					<cfif NOT StructKeyExists(loc.result.pubs,loc.key)>
						<cfset loc.rec={}>
						<cfset loc.rec.count=0>
						<cfset loc.rec.pubTitle=pubTitle>
						<cfset loc.rec.psIssue=psIssue>
						<cfset loc.rec.psDate=LSDateFormat(psDate,'ddd dd-mmm-yyyy')>
						<cfset loc.rec.psDiscountType=psDiscountType>
						<cfset loc.rec.psVatRate=psVatRate>
						<cfset loc.rec.psRetail=DecimalFormat(psRetail+psPWRetail)>
						<cfset loc.rec.unitTrade = loc.psTradePrice>
						<cfset loc.rec.psDiscount=psDiscount>
						<cfset loc.rec.psQty=psQty>
						<cfset loc.rec.valueRetail=psQty*psRetail>
						<cfif psDiscountType eq "pc">
							<cfset loc.rec.discount=loc.rec.valueRetail*(psDiscount/100)>
						<cfelse>
							<cfset loc.rec.discount=psDiscount*psQty>
						</cfif>
						<cfset loc.rec.valueTrade=loc.rec.valueRetail-psDiscount>
						<cfset loc.rec.received=0>
						<cfset loc.rec.returned=0>
						<cfset loc.rec.credited=0>
						<cfset loc.rec.claim=0>
						<cfset StructInsert(loc.result.pubs,loc.key,loc.rec)>
					<cfelse>
						<cfset loc.rec=StructFind(loc.result.pubs,loc.key)>
					</cfif>
					<cfswitch expression="#psType#">
						<cfcase value="received">
							<cfset loc.rec.received += psQty>
						</cfcase>
						<cfcase value="returned">
							<cfset loc.rec.returned += psQty>
						</cfcase>
						<cfcase value="credited">
							<cfset loc.rec.credited += psQty>
						</cfcase>
						<cfcase value="claim">
							<cfset loc.rec.claim += psQty>
						</cfcase>
					</cfswitch>
					<cfset loc.rec.sold = loc.rec.received - loc.rec.returned - loc.rec.claim>
					<cfset loc.rec.missing = loc.rec.returned + loc.rec.claim - loc.rec.credited>
					<cfset loc.rec.count++>
					<cfset StructUpdate(loc.result.pubs,loc.key,loc.rec)>
				</cfloop>
				<cfset ArrayAppend(loc.result.QPubStock,loc.QPubStock)>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

<!---PSACTION,PSARRIVALDAY,PSCLAIMREF,PSDATE,PSDISCOUNT,PSDISCOUNTTYPE,PSID,PSISSUE,PSORDERID,PSPUBID,PSPWRETAIL,PSPWVATRATE,PSQTY,PSRETAIL,PSSTATUS,PSSUPID,PSTRADEPRICE,PSTYPE,PSURN,PSVAT,PSVATRATE,PUBACTIVE,PUBARRIVAL,PUBBARCODE,PUBCATEGORY,PUBCATID,PUBDISCOUNT,PUBDISCTYPE,PUBEPOS,PUBFRI,PUBGROUP,PUBID,PUBMON,PUBNEXTISSUE,PUBPRICE,PUBPRICE1,PUBPRICE2,PUBPRICE3,PUBPRICE4,PUBPRICE5,PUBPRICE6,PUBPRICE7,PUBPRICE8,PUBPWPRICE,PUBPWVAT,PUBREF,PUBROUNDTITLE,PUBSALETYPE,PUBSAT,PUBSHORTTITLE,PUBSOR,PUBSUN,PUBTHU,PUBTITLE,PUBTRADEPRICE,PUBTUE,PUBTYPE,PUBTYPEID,PUBVAT,PUBWED,
 --->
	<cffunction name="ArrayOfStructSort" returntype="array" access="public" output="no">
	  <cfargument name="base" type="array" required="yes" />
	  <cfargument name="sortType" type="string" required="no" default="text" />
	  <cfargument name="sortOrder" type="string" required="no" default="ASC" />
	  <cfargument name="pathToSubElement" type="string" required="no" default="" />
	
	  <cfset var tmpStruct = StructNew()>
	  <cfset var returnVal = ArrayNew(1)>
	  <cfset var i = 0>
	  <cfset var keys = "">
	
	  <cfloop from="1" to="#ArrayLen(base)#" index="i">
		<cfset tmpStruct[i] = base[i]>
	  </cfloop>
	
	  <cfset keys = StructSort(tmpStruct, sortType, sortOrder, pathToSubElement)>
	
	  <cfloop from="1" to="#ArrayLen(keys)#" index="i">
		<cfset returnVal[i] = tmpStruct[keys[i]]>
	  </cfloop>
	
	  <cfreturn returnVal>
	</cffunction>

	<cffunction name="BuildReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=[]>
		<cfset var QPubStock="">
		<cfset var QReturned="">
		<cfset var QCredited="">
		<cfset var QReceived="">
		<cfset var item={}>
		<cftry>
		<cfquery name="QPubStock" datasource="#args.datasource#">
			SELECT tblPublication.pubTitle, tblPubStock.*
			FROM tblPubStock
			INNER JOIN tblPublication ON psPubID=pubID
			WHERE psDate >= '#LSDateFormat(args.form.from,"yyyy-mm-dd")#'
			AND psDate <= '#LSDateFormat(args.form.to,"yyyy-mm-dd")#'
			AND psOrderID=#val(args.form.customer)#
			AND psPubID=pubID
			<cfif len(args.form.issue)>AND psIssue = '#args.form.issue#'</cfif>
			<cfif StructKeyExists(args.form,"pub") AND args.form.pub gt 0>AND psPubID IN (#args.form.pub#)</cfif>
			ORDER by pubTitle asc, psIssue asc, psDate asc, psType , psID ASC
		</cfquery>

		<cfloop query="QPubStock">
			<cfset item={}>
			<cfset item.ID=psID>
			<cfset item.URN=psURN>
			<cfset item.Ref=psClaimRef>
			<cfset item.PubID=psPubID>
			<cfset item.SupID=psSupID>
			<cfset item.Type=psType>
			<cfset item.subType=psSubType>
			<cfset item.Status=psStatus>
			<cfset item.Title=pubTitle>
			<cfset item.Date=psDate>
			<cfset item.Issue=psIssue>
			<cfset item.psAction=psAction>
			<cfset item.ArrivalDay=psArrivalDay>
			<cfset item.Qty=psQty>
			<cfset item.Retail=psRetail>
			<cfset item.Discount=psDiscount>
			<cfset item.DiscountType=psDiscountType>
			<cfset item.VatRate=psVatRate>
			<cfset item.Vat=StructFind(application.site.VAT,psVat)>
			<cfset item.LineTotal=item.Retail*item.Qty/(1+item.Vat)>
			<cfif item.DiscountType eq "pc">
				<cfset item.LineDisc=item.LineTotal*(item.Discount/100)>
				<cfset item.LineTotal=item.LineTotal-item.LineDisc>
			<cfelse>
				<cfset item.LineDisc=item.Discount*item.Qty>
				<cfset item.LineTotal=item.LineTotal-item.LineDisc>
			</cfif>
			
			<cfif item.Status is "closed">
				<cfset item.class="green">
				<cfset item.diff=0>
			<cfelse>
				<cfif psType is "credited">
					<cfquery name="QReturned" datasource="#args.datasource#">
						SELECT psQty
						FROM tblPubStock
						WHERE psDate >= '#LSDateFormat(args.form.from,"yyyy-mm-dd")#'
						AND psDate <= '#LSDateFormat(args.form.to,"yyyy-mm-dd")#'
						AND psOrderID=#val(args.form.customer)#
						AND psPubID=#psPubID#
						AND psType='returned'
						AND psIssue='#psIssue#'
						AND psStatus='open'
						LIMIT 1;
					</cfquery>
					<cfset item.diff=val(psQty)-val(QReturned.psQty)>
					<cfif item.diff gt 0>
						<cfset item.diff="+"&item.diff>
					</cfif>
					<cfif QReturned.psQty gt psQty>
						<cfset item.class="red">
					<cfelseif  QReturned.psQty eq psQty>
						<cfset item.class="green">
					<cfelseif  QReturned.psQty lt psQty>
						<cfset item.class="star">
					</cfif>
				<cfelse>
					<cfset item.diff=0>
					<cfset item.class="">
				</cfif>
			</cfif>
			
			<cfif StructKeyExists(args.form,"type") AND len(args.form.type)>
				<cfif args.form.type eq "movement">
					<cfset ArrayAppend(result.list,item)>
				<cfelseif args.form.type is "missing credit" AND psType is "returned" OR psType is "claim" AND psStatus is "open"><!------>
					<cfquery name="QCredited" datasource="#args.datasource#">
						SELECT SUM(psQty) AS TotalQty
						FROM tblPubStock
						WHERE psPubID=#psPubID#
						AND psIssue='#psIssue#'
						AND psType='credited'
						AND psOrderID=#val(args.form.customer)#
					</cfquery>
					<cfquery name="QReceived" datasource="#args.datasource#">
						SELECT SUM(psQty) AS TotalQty
						FROM tblPubStock
						WHERE psPubID=#psPubID#
						AND psIssue='#psIssue#'
						AND psType='received'
						AND psOrderID=#val(args.form.customer)#
					</cfquery>
					<cfif QCredited.TotalQty lt psQty>
						<cfset item.revQty=QReceived.TotalQty>
						<cfset item.crdQty=QCredited.TotalQty>
						<cfset item.class="red">
						<cfset item.diff=val(QCredited.TotalQty)-val(psQty)>
						<cfset item.diffInt=ReReplace(item.diff,"-","","all")>
						<cfset item.LineTotal=item.Retail*item.diffInt/(1+item.Vat)>
						<cfif item.DiscountType eq "pc">
							<cfset item.LineDisc=item.LineTotal*(item.Discount/100)>
							<cfset item.LineTotal=item.LineTotal-item.LineDisc>
						<cfelse>
							<cfset item.LineDisc=item.Discount*item.diffInt>
							<cfset item.LineTotal=item.LineTotal-item.LineDisc>
						</cfif>
						<cfset ArrayAppend(result.list,item)>
					</cfif>
				<cfelseif args.form.type eq "claim" AND psType eq "claim">
					<cfset ArrayAppend(result.list,item)>
				</cfif>
			</cfif>
		</cfloop>
		<cfset result.list = ArrayOfStructSort(result.list,"numeric","asc","ID")>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="BuildReport" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateReportStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"selectitem")>
				<cfloop list="#args.form.selectitem#" delimiters="," index="i">
					<cfquery name="QUpdate" datasource="#args.datasource#">
						UPDATE tblPubStock
						SET psStatus='closed'
						WHERE psID=#i#
					</cfquery>
				</cfloop>
				<cfset result.msg="Done">
			<cfelse>
				<cfset result.error="Selected items not found">
			</cfif>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="GetBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">
		<cfset result.error=false>
		<cfset result.msg="">
		<cfset loc = {}>
		<cftry>
			<cfquery name="QBarcode" datasource="#args.datasource#">
				SELECT *
				FROM tblBarcodes
				WHERE barCode='#args.form.barcode#'
				LIMIT 1;
			</cfquery>
			<cfif QBarcode.recordcount is 1>
				<cfset parm={}>
				<cfset parm.datasource=args.datasource>
				<cfset parm.date=LSDateFormat(Now(),"yyyy-mm-dd")>
				<cfset parm.pubID=QBarcode.barProdID>
				<cfset loc.get=GetPub(parm)>
				<cfset result.id=loc.get.id>
				<cfset result.msg=loc.get.msg>
			<cfelse>
				<cfset result.msg="Barcode not found">
				<cfset result.error=true>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>		
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPub" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		<cfset var QPubStock="">

		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubID=#val(args.pubID)#
		</cfquery>
		<cfif QPub.recordcount eq 1>
			<cfquery name="QPubStock" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock
				WHERE psPubID=#QPub.pubID#
				AND psDate <= '#LSDateFormat(args.date,"yyyy-mm-dd")#'
				ORDER BY psDate desc
				LIMIT 3;
			</cfquery>
			<cfset result.ID=QPub.pubID>
			<cfset result.msg=QPub.pubTitle>
		<cfelse>
			<cfset result.ID=0>
			<cfset result.msg="Publication not found (#args.pubID#)">
		</cfif>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddPubBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">
		<cfset var QInsert="">
		
		<cfquery name="QBarcode" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barCode='#args.form.barcode#'
			LIMIT 1;
		</cfquery>
		<cfif QBarcode.recordcount is 0>
			<cfquery name="QInsert" datasource="#args.datasource#">
				INSERT INTO tblBarcodes (
					barCode,
					barType,
					barProdID
				) VALUES (
					'#args.form.barcode#',
					'publication',
					#args.form.TitleID#
				)
			</cfquery>
			<cfset result.status="success">
			<cfset result.msg="Added">
		<cfelse>
			<cfset result.status="error">
			<cfset result.msg="Barcode already exists">
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="CheckPublication" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPublication="">
		
		<cfquery name="QPublication" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubID=#val(args.form.oiPubID)#
			LIMIT 1;
		</cfquery>
		<cfset result.ID=QPublication.pubID>
		<cfset result.Title=QPublication.pubTitle>
		<cfset result.Cat=QPublication.pubCategory>
		<cfset result.Arrival=QPublication.pubArrival>
		<cfset result.sumPrice=QPublication.pubPrice1+QPublication.pubPrice2+QPublication.pubPrice3+QPublication.pubPrice4+QPublication.pubPrice5+QPublication.pubPrice6+QPublication.pubPrice7>
		<cfif result.sumPrice is 0>
			<cfset result.Qty=QPublication.pubPrice>
		<cfelse>
			<cfset result.Mon=QPublication.pubPrice1>
			<cfset result.Tue=QPublication.pubPrice2>
			<cfset result.Wed=QPublication.pubPrice3>
			<cfset result.Thu=QPublication.pubPrice4>
			<cfset result.Fri=QPublication.pubPrice5>
			<cfset result.Sat=QPublication.pubPrice6>
			<cfset result.Sun=QPublication.pubPrice7>
		</cfif>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublication" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		
		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubID=#val(args.pubID)#
			LIMIT 1;
		</cfquery>
		<cfset result.ID=QPub.pubID>
		<cfset result.Title=QPub.pubTitle>
		<cfset result.ShortTitle=QPub.pubShortTitle>
		<cfset result.RoundTitle=QPub.pubRoundTitle>
		<cfset result.Group=QPub.pubGroup>
		<cfset result.Type=QPub.pubType>
		<cfset result.Category=QPub.pubCategory>
		<cfset result.Wholesaler=QPub.pubWholesaler>
		<cfset result.Arrival=QPub.pubArrival>
		<cfset result.SaleType=QPub.pubSaleType>
		<cfset result.Price=QPub.pubPrice>
		<cfset result.Discount=QPub.pubDiscount>
		<cfset result.DiscountType=QPub.pubDiscType>
		<!---<cfset result.Vat=QPub.pubVat>--->
		<cfset result.pubVATCode=QPub.pubVATCode>
		<cfset result.PWPrice=QPub.pubPWPrice>
		<cfset result.PWVat=QPub.pubPWVat>
		<cfset result.Mon=QPub.pubMon>
		<cfset result.Tue=QPub.pubTue>
		<cfset result.Wed=QPub.pubWed>
		<cfset result.Thu=QPub.pubThu>
		<cfset result.Fri=QPub.pubFri>
		<cfset result.Sat=QPub.pubSat>
		<cfset result.Sun=QPub.pubSun>
		<cfset result.Active=QPub.pubActive>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdatePublication" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		<cfset var mon=0>
		<cfset var tue=0>
		<cfset var wed=0>
		<cfset var thu=0>
		<cfset var fri=0>
		<cfset var sat=0>
		<cfset var sun=0>
		
		<cftry>
			<cfif StructKeyExists(args.form,"pubMon")><cfset mon=1></cfif>
			<cfif StructKeyExists(args.form,"pubTue")><cfset tue=1></cfif>
			<cfif StructKeyExists(args.form,"pubWed")><cfset wed=1></cfif>
			<cfif StructKeyExists(args.form,"pubThu")><cfset thu=1></cfif>
			<cfif StructKeyExists(args.form,"pubFri")><cfset fri=1></cfif>
			<cfif StructKeyExists(args.form,"pubSat")><cfset sat=1></cfif>
			<cfif StructKeyExists(args.form,"pubSun")><cfset sun=1></cfif>
			
			<cfquery name="QPub" datasource="#args.datasource#">
				UPDATE tblPublication
				SET pubTitle='#args.form.pubTitle#',
					pubShortTitle='#args.form.pubShortTitle#',
					pubRoundTitle='#args.form.pubRoundTitle#',
					pubGroup='#args.form.pubGroup#',
					pubType='#args.form.pubType#',
					pubWholesaler='#args.form.pubWholesaler#',
					<cfif StructKeyExists(args.form,"pubArrival")>pubArrival=#args.form.pubArrival#,</cfif>
					pubSaleType='#args.form.pubSaleType#',
					pubPrice=#args.form.pubPrice#,
					pubDiscount=#args.form.pubDiscount#,
					pubDiscType='#args.form.pubDiscType#',
					<!---pubVat=#args.form.pubVat#,--->
					pubVATCode=#args.form.pubVATCode#,
					pubPWPrice=#args.form.pubPWPrice#,
					pubPWVat=#args.form.pubPWVat#,
					pubMon=#mon#,
					pubTue=#tue#,
					pubWed=#wed#,
					pubThu=#thu#,
					pubFri=#fri#,
					pubSat=#sat#,
					pubSun=#sun#,
					pubActive=#args.form.pubActive#
				WHERE pubID=#val(args.form.pubID)#
			</cfquery>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPubTypes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QPub="">
		
		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT pubType
			FROM tblPublication
			WHERE 1
			GROUP BY pubType
		</cfquery>
		<cfloop query="QPub">
			<cfset item={}>
			<cfset item.Title=pubType>
			<cfset ArrayAppend(result,item)>
		</cfloop>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPubBarcodes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QBarcode="">

		<cfquery name="QBarcode" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barProdID=#val(args.pubID)#
			AND barType='#args.type#'
		</cfquery>
		<cfloop query="QBarcode">
			<cfset item={}>
			<cfset item.ID=barID>
			<cfset item.code=barCode>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">
		
		<cfif StructKeyExists(args.form,"selectcode")>
			<cfquery name="QBarcode" datasource="#args.datasource#">
				DELETE FROM tblBarcodes
				WHERE barID IN (#args.form.selectcode#)
			</cfquery>
		</cfif>

		<cfreturn result>
	</cffunction>

</cfcomponent>









