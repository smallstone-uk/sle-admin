<cfcomponent displayname="Import" extends="code/core">

	<cfset this.nomKeys = []>
	<cfset this.clientKeys = []>
	<cfset this.accKeys = []>	
	
	<cffunction name="LoadKeys" access="public" returntype="struct">	<!--- filter keys for identifying customers, suppliers & nominal accounts from spreadsheet data --->
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>

		<cftry>
			<cfquery name="loc.QNomKeys" datasource="#args.datasource#">
				SELECT nomID,nomTitle,nomKey FROM tblnominal WHERE nomKey != '' ORDER BY nomKey;
			</cfquery>
			<cfloop query="loc.QNomKeys">
				<cfset ArrayAppend(this.nomKeys,{
					type = 'nom',
					id = nomID,
					title = nomTitle,
					key = nomKey
				})>
			</cfloop>
			
			<cfquery name="loc.QClientKeys" datasource="#args.datasource#">
				SELECT cltID,cltName,cltKey FROM tblclients WHERE cltKey != '' AND cltAccountType NOT LIKE 'N' ORDER BY cltKey;
			</cfquery>
			<cfloop query="loc.QClientKeys">
				<cfset ArrayAppend(this.clientKeys,{
					type = 'client',
					id = cltID,
					title = cltName,
					key = cltKey
				})>
			</cfloop>
			
			<cfquery name="loc.QAccKeys" datasource="#args.datasource#">
				SELECT accID,accName,accIndex FROM tblaccount WHERE accIndex != "" ORDER BY accIndex;
			</cfquery>
			<cfloop query="loc.QAccKeys">
				<cfset ArrayAppend(this.accKeys,{
					type = 'account',
					id = accID,
					title = accName,
					key = accIndex
				})>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="HintKeys" access="public" returntype="struct">
		<cfset var loc = {}>
		<cfset loc.nomKeys = this.nomKeys>
		<cfset loc.clientKeys = this.clientKeys>
		<cfset loc.accKeys = this.accKeys>
		<cfreturn loc>
	</cffunction>

	<cffunction name="SearchHints" access="public" returntype="struct">
		<cfargument name="str" type="string" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.matches = []>

		<cftry>		
			<cfloop list="#str#" index="loc.item" delimiters="|">
				<!---<cffile action="append" file = "#application.site.dir_logs#\import.txt" addNewLine = "yes" output = "looking for #loc.item# IN #str#"> 	--->
				<cfloop array="#this.nomKeys#" index="loc.hint">
					<!---<cffile action="append" file = "#application.site.dir_logs#\import.txt" addNewLine = "yes" output = "#loc.hint.key# IN #loc.item# OF #str#"> --->
					<cfset loc.match = ReFindNoCase(loc.hint.key,loc.item,1,true)>
					<cfif FindNoCase(loc.hint.key,loc.item)>
						<cfset loc.hint.match = loc.match>
						<cfset ArrayAppend(loc.matches,loc.hint)>
					</cfif>
				</cfloop>
				<cfloop array="#this.clientKeys#" index="loc.hint">
					<!---<cffile action="append" file = "#application.site.dir_logs#\import.txt" addNewLine = "yes" output = "#loc.hint.key# = #str#"> --->
					<cfset loc.match = ReFindNoCase(loc.hint.key,loc.item,1,true)>
					<cfif FindNoCase(loc.hint.key,loc.item)>
						<cfset loc.hint.match = loc.match>
						<cfset ArrayAppend(loc.matches,loc.hint)>
					</cfif>
				</cfloop>
				<cfloop array="#this.accKeys#" index="loc.hint">
					<!---<cffile action="append" file = "#application.site.dir_logs#\import.txt" addNewLine = "yes" output = "#loc.hint.key# = #str#"> --->
					<cfset loc.match = ReFindNoCase(loc.hint.key,loc.item,1,true)>
					<cfif FindNoCase(loc.hint.key,loc.item)>
						<cfset loc.hint.match = loc.match>
						<cfset ArrayAppend(loc.matches,loc.hint)>
					</cfif>
				</cfloop>
			</cfloop>
			<cfset loc.maxlength = 0>
			<cfloop array="#loc.matches#" index="loc.key">
				<cfif loc.key.match.len[1] gte loc.maxlength>
					<cfset loc.maxlength = loc.key.match.len[1]>
					<cfset loc.result = loc.key>
				</cfif>
			</cfloop>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="PreviewFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.fields = "">
		<cfset loc.srchfields = "">
		<cfset loc.srchHintFields = "">

		<cftry>
			<!---<cfdump var="#args#" label="PreviewFile" expand="false">--->
			<cfif StructKeyExists(args.form, "srchFields")>
				<cfset loc.fields = args.form.srchFields>
			</cfif>
			<cfif StructKeyExists(args.form, "srchHintFields")>
				<cfset loc.srchHintFields = args.form.srchHintFields>
			</cfif>
			<cfif len(args.form.srchFile) eq 0>
				<cfset loc.result.msg = "no file selected">
			<cfelse>
				<cfset loc.filePath = "#args.dataDir##args.form.srchFile#">
				<cfif FileExists(loc.filePath)>
					<cfset loc.suffix = ListLast(args.form.srchFile,'.')>
					<cfif FindNoCase(loc.suffix ,'xls,xlsx',1)>
						<!--- spreadsheet file --->
						<cfspreadsheet action="read" src="#loc.filePath#" name="worksheet" rows="10">

						<cfif StructKeyExists(worksheet,"SUMMMARYINFO")>
							<cfset loc.result.summaryInfo = worksheet.summaryInfo>
						</cfif>
						<cfset loc.result.worksheet = worksheet>
						<cfoutput>
							<table border="1" width="700">
								<tr>
									<td>Sheet Names (#worksheet.summaryInfo.sheets#)</td>
									<td>
										<select name="srchSheet" class="select">
											<option value="">Select sheet...</option>
											<cfloop list="#worksheet.summaryInfo.sheetnames#" index="loc.key">
												<option value="#loc.key#"<cfif loc.key is srchSheet> selected="selected"</cfif>>#loc.key#</option>
											</cfloop>
										</select>
									</td>
								</tr>
								<cfif len(args.form.srchSheet)>
									<cfspreadsheet action="read" src="#loc.filePath#" sheetname="#args.form.srchSheet#" query="loc.result.QData" headerrow="1" excludeHeaderRow="true" />
									<cfset loc.result.colNames = loc.result.QData.ColumnList>
									<tr>
										<td>Column Names</td>
										<td>
											<input type="checkbox" name="tickAll" id="tickAll" tabindex="-1" checked title="Toggle checkboxes for all the fields." />Select all fields<br>
											<cfloop list="#loc.result.colNames#" index="loc.field">
												<input type="checkbox" class="fields" name="srchFields" value="#loc.field#" checked />#loc.field#<br>
											</cfloop>
										</td>
									</tr>
									<tr>
										<td>Hint Fields</td>
										<td>
											<select name="srchHintFields" class="srchHintFields" multiple="multiple" data-placeholder="Select...">
												<cfloop list="#loc.result.colNames#" index="loc.field">
													<option value="#loc.field#"<cfif ListFind(loc.srchHintFields,loc.field)> selected="selected"</cfif>>#loc.field#</option>
												</cfloop>
											</select>
										</td>
									</tr>
								</cfif>
							</table>
						</cfoutput>
					</cfif>
				</cfif>
			</cfif>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ProcessFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.result.data = "">
		<cfset loc.srchFields = "">
		<cfset loc.srchHintFields = "">
		<cfset loc.dataArray = []>
		<cfdump var="#args#" label="ProcessFile" expand="false">
		
		<cftry>
			<cfset loc.ping = LoadKeys(args)>
			<cfif StructKeyExists(args.form, "srchFields")>
				<cfset loc.srchFields = args.form.srchFields>
			</cfif>
			<cfif StructKeyExists(args.form, "srchHintFields")>
				<cfset loc.srchHintFields = args.form.srchHintFields>
			</cfif>
			<cfif len(args.form.srchFile) eq 0>
				<cfset loc.result.msg = "no file selected">
			<cfelse>
				<cfset loc.filePath = "#args.dataDir##args.form.srchFile#">
				<cfif FileExists(loc.filePath)>
					<cfset loc.suffix = ListLast(args.form.srchFile,'.')>
					<cfif FindNoCase(loc.suffix ,'xls,xlsx',1)>
						<!--- spreadsheet file --->
						<cfspreadsheet action="read" src="#loc.filePath#" name="worksheet">
						<cfset SpreadsheetSetActiveSheet(worksheet,args.form.srchSheet)>
						<cfset loc.data = SpreadsheetRead(loc.filePath,args.form.srchSheet)>
						
						<!--- get column names --->
						<cfspreadsheet action="read" src="#loc.filePath#" sheetname="#args.form.srchSheet#" 
							query="loc.QData" headerrow="1" excludeHeaderRow="false" rows="1" />
						<cfscript>
							queryToJSON=serializeJSON(loc.QData);
							// Note how the columns are in the 'correct' order
							// writeoutput(queryToJSON);
							loc.cols = deserializeJSON(queryToJSON,true);
						</cfscript>
						<cfset loc.count = 0>
						<cfset loc.activeCols = []>
						<cfset loc.colTitles = loc.cols.data[1]>
						<cfdump var="#loc.colTitles#" label="cols" expand="false">
						<cfloop array="#loc.colTitles#" index="loc.colTitle">
							<cfset loc.count++>
							<cfif ListFindNoCase(loc.srchFields,loc.colTitle,",")>
								<cfset ArrayAppend(loc.activeCols,loc.colTitle)>
							</cfif>
						</cfloop>
						<cfset loc.result.columnList = loc.activeCols>
								<cfdump var="#loc.activeCols#" label="activeCols #loc.count#" expand="false">
						<cfdump var="#loc.result.columnList#" label="columnList" expand="false">
						
						<cfset loc.count = 1>
						<cfspreadsheet action="read" src="#loc.filePath#" sheetname="#args.form.srchSheet#" 
							query="loc.QData" headerrow="1" excludeHeaderRow="true" rows="1-100" />
						<cfloop query="loc.QData">
							<cfset loc.rec = {"position" = loc.count}>
							<cfset loc.rec.search = "">
							<cfset loc.dl = "">
							
							<cfloop list="#loc.srchFields#" index="loc.key">
								<cfset "loc.rec.#loc.key#" = loc.QData[loc.key][loc.count]>
								<cfif ListFind(loc.srchHintFields,loc.key,",")>
									<cfset loc.rec.search = "#loc.rec.search##loc.dl##loc.QData[loc.key][loc.count]#">
									<cfset loc.dl = "|">
									<!---<cffile action="append" file = "#application.site.dir_logs#\import.txt" addNewLine = "yes" output = "#loc.key# IN search #loc.rec.search#"> --->
								</cfif>
							</cfloop>
							<cfset loc.rec.hint = SearchHints(loc.rec.search)>
							<cfset ArrayAppend(loc.dataArray,loc.rec)>
							<cfset loc.count++>
						</cfloop>
					</cfif>
				</cfif>
			</cfif>
			<cfset loc.result.parms = args>
			<cfset loc.result.data = loc.dataArray>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfdump var="#args#" label="ViewFile" expand="false">
		<cftry>
			<cfoutput>
			<table class="tableList">
				<tr>
					<cfloop array="#args.columnList#" index="loc.fld">
						<th>#loc.fld#</th>
					</cfloop>
					<td>Hint</td>
				</tr>
				<cfloop array="#args.data#" index="loc.item">
					<tr>
						<cfloop array="#args.columnList#" index="loc.fld">
							<td>#loc.item[loc.fld]#</td>
						</cfloop>
						<cfset loc.hint = loc.item["hint"]>
						<cfif NOT StructIsEmpty(loc.hint)>
							<td>
								<table width="100%">
									<tr>
										<td>#loc.hint.type#</td>
										<td>#loc.hint.key#</td>
										<td>#loc.hint.id#</td>
										<td>#loc.hint.title#</td>
									</tr>
								</table>
							</td>
						</cfif>
					</tr>
				</cfloop>
			</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
	
	<cffunction name="LoadAccountCodes" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QAccounts" datasource="#args.datasource#">
				SELECT accID,accCode,accName
				FROM tblAccount
				WHERE accType = 'purch'
				ORDER BY accName
			</cfquery>
			<cfset loc.result.QAccounts = loc.QAccounts>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ImportFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.trans = {}>
		<cfset loc.dupes = {}>
		<cfset loc.result.parms = args>
		
		<cftry>
			<cfset loc.filePath = "#args.dataDir##args.form.srchFile#">
			<cfif FileExists(loc.filePath)>
				<cfset loc.suffix = ListLast(args.form.srchFile,'.')>
				<cfif FindNoCase(loc.suffix ,'xls,xlsx',1)>
					<!--- spreadsheet file --->
					<cfspreadsheet action="read" src="#loc.filePath#" name="worksheet">
					<cfset SpreadsheetSetActiveSheet(worksheet,args.form.srchSheet)>
					<cfset loc.data = SpreadsheetRead(loc.filePath,args.form.srchSheet)>
					
					<!--- get column names --->
					<cfspreadsheet action="read" src="#loc.filePath#" sheetname="#args.form.srchSheet#" 
						query="loc.QData" headerrow="1" excludeHeaderRow="false" rows="1" />
					<cfscript>
						queryToJSON=serializeJSON(loc.QData);
						// Note how the columns are in the 'correct' order
						// writeoutput(queryToJSON);
						loc.cols = deserializeJSON(queryToJSON,true);
					</cfscript>
					<cfset loc.result.columns = loc.cols.columns>

					<cfquery name="loc.QSupplier" datasource="#args.datasource#">
						SELECT accID,accCode,accName,accPayAcc
						FROM tblAccount
						WHERE accID = #val(args.form.srchSupplier)#
					</cfquery>
					
					<!--- get data --->
					<cfspreadsheet action="read" src="#loc.filePath#" sheetname="#args.form.srchSheet#" 
						query="loc.QData" headerrow="1" excludeHeaderRow="true" rows="1-200" />
					<cfloop query="loc.QData">
						<cfset loc.date = loc.QData.Date>
						<cfif StructKeyExists(args,"form")>
							<cfset loc.inRange = loc.date GTE args.form.srchDateFrom AND (loc.date LTE args.form.srchDateTo OR len(args.form.srchDateTo) IS 0)>
						<cfelse>
							<cfset loc.inRange = true>
						</cfif>
						<cfif loc.inRange>
							<cfif FindNoCase("Invoice",Source,1)>
								<cfset loc.type = 'inv'>
								<cfset loc.payAcc = 0>
							<cfelseif FindNoCase("Credit",Source,1)>
								<cfset loc.type = 'crn'>
								<cfset loc.payAcc = 0>
							<cfelseif FindNoCase("Payment",Source,1)>
								<cfset loc.type = 'pay'>
								<cfset loc.payAcc = val(loc.QSupplier.accPayAcc)>
							<cfelse>
								<cfset loc.type = Source>
								<cfset loc.payAcc = 0>
							</cfif>
							<cfif len(Reference) IS 0>
								<cfset loc.m = REFind("\d+", Description, 1, true)>
								<cfif loc.m.len[1] GT 0>
									<cfset loc.numberOnly = Mid(Description, loc.m.pos[1], loc.m.len[1])>
									<cfset loc.ref = "#loc.type##loc.numberOnly#">
								<cfelse>
									<cfset loc.ref = Reference>
								</cfif>
							<cfelse>
								<cfset loc.ref = Reference>
							</cfif>
							<cfif !StructKeyExists(loc.trans,loc.ref)>
								<cfif Find("(",Amount,1)>
									<cfset loc.amount = ReReplaceNoCase(Amount,"[^0-9,\.]","","ALL")>
									<cfset loc.amount = -loc.amount>
								<cfelse>
									<cfset loc.amount = Amount>
								</cfif>
								<cfset StructInsert(loc.trans,loc.ref, {
									"trnAccountID" = args.form.srchSupplier,
									"row" = currentRow,
									"trnDate" = Date,
									"trnRef" = loc.ref,
									"trnType" = loc.type,
									"trnDesc" = Description,
									"trnAmnt1" = loc.amount,
									"trnPayAcc" = loc.payAcc,
									"Balance" = Balance,
									"items" = {
										"niAmount" = loc.amount, 
										"debit" = args.form.srchDebit,
										"credit" = args.form.srchCredit,
										"payAccount" = loc.payAcc
									}
								})>
							<cfelse>
								<cfif !StructKeyExists(loc.dupes,loc.ref)>
									<cfset StructInsert(loc.dupes,loc.ref,1)>
								<cfelse>
									<cfset loc.check = StructFind(loc.dupes,loc.ref)>
									<cfset StructUpdate(loc.dupes,loc.ref,loc.check++)>
								</cfif>
							</cfif>
						</cfif>
					</cfloop>
					<cfset loc.result.trans = loc.trans>
					<cfset loc.result.dupes = loc.dupes>
				</cfif>
			</cfif>

		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

	<cffunction name="ViewImportFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		<cfset loc.counter = 0>
		
		<cftry>
			<cfoutput>
				<table>
					<tr>
						<th>##</th>
						<th>Supplier</th>
						<cfloop array="#args.columns#" index="loc.col">
							<th>#loc.col#</th>
						</cfloop>
						<th>Debit</th>
						<th>Credit</th>
						<th>Pay ID</th>
						<th>Tran ID</th>
						<th>Status</th>
					</tr>
					<cfset loc.keys = ListSort(StructKeyList(args.trans,","),"text","asc")>
					<cfloop list="#loc.keys#" index="loc.key">
						<cfset loc.counter++>
						<cfset loc.tranID = 0>
						<cfset loc.data = StructFind(args.trans,loc.key)>
						<cfquery name="loc.QTranExist" datasource="#args.parms.datasource#">
							SELECT trnID
							FROM tblTrans
							WHERE trnRef = '#loc.data.trnRef#'
							AND trnDate = '#loc.data.trnDate#'
							AND trnAccountID = #loc.data.trnAccountID#
						</cfquery>
						<cfif loc.QTranExist.recordcount eq 0>
							<cfif args.parms.form.srchMode eq 2>
								<cfquery name="loc.QInsertTran" datasource="#args.parms.datasource#" result="loc.QInsertTranResult">
									INSERT INTO tblTrans
										(trnAccountID,trnType,trnDate,trnRef,trnDesc,trnAmnt1,trnPayAcc) 
									VALUES (#loc.data.trnAccountID#, '#loc.data.trnType#', '#loc.data.trnDate#', 
										'#loc.data.trnRef#', '#loc.data.trnDesc#', #loc.data.items.niAmount#, '#loc.data.trnPayAcc#')
								</cfquery>
								<cfset loc.tranID = loc.QInsertTranResult.generatedkey>
								<cfif Find(loc.data.trnType,'inv,crn',1)>
									<cfquery name="loc.QInsertItems" datasource="#args.parms.datasource#">
										INSERT INTO tblNomItems
											(niTranID,niNomID,niAmount) 
										VALUES 
											(#loc.tranID#,#loc.data.items.credit#,#-loc.data.items.niAmount#),
											(#loc.tranID#,#loc.data.items.debit#,#loc.data.items.niAmount#)			
									</cfquery>
									<cfset loc.status = "inv/crn inserted">
								<cfelse>
									<cfquery name="loc.QInsertItems" datasource="#args.parms.datasource#">
										INSERT INTO tblNomItems
											(niTranID,niNomID,niAmount) 
										VALUES 
											(#loc.tranID#,#loc.data.items.payAccount#,#-loc.data.items.niAmount#),
											(#loc.tranID#,#loc.data.items.credit#,#loc.data.items.niAmount#)			
									</cfquery>
									<cfset loc.status = "pay/jnl inserted">
								</cfif>
							<cfelse>
								<cfset loc.status = "not found">
							</cfif>
						<cfelse>
							<cfset loc.tranID = loc.QTranExist.trnID>
							<cfquery name="loc.QUpdate" datasource="#args.parms.datasource#">
								UPDATE tblTrans
								SET
									trnAccountID = #loc.data.trnAccountID#,
									trnType = '#loc.data.trnType#',
									trnDate = '#loc.data.trnDate#',
									trnRef = '#loc.data.trnRef#',
									trnDesc = '#loc.data.trnDesc#',
									trnAmnt1 = #loc.data.items.niAmount#,
									trnPayAcc = #loc.data.items.payAccount#
								WHERE
									trnID = #loc.tranID#
							</cfquery>
							<!--- update nom items too --->
							<cfset loc.status = "updated #loc.tranID#">
						</cfif>
						<tr>
							<td>#loc.counter#</td>
							<td>#loc.data.trnAccountID#</td>
							<td>#loc.data.row#</td>
							<td>#loc.data.trnDate#</td>
							<td>#loc.data.trnType#</td>
							<td>#loc.data.trnRef#</td>
							<td>#loc.data.trnDesc#</td>
							<td>#loc.data.items.niAmount#</td>
							<td>#loc.data.Balance#</td>
							<td>#loc.data.items.debit#</td>
							<td>#loc.data.items.credit#</td>
							<td>#loc.data.items.payAccount#</td>
							<td>#loc.tranID#</td>
							<td>#loc.status#</td>
						</tr>
						<!---<cfif loc.counter eq 20>
							<cfbreak>
						</cfif>--->
					</cfloop>
				</table>
			</cfoutput>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

</cfcomponent>