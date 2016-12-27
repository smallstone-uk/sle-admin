<cfcomponent>

	<cffunction name="UpdateRecords" access="public" returntype="struct">
		<cfset var result={}>
		<cfset var QUpdate=0>
		<cfset var QCheckRecord=0>
		<cfset var keyCount=0>
		<cfset var loopCount=0>
		<cfset var fld="">
		<cfset var currFld="">

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
					<cfset currFld=StructFind(arguments.fields,fld)>
					<cfif currFld.type is "numeric">
						<cfset result.update="#result.update# #fld#=#val(currFld.value)#">
					<cfelse>
						<cfset result.update="#result.update# #fld#='#Replace(currFld.value,"'","\'","all")#'">
					</cfif>
					<cfset result.tablerow="#result.tablerow#<td>#currFld.value#</td>">
					<cfif loopCount lt result.keyCount><cfset result.update="#result.update#,"></cfif>
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
					<cfset currFld=StructFind(arguments.fields,fld)>
					<cfset result.columns="#result.columns# #fld#">
					<cfif currFld.type is "numeric">
						<cfset result.values="#result.values##val(currFld.value)#">
					<cfelse>
						<cfset result.values="#result.values#'#Replace(currFld.value,"'","\'","all")#'">
					</cfif>
					<cfset result.tablerow="#result.tablerow#<td>#currFld.value#</td>">
					<cfif loopCount lt result.keyCount>
						<cfset result.columns="#result.columns#,">
						<cfset result.values="#result.values#,">
					</cfif>
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
		<cfset var QResult="">
		<cfset var added=false>
		<cfset var orderID=0>
		<cfset var QCheckPub="">
		<cfset var QQuery="">
		<cfset var item="">
		<cfset var orderLine={}>
		<cfset var QCheckLine="">
		<cfset var QSaveLine="">
		
		<cftry>
			<cfquery name="QCheckOrder" datasource="#args.datasource#">
				SELECT ordID
				FROM tblOrder
				WHERE ordClientID=#val(account.ID)#
			</cfquery>
			<cfif QCheckOrder.recordcount is 0>
				<cfquery name="QQuery" datasource="#args.datasource#" result="QResult">
					INSERT INTO tblOrder (
						ordClientID,
						ordDate
					) VALUES (
						#val(account.ID)#,
						'2013-02-11'
					)
				</cfquery>
				<cfset orderID=QResult.generatedkey>
				<cfset added=true>
			<cfelse>
				<cfset orderID=QCheckOrder.ordID>
				<cfquery name="QQuery" datasource="#args.datasource#" result="QResult">
					UPDATE tblOrder
					SET	ordDate=Now()
					WHERE ordID=#orderID#
				</cfquery>
			</cfif>
			
			<cfloop array="#account.media#" index="item">
				<cfquery name="QCheckPub" datasource="#args.datasource#">
					SELECT *
					FROM tblPublication
					WHERE pubTitle='#item.publication#'
					LIMIT 1;
				</cfquery>
				<cfif QCheckPub.recordcount eq 1>
					<cfset orderLine={}>
					<cfset orderLine.orderID=orderID>
					<cfset orderLine.pubID=QCheckPub.pubID>
					<cfset orderLine.mon=0>
					<cfset orderLine.tue=0>
					<cfset orderLine.wed=0>
					<cfset orderLine.thu=0>
					<cfset orderLine.fri=0>
					<cfset orderLine.sat=0>
					<cfset orderLine.sun=0>
					<cfset orderLine.weekly=0>
					<cfset orderLine.Note="">
					<cfswitch expression="#QCheckPub.pubType#">
						<cfcase value="Morning">
							<cfset orderLine.mon=val(item.days[1])>
							<cfset orderLine.tue=val(item.days[2])>
							<cfset orderLine.wed=val(item.days[3])>
							<cfset orderLine.thu=val(item.days[4])>
							<cfset orderLine.fri=val(item.days[5])>
							<cfset orderLine.sat=val(item.days[6])>
						</cfcase>
						<cfcase value="Sunday">
							<cfset orderLine.sun=val(item.days[1])>
						</cfcase>
						<cfcase value="Monthly">
							<cfset orderLine.sun=val(item.days[1])>
						</cfcase>
						<cfcase value="Weekly">
							<cfset orderLine.sun=val(item.days[1])>
						</cfcase>
						<cfdefaultcase>
							<cfset orderLine.Note="#QCheckPub.pubTitle# - #QCheckPub.pubType#">
						</cfdefaultcase>
					</cfswitch>
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
								oiMon=#orderLine.mon#,
								oiTue=#orderLine.tue#,
								oiWed=#orderLine.wed#,
								oiThu=#orderLine.thu#,
								oiFri=#orderLine.fri#,
								oiSat=#orderLine.sat#,
								oiSun=#orderLine.sun#,
								oiWeekly=#orderLine.weekly#,
								oiNote='#orderLine.Note#'
							WHERE
								oiID=#val(QCheckLine.oiID)#
						</cfquery>
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
								oiWeekly,
								oiNote					
							) VALUES (
								#orderLine.orderID#,
								#orderLine.pubID#,
								#orderLine.mon#,
								#orderLine.tue#,
								#orderLine.wed#,
								#orderLine.thu#,
								#orderLine.fri#,
								#orderLine.sat#,
								#orderLine.sun#,
								#orderLine.weekly#,
								'#orderLine.Note#'						
							)
						</cfquery>
					</cfif>
				</cfif>
			</cfloop>
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
		<cfset var dateFld="">
		<cfset var dateLastStr="">
		<cfset var dateLastFld="">
		<cfset var telstr="">
		
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
				<cfif ListLen(account.parms[5],":") eq 2>
					<cfset dateStr=trim(ListLast(account.parms[5],":"))>
					<cfif IsDate(dateStr)><cfset dateFld=DateFormat(dateStr,"yyyy-mm-dd")></cfif>
				</cfif>
				<cfif ListLen(account.parms[6],":") eq 2>
					<cfset dateLastStr=trim(ListLast(account.parms[6],":"))>
					<cfif IsDate(dateLastStr)><cfset dateLastFld=DateFormat(dateLastStr,"yyyy-mm-dd")></cfif>
				</cfif>
				<cfif ListLen(account.address[5],":") eq 2>
					<cfset telstr=trim(ListLast(account.address[5],":"))>
				</cfif>
				<cfquery name="QQuery" datasource="#args.datasource#">
					UPDATE tblClients
					SET 
						cltName='#account.address[1]#',
						cltDelHouse='#trim(ListFirst(account.address[2],","))#',
						cltDelAddr='#street#',
						cltDelTown='#account.address[3]#',
						cltDelPostcode='#Left(account.address[4],10)#',
						cltDelTel='#telstr#',
						cltStreetCode=#streetcode#,
						cltAccountType='#trim(ListLast(account.parms[1],":"))#',
						cltAvgPay=#val(ListLast(account.parms[3],":"))#,
						<cfif len(dateFld)>cltLastPaid='#dateFld#',</cfif>
						<cfif len(dateLastFld)>cltLastDel='#dateLastFld#',</cfif>
						cltDelCode=#val(ListLast(account.parms[7],":"))#
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
	
	<cffunction name="ScanClientDetails" access="public" returntype="struct" hint="scans simple line list">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var content="">
		<cfset var skipTo="">
		<cfset var data={}>
		<cfset var callResult=0>
		<cfset var account={}>
		<cfset var order={}>
		<cfset var updateResult="">

		<cfdump var="#args#" label="" expand="no">
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
									<!---<cfset data={}>
									<cfloop array="#args.fields#" index="fld">
										<cfset "data.fields.#fld.name#"={"value"=trim(mid(line,fld.col,fld.size)),"type"=fld.type}>
									</cfloop>--->
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
									</cfif>
									<cfif args.showSource>#result.linecount# DATA1 #line#<br /></cfif>
									<!---<cfif callResult.insertRec><cfset result.insertRec++></cfif>
									<cfif args.showSource>#result.linecount# DATA1 #line#<br />
										<cfelse>#StructFind(callResult,"tablerow")#</cfif>--->
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

	<cffunction name="ExtractRound" access="public" returntype="struct">
		<cfset var result={}>
		<cfset var section2data="">
		<cfset var dataStr="">
		<cfdump var="#arguments#" label="ExtractRound" expand="no">
		<cfset result.keyCount=ArrayLen(arguments.fields)>
		<cfset result.datasource=arguments.datasource>
		<cfif ReFindNoCase(arguments.section2,line,1,false)>
			<cfset section2data=ReFindNoCase(arguments.section2exp,line,1,true)>
			<cfdump var="#section2data#" label="section2data" expand="no">
			<cfloop from="1" to="#ArrayLen(section2data.pos)#" index="i">
				<cfset "result.data#i#"=trim(mid(line,section2data.pos[i],section2data.len[i]))>
			</cfloop>
		</cfif>
		<cfset result.DB=UpdateRound(result)>
		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateRound" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QCheckRound="">
		<cfset var QResult="">
		
		<cfquery name="QCheckRound" datasource="#args.datasource#" result="QResult">
			SELECT rndID
			FROM tblRounds
			WHERE rndRef=#val(args.data2)#
			LIMIT 1;
		</cfquery>
		<cfif QCheckRound.recordcount is 0>
			<cfquery name="QUpdate" datasource="#args.datasource#">
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
			<cfquery name="QUpdate" datasource="#args.datasource#">
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

	<cffunction name="AddRoundItems" access="public" returntype="struct">
		<cfset var result={}>
		<cfdump var="#arguments#" label="" expand="no">
		<cfset result.insertRec=false>
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
								<cfelse>
									<cfset result.recCount++>
									<cfset data={}>
									<cfloop array="#args.fields#" index="fld">
										<cfset "data.fields.#fld.name#"={"value"=trim(mid(line,fld.col,fld.size)),"type"=fld.type}>
									</cfloop>
									<cfif ReFindNoCase(args.section2,line,1,false)>
										<cfif len(args.customCall)>
											<cfinvoke method="#args.customCall#" argumentcollection="#args#" returnvariable="callResult">
												<cfinvokeargument name="line" value="#line#">
											</cfinvoke>
											<cfdump var="#callResult#" label="callResult" expand="no">
											<cfif args.showSource>#result.linecount# SKIP4 #line#<br /></cfif>
											<cfset skipTo=result.linecount+1>
										</cfif>
									<cfelseif len(args.call)>
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
				<cfset parm.customCall="ExtractRound">
				<cfset parm.table="tblClients">
				<cfset parm.indexKey="cltRef">
				<cfset ArrayAppend(parm.fields,{"name"="cltRef","col"=3,"size"=4, "type"="numeric"})>
				<cfset ArrayAppend(parm.fields,{"name"="cltDelRound","col"=1,"size"=1, "type"="numeric"})>
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
							<!---<cfset clientDetail("#application.site.fileDir##fname#")>--->
							<cfset parm={}>
							<cfset parm.fileDir="#ExpandPath(".")#\#sitedata.sourceDir#\">
							<cfset parm.datasource=sitedata.datasource1>
							<cfset parm.fields=[]>
							<cfset parm.limitRecs=args.limitRecs>
							<cfset parm.showSource=StructKeyExists(args,"showSource")>
							<cfset parm.updateRecs=StructKeyExists(args,"updateRecs")>
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
							<!---<cfset scanDebtors("#application.site.fileDir##fname#")>--->
						</cfcase>
						<!---<cfcase value="3">
							<cfset importPubs("#application.site.fileDir##fname#")>
							<cfset scanPubs("#application.site.fileDir##fname#")>
						</cfcase>--->
						<cfcase value="4">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
							<!---<cfset scanPubRetail("#application.site.fileDir##fname#")>--->
						</cfcase>
						<cfcase value="5">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
							<!---<cfset scanStreets("#application.site.fileDir##fname#")>--->
						</cfcase>
						<cfcase value="6">
							<cfset ProcessListFile(args,procNum,sitedata,fname)>
						</cfcase>
						<cfcase value="8">
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