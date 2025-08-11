<cfcomponent displayname="purchase reports" extends="accounts">

	<cfset this.nomAccounts={}>
	<cfset this.nomBalanceAccounts={}>
	
	<cffunction name="LoadSuppliers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QSuppliers="">
		<cfset var rec={}>
		
		<cfset result.list=[]>
		<cfquery name="QSuppliers" datasource="#args.datasource#">
			SELECT accID,accCode,accName
			FROM tblAccount
			WHERE accType IN ('purch','sales')
			ORDER BY accCode
		</cfquery>
		<cfloop query="QSuppliers">
			<cfset rec={}>
			<cfset rec.accID=accID>
			<cfset rec.accCode=accCode>
			<cfset rec.accName=accName>
			<cfset ArrayAppend(result.list,rec)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="CODLoadCrossCheck" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.suppliers = {}>
		
		<cftry>
			<cfquery name="loc.QCODPayments" datasource="#args.datasource#">
				SELECT 	accID,accCode,accGroup,accPayType,accIndex,accName,accType,
						tblepos_items.*
				FROM tblepos_items
				INNER JOIN tblAccount ON eiSuppID = accID
				WHERE eiSuppID > 1
				<cfif len(args.form.srchDateFrom)>
					AND eiTimeStamp >= '#args.form.srchDateFrom#'
					AND eiTimeStamp <= '#args.form.srchDateTo#'
				</cfif>
				ORDER BY eiTimeStamp ASC
			</cfquery>
			<cfset loc.result.QCODPayments = loc.QCODPayments>
			<cfloop query="loc.QCODPayments">	<!--- loop supplier till payments --->
				<cfset loc.tillDate = LSDateFormat(eiTimeStamp,"yyyy-mm-dd")>
				<cfset loc.tillAmount = val(eiNet)>
				<cfset loc.class = "normal">
				<cfset loc.tran = {}>
				<cfset loc.tran.trnID = 0>
				<cfset loc.tran.trnRef = "">
				<cfset loc.tran.trnDate = "">
				<cfset loc.tran.trnAmnt1 = 0.00>
				<cfquery name="loc.QSuppPayment" datasource="#args.datasource#">	<!--- look for matching payment --->
					SELECT *
					FROM tblTrans
					WHERE trnAccountID = #eiSuppID#
					AND trnType = 'pay'
					AND trnDate = '#loc.tillDate#'
					AND ABS(trnAmnt1) = #loc.tillAmount#
					LIMIT 1;
				</cfquery>
				<cfif loc.QSuppPayment.recordcount eq 0>	<!--- found no match --->
					<cfquery name="loc.QSuppPayment" datasource="#args.datasource#">	<!--- widen the date search range --->
						SELECT *
						FROM tblTrans
						WHERE trnAccountID = #eiSuppID#
						AND trnType = 'pay'
						AND trnDate BETWEEN '#LSDateFormat(DateAdd("d",-5,loc.tillDate),"yyyy-mm-dd")#' 
							AND '#LSDateFormat(DateAdd("d",5,loc.tillDate),"yyyy-mm-dd")#'
					</cfquery>
					<cfif loc.QSuppPayment.recordcount gt 0>
						<cfloop query="loc.QSuppPayment">	<!--- loop the found records --->
							<cfset loc.class = "missing">	<!--- assume it wont be found --->
							<cfif ABS(trnAmnt1) eq loc.tillAmount>	<!--- found it --->
								<cfset loc.tran.trnID = loc.QSuppPayment.trnID>
								<cfset loc.tran.trnRef = loc.QSuppPayment.trnRef>
								<cfset loc.tran.trnDate = loc.QSuppPayment.trnDate>
								<cfset loc.tran.trnAmnt1 = loc.QSuppPayment.trnAmnt1>
								<cfset loc.class = "drifted">
								<cfbreak>
							</cfif>			
						</cfloop>
					<cfelse>	<!--- still nothing found --->
						<cfset loc.class = "missing">
					</cfif>
				<cfelse>	<!--- found it first time --->
					<cfset loc.tran.trnID = loc.QSuppPayment.trnID>
					<cfset loc.tran.trnRef = loc.QSuppPayment.trnRef>
					<cfset loc.tran.trnDate = loc.QSuppPayment.trnDate>
					<cfset loc.tran.trnAmnt1 = loc.QSuppPayment.trnAmnt1>
				</cfif>
				<cfif !StructKeyExists(loc.result.suppliers,accID)>
					<cfset StructInsert(loc.result.suppliers,accID,{"accID" = accID, "accName" = accName, trans = []})>
				</cfif>
				<cfset loc.supp = StructFind(loc.result.suppliers,accID)>
				<cfset ArrayAppend(loc.supp.trans,{
					"eiID" = eiID,
					"eiParent" = eiParent,
					"eiTimeStamp" = loc.tillDate,
					"trnType" = loc.QSuppPayment.trnType,
					"eiNet" = eiNet,
					"eiSuppID" = eiSuppID,
					"found" = loc.QSuppPayment.recordcount,
					"trnID" = val(loc.tran.trnID),
					"trnRef" = loc.tran.trnRef,
					"trnDate" = loc.tran.trnDate,
					"trnAmnt1" = loc.tran.trnAmnt1,
					"class" = loc.class
				})>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CODViewCrossCheck" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.errors = 0>
		<cftry>
			<cfoutput>
				<table class="tableList" border="1">
				<cfloop collection="#args.data.suppliers#" item="loc.key">
					<cfset loc.supp = StructFind(args.data.suppliers,loc.key)>
					<tr class="header">
						<th>#loc.key#</th>
						<th colspan="9">#loc.supp.accName#</th>
					</tr>
					<tr>
						<th>eiID</th>
						<th>EPOS Tran</th>
						<th>eiTimeStamp</th>
						<th>eiNet</th>
						<th></th>
						<th>trnID</th>
						<th>trnRef</th>
						<th>Tran Date</th>
						<th>Tran Amount</th>
						<th>found</th>
					</tr>
					<cfloop array="#loc.supp.trans#" index="loc.tran">
						<cfset loc.class = "">
						<cfset loc.errors += int(loc.tran.found eq 0)>
						<cfif loc.tran.found eq 0><cfset loc.class = "error"></cfif>
						<tr class="#loc.tran.class#">
							<td>#loc.tran.eiID#</td>
							<td align="right">#loc.tran.eiParent#</td>
							<td>#DateFormat(loc.tran.eiTimeStamp,"ddd dd-mmm-yyyy")#</td>
							<td align="right">#loc.tran.eiNet#</td>
							<td>&nbsp;</td>
							<td align="right">#loc.tran.trnID#</td>
							<td align="right">#loc.tran.trnRef#</td>
							<td align="right">#DateFormat(loc.tran.trnDate,"ddd dd-mmm-yyyy")#</td>
							<td align="right">#loc.tran.trnAmnt1#</td>
							<td align="center">#loc.tran.found#</td>
						</tr>
					</cfloop>
				</cfloop>
				<tr>
					<th colspan="10">#loc.errors# errors found.</th>
				</tr>
				</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CODPaymentAnalysis" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfset loc.span = DateDiff("d",args.form.srchDateFrom,args.form.srchDateTo) + 1>
			<cfquery name="loc.result.QTrans" datasource="#args.datasource#" result="loc.result.QTransResult">
				SELECT accID,accCode,accGroup,accPayType,accIndex,accName,accType,
						eiSuppID,eiTimeStamp,eiNet
				FROM tblepos_items
				INNER JOIN tblAccount ON eiSuppID = accID
				WHERE eiSuppID > 1
				<cfif len(args.form.srchDateFrom)>
					AND eiTimeStamp >= '#args.form.srchDateFrom#'
					AND eiTimeStamp <= '#args.form.srchDateTo#'
				</cfif>
				ORDER BY eiTimeStamp ASC
			</cfquery>
			<cfif loc.span lt 8>
				<!--- day summary --->
				<cfset loc.days = {}>
				<cfloop from="#args.form.srchDateFrom#" to="#args.form.srchDateTo#" index="loc.i">
					<cfset StructInsert(loc.days,DateFormat(loc.i,'yyyy-mm-dd'),0)>
				</cfloop>
				<cfloop query="loc.result.QTrans">
					<cfset loc.tranDate = DateFormat(eiTimestamp,'yyyy-mm-dd')>
					<cfif StructKeyExists(loc.days,loc.tranDate)>
						<cfset loc.currTotal = StructFind(loc.days,loc.tranDate)>
						<cfset StructUpdate(loc.days,loc.tranDate,loc.currTotal+eiNet)>
					<cfelse>
						<cfset StructInsert(loc.days,loc.tranDate,eiNet)>
					</cfif>
				</cfloop>
			<cfelseif loc.span lt 32>
				<!--- week summary --->
			<cfelse>
				<!--- month summary --->
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="CODPaymentAnalysis" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc>
	</cffunction>

	<cffunction name="CODPaymentsReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.skipZeros=StructKeyExists(args.form,"srchIgnoreZero")>
		<cfset loc.result.suppliers=[]>
		<cftry>
			<cfquery name="loc.QDistinctSuppliers" datasource="#args.datasource#">
				SELECT DISTINCT eiSuppID
				FROM tblepos_items
				WHERE eiSuppID > 1
			</cfquery>			
<!---
				SELECT accID,accCode,accGroup,accPayType,accIndex,accName,accType, tblepos_items . *
				FROM `tblepos_items`
				INNER JOIN tblaccount ON eiSuppID = accID
				WHERE `eiSuppID` >1
				<cfif len(StructFind(args.form,"srchDateFrom"))>AND eiTimeStamp >= "#LSDateFormat(args.form.srchDateFrom,'yyyy-mm-dd')#"</cfif>
				ORDER BY accName, eiTimeStamp
--->				
			<cfif loc.QDistinctSuppliers.recordcount GT 0>
				<cfloop query="loc.QDistinctSuppliers">
					<cfquery name="loc.QSuppliers" datasource="#args.datasource#">
						SELECT accID,accCode,accGroup,accPayType,accIndex,accName,accType
						FROM tblAccount
						WHERE accID = #val(eiSuppID)#
					</cfquery>
				
					<cfset loc.item={}>
					<cfset loc.item.ID=loc.QSuppliers.accID>
					<cfset loc.item.ref=loc.QSuppliers.accCode>
					<cfset loc.item.name=loc.QSuppliers.accName>
					<cfset loc.item.type=loc.QSuppliers.accType>
					<cfset loc.item.accPayType=loc.QSuppliers.accPayType>
					<cfset loc.item.balance0=0>
					<cfset loc.item.balance1=0>
					<cfset loc.item.balance2=0>
					<cfset loc.item.balance3=0>
					<cfset loc.item.balance4=0>
					<cfset loc.item.balance5=0>
					<cfset loc.item.balance6=0>
					<cfset loc.item.balance7=0>
					<cfset loc.item.balance8=0>
					<cfset loc.item.balance9=0>
					<cfset loc.item.balance10=0>
					<cfset loc.item.balance11=0>
					<cfset loc.item.balance12=0>
					<cfquery name="loc.QTrans" datasource="#args.datasource#" result="loc.result.QTransResult">
						SELECT eiSuppID,eiTimeStamp,eiNet
						FROM tblepos_items
						WHERE eiSuppID=#val(loc.item.ID)#
						<cfif len(args.form.srchDateFrom)>
							AND eiTimeStamp >= '#args.form.srchDateFrom#'
							AND eiTimeStamp <= '#args.form.srchDateTo#'
						</cfif>
						ORDER BY eiTimeStamp ASC
					</cfquery>
					<cfset loc.result.QTrans=loc.QTrans>
					<cfset loc.item.balance0=0>
					<cfloop query="loc.QTrans">
						<cfset loc.item.balance0 = precisionEvaluate(loc.item.balance0+eiNet)>
						<cfswitch expression="#Month(eiTimeStamp)#">
							<cfcase value="1"><cfset loc.item.balance1=precisionEvaluate(loc.item.balance1+eiNet)></cfcase>
							<cfcase value="2"><cfset loc.item.balance2=precisionEvaluate(loc.item.balance2+eiNet)></cfcase>
							<cfcase value="3"><cfset loc.item.balance3=precisionEvaluate(loc.item.balance3+eiNet)></cfcase>
							<cfcase value="4"><cfset loc.item.balance4=precisionEvaluate(loc.item.balance4+eiNet)></cfcase>
							<cfcase value="5"><cfset loc.item.balance5=precisionEvaluate(loc.item.balance5+eiNet)></cfcase>
							<cfcase value="6"><cfset loc.item.balance6=precisionEvaluate(loc.item.balance6+eiNet)></cfcase>
							<cfcase value="7"><cfset loc.item.balance7=precisionEvaluate(loc.item.balance7+eiNet)></cfcase>
							<cfcase value="8"><cfset loc.item.balance8=precisionEvaluate(loc.item.balance8+eiNet)></cfcase>
							<cfcase value="9"><cfset loc.item.balance9=precisionEvaluate(loc.item.balance9+eiNet)></cfcase>
							<cfcase value="10"><cfset loc.item.balance10=precisionEvaluate(loc.item.balance10+eiNet)></cfcase>
							<cfcase value="11"><cfset loc.item.balance11=precisionEvaluate(loc.item.balance11+eiNet)></cfcase>
							<cfcase value="12"><cfset loc.item.balance12=precisionEvaluate(loc.item.balance12+eiNet)></cfcase>
						</cfswitch>
					</cfloop>
					<cfif loc.item.balance0 neq 0 OR NOT loc.skipZeros>
						<cfset ArrayAppend(loc.result.suppliers,loc.item)>
					</cfif>
				</cfloop>
				<cfset ArraySort(loc.result.weekArray,"numeric")>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="CODPaymentsList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.weekends = {}>
		<cfif !IsDate(args.form.srchDateTo)>
			<cfset args.form.srchDateTo = Now()>
		</cfif>
		<cfset args.form.srchDateTo = DateAdd("d",1,args.form.srchDateTo)>	<!--- to midnight next day --->
		<cfquery name="loc.result.QTrans" datasource="#args.datasource#" result="loc.result.QTransResult">
			SELECT accID,accName, eiTimeStamp,eiNet
			FROM tblepos_items
			INNER JOIN tblAccount ON accID = eiSuppID
			WHERE eiSuppID > 1
			AND eiSuppID NOT IN (0)	<!--- none selected --->
			<cfif len(args.form.srchDateFrom)>
				AND eiTimeStamp <= '#DateFormat(args.form.srchDateTo,"yyyy-mm-dd")#'
				AND eiTimeStamp >= '#DateFormat(args.form.srchDateFrom,"yyyy-mm-dd")#'
			</cfif>
			ORDER BY accName, eiTimeStamp ASC
		</cfquery>
		<cfoutput>
		<cfif loc.result.QTrans.recordcount gt 0>
			<cfloop from="#args.form.srchDateFrom#" to="#args.form.srchDateTo#" index="loc.aDay">
				<cfif DayOfWeek(loc.aDay) eq 7>
					<cfset StructInsert(loc.result.weekends,DateFormat(loc.aDay,"yyyymmdd"),0)>
				</cfif>
			</cfloop>
			<cfset loc.test = []>
			<cfset loc.result.grandTotal = 0>
			<cfset loc.result.dayKeys = ListSort(StructKeyList(loc.result.weekends,","),"text","asc")>
			<cfloop query="loc.result.QTrans">
				<cfset loc.lastSat = 0>
				<cfset loc.result.grandTotal += eiNet>
				<cfset loc.tranDate = DateFormat(eiTimeStamp,'yyyymmdd')>
				<cfloop list="#loc.result.dayKeys#" index="loc.key">
					<!---<cfset ArrayAppend(loc.test,{title="before if","tdate"=loc.trandate,"sat"=loc.lastSat,"key"=loc.key,"value"=eiNet})>--->
					<cfif loc.tranDate gte loc.lastSat AND loc.tranDate lte loc.key>
						<cfset loc.weekend = StructFind(loc.result.weekends,loc.key)>
						<cfset StructUpdate(loc.result.weekends,loc.key,loc.weekend + eiNet)>
						<!---<cfset ArrayAppend(loc.test,{title="inside if","tdate"=loc.trandate,"sat"=loc.lastSat,"key"=loc.key,"value"=eiNet,"total"=loc.weekend + eiNet})>--->
						<cfset loc.lastSat = loc.key>
						<cfbreak>
					</cfif>
					<cfset loc.lastSat = loc.key>
				</cfloop>
			</cfloop>
		</cfif>
		</cfoutput>
		<!---<cfset loc.result.loc = loc>--->
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="PurchReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.suppliers=[]>
		<cfset loc.result.QTransResult="">
		<cfset loc.result.firstWeek = 203053>
		<cfset loc.result.lastWeek = 0>
		<cfset loc.result.thisWeek = Week(Now())>
		<cfset loc.result.weekArray = []>
		<cfset loc.skipZeros=StructKeyExists(args.form,"srchIgnoreZero")>
		<cfset loc.gross=StructKeyExists(args.form,"srchGrossFigures")>
		
		<cfquery name="loc.QSuppliers" datasource="#args.datasource#">
			SELECT accID,accCode,accGroup,accPayType,accIndex,accName,accType
			FROM tblAccount
			WHERE true
			<cfif len(StructFind(args.form,"srchName"))>AND accName LIKE "%#args.form.srchName#%"</cfif>
			<cfif len(StructFind(args.form,"srchLedger"))>AND accType="#args.form.srchLedger#"</cfif>
			<cfif len(StructFind(args.form,"srchGroup"))>AND accGroup=#val(args.form.srchGroup)#</cfif>
			<cfif len(StructFind(args.form,"srchPayType"))>AND accPayType=#val(args.form.srchPayType)#</cfif>
			<cfif srchSort eq "accCode">
				ORDER BY accCode
			<cfelseif srchSort eq "accName">
				ORDER BY accName
			<cfelseif srchSort eq "accType">
				ORDER BY accPayType,accName
			<cfelse>
				ORDER BY accID
			</cfif>
		</cfquery>
		<cfif loc.QSuppliers.recordcount GT 0>
			<cfloop query="loc.QSuppliers">
				<cfset loc.item={}>
				<cfset loc.item.ID=accID>
				<cfset loc.item.ref=accCode>
				<cfset loc.item.name=accName>
				<cfset loc.item.type=accType>
				<cfset loc.item.accPayType=accPayType>
				<cfset loc.item.balance0=0>
				<cfset loc.item.balance1=0>
				<cfset loc.item.balance2=0>
				<cfset loc.item.balance3=0>
				<cfset loc.item.balance4=0>
				<cfset loc.item.balance5=0>
				<cfset loc.item.balance6=0>
				<cfset loc.item.balance7=0>
				<cfset loc.item.balance8=0>
				<cfset loc.item.balance9=0>
				<cfset loc.item.balance10=0>
				<cfset loc.item.balance11=0>
				<cfset loc.item.balance12=0>
				<!---<cfset loc.item.weeks = {}>--->
				<cfquery name="loc.QTrans" datasource="#args.datasource#" result="loc.result.QTransResult">
					SELECT trnAccountID,trnDate,trnType,TRUNCATE(trnAmnt1,2) AS amount1,TRUNCATE(trnAmnt2,2) AS amount2
					FROM tblTrans
					WHERE trnAccountID=#val(loc.item.ID)#
					<cfif len(args.form.srchDateFrom)>
						AND trnDate>='#args.form.srchDateFrom#'
						AND trnDate<='#args.form.srchDateTo#'
					</cfif>
					<cfif len(StructFind(args.form,"srchType"))>
						<cfif args.form.srchType eq 'debits'>AND trnType IN ('inv','crn')
						<cfelseif args.form.srchType eq 'credits'>AND trnType IN ('pay','jnl','nom','rfd','dbt')</cfif>
					</cfif>
					<cfif StructKeyExists(args.form,"srchAllocated")>AND trnAlloc=0</cfif>
					ORDER BY trnDate
				</cfquery>
				<cfset loc.result.QTrans=loc.QTrans>
				<cfset loc.item.balance0=0>
				<cfloop query="loc.QTrans">
					<cfif loc.gross><cfset loc.amount=precisionEvaluate(amount1+amount2)>
						<cfelse><cfset loc.amount=precisionEvaluate(amount1)></cfif>
					<cfset loc.item.balance0=precisionEvaluate(loc.item.balance0+loc.amount)>
					<cfswitch expression="#Month(trnDate)#">
						<cfcase value="1"><cfset loc.item.balance1=precisionEvaluate(loc.item.balance1+loc.amount)></cfcase>
						<cfcase value="2"><cfset loc.item.balance2=precisionEvaluate(loc.item.balance2+loc.amount)></cfcase>
						<cfcase value="3"><cfset loc.item.balance3=precisionEvaluate(loc.item.balance3+loc.amount)></cfcase>
						<cfcase value="4"><cfset loc.item.balance4=precisionEvaluate(loc.item.balance4+loc.amount)></cfcase>
						<cfcase value="5"><cfset loc.item.balance5=precisionEvaluate(loc.item.balance5+loc.amount)></cfcase>
						<cfcase value="6"><cfset loc.item.balance6=precisionEvaluate(loc.item.balance6+loc.amount)></cfcase>
						<cfcase value="7"><cfset loc.item.balance7=precisionEvaluate(loc.item.balance7+loc.amount)></cfcase>
						<cfcase value="8"><cfset loc.item.balance8=precisionEvaluate(loc.item.balance8+loc.amount)></cfcase>
						<cfcase value="9"><cfset loc.item.balance9=precisionEvaluate(loc.item.balance9+loc.amount)></cfcase>
						<cfcase value="10"><cfset loc.item.balance10=precisionEvaluate(loc.item.balance10+loc.amount)></cfcase>
						<cfcase value="11"><cfset loc.item.balance11=precisionEvaluate(loc.item.balance11+loc.amount)></cfcase>
						<cfcase value="12"><cfset loc.item.balance12=precisionEvaluate(loc.item.balance12+loc.amount)></cfcase>
					</cfswitch>
<!---
					<cfset loc.tranWeek = Week(trnDate)>
					<cfset loc.tranYYWW = Year(trnDate) * 100 + loc.tranWeek>
					<cfif NOT ArrayFind(loc.result.weekArray,loc.tranYYWW)><cfset ArrayAppend(loc.result.weekArray,loc.tranYYWW)></cfif>
					<cfif loc.tranYYWW lt loc.result.firstWeek><cfset loc.result.firstWeek = loc.tranYYWW></cfif>
					<cfif loc.tranYYWW gt loc.result.lastWeek><cfset loc.result.lastWeek = loc.tranYYWW></cfif>
					<cfif StructKeyExists(loc.item.weeks,loc.tranYYWW)>
						<cfset loc.thisWeekBalance = StructFind(loc.item.weeks,loc.tranYYWW)>
						<cfset loc.thisWeekBalance += loc.amount>
						<cfset StructUpdate(loc.item.weeks,loc.tranYYWW,loc.thisWeekBalance)>
					<cfelse>
						<cfset StructInsert(loc.item.weeks,loc.tranYYWW,loc.amount)>
					</cfif>
--->
				</cfloop>
				<cfif loc.item.balance0 neq 0 OR NOT loc.skipZeros>
					<cfset ArrayAppend(loc.result.suppliers,loc.item)>
				</cfif>
			</cfloop>
			<cfset ArraySort(loc.result.weekArray,"numeric")>
		</cfif>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="VATAnalysis" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var QTransResult="">
		<cfset var rec={}>
		<cfset var monthData={}>
		<cfset var key="">
		<cfset var loNum=12>
		<cfset var hiNum=0>
		
		<cfquery name="QTrans" datasource="#args.datasource#" result="QTransResult">
			SELECT nomCode, nomTitle, nomVATCode, vatRate, niAmount, round(niAmount*vatRate/100,2) AS vatAmnt, Month(trnDate) AS Mnth
			FROM (((tblNominal 
				INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
					INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode) 
						INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
			WHERE 1	<!--- pass option --->
			<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=#args.form.srchAccount#
				<cfelseif val(args.form.srchAccount) eq -1>AND trnClientRef=0</cfif>
			<cfif len(args.form.srchLedger) gt 0>
				AND trnLedger='#args.form.srchLedger#'
				AND nomType='#args.form.srchLedger#'
			</cfif>
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			<cfif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#' </cfif>
			ORDER BY nomCode, trnDate, trnAccountID
		</cfquery>
		<cfset result.QTransResult=QTransResult>
		<cfset result.titleLedger=args.titleLedger>
		<cfset result.analysis={}>
		<cfset result.VAT={}>
		<cfset result.TotalNet=0>
		<cfset result.TotalVAT=0>
		<cfset result.columnCount=0>
		<cfloop query="QTrans">
			<cfset loNum=Min(loNum,mnth)>
			<cfset hiNum=Max(hiNum,mnth)>
			<cfset key=NumberFormat(mnth,"00")>
			<cfset result.TotalNet=result.TotalNet+niAmount>
			<cfset result.TotalVAT=result.TotalVAT+vatAmnt>
			<cfif NOT StructKeyExists(result.analysis,nomCode)>
				<cfset StructInsert(result.analysis,nomCode,{"Title"=nomTitle,"Rate"=vatRate})>
			</cfif>
			
			<cfif NOT StructKeyExists(result.VAT,vatRate)>
				<cfset StructInsert(result.VAT,vatRate,{"Rate"=vatRate, "Net"=0, "VAT"=0})>
			</cfif>
			<cfset rec=StructFind(result.VAT,vatRate)>
			<cfset rec.Net=rec.Net+niAmount>
			<cfset rec.VAT=rec.VAT+vatAmnt>
			<cfset StructUpdate(result.VAT,vatRate,rec)>
			
			<cfset rec=StructFind(result.analysis,nomCode)>
			<cfif StructKeyExists(rec,"month#key#")>
				<cfset monthData=StructFind(rec,"month#key#")>
				<cfset monthData.count++>
				<cfset monthData.net=monthData.net+niAmount>
				<cfset monthData.vat=monthData.vat+vatAmnt>
				<cfset StructUpdate(rec,"month#key#",monthData)>
				<cfset StructUpdate(result,"net#key#",StructFind(result,"net#key#")+niAmount)>
				<cfset StructUpdate(result,"vat#key#",StructFind(result,"vat#key#")+vatAmnt)>
			<cfelse>
				<cfset monthData={}>
				<cfset monthData.count=1>
				<cfset monthData.net=niAmount>
				<cfset monthData.vat=vatAmnt>
				<cfset StructInsert(rec,"month#key#",monthData)>
				<cfif NOT StructKeyExists(result,"net#key#")>
					<cfset result.columnCount++>
					<cfset StructInsert(result,"net#key#",niAmount)>
					<cfset StructInsert(result,"vat#key#",vatAmnt)>
				<cfelse>
					<cfset StructUpdate(result,"net#key#",StructFind(result,"net#key#")+niAmount)>
					<cfset StructUpdate(result,"vat#key#",StructFind(result,"vat#key#")+vatAmnt)>					
				</cfif>
			</cfif>
		</cfloop>
		<cfloop collection="#result.VAT#" item="key">
			<cfset rec=StructFind(result.VAT,key)>
			<cfset rec.prop=DecimalFormat((rec.Net/result.TotalNet)*100)>
		</cfloop>
		<cfset result.firstMonth=val(loNum)>
		<cfset result.lastMonth=val(hiNum)>
		<cfreturn result>
	</cffunction>

	<cffunction name="ApportionSales" access="private" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		
		<cfset args.sales.ports={}>
		<cfloop collection="#args.purch.vat#" item="loc.key">
			<cfset loc.rec=StructFind(args.purch.vat,loc.key)>
			<cfset StructInsert(args.sales.ports,loc.key,{"prop"=loc.rec.prop})>
			<cfset loc.rateStruct=StructFind(args.sales.ports,loc.key)>
			<cfloop from="#args.sales.firstMonth#" to="#args.sales.lastMonth#" index="loc.i">
				<cfset loc.mnth=NumberFormat(loc.i,"00")>
				<cfset loc.monthNet=StructFind(args.sales,"net#loc.mnth#")>
				<cfset loc.propGross=loc.monthNet*loc.rec.prop/100>
				<cfset loc.propVAT=loc.propGross-(loc.propGross/(1+(loc.key/100)))>
				<cfset loc.propNet=loc.propGross-loc.propVAT>
				<cfset StructInsert(loc.rateStruct,"net#loc.mnth#",{"gross"=loc.propGross,"vat"=loc.propVAT,"net"=loc.propNet})>
			</cfloop>
		</cfloop>
	</cffunction>

	<cffunction name="VATReturn" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.parms=args>
		<cfset loc.result.PRD = {}>
		
		<cfquery name="loc.QSalesTrans" datasource="#args.datasource#" result="loc.QSalesTransResult">
			SELECT nomClass,nomType,SUM(niAmount) AS gross, 
				year(trnDate) as DA, month(trnDate) As DB, count(*) AS trans
			FROM ((tblNominal INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
			WHERE trnLedger='sales' 
			AND nomType='sales'
			AND nomClass != 'exclude'
			<!--- AND nomClass <> 'other'	exclude news account payments & owners account --->
			AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#' 
			GROUP BY DA,DB,nomClass
		</cfquery>
<!---		<cfdump var="#loc.QSalesTransResult#" label="QSalesTrans" expand="yes" format="html" 
	output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->
		<cfloop query="loc.QSalesTrans">
			<cfset loc.yymm = "#DA#-#NumberFormat(DB,"00")#">
			<cfif NOT StructKeyExists(loc.result.PRD,loc.yymm)>
				<cfset StructInsert(loc.result.PRD,loc.yymm,{"SALES" = {"zgrand" = {}}, "PURCH" = {"zgrand" = {}} })>
			</cfif>
			<cfset loc.ledger = StructFind(loc.result.PRD,loc.yymm).SALES>
			<cfif NOT StructKeyExists(loc.ledger,nomClass)>
				<cfset StructInsert(loc.ledger,nomClass,{})>
			</cfif>
			<cfset loc.class = StructFind(loc.ledger,nomClass)>
			<cfif StructKeyExists(loc.class,"total")>
				<cfset loc.rec = StructFind(loc.class,"total")>
				<cfset loc.rec.gross += gross>
				<cfset loc.rec.trans += trans>
			<cfelse>
				<cfset StructInsert(loc.class,"total",{"gross" = gross, "net" = 0, "VAT" = 0, "trans" = trans, "rate" = "Total", "prop" = 1})>
			</cfif>
			
			<cfif NOT StructKeyExists(loc.ledger.zgrand,"total")>
				<cfset StructInsert(loc.ledger.zgrand,"total",{"gross" = 0, "net" = 0, "VAT" = 0, "trans" = trans, "rate" = "Total", "prop" = 1})>
			</cfif>
		</cfloop>
		<cfquery name="loc.QPurTrans" datasource="#args.datasource#">
			SELECT nomClass,nomVATCode, vatRate, SUM(niAmount) AS net, round(SUM(niAmount)*vatRate/100,2) AS vatAmnt, 
				year(trnDate) as DA, month(trnDate) As DB, count(*) AS trans
			FROM (((tblNominal 
			INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
			INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode) 
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
			WHERE trnClientRef=0 
			AND trnLedger='purch' 
			AND nomType='purch' 
			AND nomClass != 'exclude'
			AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
			GROUP BY DA,DB,nomClass,nomVATCode
		</cfquery>
		<cfloop query="loc.QPurTrans">
			<cfset loc.yymm = "#DA#-#NumberFormat(DB,"00")#">
			<cfif NOT StructKeyExists(loc.result.PRD,loc.yymm)>
				<cfset StructInsert(loc.result.PRD,loc.yymm,{"SALES" = {}, "PURCH" = {} })>
			</cfif>
			<cfset loc.ledger = StructFind(loc.result.PRD,loc.yymm).PURCH>
			<cfif NOT StructKeyExists(loc.ledger,nomClass)>
				<cfset StructInsert(loc.ledger,nomClass,{})>
			</cfif>
			<cfset loc.class = StructFind(loc.ledger,nomClass)>
			<cfif NOT StructKeyExists(loc.class,nomVATCode)>
				<cfset StructInsert(loc.class,nomVATCode,{"gross" = net + vatAmnt, "net" = net, "VAT" = vatAmnt, "trans" = trans, "rate" = vatRate})>
			</cfif>
			<cfif NOT StructKeyExists(loc.class,"total")>
				<cfset StructInsert(loc.class,"total",{"gross" = net + vatAmnt, "net" = net, "VAT" = vatAmnt, "trans" = trans, "rate" = "Total", "prop" = 1})>
			<cfelse>
				<cfset loc.rec = StructFind(loc.class,"total")>
				<cfset loc.rec.gross += (net + vatAmnt)>
				<cfset loc.rec.net += net>
				<cfset loc.rec.VAT += vatAmnt>
				<cfset loc.rec.trans += trans>
			</cfif>
			
			<cfif NOT StructKeyExists(loc.ledger.zgrand,"total")>
				<cfset StructInsert(loc.ledger.zgrand,"total",{"gross" = net + vatAmnt, "net" = net, "VAT" = vatAmnt, "trans" = trans, "rate" = "Total", "prop" = 1})>
			<cfelse>
				<cfset loc.rec = StructFind(loc.ledger.zgrand,"total")>
				<cfset loc.rec.gross += (net + vatAmnt)>
				<cfset loc.rec.net += net>
				<cfset loc.rec.VAT += vatAmnt>
				<cfset loc.rec.trans += trans>		
			</cfif>
		</cfloop>
		
		<cfset loc.periodKeys = ListSort(StructKeyList(loc.result.PRD,","),"numeric","asc",",")>
		<cfloop list="#loc.periodKeys#" index="loc.prdKey">
			<cfset loc.period = StructFind(loc.result.PRD,loc.prdKey)>
			<cfset loc.ledgerKeys = ListSort(StructKeyList(loc.period,","),"text","asc",",")>
			<cfloop list="#loc.ledgerKeys#" index="loc.ledgerKey">
				<cfset loc.ledger = StructFind(loc.period,loc.ledgerKey)>
				<cfif loc.ledgerKey eq "PURCH">
					<cfset loc.deptKeys = ListSort(StructKeyList(loc.ledger,","),"text","asc",",")>
					<cfloop list="#loc.deptKeys#" index="loc.deptKey">
						<cfif loc.deptKey neq "total">
							<cfset loc.dept = StructFind(loc.ledger,loc.deptKey)>
							<cfset loc.netTotal = loc.dept.total.net>
							<cfloop collection="#loc.dept#" item="loc.vatKey">
								<cfset loc.vatRate = StructFind(loc.dept,loc.vatKey)>
								<cfset StructInsert(loc.vatRate,"prop",loc.vatRate.net / loc.netTotal,true)>
							</cfloop>
						</cfif>
					</cfloop>
				<cfelse>
					<cfloop collection="#loc.ledger#" item="loc.deptKey">
						<cfset loc.salesDept = StructFind(loc.ledger,loc.deptKey)>
						<cfif StructKeyExists(loc.period.PURCH,loc.deptKey) AND loc.deptKey neq "total">
							<cfset loc.purDept = StructFind(loc.period.PURCH,loc.deptKey)>
							<cfloop collection="#loc.purDept#" item="loc.vatKey">
								<cfset loc.vatRec = StructFind(loc.purDept,loc.vatKey)>
								<cfif loc.vatKey neq "total">
									<cfset loc.sgross = int(loc.salesDept.total.gross * loc.vatRec.prop * 100) / 100>
									<cfset loc.snet = loc.sgross / (1 + (loc.vatRec.rate / 100))>
									<cfset loc.svat = loc.sgross - loc.snet>
									<cfset StructInsert(loc.salesDept,loc.vatKey,{
										"gross" = loc.sgross,
										"net" = loc.snet,
										"vat" = loc.svat,
										"rate" = loc.vatRec.rate,
										"prop" = loc.vatRec.prop
									},true)>
									<cfset loc.salesDept.total.net += loc.snet>
									<cfset loc.salesDept.total.vat += loc.svat>
									<cfset loc.ledger.zgrand.total.VAT += loc.svat>
									<cfset loc.ledger.zgrand.total.gross += loc.sgross>
									<cfset loc.ledger.zgrand.total.net += loc.snet>
								</cfif>
							</cfloop>
						<cfelse>
							<cfset loc.salesDept.total.net = loc.salesDept.total.gross>
							<cfset loc.ledger.zgrand.total.gross += loc.salesDept.total.gross>
							<cfset loc.ledger.zgrand.total.net += loc.salesDept.total.net>
						</cfif>
					</cfloop>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="VATTransactions" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.purRows = {}>
		<cfset loc.result.totals = {}>
		
		<cfquery name="loc.QSalesTrans" datasource="#args.datasource#">
			SELECT nomID,nomClass,nomGroup,nomType,nomCode,nomTitle,niAmount,trnID,trnDate
			FROM ((tblNominal INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
			WHERE trnLedger='sales' 
			AND nomType='sales'
			AND nomClass != 'exclude'
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			AND niAmount<>0
			AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
			ORDER BY nomClass,nomCode,trnDate,trnID
		</cfquery>
		<cfset loc.result.QSalesTrans=loc.QSalesTrans>
		<cfquery name="loc.QPurTrans" datasource="#args.datasource#">
			SELECT nomID,nomClass,nomGroup,nomType,nomCode,nomTitle,nomVATCode, vatRate, niAmount,round(niAmount*vatRate/100,2) AS vatAmnt, 
				trnID,trnRef,trnDate,trnAmnt1,trnAmnt2, accID,accCode,accName
			FROM tblNominal 
			INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID
			INNER JOIN tblAccount ON tblTrans.trnAccountID = tblAccount.accID
			INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode 
			WHERE trnClientRef=0 
			AND trnLedger='purch' 
			AND nomType='purch' 
			AND nomClass != 'exclude'
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
			ORDER BY accCode,trnDate,trnID
		</cfquery>
		<cfset loc.result.QPurTrans=loc.QPurTrans>
		<cfloop query="loc.QPurTrans">
			<cfset loc.grpCode = "#nomGroup#-#nomCode#">
			<cfif NOT StructKeyExists(loc.result.purRows,loc.grpCode)>
				<cfset StructInsert(loc.result.purRows,loc.grpCode,{
					nomID = nomID,
					nomGroup = nomGroup,
					nomCode = nomCode,
					nomType = nomType,
					nomTitle = nomTitle,
					nomBals = {}
				})>
			</cfif>
			<cfset loc.yymm = Year(trnDate)*100 + Month(trnDate)>
			<cfset loc.nomLine = StructFind(loc.result.purRows,loc.grpCode)>
			<cfif NOT StructKeyExists(loc.nomLine.nomBals,loc.yymm)>
				<cfset StructInsert(loc.nomLine.nomBals,loc.yymm,niAmount)>
			<cfelse>
				<cfset loc.bal = StructFind(loc.nomLine.nomBals,loc.yymm)>
				<cfset StructUpdate(loc.nomLine.nomBals,loc.yymm,loc.bal + niAmount)>
			</cfif>
			<cfif NOT StructKeyExists(loc.result.totals,loc.yymm)>
				<cfset StructInsert(loc.result.totals,loc.yymm,niAmount)>
			<cfelse>
				<cfset loc.total = StructFind(loc.result.totals,loc.yymm)>
				<cfset StructUpdate(loc.result.totals,loc.yymm,loc.total + niAmount)>
			</cfif>
		</cfloop>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="BusReportTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.saleRows = {}>
		<cfset loc.result.purRows = {}>
		<cfset loc.result.nomRows1 = {}>
		<cfset loc.result.nomRows2 = {}>
		<cfset loc.result.saletotals = {}>
		<cfset loc.result.purtotals = {}>
		<cfset loc.result.nomtotals = {}>
		<cfset loc.result.totally = {}>
		
		<cftry>
			<cfquery name="loc.QSalesTrans" datasource="#args.datasource#" result="loc.QSalesTransResult">
				SELECT nomClass,nomGroup,nomType,nomCode,nomTitle,niAmount,trnID,trnDate
				FROM ((tblNominal INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID) 
				INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID) 
				WHERE trnLedger='sales' 
				AND nomType='sales'
				AND nomClass NOT IN ('exclude','ext')
				<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
				AND niAmount != 0
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				ORDER BY nomClass,nomCode,trnDate
			</cfquery>
			<cfset loc.result.QSalesTrans=loc.QSalesTrans>
			
			<cfquery name="loc.QPurTrans" datasource="#args.datasource#">
				SELECT nomClass,nomGroup,nomType,nomCode,nomTitle,nomVATCode, vatRate, niAmount,round(niAmount*vatRate/100,2) AS vatAmnt, 
					trnID,trnDate,trnAmnt1,trnAmnt2, accID,accCode,accName
				FROM tblNominal 
				INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID
				INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID
				INNER JOIN tblAccount ON tblTrans.trnAccountID = tblAccount.accID
				INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode 
				WHERE trnClientRef=0 
				AND trnLedger='purch' 
				AND nomType='purch' 
				AND nomClass NOT IN ('exclude','other')
				<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				ORDER BY accCode,trnDate,trnID
			</cfquery>
			<cfset loc.result.QPurTrans=loc.QPurTrans>
			
			<cfquery name="loc.QNomTrans1" datasource="#args.datasource#">
				SELECT nomClass,nomGroup,nomType,nomCode,nomTitle,nomVATCode, vatRate, niAmount,round(niAmount*vatRate/100,2) AS vatAmnt, 
					trnID,trnDate,trnAmnt1,trnAmnt2, accID,accCode,accName
				FROM tblNominal 
				INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID
				INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID
				INNER JOIN tblAccount ON tblTrans.trnAccountID = tblAccount.accID
				INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode 
				WHERE trnClientRef=0 
				AND nomClass = 'other'
				<!---AND nomType = 'purch'
				AND trnLedger='nom'--->
				<!---AND nomClass NOT IN ('exclude','other')
				<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>--->
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				ORDER BY nomGroup, nomCode,trnDate,trnID
			</cfquery>
			<cfset loc.result.QNomTrans1=loc.QNomTrans1>
			
			<cfquery name="loc.QNomTrans2" datasource="#args.datasource#">
				SELECT nomClass,nomGroup,nomType,nomCode,nomTitle,nomVATCode, vatRate, niAmount,round(niAmount*vatRate/100,2) AS vatAmnt, 
					trnID,trnDate,trnAmnt1,trnAmnt2, accID,accCode,accName
				FROM tblNominal 
				INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID
				INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID
				INNER JOIN tblAccount ON tblTrans.trnAccountID = tblAccount.accID
				INNER JOIN tblVATRates ON tblNominal.nomVATCode = tblVATRates.vatCode 
				WHERE trnClientRef=0 
				AND nomClass = 'other'
				AND nomType = 'nom'
				<!---AND trnLedger='nom'--->
				<!---AND nomClass NOT IN ('exclude','other')
				<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>--->
				AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#'
				ORDER BY nomGroup, nomCode,trnDate,trnID
			</cfquery>
			<cfset loc.result.QNomTrans2=loc.QNomTrans2>
			
			<!--- PURCHASE LEDGER --->
			<cfloop query="loc.QPurTrans">
				<cfset loc.grpCode = "#nomGroup#-#nomCode#">
				<cfif NOT StructKeyExists(loc.result.purRows,loc.grpCode)>
					<cfset StructInsert(loc.result.purRows,loc.grpCode,{
						nomGroup = nomGroup,
						nomCode = nomCode,
						nomType = nomType,
						nomClass = nomClass,
						nomTitle = nomTitle,
						nomBals = {}
					})>
				</cfif>
				<cfset loc.yymm = Year(trnDate)*100 + Month(trnDate)>
				<cfset loc.nomLine = StructFind(loc.result.purRows,loc.grpCode)>
				<cfif NOT StructKeyExists(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructInsert(loc.nomLine.nomBals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.bal = StructFind(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructUpdate(loc.nomLine.nomBals,loc.yymm,loc.bal + niAmount)>
				</cfif>
				<cfif NOT StructKeyExists(loc.result.purTotals,loc.yymm)>
					<cfset StructInsert(loc.result.purTotals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.purTotals,loc.yymm)>
					<cfset StructUpdate(loc.result.purTotals,loc.yymm,loc.total + niAmount)>
				</cfif>
				<!--- combined totals --->
				<cfif NOT StructKeyExists(loc.result.totally,loc.yymm)>
					<cfset StructInsert(loc.result.totally,loc.yymm,{"purch" = niAmount, "sale" = 0, "nom" = 0})>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.totally,loc.yymm)>
					<cfset StructUpdate(loc.result.totally,loc.yymm,{"purch" = loc.total.purch + niAmount, "sale" = loc.total.sale, "nom" = loc.total.nom})>
				</cfif>
			</cfloop>
			<!--- SALES LEDGER --->
			<cfloop query="loc.QSalesTrans">
				<cfset loc.grpCode = "#nomGroup#-#nomCode#">
				<cfif NOT StructKeyExists(loc.result.saleRows,loc.grpCode)>
					<cfset StructInsert(loc.result.saleRows,loc.grpCode,{
						nomGroup = nomGroup,
						nomCode = nomCode,
						nomType = nomType,
						nomClass = nomClass,
						nomTitle = nomTitle,
						nomBals = {}
					})>
				</cfif>
				<cfset loc.yymm = Year(trnDate)*100 + Month(trnDate)>
				<cfset loc.nomLine = StructFind(loc.result.saleRows,loc.grpCode)>
				<cfif NOT StructKeyExists(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructInsert(loc.nomLine.nomBals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.bal = StructFind(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructUpdate(loc.nomLine.nomBals,loc.yymm,loc.bal + niAmount)>
				</cfif>
				<cfif NOT StructKeyExists(loc.result.saletotals,loc.yymm)>
					<cfset StructInsert(loc.result.saletotals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.saletotals,loc.yymm)>
					<cfset StructUpdate(loc.result.saletotals,loc.yymm,loc.total + niAmount)>
				</cfif>
				<!--- combined totals --->
				<cfif NOT StructKeyExists(loc.result.totally,loc.yymm)>
					<cfset StructInsert(loc.result.totally,loc.yymm,{"sale" = niAmount, "purch" = 0, "nom" = 0})>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.totally,loc.yymm)>
					<cfset StructUpdate(loc.result.totally,loc.yymm,{"sale" = loc.total.sale + niAmount, "purch" = loc.total.purch, "nom" = loc.total.nom})>
				</cfif>
			</cfloop>
			<!--- NOMINAL LEDGER --->
			<cfloop query="loc.QNomTrans1">
				<cfset loc.grpCode = "#nomGroup#-#nomCode#">
				<cfif NOT StructKeyExists(loc.result.nomRows1,loc.grpCode)>
					<cfset StructInsert(loc.result.nomRows1,loc.grpCode,{
						nomGroup = nomGroup,
						nomCode = nomCode,
						nomType = nomType,
						nomClass = nomClass,
						nomTitle = nomTitle,
						nomBals = {}
					})>
				</cfif>
				<cfset loc.yymm = Year(trnDate)*100 + Month(trnDate)>
				<cfset loc.nomLine = StructFind(loc.result.nomRows1,loc.grpCode)>
				<cfif NOT StructKeyExists(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructInsert(loc.nomLine.nomBals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.bal = StructFind(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructUpdate(loc.nomLine.nomBals,loc.yymm,loc.bal + niAmount)>
				</cfif>
				<cfif NOT StructKeyExists(loc.result.nomTotals,loc.yymm)>
					<cfset StructInsert(loc.result.nomTotals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.nomTotals,loc.yymm)>
					<cfset StructUpdate(loc.result.nomTotals,loc.yymm,loc.total + niAmount)>
				</cfif>
				
				<!--- combined totals --->
				<cfif NOT StructKeyExists(loc.result.totally,loc.yymm)>
					<cfset StructInsert(loc.result.totally,loc.yymm,{"nom" = niAmount, "sale" = 0, "purch" = 0})>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.totally,loc.yymm)>
					<cfset StructUpdate(loc.result.totally,loc.yymm,{"nom" = loc.total.nom + niAmount, "sale" = loc.total.sale, "purch" = loc.total.purch})>
				</cfif>
			</cfloop>
			<cfloop query="loc.QNomTrans2">
				<cfset loc.grpCode = "#nomGroup#-#nomCode#">
				<cfif NOT StructKeyExists(loc.result.nomRows2,loc.grpCode)>
					<cfset StructInsert(loc.result.nomRows2,loc.grpCode,{
						nomGroup = nomGroup,
						nomCode = nomCode,
						nomType = nomType,
						nomClass = nomClass,
						nomTitle = nomTitle,
						nomBals = {}
					})>
				</cfif>
				<cfset loc.yymm = Year(trnDate)*100 + Month(trnDate)>
				<cfset loc.nomLine = StructFind(loc.result.nomRows2,loc.grpCode)>
				<cfif NOT StructKeyExists(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructInsert(loc.nomLine.nomBals,loc.yymm,niAmount)>
				<cfelse>
					<cfset loc.bal = StructFind(loc.nomLine.nomBals,loc.yymm)>
					<cfset StructUpdate(loc.nomLine.nomBals,loc.yymm,loc.bal + niAmount)>
				</cfif>
				
				<!--- combined totals --->
				<cfif NOT StructKeyExists(loc.result.totally,loc.yymm)>
					<cfset StructInsert(loc.result.totally,loc.yymm,{"nom" = niAmount, "sale" = 0, "purch" = 0})>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.totally,loc.yymm)>
					<cfset StructUpdate(loc.result.totally,loc.yymm,{"nom" = loc.total.nom + niAmount, "sale" = loc.total.sale, "purch" = loc.total.purch})>
				</cfif>
			</cfloop>	
	
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="TranRemittance" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
			
		<cfquery name="loc.QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tbltrans
			WHERE trnAccountID = #args.accountID#
			AND trnAllocID = #args.allocationID#	
			ORDER BY trnDate ASC
		</cfquery>
		<cfquery name="loc.QSupplier" datasource="#args.datasource#">
			SELECT *
			FROM tblAccount
			WHERE accID = #args.accountID#
		</cfquery>
		<cfreturn loc>
	</cffunction>

	<cffunction name="TranList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#" result="result.QTransResult">
				SELECT accID,accName,accType,accNomAcct,accPayAcc, trnID,trnLedger,trnRef,trnDesc,trnDate,trnAccountID,trnClientRef,trnType,trnMethod,trnAmnt1,trnAmnt2
				FROM tblTrans,tblAccount
				WHERE trnAccountID=accID
				<cfif val(args.form.srchAccount) lt 0>AND trnClientRef=0</cfif>
				<cfif val(args.form.srchAccount) gt 0>
					AND trnAccountID=#args.form.srchAccount#
					AND trnClientRef=0
				</cfif>
				<cfif len(args.form.srchRange)>
					<cfif Left(args.form.srchRange,2) eq 'FY'>
						<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
						AND trnDate >= '#loc.fyDate.start#'
						AND trnDate <= '#loc.fyDate.end#'				
					</cfif>
				<cfelseif len(args.form.srchDateFrom)>
					AND trnDate BETWEEN '#args.form.srchDateFrom#' AND '#args.form.srchDateTo#' </cfif>
				<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=#args.form.srchAccount#</cfif>
				<cfif len(args.form.srchLedger) gt 0>AND trnLedger='#args.form.srchLedger#'</cfif>
				<cfif len(args.form.srchDept)>
                	<cfswitch expression="#args.form.srchDept#">
                    	<cfcase value="shop">
                        	AND accID = 1
                        </cfcase>
                    	<cfcase value="news">
                        	AND accID = 4
                        </cfcase>
                    	<cfcase value="other">
                        	AND accID NOT IN (1,4)
                        </cfcase>
                    </cfswitch>
                </cfif>
				<cfif StructKeyExists(args.form, "srchTranType") AND len(args.form.srchTranType)>
					AND trnType IN ('#REReplaceNoCase(args.form.srchTranType, ",", "','", "all")#')
				</cfif>
				<cfif StructKeyExists(args.form, "srchStatus") AND len(args.form.srchStatus)>
					<cfif srchStatus eq 'allocated'>
						AND trnAlloc > 0
					<cfelseif srchStatus eq 'notalloc'>
						AND trnAlloc = 0
					</cfif>
				</cfif>
				
				<cfif args.form.srchSort eq 'trnAccountID'>
					ORDER BY accName ASC, trnDate ASC
				<cfelseif args.form.srchSort eq 'trnRef'>
					ORDER BY accName ASC, trnRef ASC
				<cfelse>
					ORDER BY #args.form.srchSort#
				</cfif>
			</cfquery>
			<cfset result.tranArray=[]>
			<cfset result.totAmnt1=0>
			<cfset result.totAmnt2=0>
			<cfloop query="QTrans">
				<cfset rec={}>
				<cfset rec.accID=accID>
				<cfset rec.accName=accName>
				<cfset rec.accType=accType>
				<cfset rec.accNomAcct=accNomAcct>
				<cfset rec.accPayAcc=accPayAcc>
				<cfset rec.trnID=trnID>
				<cfset rec.trnClientRef=trnClientRef>
				<cfset rec.trnRef=trnRef>
				<cfset rec.trnDesc=trnDesc>
				<cfset rec.trnDate=trnDate>
				<cfset rec.trnType=trnType>
				<cfset rec.trnMethod=trnMethod>
				<cfset rec.trnAmnt1=trnAmnt1>
				<cfset rec.trnAmnt2=trnAmnt2>
				<cfset rec.trnTotal=trnAmnt1+trnAmnt2>
				<cfset ArrayAppend(result.tranArray,rec)>
				<cfset result.totAmnt1=result.totAmnt1+trnAmnt1>
				<cfset result.totAmnt2=result.totAmnt2+trnAmnt2>
			</cfloop>		
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="TranDetail" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		<cfset var QItems="">
		<cfset var QResult="">
		
		<cfset result.args=args>
		<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
			SELECT accID,accName, trnID, trnLedger, trnRef,trnDate, trnAccountID, trnType,trnAmnt1,trnAmnt2,trnAlloc,trnAllocID,trnMethod,trnDesc
			FROM tblTrans,tblAccount
			WHERE trnAccountID=accID
			
			<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchAccount#"></cfif>
			<cfif len(args.form.srchLedger) gt 0>AND trnLedger=<cfqueryparam cfsqltype="cf_sql_varchar" value="#args.form.srchLedger#"></cfif>
			<cfif len(args.form.srchParmNum) gt 0>AND trnAllocID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchParmNum#"></cfif>
				<cfif len(args.form.srchRange)>
					<cfif Left(args.form.srchRange,2) eq 'FY'>
						<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
						AND trnDate >= '#loc.fyDate.start#'
						AND trnDate <= '#loc.fyDate.end#'				
					</cfif>
				<cfelseif len(args.form.srchDateFrom)>
					AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
					AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
				
				<cfif StructKeyExists(args.form, "srchTranType") AND len(args.form.srchTranType)>
					AND trnType IN ('#REReplaceNoCase(args.form.srchTranType, ",", "','", "all")#')
				</cfif>
			<cfif StructKeyExists(args,"sortOrder")>
				ORDER BY #args.sortOrder#
			<cfelse>
				ORDER BY trnAccountID,trnDate,trnID
			</cfif>
		</cfquery>
		<cfset result.QTrans=QTrans>
		<cfset result.QResult=QResult>
		<cfset result.tranArray=[]>
		<cfloop query="QTrans">
			<cfset rec={}>
			<cfset rec.accID=accID>
			<cfset rec.accName=accName>
			<cfset rec.trnID=trnID>
			<cfset rec.trnRef=trnRef>
			<cfset rec.trnDate=trnDate>
			<cfset rec.trnType=trnType>
			<cfset rec.trnAmnt1=trnAmnt1>
			<cfset rec.trnAmnt2=trnAmnt2>
			<cfquery name="QItems" datasource="#args.datasource#">
				SELECT nomCode,nomTitle,niID,niAmount
				FROM tblNominal,tblNomItems
				WHERE nomID=niNomID
				AND niTranID=<cfqueryparam cfsqltype="cf_sql_integer" value="#trnID#">
			</cfquery>
			<cfset rec.itemtotal = 0>
			<cfloop query="QItems">
				<cfset rec.itemtotal += niAmount>
			</cfloop>
			<cfif rec.itemtotal lt 0.001><cfset rec.itemtotal = 0></cfif>
			<cfset rec.items=QItems>
			<cfset ArrayAppend(result.tranArray,rec)>
		</cfloop>		
		<cfreturn result>
	</cffunction>

	<cffunction name="NomTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		<cfset var nomAcc={}>
		<cfset var QTrans_result="">
		<cfquery name="QTrans" datasource="#args.datasource#" result="QTrans_result">
			SELECT nomCode,nomTitle,trnID,trnLedger,trnRef,trnClientRef,trnDate,trnAccountID,trnType,trnMethod,niAmount
			FROM ((tblNominal 
			INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID)
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID)
			WHERE 1
			<cfif val(args.form.srchAccount) gt 0>
				AND trnAccountID=#args.form.srchAccount#
				AND trnClientRef=0
			</cfif>
			<cfif len(args.form.srchLedger) gt 0>AND trnLedger='#args.form.srchLedger#'</cfif>
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			<cfif val(args.form.srchNom) gt 0>AND nomID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchNom#"></cfif>
			<cfif len(args.form.srchRange)>
				<cfif Left(args.form.srchRange,2) eq 'FY'>
					<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
					AND trnDate >= '#loc.fyDate.start#'
					AND trnDate <= '#loc.fyDate.end#'				
				</cfif>
			<cfelseif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
			ORDER BY nomCode,trnDate,trnID
		</cfquery>
		<cfset result.QTrans=QTrans>
		<cfset result.QTrans_result=QTrans_result>
		<cfset result.total=0>
		<cfset result.nomAccount={}>
		<cfloop query="QTrans">
			<cfif NOT StructKeyExists(result.nomAccount,nomCode)>
				<cfset StructInsert(result.nomAccount,nomCode,{"Title"=nomTitle,"Total"=0,"tranArray"=[]})>
			</cfif>
			<cfset nomAcc=StructFind(result.nomAccount,nomCode)>
			<cfset rec={}>
			<cfset rec.nomCode=nomCode>
			<cfset rec.nomTitle=nomTitle>
			<cfset rec.trnID=trnID>
			<cfset rec.trnLedger=trnLedger>
			<cfset rec.trnRef=trnRef>
			<cfset rec.trnClientRef=trnClientRef>
			<cfset rec.trnDate=LSDateFormat(trnDate,"ddd dd-mmm-yyyy")>
			<cfset rec.accID=trnAccountID>
			<cfset rec.trnAccountID=trnAccountID>
			<cfset rec.trnType=trnType>
			<cfset rec.trnMethod=trnMethod>
			<cfset rec.niAmount=niAmount>
			<cfset ArrayAppend(nomAcc.tranArray,rec)>
			<cfset nomAcc.total=nomAcc.total+niAmount>
			<cfset result.total=result.total+niAmount>
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="NomTranSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var rec={}>
		<cfset var nomAcc={}>
		<cfset var grpCode = "">
		<cfset result.ledgers="">
		
		<cfquery name="QTrans" datasource="#args.datasource#" result="result.QTRANSRESULT">
			SELECT nomID,nomGroup,nomCode,nomType,nomClass,nomTitle,nomBFwd,trnLedger,SUM(niAmount) AS nomTotal
			FROM ((tblNominal 
			INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID)
			INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID)
			WHERE 1 
			<cfif val(args.form.srchAccount) gt 0>AND trnAccountID=#args.form.srchAccount#</cfif>
			<cfif len(args.form.srchLedger) gt 0>AND nomType='#args.form.srchLedger#'</cfif>
			<cfif len(args.form.srchDept) gt 0>AND nomClass='#args.form.srchDept#'</cfif>
			<cfif args.form.srchAccount eq -1>AND trnClientRef = ''</cfif>
			<cfif val(args.form.srchNom) gt 0>AND nomID=<cfqueryparam cfsqltype="cf_sql_integer" value="#args.form.srchNom#"></cfif>
			<cfif len(args.form.srchRange)>
				<cfif Left(args.form.srchRange,2) eq 'FY'>
					<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
					<cfset args.form.srchDateFrom = loc.fyDate.start>
					AND trnDate >= '#loc.fyDate.start#'
					AND trnDate <= '#loc.fyDate.end#'				
				</cfif>
			<cfelseif len(args.form.srchDateFrom)>
				AND trnDate BETWEEN <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				AND <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateTo#"></cfif>
			GROUP BY trnLedger,nomGroup,nomClass,nomCode
			ORDER BY trnLedger,nomGroup,nomClass,nomCode
		</cfquery>
<cfdump var="#QTrans#" label="QTrans" expand="false">
		<cfif len(args.form.srchDateFrom)>
			<cfset result.dateFrom=LSDateFormat(args.form.srchDateFrom,"dd-mmm-yyyy")>
			<cfset result.dateTo=LSDateFormat(args.form.srchDateTo,"dd-mmm-yyyy")>
		</cfif>
		<cfloop query="QTrans">
			<cfset rec={}>
			<cfset rec.nomGroup=nomGroup>
			<cfset rec.nomClass=nomClass>
			<cfset rec.nomCode=nomCode>
			<cfset rec.nomTitle=nomTitle>
			<cfset rec.nomTotal=nomTotal>
			<cfset rec.nomBFwd=nomBFwd>
			
			<cfif nomBFwd>
				<cfquery name="loc.QBalance" datasource="#args.datasource#">
					SELECT SUM(niAmount) AS nomTotal
					FROM tblNominal 
					INNER JOIN tblNomItems ON tblNominal.nomID = tblNomItems.niNomID
					INNER JOIN tblTrans ON tblNomItems.niTranID = tblTrans.trnID
					WHERE nomID=#nomID#
					AND trnDate < <cfqueryparam cfsqltype="cf_sql_date" value="#args.form.srchDateFrom#"> 
				</cfquery>
				<cfset rec.BFwd = val(loc.QBalance.nomTotal)>
			<cfelse>
				<cfset rec.BFwd = 0>
			</cfif>
			<cfif NOT StructKeyExists(result,nomType)>
				<cfset StructInsert(result,nomType,{})>
				<cfset result.ledgers="#result.ledgers#,#nomType#">
			</cfif>
			<cfset nomAcc=StructFind(result,nomType)>
			<cfset grpCode = "#nomGroup#-#nomClass#-#nomCode#">
			<cfif StructKeyExists(nomAcc,grpCode)>
				<cfset rec=StructFind(nomAcc,grpCode)>
				<cfset rec.nomTotal=rec.nomTotal+nomTotal>
				<cfset StructUpdate(nomAcc,grpCode,rec)>
			<cfelse>
				<cfset StructInsert(nomAcc,grpCode,rec)>
			</cfif>
		</cfloop>
		<cfset result.QTrans=QTrans>
		<cfset result.total=0>
		<cfreturn result>
	</cffunction>

	<cffunction name="GetNomTable" access="private" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		
		<cfquery name="loc.QNominals" datasource="#args.datasource#" result="loc.QNominals_result">
			SELECT accNomAcct, (SELECT NomCode from tblNominal where nomID=accNomAcct) as nominalCode
			FROM `tblAccount` WHERE accNomAcct>0
			GROUP BY accNomAcct
			UNION
			SELECT accPayAcc, (SELECT NomCode from tblNominal where nomID=accPayAcc) as nominalCode
			FROM `tblAccount` WHERE accPayAcc>0
			GROUP BY accPayAcc
			UNION
			SELECT nomID, NomCode
			FROM tblNominal WHERE nomGroup='R3'
		</cfquery>
		<cfloop query="loc.QNominals">
			<cfset StructInsert(this.nomBalanceAccounts,accNomAcct,nominalCode)>
		</cfloop>
		
		<cfquery name="loc.QNominals" datasource="#args.datasource#" result="loc.QNominals_result">
			SELECT nomID,nomCode
			FROM tblNominal
			ORDER BY nomCode
		</cfquery>
		<cfloop query="loc.QNominals">
			<cfset StructInsert(this.nomAccounts,nomCode,nomID)>
		</cfloop>
	</cffunction>

	<cffunction name="ValidateTransRecord" access="public" returntype="struct">
		<cfargument name="parms" type="struct" required="yes">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result={}>
		<cfset loc.itemsFound=[]>
		<cfset loc.itemsMissing=[]>
		<cfset loc.args=args>
		<cfset loc.typeList = "inv,rfd,dbt,jnl">
		<cfset loc.TranNomCodes="">
		<cfset loc.itemTotal=0>
		<cfset loc.tranTotal=0>
		<cfset loc.analysisFound=false>

		<!--- set sign--->
		<cfset loc.typeInt = ListFind(loc.typeList, args.trnType, ",")>
		<cfset loc.signTranType = (2 * int(loc.typeInt gt 0)) - 1>
		<cfset loc.signLedger = (2 * int(args.accType eq "purch")) - 1>
		<cfset loc.signTran = loc.signLedger * loc.signTranType>
		<!--- calculate tran totals --->
		<cfset loc.netAmount = abs(args.trnAmnt1) * loc.signTran>
		<cfset loc.vatAmount = abs(args.trnAmnt2) * loc.signTran>
		<cfset loc.balanceAmount = -(loc.netAmount + loc.vatAmount)>	<!--- invert --->
		<cfset loc.empties=[]>
		
		<cfif StructCount(this.nomBalanceAccounts) EQ 0>
			<cfset GetNomTable({"datasource"=args.datasource})>
		</cfif>
		<cfquery name="loc.originalItems" datasource="#args.datasource#">
			SELECT CEIL(niAmount*100) AS amount, niID,niTranID,niAmount, nomCode,nomTitle,nomType
			FROM tblNomItems,tblNominal
			WHERE niNomID=nomID
			AND niTranID=#val(args.trnID)#
		</cfquery>
		<cfloop query="loc.originalItems">
			<cfset loc.itemTotal=loc.itemTotal+amount>
			<cfset loc.tranTotal=loc.tranTotal+niAmount>
			<cfset loc.TranNomCodes="#loc.TranNomCodes#,#nomCode#">
			<cfif nomType neq "nom">
				<cfset loc.analysisFound=true>
				<cfset loc.amnt=abs(amount/100)*loc.signTran>
				<cfif ListFind('A21,A22,A23,A25,SDAL',nomCode,",")>	<!--- prizes --->
					<cfset loc.amnt = abs(loc.amnt)>
				</cfif> 
				<cfset ArrayAppend(loc.itemsFound,{
					"nomCode"=nomCode,
					"nomTitle"=nomTitle,
					"nomType"=nomType,
					"niAmount"=loc.amnt,
					"niTranID"=niTranID,
					"niID"=niID
				})>
			<cfelse>
				<cfswitch expression="#nomCode#">
					<cfcase value="DEBT|CRED|SHOP" delimiters="|">	<!--- balance amount --->
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=loc.balanceAmount,
							"niTranID"=niTranID,
							"niID"=niID
						})>
					</cfcase>
					<cfcase value="SDCL|SDAL|VAT" delimiters="|">
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=loc.vatAmount,
							"niTranID"=niTranID,
							"niID"=niID
						})>					
					</cfcase>
					<cfcase value="SUSP|BANK|CASH|CARD|COLL|CHQ" delimiters="|">
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=loc.netAmount,
							"niTranID"=niTranID,
							"niID"=niID
						})>
					</cfcase>
					<cfdefaultcase>
						<cfset ArrayAppend(loc.itemsFound,{
							"nomCode"=nomCode,
							"nomTitle"=nomTitle,
							"nomType"=nomType,
							"niAmount"=niAmount,
							"niTranID"=niTranID,
							"niID"=niID
						})>					
					</cfdefaultcase>
				</cfswitch>
			</cfif>
		</cfloop>
		<!---<cfdump var="#loc.itemsFound#" label="itemsFound" expand="no">--->
		<cfif loc.itemTotal neq 0 OR loc.originalItems.recordcount IS 0>
			<cfset loc.itemTotal=loc.itemTotal/100>
			<cfset loc.error="item imbalance #loc.itemTotal#">
			<cfset loc.missing="">
			<cfswitch expression="#args.trnType#">
				<cfcase value="inv|crn" delimiters="|">
					<cfif ArrayLen(loc.itemsFound) IS 0 OR NOT loc.analysisFound>	<!--- no transaction analysis found --->
						<cfif args.accType IS "purch">
							<cfset loc.missing=loc.missing&",PURCH">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="PURCH",
								"niAmount"=loc.netAmount
							})>
						<cfelseif args.trnClientRef GT 0>
							<cfset loc.missing=loc.missing&",NEWS">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="NEWS",
								"niAmount"=loc.netAmount
							})>
						<cfelse>
							<cfset loc.missing=loc.missing&",SALES">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SALES",
								"niAmount"=loc.netAmount
							})>
						</cfif>
					</cfif>
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accNomAcct)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accNomAcct)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.balanceAmount
							})>
						</cfif>
						<cfif NOT ListFind(loc.TranNomCodes,"VAT",",")>
							<cfset loc.missing=loc.missing&",VAT">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="VAT",
								"niAmount"=loc.vatAmount
							})>					
						</cfif>
					</cfif>
				</cfcase>
				<cfcase value="pay|rfd" delimiters="|">
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accNomAcct)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accNomAcct)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.balanceAmount
							})>
						</cfif>
					<cfelse>
						<cfset loc.method="Balance account unknown for #args.trnMethod#">
					</cfif>
					
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accPayAcc)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accPayAcc)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.netAmount
							})>
						</cfif>
					<cfelse>
						<cfswitch expression="#args.trnMethod#">
							<cfcase value="coll">
								<cfif NOT ListFind(loc.TranNomCodes,"COLL")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="COLL",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="cash">
								<cfif NOT ListFind(loc.TranNomCodes,"CASH")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="CASH",
										"niAmount"=loc.netAmount
									})>
								</cfif>					
							</cfcase>
							<cfcase value="card">
								<cfif NOT ListFind(loc.TranNomCodes,"CARD")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="CARD",
										"niAmount"=loc.netAmount
									})>
								</cfif>				
							</cfcase>
							<cfcase value="ib">
								<cfif NOT ListFind(loc.TranNomCodes,"BANK")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="BANK",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="sv|dv" delimiters="|">
								<cfif NOT ListFind(loc.TranNomCodes,"NSV")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="NSV",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="chq|chqs" delimiters="|">
								<cfif NOT ListFind(loc.TranNomCodes,"CHQ")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="CHQ",
										"niAmount"=loc.netAmount
									})>
								</cfif>							
							</cfcase>
							<cfcase value="qchq|qs|qsib|qlost" delimiters="|">
								<cfif NOT ListFind(loc.TranNomCodes,"QS")>
									<cfset ArrayAppend(loc.itemsMissing,{
										"nomCode"="QS",
										"niAmount"=loc.netAmount
									})>
								</cfif>			
							</cfcase>
							<cfdefaultcase>
								<cfset ArrayAppend(loc.itemsMissing,{
									"nomCode"="ORPH",
									"niAmount"=loc.netAmount
								})>								
							</cfdefaultcase>
						</cfswitch>
					</cfif>
					
					<cfif args.accType IS "purch">
						<cfif NOT ListFind(loc.TranNomCodes,"SDCL",",")>
							<cfset loc.missing=loc.missing&",SDCL">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SDCL",
								"niAmount"=loc.vatAmount
							})>					
						</cfif>
					<cfelse>
						<cfif NOT ListFind(loc.TranNomCodes,"SDAL",",")>
							<cfset loc.missing=loc.missing&",SDAL">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SDAL",
								"niAmount"=loc.vatAmount
							})>					
						</cfif>
					</cfif>
				</cfcase>
				<cfcase value="jnl|dbt" delimiters="|">
					<cfif StructKeyExists(this.nomBalanceAccounts,args.accNomAcct)>
						<cfset loc.nomCode=StructFind(this.nomBalanceAccounts,args.accNomAcct)>
						<cfif NOT ListFind(loc.TranNomCodes,loc.nomCode,",")>
							<cfset loc.missing=loc.missing&","&loc.nomCode>	<!--- may need to swap balance/net amount for purchases? --->
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"=loc.nomCode,
								"niAmount"=loc.netAmount
							})>
						</cfif>
						<cfif NOT ListFind(loc.TranNomCodes,"SUSP",",")>
							<cfset loc.missing=loc.missing&",SUSP">
							<cfset ArrayAppend(loc.itemsMissing,{
								"nomCode"="SUSP",
								"niAmount"=loc.balanceAmount
							})>
						</cfif>
					</cfif>
					<!---<cfdump var="#loc#" label="#args.trnID# #args.trnType#" expand="yes">--->
				</cfcase>
			</cfswitch>
		</cfif>
		<cfif StructKeyExists(parms.form,"srchFixData")>
			<cfset loc.queries=[]>
			<cfif ArrayLen(loc.itemsFound)>
				<cfloop array="#loc.itemsFound#" index="loc.rec">
					<cfif loc.rec.niAmount neq 0>
						<cfquery name="loc.QUpdateItem" datasource="#args.datasource#" result="loc.QUpdateItemResult">
							UPDATE tblNomItems
							SET niAmount=#loc.rec.niAmount#
							WHERE niID=#val(loc.rec.niID)#
							LIMIT 1;
						</cfquery>
						<cfset ArrayAppend(loc.queries,loc.QUpdateItemResult)>
					<cfelse>
						<cfset ArrayAppend(loc.empties,loc.rec)>						
					</cfif>
				</cfloop>
			</cfif>
			<cfif ArrayLen(loc.itemsMissing)>
				<cfloop array="#loc.itemsMissing#" index="loc.rec">
					<cfquery name="loc.QInsertItem" datasource="#args.datasource#" result="loc.QInsertItemResult">
						INSERT INTO tblNomItems (
							niAmount,
							niNomID,
							niTranID
						) VALUES (
							#loc.rec.niAmount#,
							#StructFind(this.nomAccounts,loc.rec.nomCode)#,
							#args.trnID#
						)
					</cfquery>
					<cfset ArrayAppend(loc.queries,loc.QInsertItemResult)>
				</cfloop>
			</cfif>
			<!---<cfdump var="#loc#" label="#args.trnID# #args.trnType#" expand="yes">--->
		</cfif>
		<cfset loc.result.tran=args>
		<cfset loc.result.itemsFound=loc.itemsFound>
		<cfset loc.result.itemsMissing=loc.itemsMissing>		
		<cfreturn loc.result>
	</cffunction>		

	<cffunction name="NomTotalReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.totals = {}>
		<cftry>
			<cfquery name="loc.result.QNomTotal" datasource="#args.datasource#" result="loc.result.QNomTotalResult">
				SELECT nomGroup,nomType,nomCode,nomTitle, tblNomTotal.*
				FROM tblNominal,tblNomTotal
				WHERE ntNomID = nomID
				<cfif len(args.form.srchRange)>
					<cfif Left(args.form.srchRange,2) eq 'FY'>
						<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
						<cfset loc.result.prdFrom = LSDateFormat(loc.fyDate.start,"YYMM")>
						<cfset loc.result.prdTo = LSDateFormat(loc.fyDate.end,"YYMM")>
						AND ntPrd >= #loc.result.prdFrom#
						AND ntPrd <= #loc.result.prdTo#				
					</cfif>
				<cfelse>
					<cfif len(args.form.srchDateFrom)>
						<cfset loc.result.prdFrom = LSDateFormat(args.form.srchDateFrom,"YYMM")>
						<cfset loc.result.prdTo = LSDateFormat(args.form.srchDateTo,"YYMM")>
					</cfif>
					AND ntPrd >= #loc.result.prdFrom#
					AND ntPrd <= #loc.result.prdTo#				
				</cfif>
				<cfif len(args.form.srchDept)>AND nomClass = '#args.form.srchDept#'</cfif>
				<cfif len(args.form.srchLedger)>AND nomType = '#args.form.srchLedger#'</cfif>
				<cfif val(args.form.srchNom) gt 0>AND nomID = #val(args.form.srchNom)#</cfif>
				ORDER BY nomGroup,nomCode,ntPrd
			</cfquery>
			<cfset loc.result.rows = {}>
			<cfloop query="loc.result.QNomTotal">
				<cfset grpCode = "#nomGroup#-#nomCode#">
				<cfif NOT StructKeyExists(loc.result.rows,grpCode)>
					<cfset StructInsert(loc.result.rows,grpCode,{
						nomGroup = nomGroup,
						nomType = nomType,
						nomTitle = nomTitle,
						nomBals = {}
					})>
				</cfif>
				<cfset loc.nomLine = StructFind(loc.result.rows,grpCode)>
				<cfif NOT StructKeyExists(loc.nomLine.nomBals,ntPrd)>
					<cfset StructInsert(loc.nomLine.nomBals,ntPrd,ntBal)>
				</cfif>
				<cfif NOT StructKeyExists(loc.result.totals,ntPrd)>
					<cfset StructInsert(loc.result.totals,ntPrd,ntBal)>
				<cfelse>
					<cfset loc.total = StructFind(loc.result.totals,ntPrd)>
					<cfset StructUpdate(loc.result.totals,ntPrd,loc.total + ntBal)>
				</cfif>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>		

	<cffunction name="LoadNewsPayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfquery name="loc.result.QNewsPayments" datasource="#args.datasource#" result="loc.result.qResult">
				SELECT trnID,trnRef,trnDate,trnType,trnMethod,trnDesc,trnClientRef,trnPaidIn,niAmount
				FROM `tblnomitems` 
				INNER JOIN tblTrans ON niTranID=trnID
				WHERE `niNomID` = 871
				<cfif len(args.form.srchRange)>
					<cfif Left(args.form.srchRange,2) eq 'FY'>
						<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
						<cfset loc.result.prdFrom = loc.fyDate.start>
						<cfset loc.result.prdTo = loc.fyDate.end>
						AND trnDate >= '#loc.result.prdFrom#'
						AND trnDate <= '#loc.result.prdTo#'		
					</cfif>
				<cfelseif len(args.form.srchDateFrom)>
					<cfset loc.result.prdFrom = LSDateFormat(args.form.srchDateFrom,"yyyy-mm-dd")>
					<cfset loc.result.prdTo = LSDateFormat(args.form.srchDateTo,"yyyy-mm-dd")>
					AND trnDate >= '#loc.result.prdFrom#'
					AND trnDate <= '#loc.result.prdTo#'			
				</cfif>
				ORDER BY trnDate,trnType
			</cfquery>	

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="LoadNewsPayments" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="GetEPOSItemTotal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.result.QGetEPOSItemTotal" datasource="#args.datasource#" result="loc.result.qResult">
				SELECT eaTitle, SUM(eiNet) AS Net, Sum(eiVAT) AS VAT, Count(*) AS Num
				FROM tblepos_items
				INNER JOIN tblepos_header ON ehID = eiParent
				INNER JOIN tblepos_account ON eaID = eiPayID
				WHERE 1
				<cfif len(args.form.srchRange)>
					<cfif Left(args.form.srchRange,2) eq 'FY'>
						<cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
						<cfset loc.result.prdFrom = loc.fyDate.start>
						<cfset loc.result.prdTo = loc.fyDate.end>
						AND ehTimeStamp <= '#loc.result.prdTo#'		
						AND ehTimeStamp >= '#loc.result.prdFrom#'
					</cfif>
				<cfelseif len(args.form.srchDateFrom)>
					<cfset loc.result.prdFrom = LSDateFormat(args.form.srchDateFrom,"yyyy-mm-dd")>
					<cfset loc.result.prdTo = LSDateFormat(args.form.srchDateTo,"yyyy-mm-dd")>
					AND ehTimeStamp <= '#loc.result.prdTo#'			
					AND ehTimeStamp >= '#loc.result.prdFrom#'
				<cfelse>
					AND 1=2
				</cfif>
				<cfif args.payID neq 0>AND eiPayID = #args.payID#</cfif>
				<cfif StructKeyExists(args,'Type')>AND eiType LIKE '#args.Type#'</cfif>
				GROUP By eaTitle
			</cfquery>	
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="CheckChequeAccounts" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>		

	<cffunction name="EndofYearNominal" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="panel" type="struct" required="yes">
		<cfargument name="periodTo" type="Date" required="yes">
		<cfargument name="nominalID" type="numeric" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
            <cfquery name="loc.result.QNominal" datasource="#args.datasource#">
                SELECT nomID,nomTitle,nomGroup,SUM(niAmount) AS total
                FROM tblnomitems
                INNER JOIN tblNominal ON niNomID = nomID
                INNER JOIN tbltrans ON niTranID = trnID
                WHERE niNomID = #val(nominalID)#
                AND trndate <= '#LSDateFormat(periodTo,"yyyy-mm-dd")#'
                GROUP BY niNomID;
           </cfquery>
           <cfset loc.num = StructCount(panel)>
           <cfset loc.num++>
           <cfset StructInsert(panel,loc.num,{"ID" = nominalID, "title" = loc.result.QNominal.nomTitle,
		   		"group" = loc.result.QNominal.nomGroup, "value" = loc.result.QNominal.total})>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="EndofYearSummary" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.prdTo = "">
        <cfset loc.result.panel = {}>
        
		<cftry>
			<cfif len(args.form.srchRange)>
                <cfif Left(args.form.srchRange,2) eq 'FY'>
                    <cfset loc.fyDate=StructFind(application.site.FYDates,args.form.srchRange)>
                    <cfset loc.result.prdFrom = loc.fyDate.start>
                    <cfset loc.result.prdTo = loc.fyDate.end>
                </cfif>
            <cfelseif len(args.form.srchDateFrom)>
                <cfset loc.result.prdFrom = LSDateFormat(args.form.srchDateFrom,"yyyy-mm-dd")>
                <cfset loc.result.prdTo = LSDateFormat(args.form.srchDateTo,"yyyy-mm-dd")>
            </cfif>
            <cfif len(loc.result.prdTo)>
                <cfquery name="loc.result.QNewsDebtors" datasource="#args.datasource#">
                    SELECT SUM(trnAmnt1 + trnAmnt2) as total
                    FROM tbltrans
                    WHERE trnAccountID = 4 
                    AND trnDate <= '#LSDateFormat(loc.result.prdTo,"yyyy-mm-dd")#'
                </cfquery>
                <cfset StructInsert(loc.result.panel,1,{"ID" = 0,"title" = "News Debtors", "group" = "asset", "value" = loc.result.QNewsDebtors.total})>
                
                <cfquery name="loc.result.QCreditors" datasource="#args.datasource#">
                    SELECT SUM(trnAmnt1 + trnAmnt2) AS total
                    FROM tbltrans
                    WHERE trnLedger = 'purch'
                    AND trnDate <= '#LSDateFormat(loc.result.prdTo,"yyyy-mm-dd")#'
                </cfquery>
                <cfset StructInsert(loc.result.panel,2,{"ID" = 0,"title" = "Trade Creditors", "group" = "liability", "value" = -abs(loc.result.QCreditors.total)})>
               
                <cfset loc.fortnight = DateAdd("d",-15,loc.result.prdTo)>
                <cfquery name="loc.result.QClosingStock" datasource="#args.datasource#">
                    SELECT SUM(trnAmnt1) AS Total
                    FROM tbltrans
                    WHERE trnLedger = 'purch' 
                    AND trnType IN ('inv', 'crn') 
                    AND trnDate BETWEEN '#LSDateFormat(loc.fortnight,"yyyy-mm-dd")#' 
                    	AND '#LSDateFormat(loc.result.prdTo,"yyyy-mm-dd")#'
               </cfquery>
               <cfset StructInsert(loc.result.panel,3,{"ID" = 0,"title" = "Closing Stock", "group" = "asset", "value" = loc.result.QClosingStock.total})>

               <cfloop list="#application.controls.ctlBSIDs#" index="loc.i">
                   <cfset EndofYearNominal(args,loc.result.panel,loc.result.prdTo,loc.i)>
               </cfloop>
            </cfif>
            
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
