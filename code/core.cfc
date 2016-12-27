<cfcomponent displayname="core" extends="CMSCode/CoreFunctions">

	<cffunction name="RoundDec" returntype="numeric" hint="Validates arguments then rounds number to n places">
		<cfargument name="num" type="any" required="no" default="0">
		<cfargument name="places" type="any" required="no" default="2" hint="positive integer">
		<cfset var loc={}>
		<cfif NOT IsNumeric(num)><cfreturn 0></cfif>
		<cfset loc.places=abs(val(places))>
		<cfif loc.places gt 0>
			<cfset loc.decimalPlaces=Left("__________",loc.places)>
			<cfset loc.multiplier=10^loc.places>
			<cfset loc.newNum=Round(num*loc.multiplier)/loc.multiplier>
			<cfset loc.newNum=Replace(NumberFormat(loc.newNum,"_________.#loc.decimalPlaces#")," ","","all")>
		<cfelse>
			<cfset loc.newNum=Round(num)>
		</cfif>
		<cfreturn loc.newNum>
	</cffunction>

	<cffunction name="GetDatasource" access="public" returntype="any">
		<cfreturn application.site.datasource1>
	</cffunction>
	
	<cffunction name="GetVatTypes" access="public" returntype="array">
		<cfset var loc = {}>
		<cfquery name="loc.types" datasource="#GetDatasource()#">
			SELECT *
			FROM tblVATRates
			WHERE vatCode != 0
		</cfquery>
		<cfreturn QueryToArrayOfStruct(loc.types)>
	</cffunction>
	
	<cffunction name="GetSuspenseAccount" access="public" returntype="numeric">
		<cfreturn 31>
	</cffunction>
	
	<cffunction name="GetSettlementAccount" access="public" returntype="numeric">
		<cfargument name="type" type="string" required="yes">
		<cfif type eq "sales">
			<cfreturn 101>
		<cfelse>
			<cfreturn 111>
		</cfif>
	</cffunction>
	
	<cffunction name="GetNominalVATRecordID" access="public" returntype="numeric">
		<cfreturn 21><!---DEV[1152]--->
	</cffunction>

	<cffunction name="AddClientPayNomItems" access="public" returntype="numeric">
		<cfargument name="tranID" type="numeric" required="yes">
		<cfargument name="amount" type="numeric" required="yes">
		<cfargument name="balAcct" type="numeric" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		
		<cftry>
			<cfquery name="loc.QLoadTran" datasource="#GetDatasource()#">
				SELECT *
				FROM tblTrans
				WHERE trnID=#val(tranID)#
				LIMIT 1;
			</cfquery>
			<cfif loc.QLoadTran.recordCount EQ 1>
				<cfswitch expression="#loc.QLoadTran.trnMethod#">
					<cfcase value="card">
						<cfset loc.nomID=191>
					</cfcase>
					<cfcase value="cash">
						<cfset loc.nomID=871>	<!--- was 181 --->
					</cfcase>
					<cfcase value="chq|chqs" delimiters="|">
						<cfset loc.nomID=1472>
					</cfcase>
					<cfcase value="coll">
						<cfset loc.nomID=1482>
					</cfcase>
					<cfcase value="dv">
						<cfset loc.nomID=231>
					</cfcase>
					<cfcase value="ib">
						<cfset loc.nomID=41>
					</cfcase>
					<cfcase value="qchq|qs|qsib|qslost" delimiters="|">
						<cfset loc.nomID=1561>
					</cfcase>
					<cfcase value="cp">
						<cfset loc.nomID=1752>
					</cfcase>
					<cfcase value="na">
						<cfset loc.nomID=31>
					</cfcase>
					<cfdefaultcase>
						<cfset loc.nomID=31>	<!--- suspense --->
					</cfdefaultcase>
				</cfswitch>
				<cfquery name="loc.InsertItem" datasource="#GetDatasource()#">
					INSERT INTO tblNomItems 
						(niNomID,niTranID,niAmount) 
					VALUES 
						(#loc.nomID#,#tranID#,#amount#),
						(#balAcct#,#tranID#,#-amount#)
				</cfquery>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn 1>
	</cffunction>

<!---	<cffunction name="GetSpecialAccounts" access="public" returntype="struct">
		<cfargument name="type" type="string" required="yes">
		<cfset var loc={}>
		<cfquery name="loc.Nominals" datasource="#GetDatasource()#">
			SELECT nomID,nomTitle,nomType,nomGroup,nomClass
			FROM tblNominal
			WHERE nomID < 161
		</cfquery>
		<cfloop query="loc.Nominals">
			<cfif type eq "sales">
				<cfswitch expression="#nomID#">
					<cfcase value="1"></cfcase>
				</cfswitch>
			<cfelse>
			</cfif>
		</cfloop>
	</cffunction>--->
	
	<cffunction name="LoadActivity" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QActivity="">
		<cfset var QClient="">
		<cfset var startDate=DateAdd("d",-args.days,Now())>

		<cfquery name="QActivity" datasource="#args.datasource#">
			SELECT *
			FROM tblActivity
			WHERE actTimestamp >= '#LSDateFormat(startDate,"yyyy-mm-dd")#'
			GROUP BY actClientID, actType, actClass, actText
			ORDER BY actTimestamp desc
		</cfquery>
		<cfloop query="QActivity">
			<cfquery name="QClient" datasource="#args.datasource#">
				SELECT cltRef,cltName,cltCompanyName,cltDelTel
				FROM tblClients
				WHERE cltID=#actClientID#
				LIMIT 1;
			</cfquery>
			<cfquery name="QPub" datasource="#args.datasource#">
				SELECT pubTitle
				FROM tblPublication
				WHERE pubID=#val(actPubID)#
				LIMIT 1;
			</cfquery>
			<cfset item={}>
			<cfset item.ID=actID>
			<cfset item.Timestamp=actTimestamp>
			<cfset item.Pub=QPub.pubTitle>
			<cfset item.Type="#actType# #actClass#">
			<cfset item.Ref=QClient.cltRef>
			<cfif actClientID neq 0>
				<cfif len(QClient.cltName) AND len(QClient.cltCompanyName)>
					<cfset item.Text="(#QClient.cltRef#) #QClient.cltName# #QClient.cltCompanyName#">
				<cfelse>
					<cfset item.Text="(#QClient.cltRef#) #QClient.cltName##QClient.cltCompanyName#">
				</cfif>
				<cfset item.Info=actText>
			<cfelse>
				<cfset item.Text=actText>
				<cfset item.Info="">
			</cfif>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="AddActivity" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QActivity="">

		<cfquery name="QActivity" datasource="#args.datasource#">
			INSERT INTO tblActivity (
				actType,
				actClass,
				actClientID,
				actPubID,
				actText
			) VALUES (
				'#args.Type#',
				'#args.Class#',
				#val(args.ClientID)#,
				#val(args.PubID)#,
				'#args.Text#'
			)
		</cfquery>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="SearchClients" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QClients="">

		<cftry>
			<cfquery name="QClients" datasource="#args.datasource#">
				SELECT *
				FROM tblClients,tblStreets2
				WHERE <cfif val(args.search) neq 0>1<cfelse>cltAccountType <> 'N'</cfif>
				AND cltStreetCode=stID
				AND (
				<cfloop list="#args.search#" delimiters=" " index="i">
					<cfif val(args.search) neq 0>
						cltRef=#val(i)# OR
					<cfelse>
						cltName LIKE '%#i#%'
						OR cltCompanyName LIKE '%#i#%'
						OR cltDelHouseName LIKE '%#i#%'
						OR cltDelHouseNumber LIKE '%#i#%'
						OR cltDelTown LIKE '%#i#%'
						OR cltDelCity LIKE '%#i#%'
						OR cltDelPostcode LIKE '%#i#%'
						OR stName LIKE '%#i#%' OR
					</cfif>
				</cfloop>
				cltID=0
				)
				ORDER BY cltRef asc
			</cfquery>
			<cfloop query="QClients">
				<cfset item={}>
				<cfset item.ID=cltID>
				<cfset item.Ref=cltRef>
				<cfif len(cltName) AND len(cltCompanyName)>
					<cfset item.Name="#cltName# #cltCompanyName#">
				<cfelse>
					<cfset item.Name="#cltName##cltCompanyName#">
				</cfif>
				<cfif len(cltDelHouseName) AND len(cltDelHouseNumber)>
					<cfset item.House="#cltDelHouseName#, #cltDelHouseNumber#">
				<cfelse>
					<cfset item.House="#cltDelHouseName##cltDelHouseNumber#">
				</cfif>
				<cfset item.Street="#stName#">
				<cfset ArrayAppend(result,item)>
			</cfloop>
	
			<cfcatch type="any">
				<cfdump var="#cfcatch#" label="cfcatch" expand="no">
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>	
	
	<cffunction name="ExpiringVouchers" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var QVouchers="">
		<cfset var group={}>
		<cfset var item={}>
		<cfset var i="">
		<cfset var pub="">

		<cfquery name="QVouchers" datasource="#args.datasource#" result="QVouchersResult">
			SELECT *
			FROM tblVoucher,tblPublication
			WHERE vchOrderID=#args.orderID#
			<cfif StructKeyExists(args,"pubID")>AND pubID IN (#args.pubID#)</cfif>
			AND vchPubID=pubID
			AND vchStatus='in'
			<cfif StructKeyExists(args,"fromDate")>AND vchStop >= '#LSDateFormat(args.fromDate,"yyyy-mm-dd")#'</cfif>	<!--- 28/9/14 ignore vouchers expired before this invoice run --->
			ORDER BY vchPubID asc, vchStop desc
		</cfquery>
		<cfloop query="QVouchers">
			<cfset item={}>
			<cfset item.ID=vchID>
			<cfset item.pub=pubTitle>
			<cfset item.start=LSDateFormat(vchStart,"dd/mm/yyyy")>
			<cfset item.stop=vchStop>
			<cfset item.expired=false>
			<cfif StructKeyExists(args,"Date")>
				<cfset item.reDays=DateDiff("d",args.Date,vchStop)>
			<cfelse>
				<cfset item.reDays=DateDiff("d",Now(),vchStop)>
			</cfif>
			<cfif item.reDays lte 3>
				<cfset item.expired=true>
			<cfelse>
				<cfset item.expired=false>
			</cfif>
			<cfif StructKeyExists(group,vchPubID)>
				<cfset pub=StructFind(group,vchPubID)>
				<cfif vchStop gt pub.stop>
					<cfset StructDelete(group,vchPubID)>
					<cfset StructInsert(group,vchPubID,item)>
				</cfif>
			<cfelse>
				<cfset StructInsert(group,vchPubID,item)>
			</cfif>
		</cfloop>
		
		<cfset groupSort=StructSort(group,"textnocase","asc","pub")>
		
		<cfloop array="#groupSort#" index="x">
			<cfset i=StructFind(group,x)>
			<cfif StructKeyExists(args,"showExp")>
				<cfif i.expired>
					<cfset ArrayAppend(result,i)>
				</cfif>
			<cfelse>
				<cfset ArrayAppend(result,i)>
			</cfif>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="AutoEmail" access="public" returntype="void">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cftry>
			<cfsavecontent variable="content">
				<cfoutput>
					<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
					<html xmlns="http://www.w3.org/1999/xhtml">
					<head>
						<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
						<style type="text/css">
							html {font-family:Arial, Helvetica, sans-serif;}
						</style>
					</head>				
					<body>
						<h1>Shortlanesend Store</h1>
						<h3 style="color:##666;">Newspaper Delivery</h3>
						<hr />
						<h3 style="padding:5px 0;">Hello #args.name#,</h3>
						<h2 style="padding:5px 0;margin:0;">#args.subject#</h2>
						<div style="padding:5px 0;">
							<p>#args.text#</p>
						</div>
						<hr>
						<p style="color:##666;">
							If any the information here is incorrect, please contact us on: 01872 275102 or email us at: news@shortlanesendstore.co.uk</p>
					</body>
					</html>
				</cfoutput>
			</cfsavecontent>
			<cfmail 
				to="#args.email#" 
				from="news@shortlanesendstore.co.uk" 
				bcc="news@shortlanesendstore.co.uk" 
				server="mail.shortlanesendstore.co.uk" 
				username="steven@shortlanesendstore.co.uk" 
				password="kcc150297"
				subject="#args.subject# - Shortlanesend Store">
				<cfmailpart type="html">
					#content#
				</cfmailpart>
			</cfmail>
			<cffile action="append" addnewline="yes" file="D:\HostingSpaces\SLE\shortlanesendstore.co.uk\data\logs\email\mail-#DateFormat(Now(),'yyyymmdd')#.txt"
				output="Message sent to: #args.email# - #args.subject#">
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>



