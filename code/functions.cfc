<cfcomponent displayname="functions" extends="core">

	<cfset this.roundPubs={}>
	
	<cfset this.charges={}>
	<cfset this.roundTitleCount=0>
	
	<cfscript>
		function decimalRound(numberToRound, numberOfPlaces) {
			// Thanks to the blog of Christian Cantrell for this one
			var bd = CreateObject("java", "java.math.BigDecimal");
			var result = "";
			
			bd.init(arguments.numberToRound);
			bd = bd.setScale(arguments.numberOfPlaces, bd.ROUND_HALF_DOWN);
			result = bd.toString();
			
			if(result EQ 0) result = 0;
		
			return result;
		}
	</cfscript>
	
	<cffunction name="LoadDelCharges" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var QDelivery=0>
		<cfset var rec={}>
		<cfset var fld=0>
		<cftry>
		<cfquery name="QDelivery" datasource="#args.datasource#">
			SELECT *
			FROM tblDelCharges
		</cfquery>
		<cfset application.site.delcharges={}>
		<cfloop query="QDelivery">
			<cfset rec={}>
			<cfloop list="#QDelivery.columnlist#" index="fld">
				<cfset "rec.#fld#"=QDelivery[fld][currentrow]>
			</cfloop>
			<cfif NOT StructKeyExists(application.site.delcharges,delCode)>
				<cfset StructInsert(application.site.delcharges,delCode,rec)>
			</cfif>
		</cfloop>
		<cfcatch type="any">
			<!---IGNORE ERROR FOR NOW--->
		</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction name="LoadControls" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfquery name="loc.control" datasource="#args.datasource#">
				SELECT *
				FROM tblControl
				WHERE ctlID = 1
			</cfquery>
			
			<cfloop query="loc.control">
				<cfset loc.result.ID = ctlID>
				<cfset loc.result.NextInvNo = ctlNextInvNo>
				<cfset loc.result.FYEnd = ctlFYEnd>
				<cfset loc.result.tradeStart=ctlTradeStart>
				<cfset loc.result.NextInvDate = ctlNextInvDate>
				<cfset loc.result.FirstBillDate = ctlFirstBillDate>
				<cfset loc.result.InvInterval = ctlInvInterval>
				<cfset loc.result.Employer = ctlEmployer>
				<cfset loc.result.EmployerRef = ctlEmployerRef>
				<cfset loc.result.PayDayNo = ctlPayDayNo>
				<cfset loc.result.WeekNoStartDate = ctlWeekNoStartDate>
				<cfset loc.result.ctlInvMessage = ctlInvMessage>
			</cfloop>

			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">			
			</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadSite" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfquery name="loc.site" datasource="#args.datasource0#">
				SELECT *
				FROM cmssites
				WHERE scID = 143
			</cfquery>
			<cfset loc.result=QueryToStruct(loc.site)>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">			
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadSiteClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cftry>
			<cfquery name="loc.siteClient" datasource="#args.datasource0#">
				SELECT *
				FROM cmsclients
				WHERE cltSiteID = 143
			</cfquery>
			<cfset loc.result=QueryToStruct(loc.siteClient)>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">			
		</cfcatch>
		</cftry>
		
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadInvoiceData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QControl="">
		
		<cfquery name="QControl" datasource="#args.datasource#">
			SELECT *
			FROM tblControl
			WHERE ctlID=1
			LIMIT 1;
		</cfquery>
		<cfset result.InvNo=QControl.ctlNextInvNo>
		<cfset result.InvDate=QControl.ctlNextInvDate>
		<cfset result.InvInterval=QControl.ctlInvInterval>
		<cfset result.ctlInvMessage=QControl.ctlInvMessage>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadDeliveryCharges" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var QDelivery="">
		
		<cfquery name="QDelivery" datasource="#args.datasource#">
			SELECT *
			FROM tblDelCharges
		</cfquery>
		<cfloop query="QDelivery">
			<cfset item={}>
			<cfset item.ID=delID>
			<cfset item.Code=delCode>
			<cfset item.Price1=delPrice1>
			<cfset item.Price2=delPrice2>
			<cfset item.Price3=delPrice3>
			<cfset item.Type=delType>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="ClientSearch" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parms={}>
		<cfset var i="">
		<cfset var QCustomers="">
		<cfset var count=0>
		<cfset var comma="">
		
		<cfset parms.srchRefFrom=0>
		<cfset parms.srchRefTo=0>
		<cfset parms.name="">
		<cfset parms.addr="">
		<cfset parms.type="">
		<cfset parms.types="">
		<cfset parms.srchLastDel="">
		<cfset result.records=0>
		<cfif StructKeyExists(args.search,"srchRefFrom") AND args.search.srchRefFrom gt 0>
			<cfset parms.srchRefFrom=args.search.srchRefFrom>
		</cfif>
		<cfif StructKeyExists(args.search,"srchRefTo") AND args.search.srchRefTo gt 0>
			<cfset parms.srchRefTo=args.search.srchRefTo>
		</cfif>
		<cfif StructKeyExists(args.search,"srchName") AND len(args.search.srchName)>
			<cfset parms.name=args.search.srchName>
		</cfif>
		<cfif StructKeyExists(args.search,"srchAddr") AND len(args.search.srchAddr)>
			<cfset parms.addr=args.search.srchAddr>
		</cfif>
		<cfif StructKeyExists(args.search,"srchType") AND len(args.search.srchType)>
			<cfset parms.type=args.search.srchType>
			<cfloop list='#parms.type#' delimiters=',' index='i'><cfset count=count+1><cfif count neq 1><cfset comma=","></cfif><cfset parms.types=parms.types&"#comma#'#i#'"></cfloop>
		</cfif>
		<cfif StructKeyExists(args.search,"srchLastDel") AND len(args.search.srchLastDel)>
			<cfset parms.srchLastDel=args.search.srchLastDel>
		</cfif>
		<cfset parms.sql="SELECT * FROM tblClients,tblStreets2 WHERE 1=1 AND cltStreetCode=stID ">
		<cfif parms.srchRefFrom gt 0><cfset parms.sql="#parms.sql#AND cltRef>=#parms.srchRefFrom# "></cfif>
		<cfif parms.srchRefTo gt 0><cfset parms.sql="#parms.sql#AND cltRef<=#parms.srchRefTo# "></cfif>
		<cfif parms.name gt 0><cfset parms.sql="#parms.sql#AND (cltName LIKE '%#parms.name#%' OR cltCompanyName LIKE '%#parms.name#%') "></cfif>
		<cfif parms.addr gt 0><cfset parms.sql="#parms.sql#AND (cltDelHouseName LIKE '%#parms.addr#%' OR cltDelHouseNumber LIKE '%#parms.addr#%' OR cltAddr1 LIKE '%#parms.addr#%' OR cltAddr2 LIKE '%#parms.addr#%' OR stName LIKE '%#parms.addr#%') "></cfif>
		<cfif parms.type gt 0><cfset parms.sql="#parms.sql#AND cltAccountType IN (#parms.types#) "></cfif>
		<cfif parms.srchLastDel gt 0><cfset parms.sql="#parms.sql#AND cltLastDel>='#parms.srchLastDel#' "></cfif>
		<cfset parms.sql="#parms.sql# ORDER BY #args.search.srchSort#">
		<cfif val(args.search.limitRecs) gt 0><cfset parms.sql="#parms.sql# LIMIT 0,#args.search.limitRecs#; "></cfif>
		<cftry>
			<cfquery name="QCustomers" datasource="#args.datasource#" result="result.QCustomersResult">
				#PreserveSingleQuotes(parms.sql)#
			</cfquery>
			<cfset result.sql=parms.sql>
			<cfset result.rowMax=QCustomers.recordcount>
			<cfset result.records=QCustomers>
		<cfcatch type="any">
			<cfset result.err=cfcatch>
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=args>
		<cfset var QClient="">
		<cfset result.srchDelDate="recent">
		<cfif NOT StructKeyExists(args,"clientRef")>
			<cfif StructKeyExists(args,"direction")>
				<cfif args.direction eq "next">
					<cfif result.row lt args.rowMax-1><cfset result.row++></cfif>
				<cfelseif args.direction eq "prev">
					<cfif result.row gt 0><cfset result.row--></cfif>
				<cfelseif args.direction eq "first">
					<cfset result.row=0>
				<cfelseif args.direction eq "last">
					<cfset result.row=args.rowMax-1>
				</cfif>
			</cfif>
			<cfquery name="QClient" datasource="#args.datasource#">
				#PreserveSingleQuotes(args.sql)#
				LIMIT #result.row#,1;
			</cfquery>
			<cfloop list="#QClient.columnlist#" index="fld">
				<cfset "result.rec.#fld#"=QClient[fld]>
			</cfloop>
			<cfset result.row=args.row>
		<cfelse>
			<cfquery name="QClient" datasource="#args.datasource#">
				SELECT *
				FROM tblClients
				WHERE cltRef='#args.clientRef#'
			</cfquery>
			<cfloop list="#QClient.columnlist#" index="fld">
				<cfset "result.rec.#fld#"=QClient[fld]>
			</cfloop>
			<cfset result.row=0>
		</cfif>	
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientByID" access="public" returntype="any">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClient="">

		<cfquery name="QClient" datasource="#args.datasource#">
			SELECT *
			FROM tblClients
			WHERE cltID=#args.clientID#
		</cfquery>
		<cfset result=QueryToArrayOfStruct(QClient)>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientByRef" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClient="">

		<cfquery name="QClient" datasource="#args.datasource#">
			SELECT *
			FROM tblClients
			WHERE cltRef=#args.clientRef#
		</cfquery>
		<cfset result.ID=QClient.cltID>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateClientChase" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var actParms={}>
		<cfset var msgParms={}>
		<cfset var QClient="">

		<cftry>
			<cfquery name="QClient" datasource="#args.datasource#">
				UPDATE tblClients
				SET cltChaseDate='#LSDateFormat(args.Date,"yyyy-mm-dd")#',
					<cfif args.level is 4>cltAccountType='N',</cfif>
					cltChase=#val(args.level)#
				WHERE cltID=#args.clientID#
			</cfquery>
			
			<cfset actParms={}>
			<cfset actParms.datasource=args.datasource>
			<cfset actParms.type="client">
			<cfset actParms.class="updated">
			<cfset actParms.clientID=args.clientID>
			<cfset actParms.pubID=0>
			<cfif args.level is 4>
				<cfset actParms.Text=args.text&" letter was sent. Account now closed.">
			<cfelseif args.level is 3>
				<cfset actParms.Text=args.text&" letter was sent. <b>Stop all deliveries from #LSDateFormat(DateAdd("d",7,args.Date),"DD/MM/YYYY")# if no payment is received.</b>">
			<cfelse>
				<cfset actParms.Text=args.text&" letter was sent.">
			</cfif>
			<cfset actInsert=AddActivity(actParms)>
			
			<cfset msgParms={}>
			<cfset msgParms.datasource=args.datasource>
			<cfset msgParms.form.notClientID=args.clientID>
			<cfset msgParms.form.notType="letter">
			<cfset msgParms.form.notText=actParms.Text>
			<cfset msgParms.form.notStatus="open">
			<cfset msgParms.form.notImportant=1>
			<cfset savemsg=AddMsg(msgParms)>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadLetter" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QLetter="">

		<cfquery name="QLetter" datasource="#args.datasource#">
			SELECT * 
			FROM tblLetters
			WHERE letID=#args.ID#
		</cfquery>
		
		<cfset result.ID=QLetter.letID>
		<cfset result.Level=QLetter.letLevel>
		<cfset result.Title=QLetter.letTitle>
		<cfset result.Text=QLetter.letText>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadLetters" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QLetters="">

		<cfquery name="QLetters" datasource="#args.datasource#">
			SELECT * 
			FROM tblLetters
			ORDER BY letLevel
		</cfquery>
		<cfloop query="QLetters">
			<cfset item={}>
			<cfset item.ID=letID>
			<cfset item.Title=letTitle>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">
		
		<cftry>
			<cfquery name="QUpdate" datasource="#args.datasource#">
				UPDATE tblClients
				SET <cfif len(cltStreetCode)>cltStreetCode=#args.form.cltStreetCode#,<cfelse>cltStreetCode=0,</cfif>
					cltTitle='#args.form.cltTitle#',
					cltInitial='#args.form.cltInitial#',
					cltName='#args.form.cltName#',
					cltDept='#args.form.cltDept#',
					cltCompanyName='#args.form.cltCompanyName#',
					cltDelHouse='#args.form.cltDelHouse#',
					cltDelHouseName='#args.form.cltDelHouseName#',
					cltDelHouseNumber='#args.form.cltDelHouseNumber#',
					cltDelTown='#args.form.cltDelTown#',
					cltDelCity='#args.form.cltDelCity#',
					cltDelPostcode='#args.form.cltDelPostcode#',
					cltDelTel='#args.form.cltDelTel#',
					cltMobile='#args.form.cltMobile#',
					cltEMail='#args.form.cltEMail#',
					cltAddr1='#args.form.cltAddr1#',
					cltAddr2='#args.form.cltAddr2#',
					cltTown='#args.form.cltTown#',
					cltCity='#args.form.cltCity#',
					cltCounty='#args.form.cltCounty#',
					cltPostCode='#args.form.cltPostCode#',
					cltKey='#args.form.cltKey#',
					cltAccountType='#args.form.cltAccountType#',
					cltPaymentType='#args.form.cltPaymentType#',
					cltPayMethod='#args.form.cltPayMethod#',
					cltPayType='#args.form.cltPayType#',
					cltInvoiceType='#args.form.cltInvoiceType#',
					cltInvDeliver='#args.form.cltInvDeliver#',
					cltDefaultHoliday='#args.form.cltDefaultHoliday#',
					cltKey='#args.form.cltKey#',
					cltDelCode=#args.form.cltDelCode#
				WHERE cltID=#args.form.cltID#
			</cfquery>
			<cfset result.msg="Customer detail has been updated">
			<cfset result.ref=args.form.cltRef>
			<cfset result.stage=2>
			
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="client">
			<cfset actParms.class="updated">
			<cfset actParms.clientID=args.form.cltID>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddClient" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAdd="">
		<cfset var QClientRef="">
		<cfset var result.error="">
		
		<cftry>
			<cfif NOT len(args.form.cltName) AND NOT len(args.form.cltCompanyName)>
				<cfset result.error=result.error&"Please enter a Customer/Company Name<br>">
			</cfif>
			<cfif NOT len(args.form.cltAccountType)>
				<cfset result.error=result.error&"Please select an Account Type<br>">
			</cfif>
			
			<cfif NOT len(result.error)>
				<cfquery name="QAdd" datasource="#args.datasource#" result="NewClient">
					INSERT INTO tblClients (
						cltEntered,
						cltRef,
						cltStreetCode,
						cltTitle,
						cltInitial,
						cltName,
						cltDept,
						cltCompanyName,
						cltDelHouseName,
						cltDelHouseNumber,
						cltDelTown,
						cltDelCity,
						cltDelPostcode,
						cltDelTel,
						cltMobile,
						cltEMail,
						cltAddr1,
						cltAddr2,
						cltTown,
						cltCity,
						cltCounty,
						cltPostCode,
						cltAccountType,
						cltPaymentType,
						cltPayMethod,
						cltPayType,
						cltInvoiceType,
						cltInvDeliver,
						cltDelCode
					) VALUES (
						#Now()#,
						#val(args.form.cltRef)#,
						#args.form.cltStreetCode#,
						'#args.form.cltTitle#',
						'#args.form.cltInitial#',
						'#args.form.cltName#',
						'#args.form.cltDept#',
						'#args.form.cltCompanyName#',
						'#args.form.cltDelHouseName#',
						'#args.form.cltDelHouseNumber#',
						'#args.form.cltDelTown#',
						'#args.form.cltDelCity#',
						'#args.form.cltDelPostcode#',
						'#args.form.cltDelTel#',
						'#args.form.cltMobile#',
						'#args.form.cltEMail#',
						'#args.form.cltAddr1#',
						'#args.form.cltAddr2#',
						'#args.form.cltTown#',
						'#args.form.cltCity#',
						'#args.form.cltCounty#',
						'#args.form.cltPostCode#',
						'#args.form.cltAccountType#',
						'#args.form.cltPaymentType#',
						'#args.form.cltPayMethod#',
						'#args.form.cltPayType#',
						'#args.form.cltInvoiceType#',
						'#args.form.cltInvDeliver#',
						#val(args.form.cltDelCode)#
					)
				</cfquery>
				<cfset result.msg="Customer has been added">
				<cfset result.ID=NewClient.generatedKey>
				<cfset result.ref=args.form.cltRef>
			</cfif>
			
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="client">
			<cfset actParms.class="added">
			<cfset actParms.clientID=NewClient.generatedKey>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
			
			<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadStreets" access="public" returntype="any">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var QStreets="">
		<cfset var item={}>
		
		<cfquery name="QStreets" datasource="#args.datasource#">
			SELECT *
			FROM tblStreets2
			<cfif StructKeyExists(args,"streetcode")>WHERE stID=#args.streetcode#</cfif>
		</cfquery>
		<cfif QStreets.recordcount is 1>
			<cfset result=QStreets.stName>
		<cfelse>
			<cfloop query="QStreets">
				<cfset item={}>
				<cfset item.ID=stID>
				<cfset item.Name=stName>
				<cfset ArrayAppend(result,item)>
			</cfloop>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadLastClientRef" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClientRef="">
		
		<cfquery name="QClientRef" datasource="#args.datasource#">
			SELECT * 
			FROM tblClients 
			WHERE cltRef < 5000
			ORDER BY cltRef desc
			LIMIT 1;
		</cfquery>
		<cfset result.ref=QClientRef.cltRef>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientTrans" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var tran={}>
		
		<cfquery name="QTrans" datasource="#args.datasource#">
			SELECT *
			FROM tblTrans
			WHERE trnClientRef=#val(args.rec.cltRef)#
			ORDER BY trnDate
		</cfquery>
		<cfset result.trans=[]>
		<cfset result.balance=0>
		<cfloop query="QTrans">
			<cfset tran={}>
			<cfset tran.ID=trnID>
			<cfset tran.ref=trnRef>
			<cfset tran.date=DateFormat(trnDate,"dd-mmm-yyyy")>
			<cfset tran.type=trnType>
			<cfset tran.method=trnMethod>
			<cfset tran.amnt1=trnAmnt1>
			<cfset tran.amnt2=trnAmnt2>
			<cfset tran.alloc=trnAlloc>
			<cfif tran.type eq "pay"><cfset tran.paidin=trnPaidIn><cfelse><cfset tran.paidin=""></cfif>
			<cfset ArrayAppend(result.trans,tran)>
			<cfset result.balance=result.balance+trnAmnt1+trnAmnt2>
		</cfloop>
		<cfset result.QTrans=QTrans>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadClientMsgs" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QMsgs=0>
		
		<cfquery name="QMsgs" datasource="#args.datasource#">
			SELECT *, tblClients.cltRef,tblClients.cltName,tblClients.cltCompanyName,tblClients.cltDelTel
			FROM tblNotification, tblClients
			WHERE notClientID=cltID
			<cfif args.rec.cltID gt 0>AND notClientID=#val(args.rec.cltID)#</cfif>
			AND (notStatus<>'archived')
			ORDER BY notEntered DESC
		</cfquery>
		
		<cfset result.QMsgs=QMsgs>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddMsg" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QMsg=0>
		<cfset var QResult=0>
		
		<cfquery name="QMsg" datasource="#args.datasource#" result="QResult">
			INSERT INTO tblNotification (
				notClientID, 
				notEntered, 
				notType, 
				notText, 
				notUrgent,
				notImportant,
				notStatus
			) VALUES (
				#args.form.notClientID#,
				Now(),
				'#args.form.notType#',
				'#args.form.notText#',
				<cfif StructKeyExists(args.form,"notUrgent")>1<cfelse>0</cfif>,
				<cfif StructKeyExists(args.form,"notImportant")>#val(args.form.notImportant)#<cfelse>0</cfif>,
				'#args.form.notStatus#'
			)
		</cfquery>
		<cfset result.msg="Message has been added">
		<cfreturn result>
	</cffunction>
	

	<cffunction name="GetRoundData" access="public" returntype="array">
		<cfreturn this.roundPubs>
	</cffunction>

	<cffunction name="LoadRoundList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRounds="">
		
		<cfquery name="QRounds" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndActive
			<cfif len(args.roundType)>AND rndType='#(args.roundType)#'</cfif>
		</cfquery>
		<cfset result.rounds=[]>
		<cfloop query="QRounds">
			<cfset ArrayAppend(result.rounds,{"rndRef"=#rndRef#, "rndTitle"=#rndTitle#})>
		</cfloop>
		<cfset result.qrounds=QRounds>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadRoundDataForWeek" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound=0>
		<cfset var QRoundItems=0>
		<cfset var rec={}>
		<cfif application.site.showdumps><cfdump var="#args#" label="LoadRoundDataForWeek" expand="no"></cfif>
		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndRef=#val(args.roundNo)#
		</cfquery>
		<cfif QRound.recordcount eq 1>
			<cfset result.roundNo=args.roundNo>
			<cfset result.roundName=QRound.rndTitle>
			<cfset result.pubs={}>
			<cfset result.orders=[]>
			<cfquery name="QRoundItems" datasource="#args.datasource#">
				SELECT tblRoundItems.*, cltID,cltRef,cltName,cltDelHouse,cltDelAddr,cltDelCode,cltStreetCode,cltDelPostcode,stName
				FROM tblRoundItems,tblClients, tblStreets
				WHERE riRoundRef=#QRound.rndRef#
				AND stRef=cltStreetCode
				AND cltID=riClientID
				AND cltAccountType<>"N"
				ORDER BY riOrder
			</cfquery>
			<cfif application.site.showdumps><cfdump var="#QRoundItems#" label="QRoundItems" expand="false"></cfif>
			<cfloop query="QRoundItems">
				<cfset data={}>
				<cfset data.cltRef=cltRef>
				<cfset data.cltName=cltName>
				<cfset data.cltDelHouse=cltDelHouse>
				<cfset data.cltDelAddr=cltDelAddr>
				<cfset data.stName=stName>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=cltID>
				<cfset data.cltDelCode=cltDelCode>
				<cfset data.order=processOrder(data)>
				<cfset ArrayAppend(result.orders,data)>
			</cfloop>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadRoundData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRound=0>
		<cfset var QRoundItems=0>
		<cfset var streetCode=-1>
		<cfset var street={}>
		<cfset var consig=[]>
		<cfif application.site.showdumps><cfdump var="#args#" label="LoadRoundData" expand="no"></cfif>
		<cfquery name="QRound" datasource="#args.datasource#">
			SELECT *
			FROM tblRounds
			WHERE rndRef=#val(args.roundNo)#
		</cfquery>
		<cfif QRound.recordcount eq 1>
			<cfset result.roundNo=args.roundNo>
			<cfset result.roundName=QRound.rndTitle>
			<!---<cfset result.dayNo=args.dayNo>--->

			<cfset result.pubs={}>
			<cfset this.roundPubs={}>
			<cfset this.charges={}>
			<cfset this.roundTitleCount=0>
			<cfquery name="QRoundItems" datasource="#args.datasource#">
				SELECT tblRoundItems.*, cltID,cltRef,cltName,cltDelHouse,cltDelAddr,cltDelCode,cltStreetCode,cltDelPostcode,stName,stRef
				FROM tblRoundItems,tblClients, tblStreets
				WHERE riRoundID=#QRound.rndID#
				AND stRef=cltStreetCode
				AND cltID=riClientID
				AND cltAccountType<>"N"
				ORDER BY riOrder
				<!---LIMIT 0,20;--->
			</cfquery>
			<cfset result.streets=[]>
			<cfset result.dropCount=0>
			<cfloop query="QRoundItems">
				<cfif cltStreetCode neq streetCode>
					<cfif StructKeyExists(street,"houses")>
						<cfset street.drops=ArrayLen(street.houses)>
						<cfset result.dropCount=result.dropCount+street.drops>
						<cfset ArrayAppend(result.streets,street)>
					</cfif>
					<cfset street={}>
					<cfset street.ID=stRef>
					<cfset street.name=stName>
					<cfset street.houses=[]>
					<cfset streetCode=cltStreetCode>
				</cfif>
				<cfset args.clientID=cltID>
				<cfset args.delCode=cltDelCode>
				<cfset consig=LoadDrops(args)>
				<cfif ArrayLen(consig) gt 0>
					<cfset House=ReReplace(cltDelHouse, '[^0-9A-Za-z ]', '', 'all')>
					<cfset ArrayAppend(street.houses,{
						"Account"=cltRef,
						"StreetCode"=cltStreetCode,
						"HouseID"=cltID,
						"House"=House,
						"Order"=riOrder,
						"ID"=riID,
						"Cons"=consig
					})>
				</cfif>
			</cfloop>
			<cfif StructKeyExists(street,"houses")>
				<cfset street.drops=ArrayLen(street.houses)>
				<cfset result.dropCount=result.dropCount+street.drops>
				<cfset ArrayAppend(result.streets,street)>
			</cfif>
		</cfif>
		<cfset result.pubs=this.roundPubs>
		<cfset result.charges=this.charges>
		<cfset result.roundTitleCount=this.roundTitleCount>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientAddress" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAddress="">
							<!--- untidy! --->
			<cfquery name="QAddress" datasource="#args.datasource#">
				SELECT *
				FROM tblClients, tblStreets
				WHERE cltID=#args.clientID#
				AND stRef=cltStreetCode
			</cfquery>
			<cfset House=ReReplace(QAddress.cltDelHouse, '[^0-9A-Za-z ]', '', 'all')>
			<cfset Address=ReReplace(QAddress.cltDelAddr, '[^0-9A-Za-z ]', '', 'all')>
			<cfif len(QAddress.cltDelPostcode)>
				<cfset Postcode=", #ReReplace(QAddress.cltDelPostcode, '[^0-9A-Za-z ]', '', 'all')#">
			<cfelse>
				<cfset Postcode="">
			</cfif>
			<cfset string="#House# #Address##Postcode#">
			<cfset findinfo=Find(string,"truro")>
			<cfif findinfo>
				<cfset result="#House# #Address##Postcode#">
			<cfelse>
				<cfset result="#House# #Address#, Truro#Postcode#">
			</cfif>
			
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SaveDropOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdateRoundItems="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"riID")>
				<cfloop list="#args.form.riID#" index="i" delimiters=",">
					<cfif StructKeyExists(args.form, i)>
						<cfset ID=ListLast(i,"_")>
						<cfset Order=StructFind(args.form, i)>
						<cfquery name="QUpdateRoundItems" datasource="#args.datasource#">
							UPDATE tblRoundItems
							SET riOrder=#Order#
							WHERE riID=#ID#
						</cfquery>
					</cfif>
				</cfloop>
				<cfset result.msg="Order Updated">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="GetCharge" access="private" returntype="numeric" hint="returns the rate to charge for a specific day">
		<cfargument name="delItem" type="numeric" required="yes">
		<cfargument name="dayNo" type="numeric" required="yes">
		<cfset var rate=-0.01>
		<cfset var delRec=StructFind(application.site.delCharges,delItem)>
		<cfif delRec.delType neq "Per Week">
			<cfif dayNo eq 7 AND delRec.delPrice3 gt 0>
				<cfset rate=delRec.delPrice3>
			<cfelseif dayNo eq 6 AND delRec.delPrice2 gt 0>
				<cfset rate=delRec.delPrice2>
			<cfelse>
				<cfset rate=delRec.delPrice1>
			</cfif>
		</cfif>
		<cfreturn rate>
	</cffunction>

	<cffunction name="LoadDrops" access="private" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var QOrders="">
		<cfset var QHolidayOrder="">
		<cfset var item={}>
		<cfset var pub=0>
		<cfset var itemsAdded=0>
		<cfset var holidays={}>
		
		<cfquery name="QOrders" datasource="#args.datasource#">
			SELECT *
			FROM tblOrder, tblOrderItem, tblPublication
			WHERE ordClientID=#val(args.clientID)#
			AND oiOrderID=ordID
			AND oiPubID=pubID
			AND pubActive
			ORDER BY pubTitle
		</cfquery>
		<cfif StructKeyExists(args,"roundDate")>
			<cfquery name="QHolidayOrder" datasource="#args.datasource#">
				SELECT *
				FROM tblHolidayOrder,tblHolidayItem
				WHERE hoOrderID=#val(QOrders.ordID)#
				AND hiHolidayID=hoID
				AND hoStop<='#args.roundDate#'
				AND hoStart>='#args.roundDate#'
			</cfquery>
			<cfif QHolidayOrder.recordcount gt 0>
				<cfloop query="QHolidayOrder">
					<cfset StructInsert(holidays,hiOrderItemID,hiAction)>
				</cfloop>
			</cfif>
		</cfif>
		<cfif args.dayNo gt 0>
			<cfloop query="QOrders">
				<cfset item={}>
				<cfset item.ID=pubID>
				<cfset item.ref=pubRef>
				<cfset item.title=pubTitle>
				<cfset item.delcode=args.delCode>
				<cfset item.qty=0>
				<cfset item.price=0>
				<cfset item.delchg=0>
				<cfif StructKeyExists(holidays,oiID)>
					<cfset item.action=StructFind(holidays,oiID)>
				<cfelse><cfset item.action='deliver'></cfif>
				<cfif item.action NEQ 'cancel'>
					<cfswitch expression="#args.dayNo#">
						<cfcase value="1">	<!--- monday --->
							<cfif oiMon neq 0>
								<cfset item.qty=oiMon>
								<cfset item.price=pubPrice1>
							</cfif>
						</cfcase>
						<cfcase value="2">
							<cfif oiTue neq 0>
								<cfset item.qty=oiTue>
								<cfset item.price=pubPrice2>
							</cfif>
						</cfcase>
						<cfcase value="3">
							<cfif oiWed neq 0>
								<cfset item.qty=oiWed>
								<cfset item.price=pubPrice3>
							</cfif>
						</cfcase>
						<cfcase value="4">
							<cfif oiThu neq 0>
								<cfset item.qty=oiThu>
								<cfset item.price=pubPrice4>
							</cfif>
						</cfcase>
						<cfcase value="5">
							<cfif oiFri neq 0>
								<cfset item.qty=oiFri>
								<cfset item.price=pubPrice5>
							</cfif>
						</cfcase>
						<cfcase value="6">
							<cfif oiSat neq 0>
								<cfset item.qty=oiSat>
								<cfset item.price=pubPrice6>
							</cfif>
						</cfcase>
						<cfcase value="7">	<!--- sunday --->
							<cfif oiSun neq 0>
								<cfset item.qty=oiSun>
								<cfset item.price=pubPrice7>
							</cfif>
						</cfcase>
					</cfswitch>
				</cfif>
				<!---<cfif item.qty neq 0>--->
					<cfset itemsAdded++>
					<cfset item.value=item.qty*item.price>
					<cfset item.trade=item.value*(1-pubDiscount)>
					<cfif NOT StructKeyExists(this.roundPubs,pubTitle)>
						<cfset StructInsert(this.roundPubs,pubTitle,{"qty"=item.qty,"retail"=item.price,"value"=item.value,"trade"=item.trade})>
					<cfelse>
						<cfset pub=StructFind(this.roundPubs,pubTitle)>
						<cfset pub.qty=pub.qty+item.qty>
						<cfset pub.value=pub.value+item.value>
						<cfset pub.trade=pub.trade+item.trade>
						<cfset StructUpdate(this.roundPubs,pubTitle,pub)>
					</cfif>
					<cfset this.roundTitleCount=this.roundTitleCount+item.qty>
					<cfif itemsAdded is 1>
						<cfset item.delchg=GetCharge(args.delCode,args.dayNo)>
						<cfif NOT StructKeyExists(this.charges,args.delCode)>
							<cfset StructInsert(this.charges,args.delCode,{"code"=args.delCode,"rate"=item.delchg,"count"=1,"charge"=item.delchg})>
							<cfset pub=StructFind(this.charges,args.delCode)>
						<cfelse>
							<cfset pub=StructFind(this.charges,args.delCode)>
							<cfset pub.count++>
							<cfset pub.charge=pub.charge+item.delchg>
							<cfset StructUpdate(this.charges,args.delCode,pub)>
						</cfif>
					</cfif>
					<cfset ArrayAppend(result,item)>
				<!---</cfif>--->
			</cfloop>
			<cfif args.chargeAccts>
				<cfset ChargeAccount(args,result)>
			</cfif>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="ChargeAccount" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="items" type="array" required="yes">
		<cfset var result={}>
		<cfset var pub="">
		<cfset var QExists="">
		<cfset var QBatch="">
		<cfset var QResult="">
		<cfset var batchID=0>
		<cfset var QQuery="">
		<cfquery name="QBatch" datasource="#args.datasource#">
			SELECT *
			FROM tblDelBatch
			WHERE dbRef='#args.roundDate#'
			AND dbRound=#args.roundNo#
			LIMIT 1;
		</cfquery>
		<cfif QBatch.recordcount eq 0>
			<cfquery name="QBatch" datasource="#args.datasource#" result="QResult">
				INSERT INTO tblDelBatch (
				dbRef,dbRound) VALUES ('#args.roundDate#',#args.roundNo#)
			</cfquery>
			<cfset batchID=QResult.generatedKey>
		<cfelse><cfset batchID=QBatch.dbID></cfif>
		
		<cfloop array="#items#" index="pub">
			<cfquery name="QExists" datasource="#args.datasource#">
				SELECT diBatchID
				FROM tblDelItems
				WHERE diClientID=#val(args.clientID)#
				AND diBatchID=#batchID#
				AND diPubID=#pub.ID#
				LIMIT 1;
			</cfquery>
			<cfif QExists.recordcount eq 0>
				<!--- Add Delivery Item--->
				<cfquery name="QQuery" datasource="#args.datasource#">
					INSERT INTO tblDelItems (
						diClientID,
						diBatchID,
						diPubID,
						diDate,
						diQty,
						diPrice,
						diCharge
					) VALUES (
						#val(args.clientID)#,
						#batchID#,
						#pub.ID#,
						'#args.roundDate#',
						#pub.qty#,
						#pub.price#,
						#pub.delchg#
					)
				</cfquery>
			<cfelse>
				<!--- Update Delivery Item --->
				<cfquery name="QQuery" datasource="#args.datasource#">
					UPDATE tblDelItems
					SET
						diQty=#pub.qty#,
						diPrice=#pub.price#,
						diCharge=#pub.delchg#
					WHERE diClientID=#val(args.clientID)#
					AND diBatchID=#batchID#
					AND diPubID=#pub.ID#
				</cfquery>
			</cfif>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPubPrice" access="public" returntype="numeric">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=0>
		<cfset var QPub="">
		<cfset var QStockCheck="">
		<cfset var thisDay="">
		
		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT pubPrice,pubPWPrice
			FROM tblPublication
			WHERE pubID=#args.pubID#
		</cfquery>
		<cfquery name="QStockCheck" datasource="#args.datasource#">
			SELECT psRetail,psPWRetail
			FROM tblPubStock
			WHERE psPubID=#args.pubID#
			AND psType='received'
			AND psDate='#LSDateFormat(args.date,'yyyy-mm-dd')#'
			LIMIT 1;
		</cfquery>
					
		<cfif QStockCheck.recordcount is 1>
			<cfset result=QStockCheck.psRetail+QStockCheck.psPWRetail>
		<cfelse>
			<cfset result=QPub.pubPrice+QPub.pubPWPrice>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddManualCharge" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var parm={}>
		<cfset var QPub="">
		<cfset var QAddDelItem="">
		<cfset var QLoadPubStock="">
		<cfset var QCheckVouchers="">
		<cfset var QCheckRound="">
		<cfset var QCheckBatch="">
		<cfset var QCreateBatch="">
		<cfset var QNewBatch="">
		<cfset var QCheckCharge="">
		<cfset var BatchID=0>
		<cfset var charge=0>
		<cfset var price=0>
		<cfset var voucher=0>
		
		<cftry>
			<cfquery name="QCheckRound" datasource="#args.datasource#">
				SELECT *
				FROM tblRoundItems
				WHERE riDay='#LSDateFormat(args.form.datefrom,'ddd')#'
				AND riOrderID=#args.form.orderID#
			</cfquery>
			<cfquery name="QCheckBatch" datasource="#args.datasource#">
				SELECT dbID
				FROM tblDelBatch
				WHERE dbRef='#LSDateFormat(args.form.datefrom,'yyyy-mm-dd')#'
				AND dbRound=#val(QCheckRound.riRoundID)#
				LIMIT 1;
			</cfquery>
			<cfif QCheckBatch.recordcount is 0 AND val(QCheckRound.riRoundID) neq 0>
				<cfquery name="QCreateBatch" datasource="#args.datasource#" result="QNewBatch">
					INSERT INTO tblDelBatch (dbRef,dbRound) VALUES ('#LSDateFormat(args.form.datefrom,'yyyy-mm-dd')#',#val(QCheckRound.riRoundID)#)
				</cfquery>
				<cfset BatchID=QNewBatch.generatedKey>
			<cfelse>
				<cfset BatchID=QCheckBatch.dbID>
			</cfif>
			<cfset parm={}>
			<cfset parm.datasource=args.datasource>
			<cfset parm.pubID=args.form.pubID>
			<cfset parm.date=args.form.datefrom>
			<cfset price=GetPubPrice(parm)>
			<cfset DayNum=DateFormat(parm.date,"DDD")>		
			<cfquery name="QCheckCharge" datasource="#args.datasource#">
				SELECT diCharge
				FROM tblDelItems
				WHERE diOrderID=#args.form.orderID#
				AND diDate='#LSDateFormat(args.form.datefrom,'yyyy-mm-dd')#'
				AND diType='debit'
				AND diCharge > 0
				LIMIT 1;
			</cfquery>
			<cfif QCheckCharge.recordcount is 0>
				<cfswitch expression="#DayNum#">
					<cfcase value="mon"><cfset dayInt=1></cfcase>
					<cfcase value="tue"><cfset dayInt=2></cfcase>
					<cfcase value="wed"><cfset dayInt=3></cfcase>
					<cfcase value="thu"><cfset dayInt=4></cfcase>
					<cfcase value="fri"><cfset dayInt=5></cfcase>
					<cfcase value="sat"><cfset dayInt=6></cfcase>
					<cfcase value="sun"><cfset dayInt=7></cfcase>
				</cfswitch>
				<cfset charge=GetCharge(args.form.delCode,dayInt)>
			<cfelse>
				<cfset charge=0>
			</cfif>
			
			<cfquery name="QLoadPubStock" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock
				WHERE psPubID=#args.form.pubID#
				AND psDate='#LSDateFormat(args.form.datefrom,'yyyy-mm-dd')#'
				LIMIT 1;
			</cfquery>
			<cfquery name="QCheckVouchers" datasource="#args.datasource#">
				SELECT vchID
				FROM tblVoucher
				WHERE vchOrderID=#args.form.orderID#
				AND vchPubID=#args.form.pubID#
				AND vchStart <= '#LSDateFormat(args.form.datefrom,'yyyy-mm-dd')#'
				AND vchStop >= '#LSDateFormat(args.form.datefrom,'yyyy-mm-dd')#'
				LIMIT 1;
			</cfquery>
			<cfif QCheckVouchers.recordcount is 1>
				<cfset voucher=val(QCheckVouchers.vchID)>
			</cfif>
			<cfquery name="QAddDelItem" datasource="#args.datasource#">
				INSERT INTO tblDelItems (
					diClientID,
					diOrderID,
					diBatchID,
					diPubID,
					diType,
					diDatestamp,
					diDate,
					diIssue,
					diQty,
					diPrice,
					diCharge,
					diVatAmount,
					diTest,
					diVoucher,
					diReason
				) VALUES (
					#args.form.cltID#,
					#args.form.orderID#,
					#val(BatchID)#,
					#args.form.pubID#,
					'debit',
					'#LSDateFormat(args.form.datefrom,"yyyy-mm-dd")#',
					'#LSDateFormat(args.form.datefrom,"yyyy-mm-dd")#',
					'#QLoadPubStock.psIssue#',
					#args.form.qty#,
					#price#,
					#charge#,
					#val(QLoadPubStock.psVatRate)#,
					0,
					#voucher#,
					''
				)
			</cfquery>
			<cfset result.msg="Charge has been added">
			
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="charge">
			<cfset actParms.class="added">
			<cfset actParms.clientID=args.form.cltID>
			<cfset actParms.pubID=args.form.pubID>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="AddCreditNote" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QLoadItem="">
		<cfset var QLoadCredit="">
		<cfset var QAddDelItem="">
		<cfset var charge=0>
		<cfset var price=0>
		<cfset var vat=0>
		<cfset var qty=0>
							
		<cftry>
			<cfif StructKeyExists(args.form,"selectItem")>
				<cfloop list="#args.form.selectItem#" delimiters="," index="i">
					<cfset qty=StructFind(args.form,"qty"&i)>
					<cfquery name="QLoadItem" datasource="#args.datasource#">
						SELECT *
						FROM tblDelItems
						WHERE diID=#i#
						LIMIT 1;
					</cfquery>
					<cfif QLoadItem.recordcount is 1>				
						<cfquery name="QLoadCredit" datasource="#args.datasource#">
							SELECT *
							FROM tblDelItems
							WHERE diOrderID=#QLoadItem.diOrderID#
							AND diPubID=#QLoadItem.diPubID#
							AND diDate='#LSDateFormat(QLoadItem.diDate,"yyyy-mm-dd")#'
							AND diType='credit'
							LIMIT 1;
						</cfquery>
						<cfquery name="QLoadDebits" datasource="#args.datasource#">
							SELECT COUNT(*) AS TotalDebits
							FROM tblDelItems
							WHERE diOrderID=#QLoadItem.diOrderID#
							AND diDate='#LSDateFormat(QLoadItem.diDate,"yyyy-mm-dd")#'
							AND diType='debit'
						</cfquery>
						<cfif QLoadDebits.TotalDebits is 1 AND QLoadItem.diCharge neq 0>
							<cfset charge=0-QLoadItem.diCharge>
						</cfif>
						<cfset price=0-QLoadItem.diPrice>
						<cfset vat=0-QLoadItem.diVatAmount>
						<cfif QLoadCredit.recordcount is 0>
							<cfquery name="QAddDelItem" datasource="#args.datasource#">
								INSERT INTO tblDelItems (
									diClientID,
									diOrderID,
									diBatchID,
									diPubID,
									diType,
									diDatestamp,
									diDate,
									diIssue,
									diQty,
									diPrice,
									diCharge,
									diVatAmount,
									diTest,
									diVoucher,
									diInvoiceID,
									diReason
								) VALUES (
									#QLoadItem.diClientID#,
									#QLoadItem.diOrderID#,
									#QLoadItem.diBatchID#,
									#QLoadItem.diPubID#,
									'credit',
									'#LSDateFormat(QLoadItem.diDate,"yyyy-mm-dd")#',
									'#LSDateFormat(QLoadItem.diDate,"yyyy-mm-dd")#',
									'#QLoadItem.diIssue#',
									#qty#,
									#price#,
									#charge#,
									#vat#,
									#QLoadItem.diTest#,
									#QLoadItem.diVoucher#,
									0,
									''
								)
							</cfquery>
							
							<cfset actParms={}>
							<cfset actParms.datasource=application.site.datasource1>
							<cfset actParms.type="credit">
							<cfset actParms.class="added">
							<cfset actParms.clientID=QLoadItem.diClientID>
							<cfset actParms.pubID=QLoadItem.diPubID>
							<cfset actParms.Text="">
							<cfset actInsert=AddActivity(actParms)>
							
						</cfif>
					</cfif>
				</cfloop>
				<cfset result.msg="Credits have been added">
			<cfelse>
				<cfset result.msg="Items not found">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteCreditNote" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDeleteItem="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"selectItem")>
				<cfloop list="#args.form.selectItem#" delimiters="," index="i">
					<cfquery name="QDeleteItem" datasource="#args.datasource#">
						DELETE FROM tblDelItems
						WHERE diID=#i#
					</cfquery>
				</cfloop>
			<cfelse>
				<cfset result.msg="Items not found">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadChargesFromDate" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QDelItems="">
		
		<cfset result.debit=[]>
		<cfset result.credit=[]>
		
		<cftry>
			<cfquery name="QDelItems" datasource="#args.datasource#">
				SELECT *
				FROM tblDelItems, tblPublication
				WHERE diOrderID=#val(args.form.orderID)#
				<cfif StructKeyExists(args.form,"dateTo")>
					AND diDate >= '#LSDateFormat(args.form.dateFrom,"yyyy-mm-dd")#'
					AND diDate <= '#LSDateFormat(args.form.dateTo,"yyyy-mm-dd")#'
				<cfelse>
					AND diDate='#LSDateFormat(args.form.dateFrom,"yyyy-mm-dd")#'
				</cfif>
				AND diPubID=pubID
				ORDER BY diPubID asc, diType asc, diDate asc
			</cfquery>
			<cfif QDelItems.recordcount gt 0>
				<cfloop query="QDelItems">
					<cfset item={}>
					<cfset item.ID=diID>
					<cfset item.date=diDate>
					<cfset item.diType=diType>
					<cfset item.price=diPrice>
					<cfset item.charge=diCharge>
					<cfset item.qty=diQty>
					<cfset item.category=pubCategory>
					<cfset item.ref=pubRef>
					<cfset item.title=pubTitle>
					<cfset item.type=pubType>
					<cfif item.diType is "debit">
						<cfset ArrayAppend(result.debit,item)>
					<cfelse>
						<cfset ArrayAppend(result.credit,item)>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset result.msg="No charges found">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientDelItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset var result={}>
		<cfset var QDelItems="">
		<cfset var item={}>
		
<cftry>
		<cfset result.args=args>
		<cfset result.delItems=[]>
			<cfquery name="QDelItems" datasource="#args.datasource#" result="loc.QResult">
				SELECT tblDelItems.*,tblPublication.pubRef,tblPublication.pubArrival,tblPublication.pubTitle,tblPublication.pubType,tblPublication.pubCategory
				FROM tblDelItems, tblPublication
				WHERE diClientID=#val(args.rec.cltID)#
				AND diPubID=pubID
				<cfswitch expression="#args.srchDelDate#">
					<cfcase value="recent">
						AND diDate >= #DateAdd("d",-27,application.controls.nextInvDate)#
						<!---AND diDate BETWEEN #DateAdd("d",-27,application.controls.nextInvDate)# AND #application.controls.nextInvDate#--->
					</cfcase>
					<cfcase value="current">
						AND diDate BETWEEN #DateAdd("d",-55,application.controls.nextInvDate)# AND #DateAdd("d",-28,application.controls.nextInvDate)# 
					</cfcase>
					<cfcase value="previous">
						AND diDate BETWEEN #DateAdd("d",-83,application.controls.nextInvDate)# AND #DateAdd("d",-56,application.controls.nextInvDate)# 
					</cfcase>
					<cfcase value="thisyear">
						<cfif Year(application.controls.fyEnd) gt Year(Now())>
							AND diDate > #DateAdd("yyyy",-1,application.controls.fyEnd)#
						<cfelse>
							AND diDate > #application.controls.fyEnd#
						</cfif>
					</cfcase>
					<cfcase value="all">
						<!--- ignore --->
					</cfcase>
					<cfdefaultcase>
						AND diDate>#application.controls.nextInvDate#
					</cfdefaultcase>
				</cfswitch>
				ORDER BY diDate ASC, diID ASC
			</cfquery>
			<cfset result.pubTotal=0>
			<cfset result.delTotal=0>
			<cfloop query="QDelItems">
				<cfset item={}>
				<cfif pubArrival gt 0><cfset item.arrival=application.site.days[pubArrival]>
					<cfelse><cfset item.arrival=""></cfif>
				<cfset item.category=pubCategory>
				<cfset item.ref=pubRef>
				<cfset item.title=pubTitle>
				<cfset item.type=pubType>
				
				<cfset item.ID=diID>
				<cfset item.orderID=diOrderID>
				<cfset item.date=diDate>
				<cfset item.price=diPrice>
				<cfset item.qty=diQty>
				<cfset item.delType=diType>
				<cfset item.charge=diCharge>
				<cfset result.delTotal=result.delTotal+item.charge>
				<cfset item.value=DecimalFormat(diQty*diPrice)>
				<cfset result.pubTotal=result.pubTotal+item.value>
				<cfset ArrayAppend(result.delItems,item)>
			</cfloop>
			<cfset result.netTotal=DecimalFormat(result.pubTotal+result.delTotal)>
			<cfset result.pubTotal=DecimalFormat(result.pubTotal)>
			<cfset result.delTotal=DecimalFormat(result.delTotal)>
			<cfset result.QDelItems=QDelItems>
			<cfset result.QResult=loc.QResult>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="processOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var del={}>
		<cfset var QOrders="">
		<cfset var QOrderItems="">
		<cfset var QStreet="">
		<cfset var QCheckVouchers="">
		<cfset var delCharge={}>
		<cfset var itemDel={}>
		<cfset var dayNum=1>
		<cfset var varDel=0>
		<cfset var vDiscount=0>
		<cfset var totalMonthCharges=0>
		
		<cfset result.msg="">
		<cfset result.list=ArrayNew(1)>
		<cfset item.DelWeek=ArrayNew(1)>
		
		<cftry>
			<cfquery name="QOrders" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder
				WHERE ordClientID=#args.clientID#
				<cfif StructKeyExists(args,"OrderID")>AND ordID=#args.OrderID#</cfif>
				AND ordActive=1
			</cfquery>
			<cfloop query="QOrders">
				<cfquery name="QStreet" datasource="#args.datasource#">
					SELECT *
					FROM tblStreets2
					WHERE stID=#val(QOrders.ordStreetCode)#
				</cfquery>
				<cfset item={}>		
				<cfset del.mon=0>
				<cfset del.tue=0>
				<cfset del.wed=0>
				<cfset del.thu=0>
				<cfset del.fri=0>
				<cfset del.sat=0>
				<cfset del.sun=0>
				<cfset del.qty=0>
				<cfset item.items=ArrayNew(1)>		
				<cfset item.DelWeek=ArrayNew(1)>
				<cfset item.orderID=QOrders.ordID>
				<cfset item.orderDate=LSDateFormat(QOrders.ordDate,"dd-mmm-yyyy")>
				<cfset item.Type=QOrders.ordType>
				<cfset item.DeliveryCode=QOrders.ordDeliveryCode>
				<cfset item.HouseName=QOrders.ordHouseName>
				<cfset item.HouseNumber=QOrders.ordHouseNumber>
				<cfset item.StreetCode=QOrders.ordStreetCode>
				<cfset item.Street=QStreet.stName>
				<cfset item.Town=QOrders.ordTown>
				<cfset item.City=QOrders.ordCity>
				<cfset item.Postcode=QOrders.ordPostcode>
				<cfset item.Active=QOrders.ordActive>
				<cfset item.orderPerWeek=0>
				<cfset item.orderPerMonth=0>
				<cfset item.voucherPerWeek=0>
				<cfset item.voucherPerMonth=0>
				<cfset item.voucherUser=false>
				<cfquery name="QOrderItems" datasource="#args.datasource#">
					SELECT *
					FROM tblOrderItem, tblPublication, tblPeriods
					WHERE oiOrderID=#QOrders.ordID#
					AND oiPubID=pubID
					AND perTitle=pubType
					AND pubActive
					AND oiStatus='active'
					<cfif StructKeyExists(args,"pubRef")>AND pubRef='#args.pubRef#'</cfif>
					ORDER BY pubTitle asc, pubType asc
				</cfquery>
				<cfset result.QOrderItems=QOrderItems>
				<cfloop query="QOrderItems">
					<cfquery name="QCheckVouchers" datasource="#args.datasource#">
						SELECT *
						FROM tblVoucher
						WHERE vchOrderID=#QOrderItems.oiOrderID#
						AND vchPubID=#QOrderItems.oiPubID#													<!--- was OR --->
						<cfif StructKeyExists(args,"Date")>AND (vchStart <= '#LSDateFormat(args.Date,'yyyy-mm-dd')#' AND vchStop >= '#LSDateFormat(args.Date,'yyyy-mm-dd')#')</cfif>
						LIMIT 1;
					</cfquery>
					<cfset totalMonthCharges=0>
					<cfset i={}>
					<cfset i.class="normal">
					<cfset i.ID=QOrderItems.oiID>
					<cfset i.pubID=QOrderItems.pubID>
					<cfset i.ref=QOrderItems.pubRef>
					<cfset i.title=QOrderItems.pubTitle>
					<cfset i.group=QOrderItems.pubGroup>
					<cfset i.arrival=QOrderItems.pubArrival>
					<cfset i.type=QOrderItems.pubType>
					<cfset i.nextIssue=QOrderItems.pubNextIssue>
					<cfset i.saleType=QOrderItems.pubSaleType>
					<cfset i.arrival=QOrderItems.pubArrival>
					<cfset i.discount=QOrderItems.pubDiscount>
					<cfset i.multiplier=QOrderItems.perInterval>
					<cfset i.voucher=QOrderItems.oiVoucher>
					<cfset i.qty=QOrderItems.oiQty>
					<cfset i.qtymon=val(QOrderItems.oiMon)>
					<cfset i.qtytue=val(QOrderItems.oiTue)>
					<cfset i.qtywed=val(QOrderItems.oiWed)>
					<cfset i.qtythu=val(QOrderItems.oiThu)>
					<cfset i.qtyfri=val(QOrderItems.oiFri)>
					<cfset i.qtysat=val(QOrderItems.oiSat)>
					<cfset i.qtysun=val(QOrderItems.oiSun)>
					<cfset i.price=QOrderItems.pubPrice>							
					<cfset i.price1=QOrderItems.pubPrice1>							
					<cfset i.price2=QOrderItems.pubPrice2>							
					<cfset i.price3=QOrderItems.pubPrice3>							
					<cfset i.price4=QOrderItems.pubPrice4>							
					<cfset i.price5=QOrderItems.pubPrice5>							
					<cfset i.price6=QOrderItems.pubPrice6>							
					<cfset i.price7=QOrderItems.pubPrice7>							
		
					<cfset i.voucherPerWeek=0>
					<cfset i.voucherPerMonth=0>
					<cfset i.linePerWeek=0>
					<cfset i.linePerMonth=0>
					<cfset i.linePerWeekQty=i.qtymon+i.qtytue+i.qtywed+i.qtythu+i.qtyfri+i.qtysat+i.qtysun>
					<cfset i.linePerWeek=i.price*i.linePerWeekQty>
					<cfif i.linePerWeek eq 0><cfset i.class="warning"></cfif>
					<cfset i.linePerMonth=i.linePerWeek*i.multiplier>
					<cfset item.orderPerWeek=item.orderPerWeek+i.linePerWeek>
					<cfset item.orderPerMonth=item.orderPerMonth+i.linePerMonth>
					
					<!--- Voucher Calculations --->
					<cfif QCheckVouchers.recordcount is 1>
						<cfif QCheckVouchers.vchType is "pc">
							<cfif QCheckVouchers.vchDiscount lt 100>
								<cfset vDiscount=(i.Price*QCheckVouchers.vchDiscount/100)*i.linePerWeekQty>
								<cfset vDiscount=(i.Price-vDiscount)*i.linePerWeekQty>
							<cfelse>
								<cfset vDiscount=i.Price*i.linePerWeekQty>
							</cfif>
						<cfelse>
							<cfset vDiscount=(i.Price-QCheckVouchers.vchDiscount)*i.linePerWeekQty>
						</cfif>
						<cfset i.vlinePerWeek=vDiscount>
						<cfset i.vlinePerMonth=i.vlinePerWeek*4>
					<cfelse>
						<cfset i.vlinePerWeek=0>
						<cfset i.vlinePerMonth=0>
					</cfif>
					
					<!--- count number of deliveries in the week --->
					<cfset del.mon=del.mon || int(oiMon gt 0)>
					<cfset del.tue=del.tue || int(oiTue gt 0)>
					<cfset del.wed=del.wed || int(oiWed gt 0)>
					<cfset del.thu=del.thu || int(oiThu gt 0)>
					<cfset del.fri=del.fri || int(oiFri gt 0)>
					<cfset del.sat=del.sat || int(oiSat gt 0)>
					<cfset del.sun=del.sun || int(oiSun gt 0)>
					
					
					<cfif oiMon gt 0>
						<cfset match=StructFindValue(item,"qtyMon")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiMon>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtyMon">
							<cfset delItem.qty=oiMon>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					<cfif oiTue gt 0>
						<cfset match=StructFindValue(item,"qtyTue")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiTue>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtyTue">
							<cfset delItem.qty=oiTue>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					<cfif oiWed gt 0>
						<cfset match=StructFindValue(item,"qtyWed")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiWed>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtyWed">
							<cfset delItem.qty=oiWed>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					<cfif oiThu gt 0>
						<cfset match=StructFindValue(item,"qtyThu")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiThu>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtyThu">
							<cfset delItem.qty=oiThu>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					<cfif oiFri gt 0>
						<cfset match=StructFindValue(item,"qtyFri")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiFri>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtyFri">
							<cfset delItem.qty=oiFri>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					<cfif oiSat gt 0>
						<cfset match=StructFindValue(item,"qtySat")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiSat>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtySat">
							<cfset delItem.qty=oiSat>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					<cfif oiSun gt 0>
						<cfset match=StructFindValue(item,"qtySun")>
						<cfif ArrayLen(match)>
							<cfif StructKeyExists(match[1].owner,"qty")>
								<cfset match[1].owner.qty=match[1].owner.qty+oiSun>
							</cfif>
							<cfif match[1].owner.multiplier lt i.multiplier>
								<cfset match[1].owner.multiplier=i.multiplier>
							</cfif>
						<cfelse>
							<cfset delItem={}>
							<cfset delItem.dayNum="qtySun">
							<cfset delItem.qty=oiSun>
							<cfset delItem.multiplier=i.multiplier>
							<cfset ArrayAppend(item.DelWeek,delItem)>
						</cfif>
					</cfif>
					
					<!--- add order item to order items array --->
					<cfset ArrayAppend(item.items,i)>
				</cfloop>
		
				<!--- new del charges --->
				<cfset item.delcount=del.mon+del.tue+del.wed+del.thu+del.fri+del.sat+del.sun>
				<!---<cfif item.delcount is 0 AND del.qty neq 0>
					<cfset item.delcount=del.qty>
				</cfif>--->
				<cfset delCharge=StructFind(application.site.delCharges,item.DeliveryCode)>
				<cfif delCharge.delPrice2 gt 0>
					<cfset varDel=0>
				<cfelse>
					<cfset varDel=1>
				</cfif>
				
				<cfloop array="#item.DelWeek#" index="m">
					<cfif m.DayNum is "qtySat">
						<cfif varDel is 0>
							<cfset totalMonthCharges=totalMonthCharges+delCharge.delPrice2*m.multiplier>
						<cfelse>
							<cfset totalMonthCharges=totalMonthCharges+delCharge.delPrice1*m.multiplier>
						</cfif>
					</cfif>
					<cfif m.DayNum is "qtySun">
						<cfif varDel is 0>
							<cfset totalMonthCharges=totalMonthCharges+delCharge.delPrice3*m.multiplier>
						<cfelse>
							<cfset totalMonthCharges=totalMonthCharges+delCharge.delPrice1*m.multiplier>
						</cfif>
					</cfif>
					<cfif m.DayNum neq "qtySat" AND  m.DayNum neq "qtySun">
						<cfset totalMonthCharges=totalMonthCharges+delCharge.delPrice1*m.multiplier>
					</cfif>
				</cfloop>
				
				<cfset item.delPerMonth=totalMonthCharges>
				<cfset item.delPerWeek=item.delPerMonth/4>
				
				<!---<cfif delCharge.delPrice2 gt 0>
					<!--- variable charges --->
					<cfset item.delPerWeek=delCharge.delPrice1*(del.mon+del.tue+del.wed+del.thu+del.fri)>
					<cfset item.delPerWeek=item.delPerWeek+(del.sat*delCharge.delPrice2)>
					<cfset item.delPerWeek=item.delPerWeek+(del.sun*delCharge.delPrice3)>
				<cfelseif delCharge.delType eq "Per Week">
					<cfset item.delPerWeek=delCharge.delPrice1>
				<cfelse>
					<!--- single charge --->
					<cfset item.delPerWeek=item.delcount*delCharge.delPrice1>
				</cfif>--->
				
				<cfif item.delPerWeek is 0>
					<cfset item.delClass="freedel">
				<cfelse>
					<cfset item.delClass="normal">
				</cfif>
					
				<!--- add item line to list array --->
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadOrderItem" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QOrderItem="">

		<cftry>
			<cfquery name="QOrderItem" datasource="#args.datasource#">
				SELECT *
				FROM tblOrderItem, tblPublication, tblPeriods
				WHERE oiID=#args.oiID#
				AND oiPubID=pubID
				AND perTitle=pubType
				AND pubActive
				AND oiStatus='active'
				ORDER BY pubType, pubTitle
			</cfquery>
			<cfset result.ID=QOrderItem.oiID>
			<cfset result.PubID=QOrderItem.pubID>
			<cfset result.Title=QOrderItem.pubTitle>
			<cfset result.qtymon=QOrderItem.oiMon>
			<cfset result.qtytue=QOrderItem.oiTue>
			<cfset result.qtywed=QOrderItem.oiWed>
			<cfset result.qtythu=QOrderItem.oiThu>
			<cfset result.qtyfri=QOrderItem.oiFri>
			<cfset result.qtysat=QOrderItem.oiSat>
			<cfset result.qtysun=QOrderItem.oiSun>
			<cfset result.price=QOrderItem.pubPrice>							
			<cfset result.price1=QOrderItem.pubPrice1>							
			<cfset result.price2=QOrderItem.pubPrice2>							
			<cfset result.price3=QOrderItem.pubPrice3>							
			<cfset result.price4=QOrderItem.pubPrice4>							
			<cfset result.price5=QOrderItem.pubPrice5>							
			<cfset result.price6=QOrderItem.pubPrice6>							
			<cfset result.price7=QOrderItem.pubPrice7>							
			<cfset result.voucher=QOrderItem.oiVoucher>
			<cfset result.lateDel=QOrderItem.oiLateDel>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var Street="">
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		<cfset var data={}>
		
		<cftry>
			<cfquery name="QCheckClient" datasource="#args.datasource#">
				SELECT tblClients.*, delType, delPrice1, delPrice2, delPrice3
				FROM tblClients, tblDelCharges
				WHERE cltRef=#val(args.rec.cltRef)#
				AND cltDelCode=delCode
				AND cltAge=0
				ORDER BY cltRef
				LIMIT 1;
			</cfquery>
			<cfquery name="Street" datasource="#args.datasource#">
				SELECT *
				FROM tblStreets2
				WHERE stID=#QCheckClient.cltStreetCode#
			</cfquery>
			<cfset result.cltRef=args.rec.cltRef>
			<cfset result.cltID=QCheckClient.cltID>
			<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
			<cfif len(QCheckClient.cltName) AND len(QCheckClient.cltCompanyName)>
				<cfset result.cltName="#QCheckClient.cltName#, #QCheckClient.cltCompanyName#">
			<cfelse>
				<cfset result.cltName="#QCheckClient.cltName##QCheckClient.cltCompanyName#">
			</cfif>
			<cfset result.cltDelCode=QCheckClient.cltDelCode>
			<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
			<cfset result.cltDelAddr=QCheckClient.cltDelAddr>
			<cfset result.cltEMail=QCheckClient.cltEMail>
			<cfset result.stName=Street.stName>
			<cfset result.order={}>
			<cfif QCheckClient.recordcount is 1>
				<cfset data={}>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=QCheckClient.cltID>
				<cfif StructKeyExists(args,"orderID")><cfset data.orderID=args.orderID></cfif>
				<cfset data.cltDelCode=QCheckClient.cltDelCode>
				<cfset data.delType=QCheckClient.delType>
				<cfset data.prices=[QCheckClient.delPrice1, QCheckClient.delPrice2, QCheckClient.delPrice3]>
				<cfset data.date=Now()>
				<cfset result.order=processOrder(data)>
			<cfelse>
				<cfset result.msg="Specified client record does not exist.">
				<cfset result.order.orderID=0>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QGetOrder="">
		
		<cftry>
			<cfquery name="QGetOrder" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder
				WHERE ordID=#val(args.orderID)#
				LIMIT 1;
			</cfquery>
			<cfset result.ID=QGetOrder.ordID>
			<cfset result.ClientID=QGetOrder.ordClientID>
			<cfset result.HouseName=QGetOrder.ordHouseName>
			<cfset result.HouseNumber=QGetOrder.ordHouseNumber>
			<cfset result.StreetCode=QGetOrder.ordStreetCode>
			<cfset result.Town=QGetOrder.ordTown>
			<cfset result.City=QGetOrder.ordCity>
			<cfset result.Postcode=QGetOrder.ordPostcode>
			<cfset result.DeliveryCode=QGetOrder.ordDeliveryCode>
			<cfset result.Type=QGetOrder.ordType>
			<cfset result.ordRef=QGetOrder.ordRef>
			<cfset result.ordContact=QGetOrder.ordContact>
			<cfset result.ordDifferent=QGetOrder.ordDifferent>
			<cfset result.Active=QGetOrder.ordActive>
			<cfset result.ordMon=QGetOrder.ordMon>
			<cfset result.ordTue=QGetOrder.ordTue>
			<cfset result.ordWed=QGetOrder.ordWed>
			<cfset result.ordThu=QGetOrder.ordThu>
			<cfset result.ordFri=QGetOrder.ordFri>
			<cfset result.ordSat=QGetOrder.ordSat>
			<cfset result.ordSun=QGetOrder.ordSun>
			<cfset result.Note=QGetOrder.ordNote>
			<cfset result.Date=DateFormat(QGetOrder.ordDate,"DDDD DD MMM YYYY")>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadOrderPubs" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var Street="">
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		<cfset var data={}>
		
		<cftry>
			<cfquery name="QCheckClient" datasource="#args.datasource#">
				SELECT tblClients.*, delType, delPrice1, delPrice2, delPrice3
				FROM tblClients, tblDelCharges
				WHERE cltRef=#val(args.rec.cltRef)#
				AND cltDelCode=delCode
				AND cltAge=0
				ORDER BY cltRef
				LIMIT 1;
			</cfquery>
			<cfquery name="Street" datasource="#args.datasource#">
				SELECT *
				FROM tblStreets2
				WHERE stID=#QCheckClient.cltStreetCode#
			</cfquery>
			<cfset result.cltRef=args.rec.cltRef>
			<cfset result.cltID=QCheckClient.cltID>
			<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
			<cfset result.cltName=QCheckClient.cltName>
			<cfset result.cltDelCode=QCheckClient.cltDelCode>
			<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
			<cfset result.cltDelAddr=QCheckClient.cltDelAddr>
			<cfset result.stName=Street.stName>
			<cfset result.order={}>
			<cfif QCheckClient.recordcount is 1>
				<cfset data={}>
				<cfset data.OrderID=args.orderID>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=QCheckClient.cltID>
				<cfset data.cltDelCode=QCheckClient.cltDelCode>
				<cfset data.delType=QCheckClient.delType>
				<cfset data.prices=[QCheckClient.delPrice1, QCheckClient.delPrice2, QCheckClient.delPrice3]>
				<cfset result.order=processOrder(data)>
			<cfelse>
				<cfset result.msg="Specified client record does not exist.">
				<cfset result.order.orderID=0>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientOrder2" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		<cfset var data={}>
		
		<cftry>
			<cfquery name="QCheckClient" datasource="#args.datasource#">
				SELECT tblClients.*, stName, delType, delPrice1, delPrice2, delPrice3
				FROM tblClients, tblStreets2, tblDelCharges
				WHERE stID=cltStreetCode
				AND cltDelCode=delCode
				AND cltAge=0
				AND cltRef=#val(args.rec.cltRef)#
				ORDER BY cltRef
				LIMIT 1;
			</cfquery>
			<cfset result.cltRef=args.rec.cltRef>
			<cfset result.cltID=QCheckClient.cltID>
			<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
			<cfset result.cltName=QCheckClient.cltName>
			<cfset result.cltDelCode=QCheckClient.cltDelCode>
			<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
			<cfset result.cltDelAddr=QCheckClient.cltDelAddr>
			<cfset result.stName=QCheckClient.stName>
			<cfset result.order={}>
			<cfif QCheckClient.recordcount is 1>
				<cfset data={}>
				<cfset data.datasource=args.datasource>
				<cfset data.clientID=QCheckClient.cltID>
				<cfset data.cltDelCode=QCheckClient.cltDelCode>
				<cfset data.delType=QCheckClient.delType>
				<cfset data.prices=[QCheckClient.delPrice1, QCheckClient.delPrice2, QCheckClient.delPrice3]>
				<cfset result.order=processOrder(data)>
			<cfelse>
				<cfset result.msg="Specified client record does not exist.">
				<cfset result.order.orderID=0>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCreateOrder="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"cltID")>
				<cfquery name="QCreateOrder" datasource="#args.datasource#">
					INSERT INTO tblOrder (
						ordClientID,
						ordType,
						ordRef,
						ordContact,
						ordDeliveryCode,
						ordHouseName,
						ordHouseNumber,
						ordStreetCode,
						ordTown,
						ordCity,
						ordPostcode,
						ordActive,
						ordDifferent
					) VALUES (
						#args.form.cltID#,
						'#args.form.ordType#',
						'#args.form.ordRef#',
						'#args.form.ordContact#',
						#args.form.ordDeliveryCode#,
						'#args.form.ordHouseName#',
						'#args.form.ordHouseNumber#',
						#args.form.ordStreetCode#,
						'#args.form.ordTown#',
						'#args.form.ordCity#',
						'#args.form.ordPostcode#',
						1,
						<cfif StructKeyExists(args.form,"ordDifferent")>#args.form.ordDifferent#<cfelse>0</cfif>
					)
				</cfquery>
				<cfset result.msg="Order has been added.">
			<cfelse>
				<cfset result.msg="Client ID is undefined">
			</cfif>
			
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="order">
			<cfset actParms.class="added">
			<cfset actParms.clientID=args.form.cltID>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
							
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdateOrder="">
		
		<cftry>
			<cfquery name="QUpdateOrder" datasource="#args.datasource#">
				UPDATE tblOrder
				SET
					ordClientID=#args.form.cltID#,
					ordType='#args.form.ordType#',
					ordRef='#args.form.ordRef#',
					ordContact='#args.form.ordContact#',
					ordDeliveryCode=#args.form.ordDeliveryCode#,
					ordHouseName='#args.form.ordHouseName#',
					ordHouseNumber='#args.form.ordHouseNumber#',
					ordStreetCode=#args.form.ordStreetCode#,
					ordTown='#args.form.ordTown#',
					ordCity='#args.form.ordCity#',
					ordPostcode='#args.form.ordPostcode#',
					ordActive=#args.form.ordActive#,
					<cfif StructKeyExists(args.form,"ordMon")>ordMon=1,<cfelse>ordMon=0,</cfif>
					<cfif StructKeyExists(args.form,"ordTue")>ordTue=1,<cfelse>ordTue=0,</cfif>
					<cfif StructKeyExists(args.form,"ordWed")>ordWed=1,<cfelse>ordWed=0,</cfif>
					<cfif StructKeyExists(args.form,"ordThu")>ordThu=1,<cfelse>ordThu=0,</cfif>
					<cfif StructKeyExists(args.form,"ordFri")>ordFri=1,<cfelse>ordFri=0,</cfif>
					<cfif StructKeyExists(args.form,"ordSat")>ordSat=1,<cfelse>ordSat=0,</cfif>
					<cfif StructKeyExists(args.form,"ordSun")>ordSun=1,<cfelse>ordSun=0,</cfif>
					ordDifferent=#int(StructKeyExists(args.form,"ordDifferent"))#,
					ordNote='#args.form.ordNote#'
				WHERE ordID=#args.form.orderID#
			</cfquery>
			<cfset result.msg="Order has been updated.">
			
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="order">
			<cfset actParms.class="updated">
			<cfset actParms.clientID=args.form.cltID>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
							
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
				<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="DeleteOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QOrder="">
		<cfset var QDeleteOrder="">
		<cfset var QDeleteItem="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"orderID")>
				<cfquery name="QOrder" datasource="#args.datasource#">
					SELECT * 
					FROM tblOrderItem
					WHERE oiOrderID=#args.form.orderID#
				</cfquery>
				<cfif QOrder.recordcount gt 0>
					<cfloop query="QOrder">
						<cfquery name="QDeleteItem" datasource="#args.datasource#">
							UPDATE tblOrderItem
							SET oiStatus='cancelled'
							WHERE oiID=#QOrder.oiID#
						</cfquery>
					</cfloop>
				</cfif>
				<cfquery name="QDeleteOrder" datasource="#args.datasource#">
					UPDATE tblOrder
					SET ordActive=0
					WHERE ordID=#args.form.orderID#
				</cfquery>
				<cfset result.msg="Order has been deleted.">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddPublicationToOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QAdd="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"oiOrderID")>
				<cfset orderID=args.form.oiOrderID>
				<cfif orderID is 0>
					<cfquery name="QCreateOrder" datasource="#args.datasource#" result="NewOrderID">
						INSERT INTO tblOrder (
							ordClientID
						) VALUES (
							#args.form.cltID#
						)
					</cfquery>
					<cfset orderID=NewOrderID.generatedKey>
				</cfif>
				<cfquery name="QAdd" datasource="#args.datasource#">
					INSERT INTO tblOrderItem (
						oiOrderID,
						oiPubID,
						oiSun,
						oiMon,
						oiTue,
						oiWed,
						oiThu,
						oiFri,
						oiSat
					) VALUES (
						#orderID#,
						#args.form.oiPubID#,
						<cfif StructKeyExists(args.form,"oiSun")>#args.form.oiSun#,<cfelse>0,</cfif>
						<cfif StructKeyExists(args.form,"oiMon")>#args.form.oiMon#,<cfelse>0,</cfif>
						<cfif StructKeyExists(args.form,"oiTue")>#args.form.oiTue#,<cfelse>0,</cfif>
						<cfif StructKeyExists(args.form,"oiWed")>#args.form.oiWed#,<cfelse>0,</cfif>
						<cfif StructKeyExists(args.form,"oiThu")>#args.form.oiThu#,<cfelse>0,</cfif>
						<cfif StructKeyExists(args.form,"oiFri")>#args.form.oiFri#,<cfelse>0,</cfif>
						<cfif StructKeyExists(args.form,"oiSat")>#args.form.oiSat#<cfelse>0</cfif>
					)
				</cfquery>
				<cfset result.msg="Publication has been added.">
			</cfif>
			
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="publication">
			<cfset actParms.class="added">
			<cfset actParms.clientID=args.form.cltID>
			<cfset actParms.pubID=args.form.oiPubID>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
							
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateOrderItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var Update="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"oiID")>
				<cfloop list="#args.form.oiID#" delimiters="," index="i">
					<cfquery name="Update" datasource="#args.datasource#">
						UPDATE tblOrderItem 
						SET 
							<cfif StructKeyExists(args.form,"qtyMon" & i)>oiMon=#StructFind(args.form,"qtyMon" & i)#,<cfelse>oiMon=0,</cfif>
							<cfif StructKeyExists(args.form,"qtyTue" & i)>oiTue=#StructFind(args.form,"qtyTue" & i)#,<cfelse>oiTue=0,</cfif>
							<cfif StructKeyExists(args.form,"qtyWed" & i)>oiWed=#StructFind(args.form,"qtyWed" & i)#,<cfelse>oiWed=0,</cfif>
							<cfif StructKeyExists(args.form,"qtyThu" & i)>oiThu=#StructFind(args.form,"qtyThu" & i)#,<cfelse>oiThu=0,</cfif>
							<cfif StructKeyExists(args.form,"qtyFri" & i)>oiFri=#StructFind(args.form,"qtyFri" & i)#,<cfelse>oiFri=0,</cfif>
							<cfif StructKeyExists(args.form,"qtySat" & i)>oiSat=#StructFind(args.form,"qtySat" & i)#,<cfelse>oiSat=0,</cfif>
							<cfif StructKeyExists(args.form,"qtySun" & i)>oiSun=#StructFind(args.form,"qtySun" & i)#<cfelse>oiSun=0</cfif>
						WHERE oiID=#i#
					</cfquery>
				</cfloop>
				<cfset result.msg="Order items have been updated.">
			</cfif>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="RemovePublicationFromOrder" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QRemove="">
		
		<cfif StructKeyExists(args.form,"selectPub")>
			<cfquery name="QRemove" datasource="#args.datasource#">
				UPDATE tblOrderItem
				SET oiStatus='cancelled'
				WHERE oiID IN (#args.form.selectPub#)
			</cfquery>
		</cfif>
		<cfset result.msg="Publications have been removed.">

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientOrderForDay" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckClient="">
		<cfset var QClientOrder="">
		<cfset var item={}>
		
		<cfquery name="QCheckClient" datasource="#args.datasource#">
			SELECT cltID,cltName,cltDelHouse,cltStreetCode,stName
			FROM tblClients, tblStreets
			WHERE stRef=cltStreetCode
			AND cltRef=#val(args.clientRef)#
			LIMIT 1;
		</cfquery>
		<cfset result.cltRef=args.clientRef>
		<cfset result.cltID=QCheckClient.cltID>
		<cfset result.cltStreetCode=QCheckClient.cltStreetCode>
		<cfset result.cltName=QCheckClient.cltName>
		<cfset result.cltDelHouse=QCheckClient.cltDelHouse>
		<cfset result.stName=QCheckClient.stName>		
		<cfif QCheckClient.recordcount is 1>
			<cfquery name="QOrders" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder, tblOrderItem, tblPublication
				WHERE ordClientID=#result.cltID#
				AND oiOrderID=ordID
				AND oiPubID=pubID
				ORDER BY pubTitle
			</cfquery>
			<cfset result.orderDetails=QOrders>
			<cfset result.roundItems=[]>
			<cfif args.dayNo gt 0>
				<cfloop query="QOrders">
					<cfset item={}>
					<cfset item.title=pubTitle>
					<cfset item.qty=0>
					<cfswitch expression="#args.dayNo#">
						<cfcase value="1">	<!--- sunday --->
							<cfif oiSun neq 0><cfset item.qty=oiSun></cfif>
						</cfcase>
						<cfcase value="2">
							<cfif oiMon neq 0><cfset item.qty=oiMon></cfif>
						</cfcase>
						<cfcase value="3">
							<cfif oiTue neq 0><cfset item.qty=oiTue></cfif>
						</cfcase>
						<cfcase value="4">
							<cfif oiWed neq 0><cfset item.qty=oiWed></cfif>
						</cfcase>
						<cfcase value="5">
							<cfif oiThu neq 0><cfset item.qty=oiThu></cfif>
						</cfcase>
						<cfcase value="6">
							<cfif oiFri neq 0><cfset item.qty=oiFri></cfif>
						</cfcase>
						<cfcase value="7">	<!--- saturday --->
							<cfif oiSat neq 0><cfset item.qty=oiSat></cfif>
						</cfcase>
					</cfswitch>
					<cfif item.qty neq 0>
						<cfset ArrayAppend(result.roundItems,item)>
					</cfif>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset result.msg="Specified client record does not exist.">
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="AddNewPub" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheck="">
		<cfset var QPublications="">
		<cfset var QResult="">
		
		<cfif len(args.form.pubTitle)>
			<cfquery name="QCheck" datasource="#args.datasource#">
				SELECT pubTitle
				FROM tblPublication
				WHERE pubWholesaler='#args.form.pubWholesaler#'
				<cfif len(args.form.pubShortTitle)>
					AND (pubTitle='#args.form.pubTitle#' OR pubShortTitle='#args.form.pubShortTitle#')
				<cfelse>
					AND pubTitle='#args.form.pubTitle#'
				</cfif>
				AND pubGroup='#args.form.pubGroup#'
				LIMIT 1;
			</cfquery>
			<cfif QCheck.recordcount is 0>
				<cfquery name="QPublications" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblPublication (
						pubTitle,
						pubShortTitle,
						pubRoundTitle,
						pubWholesaler,
						pubGroup,
						pubCategory,
						pubType
					) VALUES (
						'#args.form.pubTitle#',
						'#args.form.pubShortTitle#',
						'#args.form.pubRoundTitle#',
						'#args.form.pubWholesaler#',
						'#args.form.pubGroup#',
						'#args.form.pubCategory#',
						'#args.form.pubType#'
					)
				</cfquery>
				<cfset result.msg="Added">
				
				<cfset actParms={}>
				<cfset actParms.datasource=application.site.datasource1>
				<cfset actParms.type="Publication">
				<cfset actParms.class="Added">
				<cfset actParms.clientID=0>
				<cfset actParms.pubID=0>
				<cfset actParms.Text="New Publication - #args.form.pubTitle#">
				<cfset actInsert=AddActivity(actParms)>
								
			<cfelse>
				<cfset result.error="Publication already exists as '#QCheck.pubTitle#'">
			</cfif>
		<cfelse>
			<cfset result.error="Publication Title was not found">
		</cfif>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublications" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QPublications="">
		
		<cfquery name="QPublications" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE 1
			AND (pubWholesaler='WHS' OR pubWholesaler='DASH')
			<cfif StructKeyExists(args,"PubID")>AND pubID=#args.pubID#</cfif>
			AND pubCategory <> 'UNUSED'
			AND pubActive
			ORDER BY pubGroup asc, pubTitle asc
		</cfquery>
		<cfloop query="QPublications">
			<cfset item={}>
			<cfset item.ID=pubID>
			<cfif pubRef neq 0>
				<cfset item.Ref=pubRef>
			<cfelse>
				<cfset item.Ref=pubID>
			</cfif>
			<cfif Len(pubShortTitle)>
				<cfset item.Title=pubShortTitle>
			<cfelse>
				<cfset item.Title=pubTitle>
			</cfif>
			<cfset item.Cat=pubCategory>
			
			<cfset ArrayAppend(result.list,item)>
		</cfloop>
				
		<cfreturn result>
	</cffunction>

	<cffunction name="CheckPublication" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QPublication="">
		<cfset result.Mon=0>
		<cfset result.Tue=0>
		<cfset result.Wed=0>
		<cfset result.Thu=0>
		<cfset result.Fri=0>
		<cfset result.Sat=0>
		<cfset result.Sun=0>
				
		<cfquery name="QPublication" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubID=#args.form.oiPubID#
			LIMIT 1;
		</cfquery>
		<cfset result.ID=QPublication.pubID>
		<cfset result.Title=QPublication.pubTitle>
		<cfset result.Cat=QPublication.pubCategory>
		<cfset result.Arrival=QPublication.pubArrival>
		<cfset result.sumPrice=QPublication.pubPrice1+QPublication.pubPrice2+QPublication.pubPrice3+QPublication.pubPrice4+QPublication.pubPrice5+QPublication.pubPrice6+QPublication.pubPrice7>
		<cfset result.sumDays=QPublication.pubMon+QPublication.pubTue+QPublication.pubWed+QPublication.pubThu+QPublication.pubFri+QPublication.pubSat+QPublication.pubSun>
		<cfif result.sumDays neq 0>
			<cfif QPublication.pubMon is 1><cfset result.Mon=QPublication.pubPrice></cfif>
			<cfif QPublication.pubTue is 1><cfset result.Tue=QPublication.pubPrice></cfif>
			<cfif QPublication.pubWed is 1><cfset result.Wed=QPublication.pubPrice></cfif>
			<cfif QPublication.pubThu is 1><cfset result.Thu=QPublication.pubPrice></cfif>
			<cfif QPublication.pubFri is 1><cfset result.Fri=QPublication.pubPrice></cfif>
			<cfif QPublication.pubSat is 1><cfset result.Sat=QPublication.pubPrice></cfif>
			<cfif QPublication.pubSun is 1><cfset result.Sun=QPublication.pubPrice></cfif>
		<cfelse>
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
		</cfif>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPubs" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QPubs="">
		
		<cfquery name="QPubs" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE 1
			<cfif StructKeyExists(args,"wholesaler")>
				AND pubWholesaler='#args.wholesaler#'
			<cfelse>
				AND (pubWholesaler='WHS' OR pubWholesaler='DASH')
			</cfif>
			<cfif StructKeyExists(args,"pubGroup")>AND pubGroup='#args.pubGroup#'</cfif>
			AND pubCategory <> 'UNUSED'
			AND pubActive
			ORDER BY pubGroup asc, pubTitle asc
		</cfquery>
		<cfloop query="QPubs">
			<cfset item={}>
			<cfset item.ID=pubID>
			<cfif pubRef neq 0>
				<cfset item.Ref=pubRef>
			<cfelse>
				<cfset item.Ref=pubID>
			</cfif>
			<cfif Len(pubShortTitle)>
				<cfset item.Title=pubShortTitle>
			<cfelse>
				<cfset item.Title=pubTitle>
			</cfif>
			
			<cfset ArrayAppend(result.list,item)>
		</cfloop>
			
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPub" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		<cfset var QPubStock="">
		<cfset var issue = "">
		<cfset var subType = "">

		<cftry>
			<cfif StructKeyExists(args,"issue")><cfset issue = args.issue></cfif>
			<cfif StructKeyExists(args,"psSubType")><cfset subType = args.psSubType></cfif>
			<cfquery name="QPub" datasource="#args.datasource#">
				SELECT *
				FROM tblPublication
				WHERE pubID=#args.pub#
			</cfquery>
			<cfquery name="QPubStock" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock
				WHERE psPubID=#args.pub#
				AND psDate="#LSDateFormat(args.delDate,'YYYY-MM-DD')#"
				AND psType='#args.type#'
				<cfif len(issue)>AND psIssue = '#issue#'</cfif>
				LIMIT 1;
			</cfquery>
			<cfquery name="QLastStock" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock
				WHERE psPubID=#args.pub#
				AND psDate <="#LSDateFormat(args.delDate,'YYYY-MM-DD')#"
				AND psType='#args.type#'
				ORDER BY psDate desc
				LIMIT 1;
			</cfquery>
			<cfset result.thisDate=args.delDate>
			<cfset result.thisDay=DateFormat(result.thisDate,"DDD")>
			
			<cfif QPubStock.recordcount is 1>
				<cfset result.mode=2>
			<cfelse>
				<cfset result.mode=1>
			</cfif>
				
			<cfset result.Type=QPubStock.psType>
 			<cfset result.stockID=QPubStock.psID>
			<cfset result.issue=QPubStock.psIssue>
			<cfset result.Qty=QPubStock.psQty>
			<cfset result.psShort=QPubStock.psShort>
			
			<cfset result.ID=QPub.pubID>
			<cfset result.title=QPub.pubTitle>
			<cfset result.TradePrice=QPub.pubTradePrice>
			<cfset result.Group=QPub.pubGroup>
			
			<cfif NOT len(result.issue) AND NOT len(issue) AND result.Group is "News">
				<cfset result.issue=UCase(LSDateFormat(result.thisDate,"ddmmm"))>
			<cfelse>
				<cfset result.issue = issue>
			</cfif>
			<cfset result.psSubType = subType>
			<cfif QLastStock.recordcount is 1>
				<cfset result.discount=QLastStock.psDiscount>
				<cfset result.discountType=QLastStock.psDiscountType>
				<cfset result.VAT=QLastStock.psVatRate>
				<cfset result.retail=QLastStock.psRetail>
				<cfset result.pwRetail=QLastStock.psPWRetail>
				<cfset result.pwVat=QLastStock.psPWVatRate>
			<cfelse>
				<cfset result.discount=QPub.pubDiscount>
				<cfset result.discountType=QPub.pubDiscType>
				<cfset result.VAT=QPub.pubVAT>
				<cfset result.retail=QPub.pubPrice>
				<cfset result.pwRetail=QPub.pubPWPrice>
				<cfset result.pwVat=QPub.pubPWVat>
			</cfif>
			
			<cfset result.dayName=QPub.pubType>
			<cfset result.pubVATCode=QPub.pubVATCode>
			<cfset result.warning="">
			<cfset dayDate=DateFormat(args.delDate,"DDDD")>
			<cfif QPub.pubGroup is "News">
				<cfswitch expression="#dayDate#">
					<cfcase value="Saturday">
						<cfif result.dayName is "morning" OR result.dayName is "sunday">
							<cfset result.warning="You have selected a publication that is not a Saturday publication. Is this correct?">
						</cfif>
					</cfcase>
					<cfcase value="Sunday">
						<cfif result.dayName is "morning" OR result.dayName is "saturday">
							<cfset result.warning="You have selected a publication that is not a Sunday publication. Is this correct?">
						</cfif>
					</cfcase>
					<cfdefaultcase>
						<cfif result.dayName is "sunday" OR result.dayName is "saturday">
							<cfset result.warning="You have selected a publication that is not a Morning publication. Is this correct?">
						</cfif>
					</cfdefaultcase>
				</cfswitch>
			</cfif>
			<cfif result.thisDay eq "Mon">
				<cfset result.dayINT=1>
			<cfelseif result.thisDay eq "Tue">
				<cfset result.dayINT=2>
			<cfelseif result.thisDay eq "Wed">
				<cfset result.dayINT=3>
			<cfelseif result.thisDay eq "Thu">
				<cfset result.dayINT=4>
			<cfelseif result.thisDay eq "Fri">
				<cfset result.dayINT=5>
			<cfelseif result.thisDay eq "Sat">
				<cfset result.dayINT=6>
			<cfelseif result.thisDay eq "Sun">
				<cfset result.dayINT=7>
			<cfelse>
				<cfset result.dayINT=0>
			</cfif>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdatePubStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">
		<cfset var QPubUpdate="">
		<cfset var QDelItems="">
		<cfset var QCheckStock="">
		<cfset var QVoucherTitles="">
		<cfset var QSelectItems="">
		<cfset var QVoucherItems="">
		<cfset var updatePrice=0>
		<cfset var trade=0>
		
		<cftry>
			<cfif args.form.psDiscountType eq "pc">
				<cfset trade=args.form.psRetail - (args.form.psRetail*args.form.psDiscount/100)>
			<cfelse>
				<cfset trade=args.form.psRetail-args.form.psDiscount>
			</cfif>
			
			<cfif args.form.mode is 1>
				<cfquery name="QUpdate" datasource="#args.datasource#" result="Qrec">
					INSERT INTO tblPubStock (
						psPubID,
						psSupID,
						psType,
						psDate,
						psSubType,
						psIssue,
						psArrivalDay,
						psQty,
						psRetail,
						psDiscount,
						psDiscountType,
						psVatRate,
						psVat,
						psPWRetail,
						psPWVatRate,
						psTradePrice
					) VALUES (
						#args.form.psPubID#,
						'#args.form.psSupID#',
						'#args.form.psType#',
						'#LSDateFormat(args.form.psDate,"YYYY-MM-DD")#',
						'#args.form.psSubType#',
						'#args.form.psIssue#',
						#args.form.psArrivalDayINT#,
						#args.form.psQty#,
						#args.form.psRetail#,
						#args.form.psDiscount#,
						'#args.form.psDiscountType#',
						#StructFind(application.site.VAT,args.form.psVat)#,
						#args.form.psVat#,
						#args.form.psPWRetail#,
						#args.form.psPWVat#,
						#trade#
					)
				</cfquery>
				<cfset rowAdded=Qrec.generatedKey>
			<cfelse>
				<cfquery name="QUpdate" datasource="#args.datasource#" result="Qrec">
					UPDATE tblPubStock
					SET 
						psType='#args.form.psType#',
						psDate='#LSDateFormat(args.form.psDate,"YYYY-MM-DD")#',
						psSubType = '#args.form.psSubType#',
						psIssue='#args.form.psIssue#',
						psArrivalDay=#args.form.psArrivalDayINT#,
						psQty=#args.form.psQty#,
						psRetail=#args.form.psRetail#,
						psDiscount=#args.form.psDiscount#,
						psDiscountType='#args.form.psDiscountType#',
						psVatRate=#StructFind(application.site.VAT,args.form.psVat)#,
						psVat=#args.form.psVat#,
						psPWRetail=#args.form.psPWRetail#,
						psPWVatRate=#args.form.psPWVat#,
						psTradePrice=#trade#
					WHERE psID=#args.form.psID#
				</cfquery>
				<cfset rowAdded=args.form.psID>
			</cfif>
						
			<cfquery name="QCheck" datasource="#args.datasource#">
				SELECT psID
				FROM tblPubStock
				WHERE psPubID=#args.form.psPubID#
				AND psType='#args.form.psType#'
				AND psDate > '#LSDateFormat(args.form.psDate,"YYYY-MM-DD")#'
				LIMIT 1;
			</cfquery>
			<cfquery name="QPubUpdate" datasource="#args.datasource#">
				UPDATE tblPublication
				SET 
					<cfif args.form.psSubType eq "normal">
						<cfif LSDateFormat(args.form.psDate,"ddd") eq "Mon">
							pubArrival=1,
						<cfelseif LSDateFormat(args.form.psDate,"ddd") eq "Tue">
							pubArrival=2,
						<cfelseif LSDateFormat(args.form.psDate,"ddd") eq "Wed">
							pubArrival=3,
						<cfelseif LSDateFormat(args.form.psDate,"ddd") eq "Thu">
							pubArrival=4,
						<cfelseif LSDateFormat(args.form.psDate,"ddd") eq "Fri">
							pubArrival=5,
						<cfelseif LSDateFormat(args.form.psDate,"ddd") eq "Sat">
							pubArrival=6,
						<cfelseif LSDateFormat(args.form.psDate,"ddd") eq "Sun">
							pubArrival=7,
						</cfif>
					</cfif>
					<cfif QCheck.recordcount is 0>
						pubDiscount=#args.form.psDiscount#,
						pubDiscType='#args.form.psDiscountType#',
						pubTradePrice=#trade#,
						pubVATCode=#args.form.psVat#,
						pubPrice=#args.form.psRetail#,
						pubPWPrice=#args.form.psPWRetail#,
						pubPWVat=#args.form.psPWVat#
					</cfif>
				WHERE pubID=#args.form.psPubID#
			</cfquery>

			<cfset updatePrice=args.form.psRetail+args.form.psPWRetail>
			<cfquery name="QDelItems" datasource="#args.datasource#">
				UPDATE tblDelItems
				SET diPrice=#DecimalFormat(updatePrice)#
				WHERE diPubID=#args.form.psPubID#
				AND diDate='#LSDateFormat(args.form.psDate,"yyyy-mm-dd")#'
				AND diType='debit'
			</cfquery>
			<cfquery name="QVoucherTitles" datasource="#args.datasource#">
				UPDATE tblVoucherTitles
				SET vtValue=#DecimalFormat(updatePrice)#
				WHERE vtPubID=#args.form.psPubID#
			</cfquery>
			<cfquery name="QSelectItems" datasource="#args.datasource#">
				SELECT *
				FROM tblVoucherItems,tblVoucherTitles
				WHERE vtPubID=#args.form.psPubID#
				AND vtmTitleID=vtID
				AND vtmDate='#LSDateFormat(args.form.psDate,"yyyy-mm-dd")#'
				AND vtmStatus='open'
			</cfquery>
			<cfloop query="QSelectItems">
				<cfquery name="QVoucherItems" datasource="#args.datasource#">
					UPDATE tblVoucherItems
					SET vtValue=#DecimalFormat(updatePrice)#
					WHERE vtmID=#QSelectItems.vtmID#
				</cfquery>
			</cfloop>
			
			<cfset result.msg="Publication has been updated">
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
					
		<cfreturn result>
	</cffunction>
	
	<cffunction name="GetPubStockList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QLoad="">
		<cfset var result.list=ArrayNew(1)>
		
		<cftry>
			<cfloop list="#args.ids#" index="i" delimiters=",">
				<cfquery name="QLoad" datasource="#args.datasource#">
					SELECT *
					FROM tblPubStock,tblPublication
					WHERE psID=#i#
					AND psPubID=pubID
				</cfquery>
				<cfset item={}>
				<cfset item.title=QLoad.pubTitle>
				<cfset item.supID=QLoad.psSupID>
				<cfset item.Type=QLoad.psType>
				<cfset item.DeliveryDate=DateFormat(QLoad.psDate,"DD/MM/YYYY")>
				<cfset item.Issue=QLoad.psIssue>
				<cfset item.ArrivalDay=QLoad.psArrivalDay>
				<cfset item.Qty=QLoad.psQty>
				<cfset item.Retail=QLoad.psRetail>
				<cfset item.Discount=QLoad.psDiscount>
				<cfset item.DiscountType=QLoad.psDiscountType>
				<cfset item.Vat=QLoad.psVat>
				
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
					
		<cfreturn result>
	</cffunction>
	
	<cffunction name="DeletePubStockItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i=0>
		<cfset var QDelete="">
		<cfset var QLoad="">
		<cfset var QUpdateStock="">
		
		<cftry>
			<cftransaction>
				<cfif StructKeyExists(args.form,"line")>
					<cfloop list="#args.form.line#" delimiters="," index="i">
						<cfquery name="QLoad" datasource="#args.datasource#">
							SELECT *
							FROM tblPubStock
							WHERE psID=#i#
							LIMIT 1;
						</cfquery>
						<cfif QLoad.recordcount is 1>
							<cfif StructKeyExists(args.form,"psDate")>
								<cfquery name="QUpdateStock" datasource="#args.datasource#">
									UPDATE tblPubStock
									SET psStatus='open'
									WHERE psPubID=#QLoad.psPubID#
									AND psIssue='#QLoad.psIssue#'
									AND psOrderID=#val(QLoad.psOrderID)#
									AND psType='returned'
									AND psDate LIKE '%#Year(args.form.psDate)#%'
								</cfquery>
							</cfif>
							<cfquery name="QDelete" datasource="#args.datasource#">
								DELETE FROM tblPubStock
								WHERE psID=#i#
							</cfquery>
						</cfif>
					</cfloop>
				</cfif>
				<cfset result.msg="Stock record deleted">
			</cftransaction>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="GetPubStockForPrint" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result.list={}>
		<cfset var set={}>
		<cfset var QLoad="">
		<cfset var QUpdate="">
		<cfset var pub="">
		<cfset var date="">
		<cfset var URN="">

		<cftry>
			<cfset date=LSDateFormat(args.form.psDate,"yyyy-mm-dd")>
			<cfquery name="QLoad" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock,tblPublication
				WHERE psDate='#date#'
				AND psType='#args.type#'
				AND psPubID=pubID
				AND pubGroup='#args.group#'
				ORDER BY pubTitle asc
			</cfquery>

			<cfloop query="QLoad">
				<cfif len(QLoad.psURN)><cfset URN=QLoad.psURN></cfif>
				<cfset set={}>
				<cfset set.key=psPubID & psIssue>
				<cfif len(pubShortTitle)>
					<cfset set.Title=pubShortTitle>
				<cfelse>
					<cfset set.Title=pubTitle>
				</cfif>
				<cfset set.Issue=psIssue>
				<cfif StructKeyExists(result.list,set.key)>
					<cfset pub=StructFind(result.list,set.key)>
					<cfset set.Qty=pub.qty+QLoad.psQty>
					<cfset StructUpdate(result.list,set.key,set)>
				<cfelse>
					<cfset set.Qty=QLoad.psQty>
					<cfset StructInsert(result.list,set.key,set)>
				</cfif>
			</cfloop>
			<cfset result.URN=URN>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>	

	<cffunction name="GetPubStockByDate" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QLoad="">
		<cfset var QCheck="">
		<cfset var result.list=ArrayNew(1)>
		<cfset var result.grandtotal=0>
		<cfset var result.vattotal=0>
		<cfset var loc = {}>

		<cftry>
			<cfset result.date=LSDateFormat(args.form.psDate,"yyyy-mm-dd")>
			<cfquery name="QLoad" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock,tblPublication
				WHERE psDate='#result.date#'
				AND psType='#args.type#'
				<!---AND psBatch=#args.form.psBatch#--->
				AND psPubID=pubID
				<cfif StructKeyExists(args,"listOrder")>
					ORDER BY pubTitle asc
				<cfelse>
					<cfif args.form.listOrder is "title">
						ORDER BY pubGroup asc, pubTitle asc
					<cfelseif args.form.listOrder is "entry">
						ORDER BY pubGroup asc, psID asc
					</cfif>
				</cfif>
			</cfquery>
			<cfset result.QLoad = QLoad>
			<cfloop query="QLoad">
				<!--- <cfset loc.sign = int(psAction neq "Returned too late")>		1 or zero --->
				<cfset loc.sign = ListFind("Returned too late,Exceeds supply",psAction,",") eq 0>		<!--- 1 or zero --->
				<cfquery name="QCheck" datasource="#args.datasource#">
					SELECT *
					FROM tblPubStock
					WHERE psPubID=#QLoad.psPubID#
					AND psIssue='#QLoad.psIssue#'
					AND psType='returned'
					AND psStatus='closed'
				</cfquery>
				<cfquery name="QCheckOrder" datasource="#args.datasource#">
					SELECT cltCompanyName,cltName
					FROM tblOrder,tblClients
					WHERE ordID=#QLoad.psOrderID#
					AND ordClientID=cltID
				</cfquery>
				<cfset item={}>
				<cfset item.ID=QLoad.psID>
				<cfset item.OrderStamp="">
				<cfset item.PubID=val(QLoad.pubID)>
				<cfif len(QLoad.pubShortTitle)>
					<cfset item.title=QLoad.pubShortTitle>
				<cfelse>
					<cfset item.title=QLoad.pubTitle>
				</cfif>
				<cfset item.ref=QLoad.psClaimRef>
				<cfset item.supID=QLoad.psSupID>
				<cfset item.Type=QLoad.psType>
				<cfset item.DeliveryDate=DateFormat(QLoad.psDate,"DD/MM/YYYY")>
				<cfset item.psSubType=QLoad.psSubType>
				<cfset item.Issue=QLoad.psIssue>
				<cfset item.ArrivalDay=QLoad.psArrivalDay>
				<cfset item.Qty=QLoad.psQty>
				<cfset item.Action=QLoad.psAction>
				<cfset item.checkQty=QCheck.psQty>
				<cfset item.Retail=QLoad.psRetail>
				<cfset item.DiscountType=QLoad.psDiscountType>
				<cfset item.Discount=QLoad.psDiscount>
				<cfif QCheckOrder.recordcount neq 0>
					<cfif len(QCheckOrder.cltName) AND len(QCheckOrder.cltCompanyName)>
						<cfset item.OrderStamp="#QCheckOrder.cltCompanyName# - #QCheckOrder.cltName#">
					<cfelse>
						<cfset item.OrderStamp="#QCheckOrder.cltCompanyName##QCheckOrder.cltName#">
					</cfif>
				</cfif>
				<cfif QLoad.psVatRate neq 0>
					<cfset item.Vat=QLoad.psVatRate>
				<cfelse>
					<cfset item.Vat=StructFind(application.site.VAT,QLoad.psVat)>
				</cfif>
				<cfset item.LineTotal=(item.Retail*item.Qty/(1+item.Vat)) * loc.sign>
				<cfif item.LineTotal neq 0>
					<cfif item.DiscountType eq "pc">
						<cfset item.LineDisc=item.LineTotal*(item.Discount/100)>
						<cfset item.LineTotal=item.LineTotal-item.LineDisc>
					<cfelse>
						<cfset item.LineDisc=item.Discount*item.Qty>
						<cfset item.LineTotal=item.LineTotal-item.LineDisc>
					</cfif>
					<cfset item.LineTotal=decimalRound(item.LineTotal * loc.sign,2)>
				</cfif>
				<cfset item.VatLineTotal=DecimalFormat(item.LineTotal*item.Vat)>
				<cfset result.vattotal=result.vattotal+item.VatLineTotal>
				<cfset result.grandtotal=ReReplace(result.grandtotal,",","","all")>
				<cfset result.grandtotal=result.grandtotal+item.LineTotal>
				<cfset ArrayAppend(result.list,item)>
				
				<cfif QLoad.psPWRetail neq 0><!--- AND args.type is "received"--->
					<cfset item={}>
					<cfset item.OrderStamp="">
					<cfset item.ID=0>
					<cfset item.ref=QLoad.psClaimRef>
					<cfset item.PubID=val(QLoad.pubID)>
					<cfif len(QLoad.pubShortTitle)>
						<cfset item.title=QLoad.pubShortTitle&" - Part Works">
					<cfelse>
						<cfset item.title=QLoad.pubTitle&" - Part Works">
					</cfif>
					<cfset item.supID=QLoad.psSupID>
					<cfset item.Type=QLoad.psType>
					<cfset item.DeliveryDate=DateFormat(QLoad.psDate,"DD/MM/YYYY")>
					<cfset item.psSubType=QLoad.psSubType>
					<cfset item.Issue=QLoad.psIssue>
					<cfset item.ArrivalDay=QLoad.psArrivalDay>
					<cfset item.Qty=QLoad.psQty>
					<cfset item.Action=QLoad.psAction>
					<cfset item.checkQty=QCheck.psQty>
					<cfset item.Retail=QLoad.psPWRetail>
					<cfset item.DiscountType=QLoad.psDiscountType>
					<cfset item.Discount=QLoad.psDiscount>
					<cfset item.Vat=QLoad.psPWVatRate>
					<cfset item.LineTotal=item.Retail*item.Qty/(1+item.Vat)>
					<cfif item.DiscountType eq "pc">
						<cfset item.LineDisc=item.LineTotal*(item.Discount/100)>
						<cfset item.LineTotal=item.LineTotal-item.LineDisc>
					<cfelse>
						<cfset item.LineDisc=item.Discount*item.Qty>
						<cfset item.LineTotal=item.LineTotal-item.LineDisc>
					</cfif>
					<cfset item.LineTotal=decimalRound(item.LineTotal * loc.sign,2)>
					<cfset item.VatLineTotal=DecimalFormat(item.LineTotal*item.Vat)>
					
					<cfset result.vattotal=result.vattotal+item.VatLineTotal>
					<cfset result.grandtotal=ReReplace(result.grandtotal,",","","all")>
					<cfset result.grandtotal=result.grandtotal+item.LineTotal>
					<cfset ArrayAppend(result.list,item)>
				</cfif>
			</cfloop>

			<cfset result.vattotal=DecimalFormat(result.vattotal)>
			<cfset result.grandtotal=ReReplace(result.grandtotal,",","","all")>
			<cfset result.grandtotal=DecimalFormat(result.grandtotal)>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
					
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPubStockIssues" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QLoad="">
		<cfset var QLoadItem="">
		<cfset var QClient="">
		<cfset var issues={}>
		<cfset var key=0>
		<cfset var i={}>
		<cfset var it={}>
		<cfset var set={}>
		<cfset result.list=[]>
		
		<cftry>
			<cfquery name="QLoad" datasource="#args.datasource#">
				SELECT *
				FROM tblPubStock
				WHERE psPubID=#val(args.pub)#
				<cfif args.type eq 'returned'>
					AND psType IN ('returned','claim')
				<cfelse>
					AND psType='#args.type#'
				</cfif>
				<cfif len(args.date)>AND psDate <='#LSDateFormat(args.date,"yyyy-mm-dd")#'</cfif>
				AND psStatus='open'
				ORDER BY psDate desc
				LIMIT #args.limit#;
			</cfquery>
			<cfif args.currenttype eq "credited" AND QLoad.recordcount is 0>
				<cfquery name="QLoad" datasource="#args.datasource#">
					SELECT *
					FROM tblPubStock
					WHERE psPubID=#args.pub#
					AND psType='claim'
					AND psDate <='#LSDateFormat(args.date,"yyyy-mm-dd")#'
					AND psStatus='open'
					ORDER BY psDate desc
					LIMIT #args.limit#;
				</cfquery>
			</cfif>
			<cfloop query="QLoad">
				<cfset key=psPubID & psIssue & psDate & psOrderID>
				<cfif StructKeyExists(issues,key)>
					<cfset i=StructFind(issues,key)>
					<cfif psQty gt i.Qty>
						<cfset set={}>
						<cfset set.ID=psID>
						<cfset set.Qty=psQty>
						<cfset set.Date=psDate>
						<cfset StructUpdate(issues,key,set)>
					</cfif>
				<cfelse>
					<cfset set={}>
					<cfset set.ID=psID>
					<cfset set.Qty=psQty>
					<cfset set.Date=psDate>
					<cfset StructInsert(issues,key,set)>
				</cfif>
			</cfloop>

			<cfset issuesSort=StructSort(issues,"numeric","desc","Date")>
			<cfloop array="#issuesSort#" index="issue">
				<cfset it=StructFind(issues,issue)>
				<cfquery name="QLoadItem" datasource="#args.datasource#">
					SELECT *
					FROM tblPubStock
					WHERE psID=#it.ID#
				</cfquery>
				<cfset item={}>
				<cfset item.ID=QLoadItem.psID>
				<cfset item.Issue=UCase(QLoadItem.psIssue)>
				<cfset item.psDate=LSDateFormat(QLoadItem.psDate)>
				<cfif QLoadItem.psOrderID neq 0>
					<cfquery name="QClient" datasource="#args.datasource#">
						SELECT cltName,cltCompanyName,ordHouseName,ordHouseNumber
						FROM tblOrder,tblClients
						WHERE ordID=#QLoadItem.psOrderID#
						AND ordClientID=cltID
					</cfquery>
					<cfif QClient.recordcount neq 0>
						<cfif len(QClient.ordHouseName)>
							<cfset item.Client=ListFirst(QClient.ordHouseName," ")>
						<cfelseif len(QClient.cltName)>
							<cfif len(QClient.cltName) AND len(QClient.cltCompanyName)>
								<cfset item.Client="#QClient.cltName# #QClient.cltCompanyName#">
							<cfelse>
								<cfset item.Client="#QClient.cltName##QClient.cltCompanyName#">
							</cfif>
						</cfif>
					<cfelse>
						<cfset item.Client="">
					</cfif>
				<cfelse>
					<cfset item.Client="">
				</cfif>
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
					output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
			</cfcatch>
		</cftry>
					
		<cfreturn result>
	</cffunction>

	<cffunction name="GetPubStockIssue" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset var result={}>
		<cfset var QLoad="">
		<cfset var QCheck="">
		<cfset var QLoadSold="">
		<cfset var QLoadSoldCredit="">
		<cfset var issueID=0>
		<cfset var issue="">
		
		<cftry>
			<cfset loc.issueID=ListFirst(args.issue,"_")>
			<cfset loc.issue=ListLast(args.issue,"_")>
			<cfif val(loc.issueID) neq 0>
				<cfquery name="loc.QLoad" datasource="#args.datasource#">
					SELECT *
					FROM tblPubStock
					WHERE psID=#val(loc.issueID)#
					LIMIT 1;
				</cfquery>
				<cfquery name="loc.QCheck" datasource="#args.datasource#" result="loc.qcheckresult">
					SELECT *
					FROM tblPubStock
					WHERE psPubID=#val(args.pub)#
					AND psIssue='#loc.issue#'
					AND psType='returned'
					AND psDate='#LSDateFormat(args.Date,"yyyy-mm-dd")#'
					AND psOrderID=#val(loc.QLoad.psOrderID)#
					LIMIT 1;
				</cfquery>
				
				<cfquery name="loc.QLoadSold" datasource="#args.datasource#">
					SELECT SUM(diQty) AS SoldTotal
					FROM tblDelItems
					WHERE diPubID=#val(args.pub)#
					AND diType='debit'
					AND diDate='#LSDateFormat(loc.QLoad.psDate,"yyyy-mm-dd")#'
				</cfquery>
				<cfquery name="loc.QLoadSoldCredit" datasource="#args.datasource#">
					SELECT SUM(diQty) AS SoldCreditTotal
					FROM tblDelItems
					WHERE diPubID=#val(args.pub)#
					AND diType='credit'
					AND diDate='#LSDateFormat(loc.QLoad.psDate,"yyyy-mm-dd")#'
				</cfquery>
				<cfif loc.QCheck.recordcount is 0>
					<cfset loc.result.ID=loc.QLoad.psID>
					<cfset loc.result.mode=1>
					<cfset loc.result.returnQty="">
				<cfelse>
					<cfset loc.result.ID=loc.QCheck.psID>
					<cfset loc.result.mode=2>
					<cfset loc.result.returnQty=loc.QCheck.psQty>
				</cfif>
				<cfset loc.result.ref=loc.QLoad.psClaimRef>
				<cfset loc.result.qty=loc.QLoad.psQty>
				<cfset loc.result.Date=DateFormat(loc.QLoad.psDate,"DD MMM YYYY")>
				<cfset loc.result.soldqty=val(loc.QLoadSold.SoldTotal)-val(loc.QLoadSoldCredit.SoldCreditTotal)>
				<cfset loc.result.checkQty=0>
				<cfset loc.result.checkID=0>
			<cfelse>
				<cfset loc.result.ID=0>
				<cfset loc.result.mode=1>
				<cfset loc.result.returnQty=0>
				<cfset loc.result.ref="">
				<cfset loc.result.qty=0>
				<cfset loc.result.Date=DateFormat(now(),"DD MMM YYYY")>
				<cfset loc.result.soldqty=0>
				<cfset loc.result.checkQty=0>
				<cfset loc.result.checkID=0>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="GetPubStockIssue" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
					
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="UpdateReturnedStock" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">

		<cfset var result={}>
		<cfset var QLoad="">
		<cfset var QInsertStock="">
		<cfset var QUpdateStock="">
		<cfset var QResult="">
		<cfset var QCheckReturnQty="">
		<cfset var QCheckCreditQty="">
		<cfset var QLoadSold="">
		<cfset var QLoadReturn="">
		<cfset var status="open">
		<cfset var issueID=0>
		<cfset var issue="">
		<cfset var pubID=0>
		<cfset var qty=1>
		<cfset result.msg="none">
		<cftry>
			<cfif NOT StructIsEmpty(args.form)>
				<cfif StructKeyExists(args.form,"override")>
					<cfset issue=args.form.psIssue>
				<cfelse>
					<cfset issueID=ListFirst(args.form.psIssue,"_")>
					<cfset issue=ListLast(args.form.psIssue,"_")>
				</cfif>
				<cfif StructKeyExists(args.form,"mode") AND args.form.mode is 1 AND val(args.form.psPubID) gt 0>
					<cfif NOT StructKeyExists(args.form,"override")>
						<cfquery name="QLoad" datasource="#args.datasource#">
							SELECT *
							FROM tblPubStock
							WHERE psID=#val(args.form.psID)#
						</cfquery>

						<cfquery name="QLoadReturn" datasource="#args.datasource#">
							SELECT SUM(psQty) AS ReturnTotal
							FROM tblPubStock
							WHERE psPubID=#val(args.form.psPubID)#
							AND psIssue='#issue#'
							AND psType='returned'
							AND psOrderID=#val(QLoad.psOrderID)#
						</cfquery>
						<cfquery name="QLoadSold" datasource="#args.datasource#">
							SELECT SUM(diQty) AS SoldTotal
							FROM tblDelItems
							WHERE diPubID=#val(args.form.psPubID)#
							AND diDate='#LSDateFormat(args.form.psDate,"yyyy-mm-dd")#'
						</cfquery>
					<cfelse>
						<cfquery name="QLoad" datasource="#args.datasource#">
							SELECT *
							FROM tblPubStock
							WHERE psPubID=#val(args.form.psPubID)#
							ORDER BY psDate desc
							LIMIT 1;
						</cfquery>
					</cfif>
					<cfquery name="QInsertStock" datasource="#args.datasource#" result="QResult">
						INSERT INTO tblPubStock (
							psPubID,
							psSupID,
							psType,
							psDate,
							psIssue,
							psArrivalDay,
							psQty,
							psRetail,
							psDiscount,
							psDiscountType,
							psVatRate,
						psPWRetail,
						psPWVatRate,
						psTradePrice,
							psOrderID,
							<cfif StructKeyExists(args.form,"psAction")>psAction,</cfif>
							<cfif StructKeyExists(args.form,"URN")>psURN,</cfif>
							psVat
						) VALUES (
							#val(args.form.psPubID)#,
							'#QLoad.psSupID#',
							'#args.form.psType#',
							'#LSDateFormat(args.form.psDate,"YYYY-MM-DD")#',
							'#issue#',
							#QLoad.psArrivalDay#,
							#args.form.psQty#,
							#QLoad.psRetail#,
							#QLoad.psDiscount#,
							'#QLoad.psDiscountType#',
							#REReplace(QLoad.psVatRate,"%","","all")#,
						#QLoad.psPWRetail#,
						#QLoad.psPWVatRate#,
						#QLoad.psTradePrice#,
							<cfif StructKeyExists(args.form,"psOrderID")>#val(args.form.psOrderID)#,<cfelse>#val(QLoad.psOrderID)#,</cfif>
							<cfif StructKeyExists(args.form,"psAction")>'#args.form.psAction#',</cfif>
							<cfif StructKeyExists(args.form,"URN")>'#args.form.URN#',</cfif>
							#QLoad.psVat#
						)
					</cfquery>
					<cfif NOT StructKeyExists(args.form,"override")>
						<cfif StructKeyExists(args.form,"psType") AND args.form.psType eq "credited">
							<cfquery name="QCheckReturnQty" datasource="#args.datasource#">
								SELECT SUM(psQty) AS TotalReturnQty
								FROM tblPubStock
								WHERE psPubID=#val(args.form.psPubID)#
								AND psIssue='#issue#'
								AND psType='returned'
								AND psOrderID=#val(QLoad.psOrderID)#
								AND psDate LIKE '%#Year(args.form.psDate)#%'
							</cfquery>
							<cfquery name="QCheckCreditQty" datasource="#args.datasource#">
								SELECT SUM(psQty) AS TotalCreditQty
								FROM tblPubStock
								WHERE psPubID=#val(args.form.psPubID)#
								AND psIssue='#issue#'
								AND psType='credited'
								AND psOrderID=#val(QLoad.psOrderID)#
								AND psDate LIKE '%#Year(args.form.psDate)#%'
							</cfquery>
							<cfif StructKeyExists(args.form,"psAction") AND args.form.psAction neq "Credited">
								<cfquery name="QUpdateStock" datasource="#args.datasource#">
									UPDATE tblPubStock
									SET psStatus='closed'
									WHERE psPubID=#val(args.form.psPubID)#
									AND psIssue='#issue#'
									AND psOrderID=#val(QLoad.psOrderID)#
									AND (psType='returned' OR psType='credited')
									AND psDate LIKE '%#Year(args.form.psDate)#%'
								</cfquery>
							<cfelse>
								<cfif QCheckReturnQty.TotalReturnQty lte QCheckCreditQty.TotalCreditQty>
									<cfquery name="QUpdateStock" datasource="#args.datasource#">
										UPDATE tblPubStock
										SET psStatus='closed'
										WHERE psPubID=#val(args.form.psPubID)#
										AND psIssue='#issue#'
										AND psOrderID=#val(QLoad.psOrderID)#
										AND (psType='returned' OR psType='credited')
										AND psDate LIKE '%#Year(args.form.psDate)#%'
									</cfquery>
								</cfif>
							</cfif>
						</cfif>
					</cfif>
					<cfset result.msg="Done">
				<cfelseif NOT StructKeyExists(args.form,"override")>
					<cfquery name="QUpdateReturn" datasource="#args.datasource#">
						UPDATE tblPubStock
						SET psQty=#args.form.psQty#
						WHERE psID=#val(args.form.psID)#
					</cfquery>
					<cfset result.msg="Done">
				<cfelse>
					<cfset result.msg="Mode is #args.form.mode# nothing happened">
				</cfif>
			<cfelse>
				<cfset result.msg="Form has not been passed">
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
					
		<cfreturn result>
	</cffunction>

	<cffunction name="AddPubClaim" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QLoad="">
		<cfset var QInsert="">
		<cfset var issueID=0>
		<cfset var issue="">
		<cfset loc = {}>
		
		<cftry>
			<cfset issueID=ListFirst(args.form.psIssue,"_")>
			<cfset issue=ListLast(args.form.psIssue,"_")>
			<cfquery name="QLoad" datasource="#args.datasource#">
				SELECT *
				FROM tblPublication
				LEFT JOIN tblPubStock ON pubID=psPubID
				WHERE pubID=#val(args.form.psPubID)#
				<cfif args.form.psID gt 0>AND psID=#val(args.form.psID)#</cfif>
			</cfquery>

			<cfif QLoad.recordcount gt 0>
				<cfset loc.discType = QLoad.pubDiscType>
			<cfelse><cfset loc.discType = 'pc'></cfif>
			<cfquery name="QInsert" datasource="#args.datasource#">
				INSERT INTO tblPubStock (
					psPubID,
					psSupID,
					psType,
					psDate,
					psIssue,
					psQty,
					psRetail,
					psDiscount,
					psDiscountType,
						psPWRetail,
						psPWVatRate,
						psTradePrice,
					psClaimRef
				) VALUES (
					#val(args.form.psPubID)#,
					'#QLoad.pubWholesaler#',
					'#args.form.psType#',
					'#LSDateFormat(args.form.psDate,"YYYY-MM-DD")#',
					'#issue#',
					#args.form.psQty#,
					#val(QLoad.pubPrice)#,
					#val(QLoad.pubDiscount)#,
					'#loc.discType#',
						#val(QLoad.psPWRetail)#,
						#val(QLoad.psPWVatRate)#,
						#val(QLoad.psTradePrice)#,
					'#args.form.psRef#'
				)
			</cfquery>
			<cfset result.msg="Done">
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
					
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublicationOptions" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCategories="">
		<cfset var QTypes="">
		
		<cfset result.types=[]>
		<cfset result.categories=[]>
		<cfquery name="QTypes" datasource="#args.datasource#">
			SELECT pubType
			FROM tblPublication
			WHERE pubType<>''
			GROUP BY pubType
		</cfquery>
		<cfquery name="QCategories" datasource="#args.datasource#">
			SELECT pubCategory
			FROM tblPublication
			WHERE pubCategory<>''
			GROUP BY pubCategory
		</cfquery>
		<cfloop query="QTypes">
			<cfset ArrayAppend(result.types,pubType)>
		</cfloop>
		<cfloop query="QCategories">
			<cfset ArrayAppend(result.categories,pubCategory)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadPublicationList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPublications="">
		
		<cfquery name="QPublications" datasource="#args.datasource#">
			SELECT tblPublication.*, (SELECT COUNT(*) FROM tblOrderItem WHERE oiPubID=pubID) as ordCount
			FROM tblPublication
			WHERE 1=1
			<cfif val(args.form.srchRefFrom) gt 0> 
				AND (pubRef>=#val(args.form.srchRefFrom)# AND pubRef<=#val(args.form.srchRefTo)#)
			</cfif>
			<cfif len(args.form.srchTitle) gt 0> AND pubTitle LIKE '%#args.form.srchTitle#%'</cfif>
			<cfif len(args.form.srchCategory) gt 0> AND pubCategory LIKE '%#args.form.srchCategory#%'</cfif>
			<cfif len(args.form.srchType) gt 0> AND pubType='#args.form.srchType#'</cfif>
			<cfif args.form.srchArrival gt 0> AND pubArrival=#args.form.srchArrival#</cfif>
			<cfif len(args.form.srchGroup) gt 0> AND pubGroup='#args.form.srchGroup#'</cfif>
			ORDER BY #args.form.srchSort#
		</cfquery>
		<cfset result.pubs=QPublications>
		<cfreturn result>
	</cffunction>

	<cffunction name="PubOrders" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QPub="">
		<cfset var QOrders="">
		<cfset var QOrderItems="">
		<cfset var parms={}>
		<cfset var item={}>
		
		<cfquery name="QPub" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubRef=#args.ref#
		</cfquery>
		<cfquery name="QOrderItems" datasource="#args.datasource#">
			SELECT *
			FROM tblOrderItem, tblOrder, tblPublication, tblClients
			WHERE pubRef=#args.ref#
			AND cltID=ordClientID
			AND oiOrderID=ordID
			AND oiPubID=pubID
			AND cltAccountType<>"N"
		</cfquery>
		<cfset result.clientorders=[]>
		<cfset result.totals={}>
		<cfset result.totals.qtymon=0>
		<cfset result.totals.qtytue=0>
		<cfset result.totals.qtywed=0>
		<cfset result.totals.qtythu=0>
		<cfset result.totals.qtyfri=0>
		<cfset result.totals.qtysat=0>
		<cfset result.totals.qtysun=0>
		<cfset result.totals.line=0>
		<cfloop query="QOrderItems">
			<cfset item={}>
			<cfset item.ref=cltRef>
			<cfset item.name=cltName>
			<cfset item.accountType=cltAccountType>
			<cfset item.qtymon=oiMon>
			<cfset item.qtytue=oiTue>
			<cfset item.qtywed=oiWed>
			<cfset item.qtythu=oiThu>
			<cfset item.qtyfri=oiFri>
			<cfset item.qtysat=oiSat>
			<cfset item.qtysun=oiSun>
			<cfset item.linePerWeek=(oiMon*QPub.pubPrice1)+(oiTue*QPub.pubPrice2)+(oiWed*QPub.pubPrice3)+(oiThu*QPub.pubPrice4)+(oiFri*QPub.pubPrice5)
				+(oiSat*QPub.pubPrice6)+(oiSun*QPub.pubPrice7)>
			<cfset ArrayAppend(result.clientorders,item)>
			<cfset result.totals.qtymon=result.totals.qtymon+item.qtymon>
			<cfset result.totals.qtytue=result.totals.qtytue+item.qtytue>
			<cfset result.totals.qtywed=result.totals.qtywed+item.qtywed>
			<cfset result.totals.qtythu=result.totals.qtythu+item.qtythu>
			<cfset result.totals.qtyfri=result.totals.qtyfri+item.qtyfri>
			<cfset result.totals.qtysat=result.totals.qtysat+item.qtysat>
			<cfset result.totals.qtysun=result.totals.qtysun+item.qtysun>
			<cfset result.totals.line=result.totals.line+item.linePerWeek>
		</cfloop>
		<cfset result.pub.ref=QPub.pubRef>
		<cfset result.pub.title=QPub.pubTitle>
		<cfset result.pub.price1=QPub.pubPrice1>
		<cfset result.pub.price2=QPub.pubPrice2>
		<cfset result.pub.price3=QPub.pubPrice3>
		<cfset result.pub.price4=QPub.pubPrice4>
		<cfset result.pub.price5=QPub.pubPrice5>
		<cfset result.pub.price6=QPub.pubPrice6>
		<cfset result.pub.price7=QPub.pubPrice7>
		<cfset result.orderItems=QOrderItems>
		<cfreturn result>
	</cffunction>

	<cffunction name="SavePubs" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i="">
		<cfset var rec={}>
		<cfset var QPub="">
		<cfif application.site.showdumps><cfdump var="#args#" label="SavePubs" expand="no"></cfif>

		<cfset result.pubRecs=[]>
		
		<cfif StructKeyExists(args.form,"recordCount")>
			<cfloop from="1" to="#args.form.recordCount#" index="i">
				<cfset rec={}>
				<cfset rec.ID=ListGetAt(args.form.ID,i,",")>
				<cfset rec.pubType=ListGetAt(args.form.pubType,i,",")>
				<cfset rec.pubArrival=ListGetAt(args.form.pubArrival,i,",")>
				<cfset rec.pubPrice1=ListGetAt(args.form.pubPrice1,i,",")>
				<cfset rec.pubPrice2=ListGetAt(args.form.pubPrice2,i,",")>
				<cfset rec.pubPrice3=ListGetAt(args.form.pubPrice3,i,",")>
				<cfset rec.pubPrice4=ListGetAt(args.form.pubPrice4,i,",")>
				<cfset rec.pubPrice5=ListGetAt(args.form.pubPrice5,i,",")>
				<cfset rec.pubPrice6=ListGetAt(args.form.pubPrice6,i,",")>
				<cfset rec.pubPrice7=ListGetAt(args.form.pubPrice7,i,",")>
				<cfset ArrayAppend(result.pubRecs,rec)>
				<cfquery name="QPub" datasource="#args.datasource#">
					UPDATE tblPublication
					SET
						pubType='#rec.pubType#',
						pubArrival=#rec.pubArrival#,
						pubPrice1=#rec.pubPrice1#,
						pubPrice2=#rec.pubPrice2#,
						pubPrice3=#rec.pubPrice3#,
						pubPrice4=#rec.pubPrice4#,
						pubPrice5=#rec.pubPrice5#,
						pubPrice6=#rec.pubPrice6#,
						pubPrice7=#rec.pubPrice7#						
					WHERE pubID=#rec.ID#
				</cfquery>
			</cfloop>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SavePayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		<cfset var setFlag=0>
		<cfset var QResult="">
		<cfset var i=0>
		<cfset var actParms={}>
		
		<cftry>
			<cfset result.tickList="">
			<cfloop from="1" to="#args.form.tranCount#" index="i">
				<cfif StructKeyExists(args.form,"tick#i#")>
					<cfset result.tickList=ListAppend(result.tickList,StructFind(args.form,"tick#i#"),",")>
				</cfif>
			</cfloop>
			<cfset result.preticked=ListLen(result.tickList,",")>
			<cfif StructKeyExists(args.form,"btnClicked") AND args.form.btnClicked eq "btnSavePayment">
				<cfquery name="QTrans" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblTrans (
						trnAccountID,
						trnClientID,
						trnClientRef,
						trnRef,
						trnDate,
						trnMethod,
						trnType,
						trnAlloc,
						trnAmnt1,
						trnAmnt2
					) VALUES (
						4,
						#val(args.form.clientID)#,
						#val(args.form.clientRef)#,
						'#args.form.trnRef#',
						'#LSDateFormat(args.form.trnDate,"yyyy-mm-dd")#',
						<cfif args.form.trnType eq 'pay'>'#args.form.trnMethod#'<cfelse>''</cfif>,
						'#args.form.trnType#',
						#int(result.preticked gt 0)#,
						#-1*val(args.form.trnAmnt1)#,
						#-1*val(args.form.trnAmnt2)#
					)
				</cfquery>
				<cfset result.qresult=qresult>
				<cfset result.tickList=ListAppend(result.tickList,qresult.generatedkey,",")>
			</cfif>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans
				WHERE trnClientRef=#val(args.form.clientRef)#
				<cfif NOT StructKeyExists(args.form,"allTrans")>AND trnAlloc=0</cfif>
				ORDER BY trnDate
			</cfquery>
			<cfset result.trans=qtrans>
			<cfloop query="QTrans">
				<cfif result.preticked AND ListFind(result.tickList,trnID,",")>
					<cfset setFlag=1>
				<cfelse><cfset setFlag=0></cfif>
				<cfquery name="QPub" datasource="#args.datasource#">
					UPDATE tblTrans
					SET trnAlloc=#setFlag#
					WHERE trnID=#trnID#
					LIMIT 1;
				</cfquery>				
			</cfloop>
	
			<cfset actParms={}>
			<cfset actParms.datasource=args.datasource>
			<cfset actParms.type="payment">
			<cfset actParms.class="added">
			<cfset actParms.clientID=args.form.clientID>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
								
		<cfcatch type="any">
			<cfset result.error=cfcatch>
			<cfdump var="#cfcatch#" label="SavePayments" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="SaveCreditPayment" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QTrans="">
		
		<cftry>
			<cfquery name="QTrans" datasource="#args.datasource#">
				INSERT INTO tblTrans (
					trnAccountID,
					trnClientID,
					trnClientRef,
					trnRef,
					trnDate,
					trnMethod,
					trnDesc,
					trnType,
					trnAmnt1,
					trnAmnt2
				) VALUES (
					4,
					#val(args.form.clientID)#,
					#val(args.form.clientRef)#,
					'#args.form.crnRef#',
					'#LSDateFormat(args.form.crnDate,"yyyy-mm-dd")#',
					'',
					'#args.form.crnDesc#',
					'crn',
					-#val(args.form.crnAmnt1)#,
					-#val(args.form.crnAmnt2)#
				)
			</cfquery>
				
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
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
			<cfset result.clients=[]>		
			<cfset result.balances=[]>		
			<cfquery name="QClients" datasource="#args.datasource#" result="QResult">
				SELECT cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltAccountType,cltPayType,cltPayMethod,cltChase,cltChaseDate
				FROM tblClients
				WHERE true
				<cfif len(StructFind(args.form,"srchType"))>
					<cfif args.form.srchType eq 'notN'>
						AND cltAccountType <> "N"
					<cfelse>
						AND cltAccountType="#args.form.srchType#"
					</cfif>
				</cfif>
				<!---<cfif len(StructFind(args.form,"srchType"))>AND cltAccountType="#args.form.srchType#"</cfif>--->
				<cfif len(StructFind(args.form,"srchPayType"))>AND cltPayType="#args.form.srchPayType#"</cfif>
				<cfif len(StructFind(args.form,"srchMethod"))>AND cltPayMethod="#args.form.srchMethod#"</cfif>
				<cfif len(StructFind(args.form,"srchName"))>AND (cltName LIKE "%#args.form.srchName#%" OR cltCompanyName LIKE "%#args.form.srchName#%")</cfif>
				<cfif StructKeyExists(args.form,"srchSkipInactive")>AND cltAccountType <> "N"</cfif>
				<cfif len(args.form.srchSort)>ORDER BY #args.form.srchSort#</cfif>
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
				<cfset item.balance0=0>
				<cfset item.balance1=0>
				<cfset item.balance2=0>
				<cfset item.balance3=0>
				<cfset item.balance4=0>
				<cfset item.date1=DateAdd("d",-28,Now())>
				<cfquery name="QTrans" datasource="#args.datasource#">
					SELECT *
					FROM tblTrans
					WHERE trnClientRef=#val(item.ref)#
					<cfif StructKeyExists(args.form,"srchSkipAllocated")>AND trnAlloc=0</cfif>
					ORDER BY trnDate
				</cfquery>
				<cfloop query="QTrans">
					<cfset item.balance0=item.balance0+trnAmnt1>
					<cfif DateCompare(trnDate,DateAdd("d",-28,Now())) gt 0>
						<cfset item.balance1=item.balance1+trnAmnt1>
					<cfelseif DateCompare(trnDate,DateAdd("d",-56,Now())) gt 0>
						<cfset item.balance2=item.balance2+trnAmnt1>
					<cfelseif DateCompare(trnDate,DateAdd("d",-84,Now())) gt 0>
						<cfset item.balance3=item.balance3+trnAmnt1>
					<cfelse>
						<cfset item.balance4=item.balance4+trnAmnt1>
					</cfif>
					<cfif trnType eq "pay">
						<cfif StructKeyExists(item.methods,trnMethod)>
							<cfset method=StructFind(item.methods,trnMethod)>
							<cfset StructUpdate(item.methods,trnMethod,method+1)>
						<cfelse>
							<cfset StructInsert(item.methods,trnMethod,1)>
						</cfif>
					</cfif>
				</cfloop>
				<cfif StructKeyExists(args.form,"srchUpdate")>
					<cfset method=0>
					<cfloop collection="#item.methods#" item="methodItem">
						<cfif StructFind(item.methods,methodItem) gt method>
							<cfset item.methodKey=methodItem>
						</cfif>
					</cfloop>
					<cfquery name="QTrans" datasource="#args.datasource#">
						UPDATE tblClients
						SET cltPayMethod='#item.methodKey#'
						WHERE cltRef=#cltRef#
					</cfquery>
				</cfif>
				<cfif item.balance0 eq 0 AND skipZeros>
				<cfelseif (item.balance0 gt minVal OR minVal eq 0)>
					<cfset ArrayAppend(result.clients,item)>
					<cfset ArrayAppend(result.balances,"#Numberformat(item.balance0,'000000.00')#_#ArrayLen(result.clients)#")>
				</cfif>
			</cfloop>
			<cfset ArraySort(result.balances,"text","desc")>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="AgedDebtorsold" access="public" returntype="struct">
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
		
		<cfset result.clients=[]>		
		<cfquery name="QClients" datasource="#args.datasource#" result="QResult">
			SELECT cltRef,cltTitle,cltInitial,cltName,cltCompanyName,cltAccountType,cltPayType,cltPayMethod
			FROM tblClients
			WHERE true
			<cfif len(StructFind(args.form,"srchType"))>
				<cfif args.form.srchType eq 'notN'>
					AND cltAccountType <> "N"
				<cfelse>
					AND cltAccountType="#args.form.srchType#"
				</cfif>
			</cfif>
			<!---<cfif len(StructFind(args.form,"srchType"))>AND cltAccountType="#args.form.srchType#"</cfif>--->
			<cfif len(StructFind(args.form,"srchPayType"))>AND cltPayType="#args.form.srchPayType#"</cfif>
			<cfif len(StructFind(args.form,"srchMethod"))>AND cltPayMethod="#args.form.srchMethod#"</cfif>
			<cfif len(StructFind(args.form,"srchName"))>AND (cltName LIKE "%#args.form.srchName#%" OR cltCompanyName LIKE "%#args.form.srchName#%")</cfif>
			<cfif StructKeyExists(args.form,"srchSkipInactive")>AND cltAccountType <> "N"</cfif>
			<cfif len(args.form.srchSort)>ORDER BY #args.form.srchSort#</cfif>
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
			<cfset item.balance0=0>
			<cfset item.balance1=0>
			<cfset item.balance2=0>
			<cfset item.balance3=0>
			<cfset item.balance4=0>
			<cfset item.date1=DateAdd("d",-28,Now())>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans
				WHERE trnClientRef=#val(item.ref)#
				<cfif StructKeyExists(args.form,"srchSkipAllocated")>AND trnAlloc=0</cfif>
				ORDER BY trnDate
			</cfquery>
			<cfloop query="QTrans">
				<cfset item.balance0=item.balance0+trnAmnt1>
				<cfif DateCompare(trnDate,DateAdd("d",-28,Now())) gt 0>
					<cfset item.balance1=item.balance1+trnAmnt1>
				<cfelseif DateCompare(trnDate,DateAdd("d",-56,Now())) gt 0>
					<cfset item.balance2=item.balance2+trnAmnt1>
				<cfelseif DateCompare(trnDate,DateAdd("d",-84,Now())) gt 0>
					<cfset item.balance3=item.balance3+trnAmnt1>
				<cfelse>
					<cfset item.balance4=item.balance4+trnAmnt1>
				</cfif>
				<cfif trnType eq "pay">
					<cfif StructKeyExists(item.methods,trnMethod)>
						<cfset method=StructFind(item.methods,trnMethod)>
						<cfset StructUpdate(item.methods,trnMethod,method+1)>
					<cfelse>
						<cfset StructInsert(item.methods,trnMethod,1)>
					</cfif>
				</cfif>
			</cfloop>
			<cfif StructKeyExists(args.form,"srchUpdate")>
				<cfset method=0>
				<cfloop collection="#item.methods#" item="methodItem">
					<cfif StructFind(item.methods,methodItem) gt method>
						<cfset item.methodKey=methodItem>
					</cfif>
				</cfloop>
				<cfquery name="QTrans" datasource="#args.datasource#">
					UPDATE tblClients
					SET cltPayMethod='#item.methodKey#'
					WHERE cltRef=#cltRef#
				</cfquery>
			</cfif>
			<cfif item.balance0 eq 0 AND skipZeros>
			<cfelseif (item.balance0 gt minVal OR minVal eq 0)>
				<cfset ArrayAppend(result.clients,item)>
			</cfif>
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SalesReport" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClients=0>
		<cfset var QTrans=0>
		<cfset var item={}>
		<cfset var QResult="">
		<cfset var skipZeros=StructKeyExists(args.form,"srchIgnoreZero")>

		<cfset result.clients=[]>
		<cfquery name="QClients" datasource="#args.datasource#" result="QResult">
			SELECT cltRef,cltName,cltCompanyName,cltAccountType,cltPayType,cltPayMethod,cltVoucher
			FROM tblClients
			WHERE true
			<cfif len(StructFind(args.form,"srchName"))>AND cltName LIKE "%#args.form.srchName#%"</cfif>
			<cfif len(StructFind(args.form,"srchType"))>
				<cfif args.form.srchType eq 'notN'>
					AND cltAccountType <> "N"
				<cfelse>
					AND cltAccountType="#args.form.srchType#"
				</cfif>
			</cfif>
			<cfif len(StructFind(args.form,"srchPayType"))>
				<cfif args.form.srchPayType eq 'noshop'>
					AND cltPayType <> "shop"
				<cfelse>
					AND cltPayType = '#args.form.srchPayType#'
				</cfif>
			</cfif>
			<cfif len(args.form.srchSort)>
				ORDER BY #args.form.srchSort#
			</cfif>
		</cfquery>
		<cfif val(args.form.srchMin) gt 0><cfset minVal=val(args.form.srchMin)>
			<cfelse><cfset minVal=0></cfif>
		<cfset result.QResult=QResult>
		<cfloop query="QClients">
			<cfset item={}>
			<cfset item.ref=cltRef>
			<cfif len(cltName) is 0><cfset item.name=cltCompanyName>
				<cfelse><cfset item.name=cltName></cfif>
			<cfset item.type=cltAccountType>
			<cfset item.payType=cltPayType>
			<cfset item.payMethod=cltPayMethod>
			<cfset item.voucher=GetToken(" ,V",cltVoucher+1,",")>
			<cfset item.balance0=0>
			<cfset item.balance1=0>
			<cfset item.balance2=0>
			<cfset item.balance3=0>
			<cfset item.balance4=0>
			<cfset item.balance5=0>
			<cfset item.balance6=0>
			<cfset item.balance7=0>
			<cfset item.balance8=0>
			<cfset item.balance9=0>
			<cfset item.balance10=0>
			<cfset item.balance11=0>
			<cfset item.balance12=0>
			<cfquery name="QTrans" datasource="#args.datasource#">
				SELECT *
				FROM tblTrans
				WHERE trnClientRef=#val(item.ref)#
				<cfif len(args.form.srchDateFrom)>
					AND trnDate>='#args.form.srchDateFrom#'
					AND trnDate<='#args.form.srchDateTo#'
				</cfif>
				AND (trnType IN ('inv','crn') OR trnMethod='sv')
				ORDER BY trnDate
			</cfquery>
			<cfloop query="QTrans">
				<cfset item.balance0=item.balance0+trnAmnt1>
				<cfswitch expression="#Month(trnDate)#">
					<cfcase value="1"><cfset item.balance1=item.balance1+trnAmnt1></cfcase>
					<cfcase value="2"><cfset item.balance2=item.balance2+trnAmnt1></cfcase>
					<cfcase value="3"><cfset item.balance3=item.balance3+trnAmnt1></cfcase>
					<cfcase value="4"><cfset item.balance4=item.balance4+trnAmnt1></cfcase>
					<cfcase value="5"><cfset item.balance5=item.balance5+trnAmnt1></cfcase>
					<cfcase value="6"><cfset item.balance6=item.balance6+trnAmnt1></cfcase>
					<cfcase value="7"><cfset item.balance7=item.balance7+trnAmnt1></cfcase>
					<cfcase value="8"><cfset item.balance8=item.balance8+trnAmnt1></cfcase>
					<cfcase value="9"><cfset item.balance9=item.balance9+trnAmnt1></cfcase>
					<cfcase value="10"><cfset item.balance10=item.balance10+trnAmnt1></cfcase>
					<cfcase value="11"><cfset item.balance11=item.balance11+trnAmnt1></cfcase>
					<cfcase value="12"><cfset item.balance12=item.balance12+trnAmnt1></cfcase>
				</cfswitch>
			</cfloop>
			<cfif item.balance0 gt 0 OR NOT skipZeros>
				<cfset ArrayAppend(result.clients,item)>
			</cfif>
		</cfloop>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadPrintList" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QClient="">
		
		<cftry>
			<cfquery name="QClient" datasource="#args.datasource#">
				SELECT *
				FROM tblRoundItems,tblClients,tblStreets
				WHERE 1
				<cfif len(args.form.type)>AND cltAccountType='#args.form.type#'</cfif>
				<cfif len(args.form.roundID)>AND riRoundRef=#args.form.roundID#</cfif>
				AND stRef=cltStreetCode
				AND cltID=riClientID
				ORDER BY riOrder
			</cfquery>
			<cfset result.list=ArrayNew(1)>
			<cfloop query="QClient">
				<cfset item={}>
				<cfset item.ID=cltID>
				<cfset item.Ref=cltRef>
				<cfset item.Name=cltName>
				<cfset item.Addr1=cltAddr1>
				<cfset item.Addr2=cltAddr2>
				<cfset item.Town=cltTown>
				<cfset item.City=cltCity>
				<cfset item.Postcode=cltPostcode>
				
				<cfset ArrayAppend(result.list,item)>
			</cfloop>
			<cfset result.count=QClient.recordcount>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="PrintStatements" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		
		<cftry>
			<cfif StructKeyExists(args,"client")>
				<cfquery name="QClient" datasource="#args.datasource#">
					SELECT cltID,cltName
					FROM tblClients
					WHERE cltID=#args.client#
				</cfquery>
				<cfset s="#application.site.dir_data#statements\">
				<cfset f="stat_#QClient.cltID#.pdf">
				<cfif FileExists("#s##f#")>
					<cfset result.ID=QClient.cltID>
					<cfset result.Name=QClient.cltName>
					<cfset result.file="#application.site.url_data#statements/#f#">
					<cfset result.status="Ok">
				<cfelse>
					<cfset result.ID=QClient.cltID>
					<cfset result.Name=QClient.cltName>
					<cfset result.file="">
					<cfset result.status="File not found">
				</cfif>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadHolidays" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var item={}>
		<cfset var i={}>
		<cfset var QHoliday="">
		<cfset var QHolidayItems="">
		
		<cfquery name="QHoliday" datasource="#args.datasource#">
			SELECT *
			FROM tblHolidayOrder
			WHERE hoOrderID=#args.rec.OrderID#
			ORDER BY hoStop desc
		</cfquery>
		<cfloop query="QHoliday">
			<cfquery name="QHolidayItems" datasource="#args.datasource#">
				SELECT *
				FROM tblHolidayItem,tblPublication,tblOrderItem
				WHERE hiHolidayID=#val(QHoliday.hoID)#
				AND hiOrderItemID=oiID
				AND oiPubID=pubID
			</cfquery>
			<cfset item={}>
			<cfset item.ID=hoID>
			<cfset item.orderID=hoOrderID>
			<cfset item.stop=LSDateFormat(hoStop,"dd-mmm-yyyy")>
			<cfif len(hoStart)>
				<cfset item.start=LSDateFormat(hoStart,"dd-mmm-yyyy")>
			<cfelse>
				<cfset item.start="">
			</cfif>
			<cfset item.items=ArrayNew(1)>
			<cfif QHolidayItems.recordcount gt 0>
				<cfloop query="QHolidayItems">
					<cfset i={}>
					<cfset i.ID=QHolidayItems.hiID>
					<cfset i.PubID=QHolidayItems.hiOrderItemID>
					<cfset i.PubTitle=QHolidayItems.pubTitle>
					<cfset i.Action=QHolidayItems.hiAction>
					
					<cfset ArrayAppend(item.items,i)>
				</cfloop>
			</cfif>
			
			<cfset ArrayAppend(result.list,item)>
		</cfloop>
		<cfreturn result>
	</cffunction>

	<cffunction name="SaveHoliday" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QSaveHoliday="">
		<cfset var QSaveHolidayItems="">
		<cfset var QCheckDelItems="">
		<cfset var QAddCredit="">
		<cfset var QCheckOrdItem="">
		<cfset var QDeleteItems="">
		<cfset var QClients="">
		<cfset var QPubTitle="">
		<cfset var QEmail="">
		<cfset var Price=0>
		<cfset var orderAction="">
		<cfset var actStart="UFN">
		<cfset var publist="">
		<cfset var orderID=0>
		<cfset var vchParms={}>
		<cfset var emailParms={}>
		<cfset var emailPubs=[]>
		<cfset var emailPub={}>
		<cfset var restartTxt="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"hoStop")>			
				<cfquery name="QSaveHoliday" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblHolidayOrder (
						hoOrderID,
						<cfif StructKeyExists(args.form,"hoStart")>hoStart,</cfif>
						hoStop
					) VALUES (
						#args.form.orderRef#,
						<cfif StructKeyExists(args.form,"hoStart")>'#LSDateFormat(args.form.hoStart,"yyyy-mm-dd")#',</cfif>
						'#LSDateFormat(args.form.hoStop,"yyyy-mm-dd")#'
					)
				</cfquery>
				<cfset holID=QResult.generatedKey>
				<cfif StructKeyExists(args.form,"OrderPub")>
					<cfloop list="#args.form.OrderPub#" delimiters="," index="i">
						<cfset orderAction=StructFind(args.form,"OrderAction" & i)>
						<cfquery name="QCheckOrdItem" datasource="#args.datasource#">
							SELECT *
							FROM tblOrderItem,tblOrder
							WHERE oiID=#i#
							AND oiOrderID=ordID
							LIMIT 1;
						</cfquery>
						<cfquery name="QCheckDelItems" datasource="#args.datasource#">
							SELECT *
							FROM tblDelItems
							WHERE diOrderID=#args.form.orderRef#
							AND diPubID=#val(QCheckOrdItem.oiPubID)#
							AND diType='debit'
							AND diDate >= '#LSDateFormat(args.form.hoStop,"yyyy-mm-dd")#'
							<cfif NOT StructKeyExists(args.form,"hoUFN")>AND diDate <= '#LSDateFormat(args.form.hoStart,"yyyy-mm-dd")#'</cfif>
							AND diInvoiceID=0
						</cfquery>
						<cfquery name="QPubTitle" datasource="#args.datasource#">
							SELECT pubTitle
							FROM tblPublication
							WHERE pubID=#val(QCheckOrdItem.oiPubID)#
							LIMIT 1;
						</cfquery>
						
						<cfset emailPub={}>
						<cfset emailPub.pubTitle=QPubTitle.pubTitle>
						<cfif orderAction is "hold"><cfset emailPub.Action="Hold Back"><cfelse><cfset emailPub.Action="Stop"></cfif>
						<cfset ArrayAppend(emailPubs,emailPub)>
						
						<cfif QCheckDelItems.recordcount neq 0>
							<cfloop query="QCheckDelItems">
								<cfif orderAction is "cancel">
									<cfquery name="QCheckCredit" datasource="#args.datasource#">
										SELECT *
										FROM tblDelItems
										WHERE diOrderID=#args.form.orderRef#
										AND diPubID=#val(QCheckOrdItem.oiPubID)#
										AND diType='credit'
										AND diDate='#LSDateFormat(QCheckDelItems.diDate,"yyyy-mm-dd")#'
									</cfquery>
									<cfif QCheckCredit.recordcount is 0>
										<cfquery name="QAddCredit" datasource="#args.datasource#">
											INSERT INTO tblDelItems (
												diClientID,diOrderID,diBatchID,diPubID,diType,diDatestamp,diDate,diQty,diPrice,diCharge,diVATAmount,diTest,diVoucher,diReason
											) VALUES (
												#QCheckDelItems.diClientID#,
												#QCheckDelItems.diOrderID#,
												#QCheckDelItems.diBatchID#,
												#QCheckDelItems.diPubID#,
												'credit',
												'#LSDateFormat(QCheckDelItems.diDate,'yyyy-mm-dd')#',
												'#LSDateFormat(QCheckDelItems.diDate,'yyyy-mm-dd')#',
												#QCheckDelItems.diQty#,
												#DecimalFormat(0-QCheckDelItems.diPrice)#,
												#DecimalFormat(0-QCheckDelItems.diCharge)#,
												#QCheckDelItems.diVATAmount#,
												#QCheckDelItems.diTest#,
												#QCheckDelItems.diVoucher#,
												'On Holiday'
											)
										</cfquery>
									</cfif>
								<cfelseif orderAction is "stop">
									<cfquery name="QDeleteItems" datasource="#args.datasource#">
										DELETE FROM tblDelItems
										WHERE diOrderID=#args.form.orderRef#
										AND diPubID=#val(QCheckOrdItem.oiPubID)#
										AND diDate >= '#LSDateFormat(args.form.hoStop,"yyyy-mm-dd")#'
										<cfif NOT StructKeyExists(args.form,"hoUFN")>AND diDate <= '#LSDateFormat(args.form.hoStart,"yyyy-mm-dd")#'</cfif>
										AND diInvoiceID=0
									</cfquery>
								<cfelse>
									<cfquery name="QUpdateCharge" datasource="#args.datasource#">
										UPDATE tblDelItems
										SET diClientID=#QCheckDelItems.diClientID#,
											diOrderID=#QCheckDelItems.diOrderID#,
											diBatchID=#QCheckDelItems.diBatchID#,
											diPubID=#QCheckDelItems.diPubID#,
											diType='#QCheckDelItems.diType#',
											diDatestamp='#LSDateFormat(QCheckDelItems.diDate,'yyyy-mm-dd')#',
											diDate='#LSDateFormat(QCheckDelItems.diDate,'yyyy-mm-dd')#',
											diQty=#QCheckDelItems.diQty#,
											diPrice=#DecimalFormat(0-QCheckDelItems.diPrice)#,
											diCharge=0,
											diVATAmount=#QCheckDelItems.diVATAmount#,
											diTest=#QCheckDelItems.diTest#,
											diVoucher=#QCheckDelItems.diVoucher#
										WHERE diID=#QCheckDelItems.diID#
									</cfquery>
								</cfif>
							</cfloop>
						</cfif>
						<cfquery name="QSaveHolidayItems" datasource="#args.datasource#">
							INSERT INTO tblHolidayItem (
								hiHolidayID,
								hiOrderItemID,
								hiAction
							) VALUES (
								#holID#,
								#i#,
								'#orderAction#'
							)
						</cfquery>
						<cfset actParms={}>
						<cfset actParms.datasource=args.datasource>
						<cfset actParms.type="holiday">
						<cfset actParms.class="added">
						<cfset actParms.clientID=QCheckOrdItem.ordClientID>
						<cfset actParms.pubID=0>
						<cfif StructKeyExists(args.form,"hoStart")><cfset actStart='#LSDateFormat(args.form.hoStart,"dd mm yy")#'></cfif>
						<cfset actParms.Text="From: #LSDateFormat(args.form.hoStop,"dd mm yy")# - To: #actStart#">
						<cfset actInsert=AddActivity(actParms)>
						
						<cfset orderID=val(QCheckOrdItem.ordID)>
						<cfif len(publist)>
							<cfset publist=publist&","&val(QCheckOrdItem.oiID)>
						<cfelse>
							<cfset publist=val(QCheckOrdItem.oiID)>
						</cfif>
					</cfloop>
				</cfif>
				<cfset result.msg="Holiday has been added successfully">
				
				<cfif StructKeyExists(args.form,"returnVouchers")>					
					<cfset vchParms={}>
					<cfset vchParms.datasource=args.datasource>
					<cfset vchParms.form.oiOrderID=val(orderID)>
					<cfset vchParms.form.OrderPub=publist>
					<cfset vchParms.form.vchStart=LSDateFormat(args.form.hoStop,"yyyy-mm-dd")>
					<cfif StructKeyExists(args.form,"hoStart")>
						<cfset vchParms.form.vchStop=LSDateFormat(args.form.hoStart,"yyyy-mm-dd")>
					<cfelse>
						<cfset vchParms.form.vchStop="">
					</cfif>
					<cfset result.vchReturn=ReturnVoucher(vchParms)>
				</cfif>
				
				<!--- Auto Email section --->
				<cfif StructKeyExists(args.form,"autoEmail")>
					<cfquery name="QClients" datasource="#args.datasource#">
						SELECT *
						FROM tblClients
						WHERE cltID=#val(args.form.cltID)#
						LIMIT 1;
					</cfquery>
					<cfquery name="QEmail" datasource="#args.datasource#">
						SELECT *
						FROM tblEmail
						WHERE mailRef='#args.emailTemplate#'
						LIMIT 1;
					</cfquery>
					<cfif len(QClients.cltEmail)>
						<cfset emailParms={}>
						<cfset emailParms.datasource=args.datasource>
						<cfset emailParms.Email=QClients.cltEmail>
						<cfset emailParms.Name="">
						<cfif len(QClients.cltName) AND len(QClients.cltCompanyName)>
							<cfif len(QClients.cltTitle)>
								<cfset emailParms.Name="#QClients.cltTitle# ">
							<cfelse>
								<cfif len(QClients.cltInitial)><cfset emailParms.Name=emailParms.Name&"#QClients.cltInitial# "></cfif>
							</cfif>
							<cfset emailParms.Name=emailParms.Name&"#QClients.cltName#, #QClients.cltCompanyName#">
						<cfelse>
							<cfif len(QClients.cltName)>
								<cfif len(QClients.cltTitle)>
									<cfset emailParms.Name="#QClients.cltTitle# ">
								<cfelse>
									<cfif len(QClients.cltInitial)><cfset emailParms.Name=emailParms.Name&"#QClients.cltInitial# "></cfif>
								</cfif>
							</cfif>
							<cfset emailParms.Name=emailParms.Name&"#QClients.cltName##QClients.cltCompanyName#">
						</cfif>
						
						<cfset emailParms.Subject=QEmail.mailSubject>
						<cfset emailParms.message=QEmail.mailText>
						<cfset emailParms.pubs="">
						<cfset emailParms.pubsarray=emailPubs>
						<cfloop array="#emailPubs#" index="i">
							<cfset emailParms.pubs=emailParms.pubs&"<li>#i.pubTitle# - #i.action#</li>">
						</cfloop>
						<cfif StructKeyExists(args.form,"hoStart")>
							<cfset restartTxt='Start delivery on <b>#LSDateFormat(args.form.hoStart,"ddd dd mmm yyyy")#</b>'>
						<cfelse>
							<cfset restartTxt='Until further notice.'>
						</cfif>
						<cfset emailParms.Text="
							<p>#emailParms.message#</p>
							<p>Stop delivery on <b>#LSDateFormat(args.form.hoStop,"ddd dd mmm yyyy")#</b><br>#restartTxt#</p>
							<p>Publications affected:
								<ul>
									#emailParms.pubs#
								</ul>
							</p>
						">
						<cfset AutoEmail(emailParms)>
					</cfif>
				</cfif>
				<!--- end --->
								
			<cfelse>
				<cfset result.msg="Please enter a stop date.">
			</cfif>
			
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="ReturnVoucher" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QOrderItem="">
		<cfset var QVouchers="">
		<cfset var QVoucherReturn="">
		<cfset result.msg="">
		<cfset result.info="">
				
		<cftry>			
			<cfif StructKeyExists(args.form,"OrderPub")>
				<cfquery name="QOrderItem" datasource="#args.datasource#">
					SELECT *
					FROM tblOrderItem
					WHERE oiID IN (#args.form.OrderPub#)
				</cfquery>
				<cfloop query="QOrderItem">
					<cfquery name="QVouchers" datasource="#args.datasource#">
						SELECT *
						FROM tblVoucher
						WHERE vchOrderID=#val(QOrderItem.oiOrderID)#
						AND vchPubID=#val(QOrderItem.oiPubID)#
						AND vchStatus='in'
						<!---  TODO - Make more accurate--->
						AND (vchStart >= '#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#' OR vchStart <= '#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#')
						<cfif len(args.form.vchStop)>AND (vchStop <= '#LSDateFormat(DateAdd("d",-1,args.form.vchStop),"yyyy-mm-dd")#' OR vchStop >= '#LSDateFormat(DateAdd("d",-1,args.form.vchStop),"yyyy-mm-dd")#')</cfif>
					</cfquery>
					<cfif QVouchers.recordcount neq 0>
						<cfquery name="QVoucherReturn" datasource="#args.datasource#">
							INSERT INTO tblVoucher (
								vchStatus,
								vchOrderID,
								vchPubID,
								vchStart,
								vchStop
							) VALUES (
								'out',
								#val(QOrderItem.oiOrderID)#,
								#val(QOrderItem.oiPubID)#,
								'#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#',
								<cfif len(args.form.vchStop)>'#LSDateFormat(DateAdd("d",-1,args.form.vchStop),"yyyy-mm-dd")#'<cfelse>NULL</cfif>
							)
						</cfquery>
						<cfset result.msg="Vouchers returned">
						<cfif len(args.form.vchStop)>
							<cfset result.info="<h2>Vouchers Found</h2><p>Customer has vouchers, please remove these vouchers from the folder to give back to the customer.</p><p>From: #LSDateFormat(args.form.vchStart,"yyyy-mm-dd")# - To: #LSDateFormat(DateAdd("d",-1,args.form.vchStop),"yyyy-mm-dd")#</p>">
						<cfelse>
							<cfset result.info="<h2>Vouchers Found</h2><p>Customer has vouchers, please remove these vouchers from the folder to give back to the customer.</p><p>From: #LSDateFormat(args.form.vchStart,"yyyy-mm-dd")# - To: Last</p>">
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="UpdateHoliday" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QSaveHoliday="">
		<cfset var QClient="">
		
		<cftry>
			<cfquery name="QSaveHoliday" datasource="#args.datasource#">
				UPDATE tblHolidayOrder 
				SET hoStart='#LSDateFormat(args.form.restartDate,"yyyy-mm-dd")#'
				WHERE hoID=#val(args.form.holID)#
			</cfquery>
			<cfset result.msg="Holiday Updated">

			<cfquery name="QClient" datasource="#args.datasource#">
				SELECT ordClientID
				FROM tblHolidayOrder,tblOrder
				WHERE hoID=#val(args.form.holID)#
				AND hoOrderID=ordID
			</cfquery>
			<cfset actParms={}>
			<cfset actParms.datasource=application.site.datasource1>
			<cfset actParms.type="holiday">
			<cfset actParms.class="updated">
			<cfset actParms.clientID=QClient.ordClientID>
			<cfset actParms.pubID=0>
			<cfset actParms.Text="">
			<cfset actInsert=AddActivity(actParms)>
			
			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="DeleteHoliday" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QDelHoliday="">
		<cfset var QCheckHol="">
		<cfset var QDelHolidayItems="">
		<cfset var QClient="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"line")>
				<cfloop list="#args.form.line#" delimiters="," index="i">
					<cfquery name="QCheckHol" datasource="#args.datasource#">
						SELECT *
						FROM tblHolidayItem,tblHolidayOrder,tblOrderItem
						WHERE hiHolidayID=#i#
						AND hoID=hiHolidayID
						AND hiOrderItemID=oiID
					</cfquery>
					<cfif QCheckHol.recordcount neq 0>
						<cfloop query="QCheckHol">
							<cfquery name="QDeleteItems" datasource="#args.datasource#">
								DELETE FROM tblDelItems
								WHERE diOrderID=#QCheckHol.oiOrderID#
								AND diPubID=#QCheckHol.oiPubID#
								<cfif QCheckHol.hiAction neq "stop">AND diType='credit'</cfif>
								AND diDate >= '#LSDateFormat(QCheckHol.hoStop,"yyyy-mm-dd")#'
								<cfif Len(QCheckHol.hoStart)>AND diDate <= '#LSDateFormat(QCheckHol.hoStart,"yyyy-mm-dd")#'</cfif>
								AND diInvoiceID=0
							</cfquery>
						</cfloop>
					</cfif>
					<cfquery name="QClient" datasource="#args.datasource#">
						SELECT ordClientID
						FROM tblHolidayOrder,tblOrder
						WHERE hoID=#val(i)#
						AND hoOrderID=ordID
					</cfquery>
					<cfset actParms={}>
					<cfset actParms.datasource=application.site.datasource1>
					<cfset actParms.type="holiday">
					<cfset actParms.class="removed">
					<cfset actParms.clientID=QClient.ordClientID>
					<cfset actParms.pubID=0>
					<cfset actParms.Text="">
					<cfset actInsert=AddActivity(actParms)>
		
					<cfquery name="QDelHolidayItems" datasource="#args.datasource#">
						DELETE FROM tblHolidayItem 
						WHERE hiHolidayID=#i#
					</cfquery>
					<cfquery name="QDelHoliday" datasource="#args.datasource#">
						DELETE FROM tblHolidayOrder 
						WHERE hoID=#i#
					</cfquery>
					
				</cfloop>
			</cfif>
			<cfset result.msg="Holidays Removed">

			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadVouchers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QVouchers="">
		
		<cfquery name="QVouchers" datasource="#args.datasource#">
			SELECT *
			FROM tblVoucher,tblPublication
			WHERE vchOrderID=#val(args.form.orderID)#
			AND vchPubID=pubID
			ORDER BY vchStart desc, pubTitle asc
		</cfquery>
		<cfloop query="QVouchers">
			<cfset item={}>
			<cfset item.ID=vchID>
			<cfset item.status=vchStatus>
			<cfset item.orderID=vchOrderID>
			<cfset item.pub=pubTitle>
			<cfset item.start=LSDateFormat(vchStart,"DD/MM/YYYY")>
			<cfset item.stop=LSDateFormat(vchStop,"DD/MM/YYYY")>
			<cfset item.type=vchType>
			<cfset item.discount=vchDiscount>
			<cfset ArrayAppend(result.list,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AddVoucher" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var emailParms={}>
		<cfset var emailPubs="">
		<cfset var i="">
		<cfset var QVoucher="">
		<cfset var QOrderItem="">
		<cfset var QResult="">
		<cfset var QCheckDelItems="">
		<cfset var QUpdateDelItem="">
		<cfset var QClients="">
		<cfset var QEmail="">
		<cfset var QPub="">
		
		<cftry>			
			<cfif StructKeyExists(args.form,"OrderPub")>
				<cfloop list="#args.form.OrderPub#" delimiters="," index="i">
					<cfquery name="QOrderItem" datasource="#args.datasource#">
						SELECT *
						FROM tblOrderItem,tblOrder
						WHERE oiOrderID=#val(args.form.oiOrderID)#
						AND oiID=#val(i)#
						AND oiOrderID=ordID
					</cfquery>
					<cfquery name="QPub" datasource="#args.datasource#">
						SELECT pubTitle
						FROM tblPublication
						WHERE pubID=#val(QOrderItem.oiPubID)#
						LIMIT 1;
					</cfquery>
					<cfif len(QPub.pubTitle)><cfset emailPubs=emailPubs&"<li>#QPub.pubTitle#</li>"></cfif>
					<cfquery name="QVoucher" datasource="#args.datasource#" result="QResult">
						INSERT INTO tblVoucher (
							vchOrderID,
							vchPubID,
							vchStart,
							vchStop,
							vchType,
							vchDiscount
						) VALUES (
							#val(args.form.oiOrderID)#,
							#val(QOrderItem.oiPubID)#,
							'#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#',
							'#LSDateFormat(args.form.vchStop,"yyyy-mm-dd")#',
							<cfif val(args.form.vchDiscount) neq 0>
								'#args.form.vchType#',
								#val(args.form.vchDiscount)#
							<cfelse>
								'pc',
								100
							</cfif>
						)
					</cfquery>
					
					<cfset actParms={}>
					<cfset actParms.datasource=application.site.datasource1>
					<cfset actParms.type="voucher">
					<cfset actParms.class="added">
					<cfset actParms.clientID=QOrderItem.ordClientID>
					<cfset actParms.pubID=QOrderItem.oiPubID>
					<cfset actParms.Text="">
					<cfset actInsert=AddActivity(actParms)>
										
					<cfquery name="QCheckDelItems" datasource="#args.datasource#">
						SELECT diID
						FROM tblDelItems
						WHERE diOrderID=#val(args.form.oiOrderID)#
						AND diPubID=#val(QOrderItem.oiPubID)#
						AND diDate >= '#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#'
						AND diDate <= '#LSDateFormat(args.form.vchStop,"yyyy-mm-dd")#'
						AND diVoucher=0
					</cfquery>
					<cfloop query="QCheckDelItems">
						<cfquery name="QUpdateDelItem" datasource="#args.datasource#">
							UPDATE tblDelItems
							SET diVoucher=#val(QResult.generatedKey)#
							WHERE diID=#val(QCheckDelItems.diID)#
						</cfquery>
					</cfloop>
				</cfloop>
				<cfset result.msg="Voucher added">
				
				<!--- Auto Email section --->
				<cfif StructKeyExists(args.form,"autoEmail")>
					<cfquery name="QClients" datasource="#args.datasource#">
						SELECT *
						FROM tblClients
						WHERE cltID=#val(args.form.cltID)#
						LIMIT 1;
					</cfquery>
					<cfquery name="QEmail" datasource="#args.datasource#">
						SELECT *
						FROM tblEmail
						WHERE mailRef='#args.emailTemplate#'
						LIMIT 1;
					</cfquery>
					<cfif len(QClients.cltEmail)>
						<cfset emailParms={}>
						<cfset emailParms.datasource=args.datasource>
						<cfset emailParms.Email=QClients.cltEmail>
						<cfset emailParms.Name="">
						<cfif len(QClients.cltName) AND len(QClients.cltCompanyName)>
							<cfif len(QClients.cltTitle)>
								<cfset emailParms.Name="#QClients.cltTitle# ">
							<cfelse>
								<cfif len(QClients.cltInitial)><cfset emailParms.Name=emailParms.Name&"#QClients.cltInitial# "></cfif>
							</cfif>
							<cfset emailParms.Name=emailParms.Name&"#QClients.cltName#, #QClients.cltCompanyName#">
						<cfelse>
							<cfif len(QClients.cltName)>
								<cfif len(QClients.cltTitle)>
									<cfset emailParms.Name="#QClients.cltTitle# ">
								<cfelse>
									<cfif len(QClients.cltInitial)><cfset emailParms.Name=emailParms.Name&"#QClients.cltInitial# "></cfif>
								</cfif>
							</cfif>
							<cfset emailParms.Name=emailParms.Name&"#QClients.cltName##QClients.cltCompanyName#">
						</cfif>
						
						<cfset emailParms.Subject=QEmail.mailSubject>
						<cfset emailParms.message=QEmail.mailText>
						<cfset emailParms.Text="
							<p>#emailParms.message#</p>
							<p>Vouchers start on <b>#LSDateFormat(args.form.vchStart,"dd mmm yyyy")#</b><br>Vouchers stop on <b>#LSDateFormat(args.form.vchStop,"dd mmm yyyy")#</b></p>
							<p>Publications vouchers assigned to:
								<ul>
									#emailPubs#
								</ul>
							</p>
						">
						<cfset AutoEmail(emailParms)>
					</cfif>
				</cfif>
				<!--- end --->
			<cfelse>
				<cfset result.msg="Publication not found">
			</cfif>

			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="CheckVoucherInRange" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i="">
		<cfset var QNewVoucherRange="">
		
		<cftry>			
			<cfif StructKeyExists(args.form,"OrderPub")>
				<cfloop list="#args.form.OrderPub#" delimiters="," index="i">
					<cfquery name="QOrderItem" datasource="#args.datasource#">
						SELECT *
						FROM tblOrderItem
						WHERE oiOrderID=#val(args.form.oiOrderID)#
						AND oiID=#val(i)#
					</cfquery>
					<cfquery name="QVoucher" datasource="#args.datasource#">
						SELECT *
						FROM tblVoucher
						WHERE vchOrderID=#val(args.form.oiOrderID)#
						AND vchPubID=#val(QOrderItem.oiPubID)#
						AND (vchStart <= '#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#' OR vchStart >= '#LSDateFormat(args.form.vchStart,"yyyy-mm-dd")#')
						AND (vchStop >= '#LSDateFormat(args.form.vchStop,"yyyy-mm-dd")#' OR vchStop <= '#LSDateFormat(args.form.vchStop,"yyyy-mm-dd")#')
					</cfquery>
				</cfloop>
			<cfelse>
				<cfset result.msg="Publication not found">
			</cfif>
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="DeleteVouchers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var i=0>
		<cfset var QVouchers="">
		<cfset var QUpdateDelItem="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"line")>
				<cfloop list="#args.form.line#" delimiters="," index="i">
					<cfquery name="QUpdateDelItem" datasource="#args.datasource#">
						UPDATE tblDelItems
						SET diVoucher=0
						WHERE diVoucher=#i#
					</cfquery>
				</cfloop>
				<cfquery name="QVouchers" datasource="#args.datasource#">
					DELETE FROM tblVoucher 
					WHERE vchID IN (#args.form.line#)
				</cfquery>
			</cfif>
			<cfset result.msg="Vouchers Removed">

			<cfcatch type="any">
				<cfset result.msg=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadVoucherReport" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QClients="">
		
		<cfquery name="QClients" datasource="#args.datasource#">
			SELECT *
			FROM tblClients,tblOrder
			WHERE 1
			<cfif StructKeyExists(args.form,"client") AND val(args.form.client) neq 0>AND cltID IN (#args.form.client#)</cfif>
			AND cltID=ordClientID
			ORDER BY cltName asc
		</cfquery>
		<cfloop query="QClients">
			<cfset item={}>
			<cfset item.orderID=ordID>
			<cfset item.clientID=cltID>
			<cfset item.clientRef=cltRef>
			<cfif len(cltName) AND len(cltCompanyName)>
				<cfset item.clientName="#cltName# #cltCompanyName#">
			<cfelse>
				<cfset item.clientName="#cltName##cltCompanyName#">
			</cfif>
			<cfset parm={}>
			<cfset parm.datasource=args.datasource>
			<cfset parm.orderID=item.orderID>
			<cfif StructKeyExists(args.form,"pub")><cfset parm.pubID=args.form.pub></cfif>
			<cfif StructKeyExists(args.form,"showExp")><cfset parm.showExp=true></cfif>
			<cfif StructKeyExists(args.form,"showCurrent")><cfset parm.showCurrent=true></cfif>
			<cfset item.vouchers=ExpiringVouchers(parm)>
			<cfif ArrayLen(item.vouchers)>
				<cfset ArrayAppend(result,item)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadClientList" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var item={}>
		<cfset var QClient="">

		<cfquery name="QClient" datasource="#args.datasource#">
			SELECT cltID,cltRef,cltName,cltCompanyName
			FROM tblClients
			WHERE cltAccountType <> 'N'
		</cfquery>
		<cfloop query="QClient">
			<cfset item={}>
			<cfset item.ID=cltID>
			<cfset item.Ref=cltRef>
			<cfset item.Name=cltName>
			<cfif len(cltName) AND len(cltCompanyName)>
				<cfset item.Name="#cltName# #cltCompanyName#">
			<cfelse>
				<cfset item.Name="#cltName##cltCompanyName#">
			</cfif>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="LoadSuppTimes" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var result.list=ArrayNew(1)>
		<cfset var QTimes="">
		<cfset var total=0>
		<cfset var count=0>
		
		<cfquery name="QTimes" datasource="#args.datasource#">
			SELECT *
			FROM tblDelTimes
			WHERE dtmSupp='DASH'
			ORDER BY dtmSupp asc, dtmTime asc
		</cfquery>
		<cfloop query="QTimes">
			<cfset item={}>
			<cfset item.ID=dtmID>
			<cfset item.Supp=dtmSupp>
			<cfset item.Date=DateFormat(dtmTime,"DD/MM/YY")>
			<cfset item.Time=TimeFormat(dtmTime,"HH:mm")>
			<cfset total=total+TimeFormat(item.Time,"HHmm")>
			<cfset count=count+1>
			<cfset ArrayAppend(result.list,item)>
		</cfloop>
		
		<cfset result.total=total/count>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadShopSaveAccounts" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=ArrayNew(1)>
		<cfset var parm={}>
		<cfset var load={}>
		<cfset var QClients="">
		<cfset var loc = {}>
		
		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT * 
				FROM tblClients,tblOrder
				WHERE cltPayType='shop'
				AND (cltAccountType='M' OR cltAccountType='W')
				AND cltPaymentType='weekly'
				AND ordClientID=cltID
				GROUP BY cltID
				ORDER BY cltName asc
			</cfquery>
			<cfloop query="QClients">
				<cfset parm={}>
				<cfset parm.datasource=application.site.datasource1>
				<cfset parm.rec.cltRef=cltRef>
				<cfset load={}>
				<cfset load=LoadClientOrder(parm)>
				
				<cfquery name="loc.QLatestInv" datasource="#args.datasource#">
					SELECT trnDate
					FROM tblTrans 
					WHERE trnClientRef = #parm.rec.cltRef# 
					AND trnType = 'inv'
					ORDER BY trnDate DESC 
					LIMIT 1
				</cfquery>
				<cfif loc.QLatestInv.recordcount eq 1>
					<cfset load.lastDate = loc.QLatestInv.trnDate>
				<cfelse>
					<cfset load.lastDate = DateAdd("d",-28,application.controls.nextInvDate)>
				</cfif>
				<cfquery name="loc.QBalance" datasource="#args.datasource#">
					SELECT SUM(trnAmnt1) AS total
					FROM tblTrans
					WHERE trnClientRef = #parm.rec.cltRef#
					AND trnDate <= #load.lastDate# 
					AND trnAlloc = 0
				</cfquery>
				<cfset load.balance = val(loc.QBalance.total)>
				<cfset ArrayAppend(result,load)>
			</cfloop>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadBankSheet" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QBanking="">
		
		<cfquery name="QBanking" datasource="#args.datasource#">
			SELECT * 
			FROM tblTrans,tblClients
			WHERE trnType='pay'
			AND (trnMethod='coll' OR trnMethod='chq' OR trnMethod='chqs')
			AND trnClientRef=cltRef
			<cfif StructKeyExists(args.form,"date")>AND trnPaidIn=#LSDateFormat(args.form.date,"yymmdd")#<cfelse>AND trnPaidIn=0</cfif>
			ORDER BY trnID asc
		</cfquery>
		<cfset result.TotalCash=0>
		<cfset result.TotalChq=0>
		<cfset result.cash=ArrayNew(1)>
		<cfset result.chq=ArrayNew(1)>
		<cfloop query="QBanking">
			<cfset item={}>
			<cfset item.ID=trnID>
			<cfset item.Ledger=trnLedger>
			<cfset item.AccountID=trnAccountID>
			<cfset item.ClientRef=trnClientRef>
			<cfif len(cltCompanyName)>
				<cfset item.ClientName=cltCompanyName>
			<cfelse>
				<cfset item.ClientName=cltName>
			</cfif>
			<cfset item.Type=trnType>
			<cfset item.Ref=trnRef>
			<cfset item.Desc=trnDesc>
			<cfset item.Method=trnMethod>
			<cfset item.Date=LSDateFormat(trnDate,"dd/mm/yyyy")>
			<cfset item.Amnt1=-trnAmnt1>
			<cfset item.Amnt2=-trnAmnt2>
			<cfset item.Alloc=trnAlloc>
			<cfset item.PaidIn=trnPaidIn>
			<cfset item.Active=trnActive>
			
			<cfif item.Method is "coll">
				<cfset result.TotalCash +=item.Amnt1>
				<cfset ArrayAppend(result.cash,item)>
			<cfelse>
				<cfset result.TotalChq += item.Amnt1>
				<cfset ArrayAppend(result.chq,item)>
			</cfif>
		</cfloop>
				
		<cfreturn result>
	</cffunction>
	
	<cffunction name="BankPayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBank="">
		<cfset var test=false>
		
		<cftry>
			<cfif StructKeyExists(args.form,"selectitem") AND NOT test>
				<cfloop list="#args.form.selectitem#" delimiters="," index="i">
					<cfquery name="QBank" datasource="#args.datasource#">
						UPDATE tblTrans
						SET trnPaidIn="#LSDateFormat(Now(),"yymmdd")#"
						WHERE trnID=#i#
						AND trnPaidIn=0
					</cfquery>
				</cfloop>
			</cfif>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadBankedPayments" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QBanking="">
		
		<cftry>
			<cfif StructKeyExists(args.form,"selectitem")>
				<cfquery name="QBanking" datasource="#args.datasource#">
					SELECT * 
					FROM tblTrans,tblClients
					WHERE trnID IN (#args.form.selectitem#)
					AND trnClientRef=cltRef
					ORDER BY trnID asc
				</cfquery>
			</cfif>
			<cfset result.TotalCash=0>
			<cfset result.TotalChq=0>
			<cfset result.cash=ArrayNew(1)>
			<cfset result.chq=ArrayNew(1)>
			<cfloop query="QBanking">
				<cfset item={}>
				<cfset item.ID=trnID>
				<cfset item.Ledger=trnLedger>
				<cfset item.AccountID=trnAccountID>
				<cfset item.ClientRef=trnClientRef>
				<cfif len(cltCompanyName)>
					<cfset item.ClientName=cltCompanyName>
				<cfelse>
					<cfset item.ClientName=cltName>
				</cfif>
				<cfset item.Type=trnType>
				<cfset item.Ref=trnRef>
				<cfset item.Desc=trnDesc>
				<cfset item.Method=trnMethod>
				<cfset item.Date=LSDateFormat(trnDate,"dd/mm/yyyy")>
				<cfset item.Amnt1=trnAmnt1>
				<cfset item.Amnt2=trnAmnt2>
				<cfset item.Alloc=trnAlloc>
				<cfset item.PaidIn=trnPaidIn>
				<cfset item.Active=trnActive>
				
				<cfif item.Method is "coll">
					<cfset result.TotalCash=result.TotalCash+item.Amnt1>
					<cfset ArrayAppend(result.cash,item)>
				<cfelse>
					<cfset result.TotalChq=result.TotalChq+item.Amnt1>
					<cfset ArrayAppend(result.chq,item)>
				</cfif>
			</cfloop>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
				
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadDoorCodes" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QCodes="">

		<cfquery name="QCodes" datasource="#args.datasource#">
			SELECT * 
			FROM tblDoorCodes
			WHERE 1
			ORDER BY dcName asc
		</cfquery>
		<cfloop query="QCodes">
			<cfset item={}>
			<cfset item.ID=dcID>
			<cfset item.Name=dcName>
			<cfset item.Code=dcCode>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AddDoorCode" access="remote" returntype="struct">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="name" type="string" required="yes">
		<cfargument name="code" type="string" required="yes">
		<cfset var result={}>
		<cfset var QCode="">

		<cfquery name="QCode" datasource="#datasource#">
			INSERT INTO tblDoorCodes (
				dcName,
				dcCode
			) VALUES (
				'#Name#',
				'#code#'
			)
		</cfquery>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateDoorCode" access="remote" returntype="struct">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="code" type="string" required="yes">
		<cfargument name="ID" type="numeric" required="yes">
		<cfset var result={}>
		<cfset var QCode="">

		<cfquery name="QCode" datasource="#datasource#">
			UPDATE tblDoorCodes
			SET dcCode='#code#'
			WHERE dcID=#ID#
		</cfquery>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="RemoveDoorCodes" access="remote" returntype="struct">
		<cfargument name="datasource" type="string" required="yes">
		<cfargument name="items" type="string" required="yes">
		<cfset var result={}>
		<cfset var QCode="">

		<cfquery name="QCode" datasource="#datasource#">
			DELETE FROM tblDoorCodes
			WHERE dcID IN (#items#)
		</cfquery>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="SaveNewDelCode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCode="">

		<cfquery name="QCode" datasource="#args.datasource#">
			UPDATE tblOrder
			SET ordDelCodeNew=#val(args.form.value)#
			WHERE ordID=#val(args.form.order)#
		</cfquery>
		<cfset result.msg="Saved">
		
		<cfreturn result>
	</cffunction>

</cfcomponent>




