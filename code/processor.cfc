<cfcomponent extends="core">

	<cfset this.parentCode=0>
	<cfset this.parentCount=0>
	
	<cffunction name="SetArrivalDate" access="public" returntype="struct">
		<cfset var result={}>
		<cfset var keyCount=0>
		<cfset var QUpdate="">
		<cfset var QResult="">
		<cfset var datestr="">
		<cfset result.datasource=arguments.datasource>
		<cfset result.keyCount=ArrayLen(arguments.fields)>
		<cfset result.data.str1=ReFindNoCase(arguments.section2exp,line,1,true)>
		<cfloop array="#arguments.fields#" index="fld">
			<cfset "result.#fld.name#"={"value"=trim(mid(line,fld.col,fld.size)),"type"=fld.type}>
		</cfloop>
		<cfif IsDate(result.pubNextIssue.value)>
			<cfset result.dayName=DateFormat(result.pubNextIssue.value,"ddd dd-mmm")>
			<cfset result.daynum=DayofWeek(result.pubNextIssue.value)-1>
			<cfif result.daynum is 0><cfset result.daynum=7></cfif>
			<cfset datestr=CheckDateStr(result.pubNextIssue.value,false,"mysqldate")>
			<cfquery name="QUpdate" datasource="#arguments.datasource#" result="QResult">
				UPDATE #arguments.table#
				SET 
					pubNextIssue='#datestr#',
					pubArrival=#result.daynum#
				WHERE pubRef=#val(result.pubRef.value)#
			</cfquery>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateRecords" access="public" returntype="struct">
		<cfset var result={}>
		<cfset var QUpdate=0>
		<cfset var QCheckRecord=0>
		<cfset var keyCount=0>
		<cfset var loopCount=0>
		<cfset var fld="">
		<cfset var currFld="">
		<cfset var datestr="">
		
		<cfset result.tablerow="">
		<cfif StructKeyExists(arguments,"tableName") AND len(arguments.tableName)>
			<cfset result.SQLstr="SELECT #arguments.indexKey# FROM #arguments.tableName# WHERE #arguments.indexKey#='#StructFind(arguments.fields,arguments.indexKey).value#'">
			<cfset result.tablerow="<tr><td>#arguments.recCount#</td>">
			<cfset result.keyCount=StructCount(arguments.fields)>
			<cfquery name="QCheckRecord" datasource="#arguments.datasource#">
				#PreserveSingleQuotes(result.SQLstr)#
			</cfquery>
			<cfif QCheckRecord.recordcount is 1>
				<cfset result.action="update">
				<cfset result.insertRec=false>
				<cfset result.update="UPDATE #arguments.tableName# SET ">
				<cfloop collection="#arguments.fields#" item="fld">
					<cfset loopCount++>
					<cfset delim=mid(",",1,int(loopCount gt 1))>
					<cfset currFld=StructFind(arguments.fields,fld)>
					<cfif currFld.type is "numeric">
						<cfset result.update="#result.update##delim# #fld#=#val(currFld.value)#">
					<cfelseif currFld.type is "date">
						<cfset datestr=CheckDateStr(currFld.value,false,"mysqldate")>
						<cfif len(datestr)><cfset result.update="#result.update##delim# #fld#='#datestr#'"></cfif>
					<cfelse>
						<cfset result.update="#result.update##delim# #fld#='#Replace(currFld.value,"'","\'","all")#'">
					</cfif>
					<cfset result.tablerow="#result.tablerow#<td>#currFld.value#</td>">
				</cfloop>
				<cfset result.tablerow="#result.tablerow#</tr">
				<cfset result.update="#result.update# WHERE #arguments.indexKey#='#StructFind(arguments.fields,arguments.indexKey).value#'">
				<cfif arguments.updateRecs>
					<cfquery name="QUpdate" datasource="#arguments.datasource#">
						#PreserveSingleQuotes(result.update)#
					</cfquery>
				</cfif>
			<cfelse>
				<cfset result.action="insert">
				<cfset result.insertRec=true>
				<cfset result.sql="INSERT INTO #arguments.tableName# (">
				<cfset result.columns="">
				<cfset result.values="">
				<cfloop collection="#arguments.fields#" item="fld">
					<cfset loopCount++>
					<cfset delim=mid(",",1,int(loopCount gt 1))>
					<cfset currFld=StructFind(arguments.fields,fld)>
					<cfset result.columns="#result.columns##delim# #fld#">
					<cfif currFld.type is "numeric">
						<cfset result.values="#result.values##delim# #val(currFld.value)#">
					<cfelseif currFld.type is "date">
						<cfset datestr=CheckDateStr(currFld.value,false,"mysqldate")>
						<cfif len(datestr)><cfset result.values="#result.values##delim# '#datestr#'">
							<cfelse><cfset result.values="#result.values##delim# null"></cfif>
					<cfelse>
						<cfset result.values="#result.values##delim# '#Replace(currFld.value,"'","\'","all")#'">
					</cfif>
					<cfset result.tablerow="#result.tablerow#<td>#currFld.value#</td>">
				</cfloop>
				<cfset result.sql="#result.sql##result.columns#) VALUES (#result.values#)">
				<cfif arguments.updateRecs>
					<cfquery name="QUpdate" datasource="#arguments.datasource#">
						#PreserveSingleQuotes(result.sql)#
					</cfquery>
				</cfif>
			</cfif>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateOrder" access="public" returntype="boolean">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="account" type="struct" required="yes">
		<cfset var QCheckOrder="">
		<cfset var QCheckStreet="">
		<cfset var QNewStreet="">
		<cfset var QResult="">
		<cfset var added=false>
		<cfset var orderID=0>
		<cfset var QCheckPub="">
		<cfset var QQuery="">
		<cfset var item="">
		<cfset var orderLine={}>
		<cfset var QCheckLine="">
		<cfset var QSaveLine="">
		<cfset var voucher=0>
		<cfset var QUpdateClient="">
		<cfset var lineCount=0>
		<cfset var bestday=0>
		<cfset var qty=0>
		<cfset var orderItems=[]>
		<cfset var itemPos=0>
		
		<cfif application.site.showdumps><cfdump var="#account#" label="account" expand="no"></cfif>
		<cftry>
			<cfquery name="QCheckOrder" datasource="#args.datasource#">
				SELECT *
				FROM tblOrder,tblClients
				WHERE ordClientID=#val(account.ID)#
				AND cltID=#val(account.ID)#
			</cfquery>
			<cfquery name="QCheckStreet" datasource="#args.datasource#">
				SELECT stName
				FROM tblStreets
				WHERE stRef=#val(QCheckOrder.cltStreetCode)#
			</cfquery>
			<cfquery name="QNewStreet" datasource="#args.datasource#">
				SELECT stID
				FROM tblStreets2
				WHERE stName LIKE '%#QCheckStreet.stName#%'
			</cfquery>
			<cfif QCheckOrder.recordcount is 0>
				<cfquery name="QQuery" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblOrder (
						ordClientID,
						ordHouseName,
						ordHouseNumber,
						ordStreetCode,
						ordTown,
						ordCity,
						ordPostcode,
						ordDeliveryCode,
						ordDate,
						ordActive
					) VALUES (
						#val(account.ID)#,
						<cfif val(QCheckOrder.cltDelHouse) is 0>
							'#ReReplace(LCase(QCheckOrder.cltDelHouse),"'","","all")#',
							'',
						<cfelse>
							'',
							#val(QCheckOrder.cltDelHouse)#,
						</cfif>
						#val(QNewStreet.stID)#,
						<cfif QCheckOrder.cltDelTown neq "truro">'#LCase(QCheckOrder.cltDelTown)#',<cfelse>'',</cfif>
						<cfif QCheckOrder.cltDelCity eq "truro">
							'#LCase(QCheckOrder.cltDelCity)#',
						<cfelse>
							<cfif QCheckOrder.cltDelTown eq "truro">
								'#LCase(QCheckOrder.cltDelTown)#',
							<cfelse>
								'#LCase(QCheckOrder.cltDelCity)#',
							</cfif>
						</cfif>
						'#UCase(QCheckOrder.cltDelPostcode)#',
						#val(QCheckOrder.cltDelCode)#,
						'#LSDateFormat(Now(),"yyyy-mm-dd")#',
						<cfif QCheckOrder.cltAccountType neq "N">1<cfelse>0</cfif>
					)
				</cfquery>
				<cfset orderID=QResult.generatedkey>
				<cfset added=true>
			<cfelse>
				<cfset orderID=QCheckOrder.ordID>
				<cfquery name="QQuery" datasource="#args.datasource#" result="QResult">
					UPDATE tblOrder
					SET	ordClientID=#val(account.ID)#,
						<cfif val(QCheckOrder.cltDelHouse) is 0>
							ordHouseName='#ReReplace(LCase(QCheckOrder.cltDelHouse),"'","","all")#',
							ordHouseNumber='',
						<cfelse>
							ordHouseName='',
							ordHouseNumber=#val(QCheckOrder.cltDelHouse)#,
						</cfif>
						ordStreetCode=#val(QNewStreet.stID)#,
						<cfif QCheckOrder.cltDelTown neq "truro">ordTown='#LCase(QCheckOrder.cltDelTown)#',<cfelse>ordTown='',</cfif>
						<cfif QCheckOrder.cltDelCity eq "truro">
							ordCity='#LCase(QCheckOrder.cltDelCity)#',
						<cfelse>
							<cfif QCheckOrder.cltDelTown eq "truro">
								ordCity='#LCase(QCheckOrder.cltDelTown)#',
							<cfelse>
								ordCity='',
							</cfif>
						</cfif>
						ordPostcode='#UCase(QCheckOrder.cltDelPostcode)#',
						ordDeliveryCode=#QCheckOrder.cltDelCode#,
						ordDate=Now(),
						<cfif QCheckOrder.cltAccountType neq "N">ordActive=1<cfelse>ordActive=0</cfif>
					WHERE ordID=#orderID#
				</cfquery>
			</cfif>
			<!--- get existing items --->
			<cfquery name="QQuery" datasource="#args.datasource#" result="QResult">
				SELECT oiID
				FROM tblOrderItem
				WHERE oiOrderID=#orderID#
			</cfquery>
			<cfloop query="QQuery">
				<cfset ArrayAppend(orderItems,oiID)>
			</cfloop>
			<!--- loop media items --->
			<cfloop array="#account.media#" index="item">
				<cfset lineCount++>
				<cfquery name="QCheckPub" datasource="#args.datasource#">
					SELECT *
					FROM tblPublication
					WHERE pubTitle='#item.publication#'
					LIMIT 1;
				</cfquery>
				<cfif QCheckPub.recordcount eq 1>
					<cfset bestday=0>
					<cfset orderLine={}>
					<cfset orderLine.title=QCheckPub.pubTitle>
					<cfset orderLine.type=QCheckPub.pubType>
					<cfset orderLine.item=lineCount>
					<cfset orderLine.orderID=orderID>
					<cfset orderLine.pubID=QCheckPub.pubID>
					<cfset orderLine.day1mon=0>
					<cfset orderLine.day2tue=0>
					<cfset orderLine.day3wed=0>
					<cfset orderLine.day4thu=0>
					<cfset orderLine.day5fri=0>
					<cfset orderLine.day6sat=0>
					<cfset orderLine.day7sun=0>
					<cfset orderLine.weekly=0>
					<cfset orderLine.Note="">
					<cfset orderLine.voucher=int(trim(item.msg) eq "P")>
					<cfset orderLine.arrival=QCheckPub.pubArrival>
					<cfset voucher=voucher || orderLine.voucher>
					<cfswitch expression="#QCheckPub.pubType#">
						<cfcase value="Morning">
							<cfset orderLine.day1mon=val(item.days[1])>
							<cfset orderLine.day2tue=val(item.days[2])>
							<cfset orderLine.day3wed=val(item.days[3])>
							<cfset orderLine.day4thu=val(item.days[4])>
							<cfset orderLine.day5fri=val(item.days[5])>
							<cfset orderLine.day6sat=val(item.days[6])>
						</cfcase>
						<cfdefaultcase>
							<cfloop array="#item.days#" index="qty">
								<cfif bestday lt val(qty)><cfset bestday=val(qty)></cfif>
							</cfloop>
							<cfswitch expression="#orderLine.arrival#">
								<cfcase value="1">
									<cfset orderLine.day1mon=bestday>
								</cfcase>
								<cfcase value="2">
									<cfset orderLine.day2tue=bestday>
								</cfcase>
								<cfcase value="3">
									<cfset orderLine.day3wed=bestday>
								</cfcase>
								<cfcase value="4">
									<cfset orderLine.day4thu=bestday>
								</cfcase>
								<cfcase value="5">
									<cfset orderLine.day5fri=bestday>
								</cfcase>
								<cfcase value="6">
									<cfset orderLine.day6sat=bestday>
								</cfcase>
								<cfcase value="7">
									<cfset orderLine.day7sun=bestday>
								</cfcase>
								<cfdefaultcase>
									<cfset orderLine.day7sun=bestday>
									<cfset orderLine.Note="#QCheckPub.pubTitle# - #QCheckPub.pubType#">
								</cfdefaultcase>
							</cfswitch>
						</cfdefaultcase>
					</cfswitch>
					<cfif application.site.showdumps><cfdump var="#orderLine#" label="orderLine #lineCount# #orderLine.title#" expand="no"></cfif>
					<cfquery name="QCheckLine" datasource="#args.datasource#">
						SELECT oiID
						FROM tblOrderItem
						WHERE oiOrderID=#orderLine.orderID#
						AND oiPubID=#orderLine.pubID#
						LIMIT 1;
					</cfquery>
					<cfif QCheckLine.recordcount eq 1>
						<cfquery name="QSaveLine" datasource="#args.datasource#">
							UPDATE tblOrderItem
							SET
								oiMon=#orderLine.day1mon#,
								oiTue=#orderLine.day2tue#,
								oiWed=#orderLine.day3wed#,
								oiThu=#orderLine.day4thu#,
								oiFri=#orderLine.day5fri#,
								oiSat=#orderLine.day6sat#,
								oiSun=#orderLine.day7sun#,
								oiQty=#orderLine.weekly#,
								oiNote='#orderLine.Note#',
								oiVoucher=#val(orderLine.voucher)#
							WHERE
								oiID=#val(QCheckLine.oiID)#
						</cfquery>
						<cfset itemPos=ArrayFind(orderItems,QCheckLine.oiID)>
						<cfif itemPos gt 0>
							<cfset ArrayDeleteAt(orderItems,itemPos)>
						</cfif>
					<cfelse>
						<cfquery name="QSaveLine" datasource="#args.datasource#">
							INSERT INTO tblOrderItem (
								oiOrderID,
								oiPubID,
								oiMon,
								oiTue,
								oiWed,
								oiThu,
								oiFri,
								oiSat,
								oiSun,
								oiQty,
								oiNote,
								oiVoucher			
							) VALUES (
								#orderLine.orderID#,
								#orderLine.pubID#,
								#orderLine.day1mon#,
								#orderLine.day2tue#,
								#orderLine.day3wed#,
								#orderLine.day4thu#,
								#orderLine.day5fri#,
								#orderLine.day6sat#,
								#orderLine.day7sun#,
								#orderLine.weekly#,
								'#orderLine.Note#',				
								#val(orderLine.voucher)#
							)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
			<!---<cfif application.site.showdumps><cfdump var="#orderItems#" label="Unused items remaining" expand="no"></cfif>--->
			<cfloop array="#orderItems#" index="item">
				<cfquery name="QCheckLine" datasource="#args.datasource#">
					DELETE FROM tblOrderItem
					WHERE oiID=#item#
					LIMIT 1;
				</cfquery>
<!--- show what is to be deleted
				<cfquery name="QCheckLine" datasource="#args.datasource#">
					SELECT oiID,pubTitle
					FROM tblOrderItem,tblPublication
					WHERE oiID=#item#
					AND oiPubID=pubID
				</cfquery>
				<cfdump var="#QCheckLine#" label="QCheckLine" expand="no">
--->
			</cfloop>
			<cfquery name="QUpdateClient" datasource="#args.datasource#">
				UPDATE tblClients
				SET cltVoucher=#voucher#
				WHERE cltID=#account.ID#
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="UpdateClientData" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="account" type="struct" required="yes">
		<cfset var result={}>
		<cfset var added=false>
		<cfset var QCheckClient="">
		<cfset var QCheckStreet="">
		<cfset var QQuery="">
		<cfset var street=trim(ListLast(account.address[2],","))>
		<cfset var streetcode=0>
		<cfset var dateStr="">
		<cfset var telstr="">
		<cfset var accountType="">
		<cfset var balance=0>
		<cfset var averagePay=0>
		<cfset var lastPaid="">
		<cfset var lastDelivery="">
		<cfset var chargeCode=0>
		<cfset var arrCount=0>
		<cfset var postcode="">
		
		<!---<cfdump var="#args#" label="UpdateClientData" expand="no">--->
		<cftry>
			<cfquery name="QCheckStreet" datasource="#args.datasource#">
				SELECT stRef
				FROM tblStreets
				WHERE stName='#street#'
				LIMIT 1;
			</cfquery>
			<cfif QCheckStreet.recordcount eq 1>
				<cfset streetcode=QCheckStreet.stRef>
			</cfif>
			<cfquery name="QCheckClient" datasource="#args.datasource#">
				SELECT cltID
				FROM tblClients
				WHERE cltRef=#val(account.ref)#
				LIMIT 1;
			</cfquery>
			<cfif QCheckClient.recordcount is 0>
				<cfquery name="QQuery" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblClients (
						cltRef,
						cltEntered
					) VALUES (
						#val(account.ref)#,
						now()
					)
				</cfquery>
				<cfset account.ID=QResult.generatedkey>
				<cfset result.action="insert">
				<cfset result.insertRec=true>
			<cfelse>
				<cfset account.ID=QCheckClient.cltID>
				<cfset result.action="update">
				<cfset result.insertRec=false>
			</cfif>
			<cfif ArrayLen(account.address) gt 4 AND ArrayLen(account.parms) gt 6>
				<cfloop array="#account.address#" index="item">
					<cfset arrCount++>
					<cfif Find("Tel:",item)>
						<cfif ListLen(item,":") eq 2><cfset telstr=trim(ListLast(item,":"))></cfif>
						<cfset postcode=trim(ListLast(account.address[arrCount-1],":"))>
					</cfif>
				</cfloop>
				<cfloop array="#account.parms#" index="item">
					<cfif ListLen(trim(item),":") eq 2>
						<cfif Find("Type",item)>
							<cfset accountType=trim(ListLast(item,":"))>
						<cfelseif Find("Balance",item)>
							<cfset balance=trim(ListLast(item,":"))>
						<cfelseif Find("Average",item)>
							<cfset averagePay=trim(ListLast(item,":"))>
						<cfelseif Find("Last Paid",item)>
							<cfset dateStr=trim(ListLast(item,":"))>
							<cfset lastPaid="#mid(dateStr,7,4)#-#mid(dateStr,4,2)#-#mid(dateStr,1,2)#">
						<cfelseif Find("Last Delivery",item)>
							<cfset dateStr=trim(ListLast(item,":"))>
							<cfset lastDelivery="#mid(dateStr,7,4)#-#mid(dateStr,4,2)#-#mid(dateStr,1,2)#">
						<cfelseif Find("Charge Code",item)>
							<cfset chargeCode=trim(ListLast(item,":"))>
						</cfif>
					</cfif>
				</cfloop>
				<cfquery name="QQuery" datasource="#args.datasource#">
					UPDATE tblClients
					SET 
						cltName='#account.address[1]#',
						cltDelHouse='#trim(ListFirst(account.address[2],","))#',
						cltDelAddr='#street#',
						cltDelTown='#account.address[3]#',
						cltDelPostcode='#postcode#',
						cltDelTel='#telstr#',
						cltStreetCode=#streetcode#,
						cltAccountType='#accountType#',
						cltAvgPay=#val(averagePay)#,
						cltBalance=0	<!---#val(balance)# not required - invalid data--->,
						<cfif len(lastPaid)>cltLastPaid='#lastPaid#',</cfif>
						<cfif len(lastDelivery)>cltLastDel='#lastDelivery#',</cfif>
						cltDelCode=#val(chargeCode)#
					WHERE
						cltID=#val(account.ID)#
				</cfquery>
				<cfset UpdateOrder(args,account)>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="ScanClientDetails" access="public" returntype="struct" hint="scans client detail report">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var content="">
		<cfset var skipTo="">
		<cfset var data={}>
		<cfset var callResult=0>
		<cfset var account={}>
		<cfset var order={}>
		<cfset var updateResult="">
		<cfset var line="">
		
		<!---<cfdump var="#args#" label="" expand="no">--->
		<cftry>
			<cfif StructKeyExists(args,"sourcefile")>
				<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="content">
				<cfoutput>
					<cfset skipTo=0>
					<cfset result.linecount=0>
					<cfset result.recCount=0>
					<cfset result.insertRec=0>
					<cfset account.dataline=0>
					<cfset account.address=[]>
					<cfset account.parms=[]>
					<cfset account.media=[]>
					
					<table border="1">
						<cfloop list="#content#" delimiters="#chr(13)##chr(10)#" index="line">
							<cfset result.linecount++>
							<cfif skipTo gt 0 AND result.linecount lt skipTo>
								<cfif args.showSource>#result.linecount# SKIP0 #line#<br /></cfif>
							<cfelse>
								<cfif ReFindNoCase(args.page1regexp,line,1,false)>
									<cfset skipTo=result.linecount+args.page1height>
									<cfif args.showSource>#result.linecount# SKIP1 #line#<br /></cfif>
								<cfelseif ReFindNoCase(args.pageregexp,line,1,false)>
									<cfset skipTo=result.linecount+args.pageheight>
									<cfif args.showSource>#result.linecount# SKIP2 #line#<br /></cfif>
								<cfelseif ReFindNoCase(args.section1,line,1,false)>
									<cfset skipTo=result.linecount+1>
									<cfif args.showSource>#result.linecount# SKIP3 #line#<br /></cfif>
								<cfelseif ReFind("Title|-----",line)>
									<cfset account={}>
									<cfset account.dataline=0>
									<cfset account.address=[]>
									<cfset account.parms=[]>
									<cfset account.media=[]>
									<cfif args.showSource>#result.linecount# SKIP4 #line#<br /></cfif>
									<cfset skipTo=result.linecount+1>
								<cfelseif Find("=====",line)>
									<cfif args.showSource>#result.linecount# DONE0 #account.ref# #account.address[2]#<br /></cfif>
									
									<tr><td>#account.ref#</td><td>#account.address[1]#</td><td>#account.address[2]#</td></tr>
									<!---<cfdump var="#account#" label="account" expand="no">--->
									<cfif args.updateRecs>
										<cfset updateResult=UpdateClientData(args,account)>
										<cfif updateResult.insertRec><cfset result.insertRec++></cfif>
										<cfset result.recCount++>
									</cfif>
								<cfelse>
									<cfset account.dataline++>
									<cfif account.dataline eq 1>
										<cfset account.ref=val(mid(line,1,5))>
									</cfif>
									<cfset ArrayAppend(account.address,trim(mid(line,7,40)))>
									<cfset ArrayAppend(account.parms,mid(line,58,27))>
									<cfset order={}>
									<cfset order.publication=trim(mid(line,85,20))>
									<cfif len(order.publication)>
										<cfset order.days=[]>
										<cfloop from="106" to="128" step="3" index="i">
											<cfset ArrayAppend(order.days,mid(line,i,3))>
										</cfloop>
										<cfset ArrayAppend(account.media,order)>
										<cfset order.msg=trim(mid(line,125,3))>
									</cfif>
									<cfif args.showSource>#result.linecount# DATA1 #line#<br /></cfif>
								</cfif>
							</cfif>
							<cfif args.limitRecs gt 0 AND result.recCount eq args.limitRecs>
								<cfbreak>
							</cfif>
						</cfloop>
						<tr>
							<td colspan="3">
								#result.linecount# lines processed.</br>
								#result.recCount# records processed.</br>
								#result.insertRec# records inserted.</br>
							</td>
						</tr>
					</table>
				</cfoutput>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="updatePubs" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckPub="">
		<cfset var QFixPub="">
		<cfset var QResult="">
		<cfset var prices=[0,0,0,0,0,0,0]>
		<cfset var i=0>
		<cfset var priceRow=1>
		<cfset var thePrice=0>
		<cfset var datestr="">
		<!---<cfdump var="#args#" label="" expand="no">--->
		
		<cfset result.updated=false>
		<cfset result.daynum=0>
		<cfset result.datestr="">
		<cfset result.odbcDate="">
		<cfset result.validate=0>
		<cfset result.newDate="">
		<cfquery name="QCheckPub" datasource="#args.datasource#">
			SELECT *
			FROM tblPublication
			WHERE pubRef=#val(args.ref)#
			LIMIT 1;
		</cfquery>
		<cfif QCheckPub.recordcount is 1>
			<cfif StructKeyExists(args,"nextIssue") AND len(args.nextIssue)>
				<cfset result.validate=ReFind("\d{1,2}\/\d{1,2}\/\d{4}",args.nextIssue)>
				<cfif result.validate>
					<cfset result.newDate="#mid(args.nextIssue,7,4)#-#mid(args.nextIssue,4,2)#-#mid(args.nextIssue,1,2)#">
				</cfif>
				<cfset result.dayName=DateFormat(result.newDate,"ddd dd-mmm")>
				<cfset result.daynum=DayofWeek(result.newDate)-1>
				<cfif result.daynum is 0><cfset result.daynum=7></cfif>
			</cfif>
			
			<cfif args.type eq "Morning" AND StructKeyExists(args,"priceMon")>
				<cfset prices[1]=args.priceMon>
				<cfset prices[2]=args.priceTue>
				<cfset prices[3]=args.priceWed>
				<cfset prices[4]=args.priceThu>
				<cfset prices[5]=args.priceFri>
				<cfset prices[6]=args.priceSat>			
				<cfset prices[7]=0>			
			<cfelseif result.daynum gt 0>
				<cfset prices[result.daynum]=args.price>			
			<cfelse>
				<cfset prices[1]=0>
				<cfset prices[2]=0>
				<cfset prices[3]=0>
				<cfset prices[4]=0>
				<cfset prices[5]=0>
				<cfset prices[6]=0>
				<cfset prices[7]=args.price>			
			</cfif>
			<cfloop from="1" to="7" index="i">
				<cfif prices[i] neq 0>
					<cfset priceRow=i>
					<cfset thePrice=prices[i]>
					<cfbreak>
				</cfif>
			</cfloop>
			<cftry>
				<cfquery name="QFixPub" datasource="#args.datasource#" result="QResult">
					UPDATE tblPublication
					SET 
						pubTitle='#args.title#',
						pubType='#args.type#',
						pubCategory='#args.category#',
						pubWholesaler='#args.wholesaler#',
						<!---pubVAT='#args.vat#',
						pubDiscount='#args.discount#', invalid data - ignore --->
						pubBarcode='#args.barcode#',
						<cfif len(result.newDate)>pubNextIssue='#result.newDate#',
							<cfelse>pubNextIssue=null,</cfif>
						pubArrival=#result.daynum#,
						pubSor='#args.sor#',
						pubPrice=#args.price#,
						pubPrice1=#prices[1]#,
						pubPrice2=#prices[2]#,
						pubPrice3=#prices[3]#,
						pubPrice4=#prices[4]#,
						pubPrice5=#prices[5]#,
						pubPrice6=#prices[6]#,
						pubPrice7=#prices[7]#,
						pubTradePrice=#thePrice*0.75#
					WHERE
						pubRef='#args.ref#'
				</cfquery>
			<cfcatch type="any">
				<cfset result.cfcatch=cfcatch>
			</cfcatch>
			</cftry>
			<cfset result.updated=true>
			<cfset result.prices=prices>
			<!---<cfdump var="#result#" label="updatePubs" expand="no">--->
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="ScanPubDetails" access="public" returntype="struct" hint="scans publications detail report">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var content="">
		<cfset var skipTo="">
		<cfset var data={}>
		<cfset var line="">
		<cfset var pub={}>
		<cfset var blockline=0>
		<cfset var updateDB="">
		<cfset var posn=[]>
		
		<cfset result.updated=0>
		<cfset result.notfound=0>

		<!---<cfdump var="#args#" label="" expand="no">--->
		<cftry>
			<cfif StructKeyExists(args,"sourcefile")>
				<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="content">
				<cfoutput>
					<cfset skipTo=0>
					<cfset result.linecount=0>
					<cfset result.recCount=0>
					<cfset result.insertRec=0>
					<table border="1">
						<cfloop list="#content#" delimiters="#chr(13)##chr(10)#" index="line">
							<cfset result.linecount++>
							<cfif skipTo gt 0 AND result.linecount lt skipTo>
								<cfif args.showSource>#result.linecount# SKIP0 #line#<br /></cfif>
							<cfelse>
								<cfif ReFindNoCase(args.page1regexp,line,1,false)>
									<cfset skipTo=result.linecount+args.page1height>
									<cfif args.showSource>#result.linecount# SKIP1 #line#<br /></cfif>
								<cfelseif ReFindNoCase(args.pageregexp,line,1,false)>
									<cfset skipTo=result.linecount+args.pageheight>
									<cfif args.showSource>#result.linecount# SKIP2 #line#<br /></cfif>
								<cfelseif ReFindNoCase(args.section1,line,1,false)>
									<cfset skipTo=result.linecount+1>
									<cfif args.showSource>#result.linecount# SKIP3 #line#<br /></cfif>
								<cfelseif ReFind("Category|-----",line)>
									<cfif args.showSource>#result.linecount# SKIP4 #line#<br /></cfif>
									<cfset skipTo=result.linecount+1>
									<cfset blockline=0>
									<cfset pub={}>
									<cfset pub.price=0>
									<cfset pub.datasource=args.datasource>
								<cfelseif Find("=====",line)>
									<cfset updateDB=updatePubs(pub)>
									<cfif updateDB.updated>
										<cfset result.updated++>								
									<cfelse>
										<cfset result.notfound++>								
									</cfif>
									<cfif args.showSource>#result.linecount# DONE0 Record end <br /></cfif>
								<cfelse>
									#result.linecount# DATA1 #line#<br />
									<cfset blockline++>
									<cfif blockline eq 1>
										<cfset pub.ref=val(mid(line,1,4))>
										<cfset pub.title=trim(mid(line,8,30))>
										<cfset pub.type=trim(mid(line,41,12))>
										<cfset pub.category=trim(mid(line,55,10))>
										<cfset pub.wholesaler=trim(mid(line,67,10))>
										<cfset pub.vat=trim(mid(line,79,3))>
										<cfset pub.discount=trim(mid(line,84,8))>
										<cfset pub.barcode=trim(mid(line,94,15))>
										<cfset pub.sor=trim(mid(line,111,7))>
									<cfelse>
										<cfif ReFindNoCase("Next Issue",line,1,false)>
											<cfset posn=ReFindNoCase("Next Issue\:(.{0,11})",line,1,true)>
											<cfset pub.nextIssue=trim(mid(line,posn.pos[2],posn.len[2]))>
											<!---<cfset pub.nextIssue=trim(mid(line,81,10))>--->
										</cfif>
										<cfif FindNoCase("Price:",line,1)>
											<cfset pub.price=val(mid(line,13,6))>
										</cfif>
										<cfif FindNoCase("(Mon):",line,1)>				
											<cfset pub.priceMon=val(mid(line,14,5))>
										<cfelseif FindNoCase("(Tue):",line,1)>
											<cfset pub.priceTue=val(mid(line,14,5))>
										<cfelseif FindNoCase("(Wed):",line,1)>
											<cfset pub.priceWed=val(mid(line,14,5))>
										<cfelseif FindNoCase("(Thu):",line,1)>
											<cfset pub.priceThu=val(mid(line,14,5))>
										<cfelseif FindNoCase("(Fri):",line,1)>
											<cfset pub.priceFri=val(mid(line,14,5))>
										<cfelseif FindNoCase("(Sat):",line,1)>
											<cfset pub.priceSat=val(mid(line,14,5))>
										</cfif>
									</cfif>
								</cfif>
							</cfif>
						</cfloop>
					</table>
				</cfoutput>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		<cfreturn result>			
	</cffunction>
	
	<cffunction name="UpdateRoundItems" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckRoundItem="">
		<cfset var QUpdate="">
		<cfset var QCheckClient="">
		<cfset var QGetRoundID="">
		<cfset result.insertRec=false>
		<cfquery name="QCheckClient" datasource="#args.datasource#">
			SELECT cltID,ordID
			FROM tblClients,tblOrder
			WHERE cltRef=#val(args.cltRef.value)#
			AND ordClientID=cltID
			LIMIT 1;
		</cfquery>
		<cfif QCheckClient.recordcount is 1>
			<cfset result.clientID=QCheckClient.cltID>
			<cfset result.orderID=QCheckClient.ordID>
			<cfquery name="QGetRoundID" datasource="#args.datasource#">
				SELECT rndID
				FROM tblRounds
				WHERE rndRef=#val(args.roundCode)#
				LIMIT 1;
			</cfquery>
			<cfquery name="QCheckRoundItem" datasource="#args.datasource#">
				SELECT riID
				FROM tblRoundItems
				WHERE riClientID=#val(result.clientID)#
				AND riRoundRef=#val(args.roundCode)#
				LIMIT 1;
			</cfquery>
			<cfif QCheckRoundItem.recordcount is 0>
				<cfquery name="QUpdate" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblRoundItems (
						riClientID,
						riOrderID,
						riRoundID,
						riRoundRef,
						riOrder
						
					) VALUES (
						#val(result.clientID)#,
						#val(result.orderID)#,
						#val(QGetRoundID.rndID)#,
						#val(args.roundCode)#,
						#args.order#
					)
				</cfquery>
				<cfset result.insertRec=true>
			<cfelse>
				<cfquery name="QUpdate" datasource="#args.datasource#" result="QResult">
					UPDATE tblRoundItems
					SET 
						riClientID=#val(result.clientID)#,
						riOrderID=#val(result.orderID)#,
						riRoundID=#val(QGetRoundID.rndID)#,
						riRoundRef=#val(args.roundCode)#,
						riOrder=#args.order#
					WHERE riID=#val(QCheckRoundItem.riID)#
				</cfquery>
			</cfif>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateRound" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckRound="">
		<cfset var QUpdate="">
		
		<cfquery name="QCheckRound" datasource="#args.datasource#">
			SELECT rndID
			FROM tblRounds
			WHERE rndRef=#val(args.data2)#
			LIMIT 1;
		</cfquery>
		<cfif QCheckRound.recordcount is 0>
			<cfquery name="QUpdate" datasource="#args.datasource#" result="QResult">
				INSERT INTO tblRounds (
					rndRef,
					rndTitle
				) VALUES (
					#val(args.data2)#,
					'#args.data3#'
				)
			</cfquery>
			<cfset result.roundID=QResult.generatedKey>
		<cfelse>
			<cfquery name="QUpdate" datasource="#args.datasource#" result="QResult">
				UPDATE tblRounds
				SET 
					rndRef=#val(args.data2)#,
					rndTitle='#args.data3#'
				WHERE rndRef=#val(args.data2)#
			</cfquery>
			<cfset result.roundID=QCheckRound.rndID>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="ProcessRounds" access="public" returntype="struct">
		<cfset var result={}>
		<cfset var fld="">
		<cfset var i="">

		<cfset result.datasource=arguments.datasource>
		<cfset result.keyCount=ArrayLen(arguments.fields)>
		<cfif ReFindNoCase(arguments.section2,line,1,false)>
			<cfset result.data.str1=ReFindNoCase(arguments.section2exp,line,1,true)>
			<cfloop from="1" to="#ArrayLen(result.data.str1.pos)#" index="i">
				<cfset "result.data#i#"=trim(mid(line,result.data.str1.pos[i],result.data.str1.len[i]))>
			</cfloop>
			<cfset result.DB=UpdateRound(result)>
			<cfset this.parentCode=result.data2>
			<cfset this.parentCount=0>
		<cfelse>
			<cfloop array="#arguments.fields#" index="fld">
				<cfset "result.#fld.name#"={"value"=trim(mid(line,fld.col,fld.size)),"type"=fld.type}>
			</cfloop>
			<cfset this.parentCount++>
			<cfset result.order=this.parentCount>
			<cfset result.roundcode=this.parentCode>
			<cfset result.item=UpdateRoundItems(result)>
		</cfif>
		<cfreturn result>
	</cffunction>

	<cffunction name="scanFile" access="public" returntype="struct" hint="scans simple line list">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var content="">
		<cfset var skipTo="">
		<cfset var data={}>
		<cfset var section2data="">
		<cfset var dataStr="">
		<cfset var callResult=0>

		<cftry>
			<cfif StructKeyExists(args,"sourcefile")>
				<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="content">
				<cfoutput>
					<cfset skipTo=0>
					<cfset result.linecount=0>
					<cfset result.recCount=0>
					<cfset result.insertRec=0>
					<cfset result.cltDelRound=0>
					<table border="1">
						<tr>
							<th>Row</th>
						<cfloop array="#args.fields#" index="fld">
							<th>#fld.name#</th>
						</cfloop>
						</tr>
						<cfloop list="#content#" delimiters="#chr(13)##chr(10)#" index="line">
							<cfset result.linecount++>
							<cfif skipTo gt 0 AND result.linecount lt skipTo>
								<cfif args.showSource>#result.linecount# SKIP0 #line#<br /></cfif>
							<cfelse>
								<cfif ReFindNoCase(args.page1regexp,line,1,false)>
									<cfset skipTo=result.linecount+args.page1height>
									<cfif args.showSource>#result.linecount# SKIP1 #line#<br /></cfif>
								<cfelseif ReFindNoCase(args.pageregexp,line,1,false)>
									<cfset skipTo=result.linecount+args.pageheight>
									<cfif args.showSource>#result.linecount# SKIP2 #line#<br /></cfif>
								<cfelseif ReFindNoCase(args.section1,line,1,false)>
									<cfset skipTo=result.linecount+1>
									<cfif args.showSource>#result.linecount# SKIP3 #line#<br /></cfif>
								<cfelseif len(args.customCall)>
									<cfset result.recCount++>
									<cfinvoke method="#args.customCall#" argumentcollection="#args#" returnvariable="callResult">
										<cfinvokeargument name="line" value="#line#">
									</cfinvoke>
									<!---<cfdump var="#callResult#" label="callResult" expand="no">--->
									<cfif args.showSource>#result.linecount# SKIP4 #args.customCall# #line#<br /></cfif>
									<cfset skipTo=result.linecount+1>
								<cfelse>
									<cfset result.recCount++>
									<cfset data={}>
									<cfloop array="#args.fields#" index="fld">
										<cfset "data.fields.#fld.name#"={"value"=trim(mid(line,fld.col,fld.size)),"type"=fld.type}>
									</cfloop>
									<cfif len(args.call)>
										<cfinvoke method="#args.call#" argumentcollection="#data#" returnvariable="callResult">
											<cfinvokeargument name="tableName" value="#args.table#">
											<cfinvokeargument name="indexKey" value="#args.indexKey#">
											<cfinvokeargument name="datasource" value="#args.datasource#">
											<cfinvokeargument name="updateRecs" value="#args.updateRecs#">
											<cfinvokeargument name="showSource" value="#args.showSource#">
											<cfinvokeargument name="recCount" value="#result.recCount#">
										</cfinvoke>
										<cfif callResult.insertRec><cfset result.insertRec++></cfif>
										<cfif args.showSource>#result.linecount# DATA1 #line#<br />
											<cfelse>#StructFind(callResult,"tablerow")#</cfif>
									</cfif>
								</cfif>
							</cfif>
							<cfif args.limitRecs gt 0 AND result.recCount gt args.limitRecs>
								<cfbreak>
							</cfif>
						</cfloop>
						<tr>
							<td colspan="#callResult.keycount#">
								#result.linecount# lines processed.</br>
								#result.recCount# records processed.</br>
								#result.insertRec# records inserted.</br>
							</td>
						</tr>
					</table>
				</cfoutput>
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="no">
		</cfcatch>
		</cftry>
		<cfreturn result>
	</cffunction>

	<cffunction name="ProcessListFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="procNum" type="numeric" required="yes">
		<cfargument name="sitedata" type="struct" required="yes">
		<cfargument name="sourcefile" type="string" required="yes">
		<cfset var result={}>
		<cfset var parm={}>

		<cfset parm.fileDir="#ExpandPath(".")#\#sitedata.sourceDir#\">
		<cfset parm.sourcefile=sourcefile>
		<cfset parm.datasource=sitedata.datasource1>
		<cfset parm.fields=[]>
		<cfset parm.limitRecs=args.limitRecs>
		<cfset parm.showSource=StructKeyExists(args,"showSource")>
		<cfset parm.updateRecs=StructKeyExists(args,"updateRecs")>
		<cfswitch expression="#procNum#">
			<cfcase value="2">
				<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
				<cfset parm.page1height=9>
				<cfset parm.pageregexp="Page[\s]*:[\s]*">
				<cfset parm.pageheight=4>
				<cfset parm.section1="Total|====">
				<cfset parm.section2="">
				<cfset parm.call="UpdateRecords">
				<cfset parm.customCall="">
				<cfset parm.table="tblClients">
				<cfset parm.indexKey="cltRef">
				<cfset ArrayAppend(parm.fields,{"name"="cltRef","col"=1,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="cltName","col"=12,"size"=26, "type"="text"})>
				<cfset ArrayAppend(parm.fields,{"name"="cltOverdue","col"=45,"size"=4, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="cltBalance","col"=54,"size"=7, "type"="numeric"})>
			</cfcase>
			<cfcase value="4">
				<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
				<cfset parm.page1height=7>
				<cfset parm.pageregexp="Page[\s]*:[\s]*">
				<cfset parm.pageheight=7>
				<cfset parm.section1="Total|====">
				<cfset parm.section2="">
				<cfset parm.call="UpdateRecords">
				<cfset parm.customCall="">
				<cfset parm.table="tblPublication">
				<cfset parm.indexKey="pubRef">
				<cfset ArrayAppend(parm.fields,{"name"="pubRef","col"=1,"size"=4, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice1","col"=30,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice2","col"=36,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice3","col"=42,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice4","col"=48,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice5","col"=54,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice6","col"=60,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubPrice7","col"=66,"size"=5, "type"="numeric"})>
			</cfcase>
			<cfcase value="5">
				<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
				<cfset parm.page1height=7>
				<cfset parm.pageregexp="Page[\s]*:[\s]*">
				<cfset parm.pageheight=4>
				<cfset parm.section1="Total|====">
				<cfset parm.section2="">
				<cfset parm.call="UpdateRecords">
				<cfset parm.customCall="">
				<cfset parm.table="tblStreets">
				<cfset parm.indexKey="stRef">
				<cfset ArrayAppend(parm.fields,{"name"="stRef","col"=2,"size"=4, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="stName","col"=14,"size"=32, "type"="text"})>
			</cfcase>
			<cfcase value="6">
				<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
				<cfset parm.page1height=6>
				<cfset parm.pageregexp="Page[\s]*:[\s]*">
				<cfset parm.pageheight=3>
				<cfset parm.section1="Total|====">
				<cfset parm.section2="">
				<cfset parm.call="UpdateRecords">
				<cfset parm.customCall="">
				<cfset parm.table="tblPublication">
				<cfset parm.indexKey="pubRef">
				<cfset ArrayAppend(parm.fields,{"name"="pubRef","col"=1,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubTitle","col"=7,"size"=30, "type"="text"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubType","col"=38,"size"=13, "type"="text"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubCategory","col"=53,"size"=10, "type"="text"})>
			</cfcase>
			<cfcase value="8">
				<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
				<cfset parm.page1height=4>
				<cfset parm.pageregexp="Page[\s]*:[\s]*">
				<cfset parm.pageheight=1>
				<cfset parm.section1="Number|--------|A/c">
				<cfset parm.section2="Round[\s]*:[\s]*">
				<cfset parm.section2exp="Round[\s]*:[\s]*(\d+)[\s]*Description\:(.*)$">
				<cfset parm.call="AddRoundItems">
				<cfset parm.customCall="ProcessRounds">
				<cfset parm.table="tblClients">
				<cfset parm.indexKey="cltRef">
				<cfset ArrayAppend(parm.fields,{"name"="cltRef","col"=3,"size"=4, "type"="numeric"})>
			</cfcase>
			<cfcase value="9">
				<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
				<cfset parm.page1height=6>
				<cfset parm.pageregexp="Page[\s]*:[\s]*">
				<cfset parm.pageheight=3>
				<cfset parm.section1="Total|====">
				<cfset parm.section2="">
				<cfset parm.section2exp="">
				<cfset parm.call="UpdateRecords">
				<cfset parm.customCall="SetArrivalDate">
				<cfset parm.table="tblPublication">
				<cfset parm.indexKey="pubRef">
				<cfset ArrayAppend(parm.fields,{"name"="pubRef","col"=1,"size"=5, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="pubNextIssue","col"=63,"size"=10, "type"="date"})>
			</cfcase>
		</cfswitch>
		<cfif ArrayLen(parm.fields)>
			<cfobject component="code/processor" name="proc">
			<cfset result=proc.scanFile(parm)>
		</cfif>
		<cfreturn result>
	</cffunction>
	
	<cffunction name="ProcessFiles" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfargument name="sitedata" type="struct" required="yes">
		<cfset var result={}>
		<cfset var fname=0>
		<cfset var dashPos=0>
		<cfset var procNum=0>
		<cfif StructKeyExists(args,"fileName")>
			<cfloop list="#args.fileName#" index="fname">
				<cfoutput><p><strong>#fname#</strong></p></cfoutput>
				<cfset dashPos=ReFind("\-",fname,1,false)>
				<cfif dashPos gt 0>
					<cfset procNum=mid(fname,1,dashPos-1)>
				<cfelse><cfset procNum=0></cfif>
				<cfif procNum gt 0>
					<cfswitch expression="#procNum#">
						<cfcase value="1">
							<cfset parm={}>
							<cfset parm.showSource=StructKeyExists(args,"showSource")>
							<cfset parm.updateRecs=StructKeyExists(args,"updateRecs")>
							<cfset parm.fileDir="#ExpandPath(".")#\#sitedata.sourceDir#\">
							<cfset parm.datasource=sitedata.datasource1>
							<cfset parm.fields=[]>
							<cfset parm.limitRecs=args.limitRecs>
							<cfset parm.sourcefile=fname>
							<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
							<cfset parm.page1height=6>
							<cfset parm.pageregexp="Page[\s]*:[\s]*">
							<cfset parm.pageheight=1>
							<cfset parm.section1="Total">
							<cfset parm.section2="">
							<cfset parm.call="UpdateRecords">
							<cfset parm.customCall="">
							<cfset parm.table="tblClients">
							<cfset parm.indexKey="cltRef">
							<cfset ScanClientDetails(parm)>
						</cfcase>
						<cfcase value="2">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfcase value="3">
							<cfset parm={}>
							<cfset parm.showSource=StructKeyExists(args,"showSource")>
							<cfset parm.updateRecs=StructKeyExists(args,"updateRecs")>
							<cfset parm.fileDir="#ExpandPath(".")#\#sitedata.sourceDir#\">
							<cfset parm.datasource=sitedata.datasource1>
							<cfset parm.fields=[]>
							<cfset parm.limitRecs=args.limitRecs>
							<cfset parm.sourcefile=fname>
							<cfset parm.page1regexp="Page[\s]*:[\s]*1$">
							<cfset parm.page1height=6>
							<cfset parm.pageregexp="Page[\s]*:[\s]*">
							<cfset parm.pageheight=1>
							<cfset parm.section1="Total">
							<cfset parm.section2="">
							<cfset parm.call="UpdateRecords">
							<cfset parm.customCall="">
							<cfset parm.table="tblPublication">
							<cfset parm.indexKey="pubRef">
							<cfset ScanPubDetails(parm)>
						</cfcase>
						<cfcase value="4">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfcase value="5">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfcase value="6">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfcase value="8">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfcase value="9">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfdefaultcase>
							<cfset result.err="#fname# not processed">
						</cfdefaultcase>
					</cfswitch>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn result>
	</cffunction>

</cfcomponent>