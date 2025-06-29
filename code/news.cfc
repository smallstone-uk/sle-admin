<cfcomponent displayname="news" hint="News Management Functions">

	<cffunction name="AgedDebtors" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClients=0>
		<cfset var QTrans=0>
		<cfset var item={}>
		<cfset var QResult="">
		<cfset var method=0>
		<cfset var methodItem={}>
		<cfset var skipZeros=StructKeyExists(args.form,"srchSkipZeros")>
		<cfset var minVal=0>
		<cftry>	
			<cfif StructKeyExists(args.form,"srchDateTo") AND ISDate(args.form.srchDateTo)>
				<cfset result.dateTo = args.form.srchDateTo>
			<cfelse>
				<cfset result.dateTo = Now()>
			</cfif>

			<cfset result.clients=[]>		
			<cfset result.balances=[]>		
			<cfquery name="QClients" datasource="#args.datasource#" result="QResult">
				SELECT cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltAccountType,cltPayType,cltPayMethod,cltChase,cltChaseDate,
					cltDelHouseNumber,cltDelHouseName, stName
				FROM tblClients
				INNER JOIN tblStreets2 ON stID = cltStreetCode
				WHERE true
				<cfif len(StructFind(args.form,"srchType"))>
					<cfif args.form.srchType eq 'notN'>
						AND cltAccountType <> "N"
					<cfelse>
						AND cltAccountType="#args.form.srchType#"
					</cfif>
				</cfif>
				<cfif len(StructFind(args.form,"srchPayType"))>AND cltPayType="#args.form.srchPayType#"</cfif>
				<cfif len(StructFind(args.form,"srchMethod"))>AND cltPayMethod="#args.form.srchMethod#"</cfif>
				<cfif len(StructFind(args.form,"srchName"))>AND (cltName LIKE "%#args.form.srchName#%" 
					OR cltCompanyName LIKE "%#args.form.srchName#%" OR cltDelHouseName LIKE "%#args.form.srchName#%")</cfif>
				<cfif StructKeyExists(args.form,"srchSkipInactive")>AND cltAccountType <> "N"</cfif>
				<cfif len(args.form.srchSort)>
					<cfif args.form.srchSort eq "address">
						ORDER BY cltDelHouseName,cltName
					<cfelse>
						ORDER BY #args.form.srchSort#
					</cfif>
				</cfif>
			</cfquery>
			<cfif val(args.form.srchMin) gt 0><cfset minVal=val(args.form.srchMin)>
				<cfelse><cfset minVal=0></cfif>
			<cfset result.QResult=QResult>
			<cfloop query="QClients">
				<cfset item={}>
				<cfset item.methods={}>
				<cfset item.ref=cltRef>
				<cfif len(cltCompanyName)>
					<cfset item.name=cltCompanyName>
				<cfelse><cfset item.name="#cltTitle# #cltInitial# #cltName#"></cfif>
				<cfset item.type=cltAccountType>
				<cfset item.cltPayType=cltPayType>
				<cfset item.methodKey=cltPayMethod>
				<cfset item.cltChase=cltChase>
				<cfset item.cltChaseDate=cltChaseDate>
				<cfset item.cltDelHouseNumber=cltDelHouseNumber>
				<cfset item.cltDelHouseName=cltDelHouseName>
				<cfset item.stName=stName>
				<cfset item.balance0=0>
				<cfset item.balance1=0>
				<cfset item.balance2=0>
				<cfset item.balance3=0>
				<cfset item.balance4=0>
				<cfset item.date1=DateAdd("d",-28,result.dateTo)>
				<cfset item.allocTotal = -1>
				<cfset item.diff = -1>
				<cfset item.lastMethod = "unknown">
				<cfquery name="QTranAllocBalance" datasource="#args.datasource#">
					SELECT SUM(trnAmnt1+trnAmnt2) AS total
					FROM tblTrans
					WHERE trnClientRef=#val(item.ref)#
					AND trnAlloc != 0
					GROUP BY trnClientRef
				</cfquery>
				<cfif QTranAllocBalance.recordcount gt 0>
					<cfset item.allocTotal = QTranAllocBalance.total>
				</cfif>
				<cfquery name="QTrans" datasource="#args.datasource#">
					SELECT *
					FROM tblTrans
					WHERE trnClientRef=#val(item.ref)#
					<cfif StructKeyExists(args.form,"srchSkipAllocated")>AND trnAlloc=0</cfif>
					<cfif StructKeyExists(args.form,"srchDateFrom") AND IsDate(args.form.srchDateFrom)>AND trnDate >= '#args.form.srchDateFrom#'</cfif>
					<cfif StructKeyExists(args.form,"srchDateTo") AND IsDate(args.form.srchDateTo)>AND trnDate <= '#args.form.srchDateTo#'</cfif>
					ORDER BY trnDate
				</cfquery>

				<!---<cfif QTrans.recordcount gt 0>
					<cfdump var="#QTrans#" label="QTrans #item.ref#" expand="false">
				</cfif>--->

				<cfset item.lags = []>
				<cfloop query="QTrans">
					<cfset item.lag = {trnType = #trnType#, trnDate = #trnDate#, trnAmnt1 = #trnAmnt1#, DIFF=0}>
					<cfset ArrayAppend(item.lags,item.lag)>
					<cfset item.balance0=item.balance0+trnAmnt1>
					<cfif DateCompare(trnDate,DateAdd("d",-28,result.dateTo)) gt 0>
						<cfset item.balance1=item.balance1+trnAmnt1>
					<cfelseif DateCompare(trnDate,DateAdd("d",-56,result.dateTo)) gt 0>
						<cfset item.balance2=item.balance2+trnAmnt1>
					<cfelseif DateCompare(trnDate,DateAdd("d",-84,result.dateTo)) gt 0>
						<cfset item.balance3=item.balance3+trnAmnt1>
					<cfelse>
						<cfset item.balance4=item.balance4+trnAmnt1>
					</cfif>
					<cfif trnType eq "pay">
						<cfset item.lastMethod = trnMethod>					
<!---
						<cfif StructKeyExists(item.methods,trnMethod)>
							<cfset method=StructFind(item.methods,trnMethod)>
							<cfset StructUpdate(item.methods,trnMethod,method+1)>
						<cfelse>
							<cfset StructInsert(item.methods,trnMethod,1)>
						</cfif>
--->
					</cfif>
				</cfloop>
				<!---<cfoutput>#item.lastMethod#<br></cfoutput>--->
				<cfif ArrayLen(item.lags)>
					<cfset item.paymentFound = 0>
					<cfset item.invdate = DateFormat(Now(),'yyyy-mm-dd')>
					<cfset item.paydate = "">
					<cfloop array="#item.lags#" index="item.lagitem">
						<cfif item.lagitem.trnType eq 'inv'>
							<cfset item.invdate = item.lagitem.trnDate>
						<cfelseif Find(item.lagitem.trnType,'pay,jnl',1)>
							<cfset item.paydate = item.lagitem.trnDate>
							<cfif len(item.invdate) AND len(item.paydate)>
								<cfset item.lagitem.diff = DateDiff("d",item.invdate,item.paydate)>
								<cfset item.paydate = "">
								<cfset item.paymentFound = 1>
							</cfif>
						</cfif>
					</cfloop>
					<cfif NOT item.paymentFound>
						<cfset item.paydate = DateFormat(Now(),'yyyy-mm-dd')>
						<cfset item.diff = DateDiff("d",item.invdate,item.paydate)>
					</cfif>
				</cfif>
				<cfif StructKeyExists(args.form,"srchUpdate")>
					<cfquery name="QTrans" datasource="#args.datasource#">
						UPDATE tblClients
						SET cltPayMethod='#item.lastMethod#'
						WHERE cltRef=#cltRef#
					</cfquery>
				</cfif>
				<cfif Round(item.balance0) eq 0 AND skipZeros>
				<cfelseif (item.balance0 gt minVal OR minVal eq 0)>
					<cfset ArrayAppend(result.clients,item)>
					<cfset ArrayAppend(result.balances,"#Numberformat(item.balance0,'000000.00')#_#ArrayLen(result.clients)#")>
				</cfif>

				<!---<cfdump var="#item#" label="item" expand="true">--->
				<!---<cfif currentrow gt 50><cfbreak></cfif>--->
				

			</cfloop>
			<cfset ArraySort(result.balances,"text","desc")>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="myFunction" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QQuery" datasource="#args.datasource#" result="loc.QQueryResult">
				SELECT *
				FROM table
				WHERE ID=#val(id)#
				LIMIT 1;
			</cfquery>
			<cfset loc.result.QQuery = loc.QQuery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>
