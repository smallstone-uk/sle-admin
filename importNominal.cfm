<!DOCTYPE HTML>
<html>
<head>
	<meta charset="utf-8">
	<title>Import Nominal Transactions</title>
	<link rel="stylesheet" type="text/css" href="css/main.css">
	<link href="css/chosen.css" rel="stylesheet" type="text/css">
	<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
	<script src="scripts/jquery-1.11.1.min.js"></script>
	<script src="scripts/jquery-ui-1.10.3.custom.min.js"></script>
	<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.datepicker').datepicker({dateFormat: "yy-mm-dd",changeMonth: true,changeYear: true,showButtonPanel: true, minDate: new Date(2013, 0, 1)});
			$(".srchAccount, .srchTranType").chosen({width: "300px"});
		});
	</script>
	<style type="text/css">
		.title {font-family:Arial, Helvetica, sans-serif; font-size:14px; font-weight:bold;}
		.tableStyle {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		.tableFiles {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border-collapse:collapse;
		}
		.tableStyle th, .tableStyle td {
			border: 1px solid #ccc;
			padding: 2px 4px;
		}
		.blue {background-color:#0000FF; color:#FFFFFF}
		.green {background-color:#0F0;}
		.red {background-color:#FF0000;}
		.fuschia {background-color:#FF33FF;}
		.insert {font-weight:bold; color:#FF00FF;}
	</style>
</head>

<cfparam name="srchDateFrom" default="">
<cfparam name="srchDateTo" default="">
<cfparam name="srchFile" default="">
<cfparam name="srchSuppliers" default="on">
<cfparam name="srchNominal" default="on">
<cfparam name="srchCustomers" default="on">
<cfparam name="srchUnknown" default="">
<cfparam name="srchFilter" default="">
<cfparam name="srchColName" default="">
<cfparam name="srchField" default="">
<cfparam name="srchRef" default="">
<cfparam name="srchDebit" default="">
<cfparam name="srchCredit" default="">

<cfobject component="code/purchase" name="pur">
<cfobject component="code/accounts" name="acc">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset nominals=acc.LoadNominalCodes(parms)>

<cfset insertCount = 0>
<cfset recordCount = 0>
<cfset colNames = "">
 
<body>

	<cffunction name="processSheet" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset var rec={}>
		<cfset loc.result={}>
		<cfset loc.accountRef="">
		<cfset loc.inFilter=true>
		<cfset loc.inRange=true>
        <cfset loc.trans = []>
		<cfset loc.i = 0>
		
		<cfspreadsheet action="read" src="#args.fileName#" name="spready">
		<cfset SpreadsheetSetActiveSheet(spready,"Bank Recon")>
		<cfset reconInfo=SpreadsheetRead(args.fileName,"Bank Recon")>
		<cfdump var="#form#" label="form" expand="false">
		<cfloop from="1" to="#reconInfo.rowCount#" index="loc.i" step="50">
			<cfspreadsheet action="read" src="#args.fileName#" sheetname="Bank Recon" query="QData"
				columns="1-11" rows="#loc.i#-#loc.i+49#" headerrow="1" excludeHeaderRow="true" />
			<cfdump var="#QData#" label="QData #loc.i#" expand="false">
            <cfset colNames = QData.ColumnList>
			<cfoutput>
				<table class="tableStyle" border="1" width="100%">
					<tr>	<!--- data block header --->
						<cfloop list="#colNames#" index="fld">
							<td>#fld#</td>
						</cfloop>
						<td>clean</td>
						<td>Result</td>
					</tr>
					<cfloop query="QData">
						<cfset loc.exists = 0>
						<cfset loc.inRange = true>
						<cfif StructKeyExists(args,"form")>
							<cfset loc.inRange = Qdata.Date GTE args.form.srchDateFrom AND (Qdata.Date LTE args.form.srchDateTo OR len(args.form.srchDateTo) IS 0)>
                            <!---<cfif len(srchFilter)><cfset loc.inRange = loc.inRange AND (Evaluate(srchColName) eq srchFilter)></cfif>--->
                           	<cfif len(srchFilter)><cfset loc.inRange = loc.inRange AND (FindNoCase(srchFilter,Evaluate(srchColName),1) gt 0)></cfif>
						</cfif>
						<cfquery name="loc.QCheckExists" datasource="#application.site.datasource1#">
							SELECT *
							FROM tblTrans
							WHERE trnRef='#Ref#'
						</cfquery>
                        <!---<cfset loc.cleanValue = val(Value)>--->
						<cfset loc.cleanValue = ReReplace(Value,"[^0-9.\-]","","all")>
						<cfif loc.QCheckExists.recordcount gt 0>
							<cfset loc.exists = 1>
							<cfset recordCount++>
						<cfelseif loc.inRange AND loc.cleanValue neq 0>
							<cfset insertCount++>
							<cfset loc.rec = {
                                "trnDate" = acc.FormatDate(Date,'yyyy-mm-dd'),
                                "trnRef" = Ref,
                                "trnDesc" = Description,
								"items" = [
									{"niNomID" = srchDebit,
									"niAmount" = ABS(loc.cleanValue)},
									{"niNomID" = srchCredit,
									"niAmount" = -ABS(loc.cleanValue)}
								]
                            }>
                            <cfset ArrayAppend(loc.trans,loc.rec)>
							<cfif srchMode eq 2>
                            	<tr>
									<td><cfset InsertTran(loc.rec)></td>
                                </tr>
							</cfif>
						</cfif>
						<cfif loc.inRange>
                        	<tr>
								<cfloop list="#colNames#" index="fld">
									<td>#Evaluate(fld)#</td>
								</cfloop>
								<td>#loc.cleanValue#</td>
								<td>#insertCount#</td>
                            </tr>
                        </cfif>
					</cfloop>
				</table>
                <!---<cfdump var="#loc.trans#" label="loc.trans" expand="false">--->
			</cfoutput>
		</cfloop>
		<cfreturn loc.result>
	</cffunction>
		
	<cffunction name="InsertTran" access="public" returntype="string">
		<cfargument name="args" type="struct" required="yes">
     	  <cfdump var="#args#" label="args" expand="false"> 
		<cfset var loc={}>
		<cfquery name="loc.QCheckExists" datasource="#application.site.datasource1#">
			SELECT *
			FROM tblTrans
			WHERE trnRef='#args.trnRef#'
		</cfquery>
		<cfif loc.QCheckExists.recordCount eq 0>
			<cfquery name="loc.QInsertTran" datasource="#application.site.datasource1#" result="loc.QInsertTranResult">
				INSERT INTO tblTrans
					(trnLedger,trnRef,trnDate,trnDesc,trnType,trnAlloc,trnActive)
				VALUES ('nom','#args.trnRef#','#args.trnDate#','#args.trnDesc#','nom',1,1)
			</cfquery>
			<cfset loc.tranID = loc.QInsertTranResult.generatedKey>
            <cfset loc.str = "">
            <cfloop array="#args.items#" index="loc.rec">
                <cfset loc.str = "#loc.str#(#loc.rec.niNomID#,#loc.tranID#,#loc.rec.niAmount#),">
            </cfloop>
            <cfset loc.str = RemoveChars(loc.str, len(loc.str),1)>
            <!--- <cfdump var="#loc.str#" label="loc.str" expand="false"> --->
			<cfquery name="loc.QInsertItems" datasource="#application.site.datasource1#">
				INSERT INTO tblNomItems
					(niNomID,niTranID,niAmount)
				VALUES
                	#loc.str#
			</cfquery>
			<cfreturn "Inserted">    
		</cfif> 
		<cfreturn "Exists">
	</cffunction>
    		
<!--- main --->
<cftry>
	<cfflush interval="200">
	<cfsetting requesttimeout="900">
	<cfset dataDir="#application.site.dir_data#spreadsheets\">
	<cfif StructKeyExists(form,"fieldnames")>
		<cfif StructKeyExists(form,"srchFile")AND ListLen(form.srchFile,",") GT 0>
			<cfloop list="#form.srchFile#" index="fileSrc">
				<cfset parm={}>
				<cfset parm.form=form>
				<cfset parm.process=form.srchMode EQ 2>
				<cfset parm.fileName="#application.site.dir_data#spreadsheets\#fileSrc#">
				<cfoutput><p class="title">#parm.fileName#</p></cfoutput>
				<h1><cfif form.srchMode eq 2>Import<cfelse>View</cfif> Nominal Transactions</h1>
				<cfset processSheet(parm)>
			</cfloop>
			<cfoutput>
				<p>#recordCount# records found.</p>
				<cfif form.srchMode eq 2>
					<p>#insertCount# records inserted.</p>
				<cfelse>
					<p>#insertCount# records to insert.</p>
				</cfif>
			</cfoutput>
			<cfset fileSrc="">
		<cfelse>
			No files selected.
		</cfif>
	</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

<cfdirectory directory="#dataDir#" action="list" name="QDir">
<h2><a href="importDelWages.cfm">Import Nominal Transactions</a></h2>
<cfoutput>
<form name="processForm" method="post" enctype="multipart/form-data">
	<table class="tableStyle" border="1" width="500">
		<tr>
			<th colspan="2" align="left">Import Settings</th>
		</tr>
		<tr>
			<td>Reference</td>
			<td><input type="text" name="srchRef" value="#srchRef#" size="15" /></td>
		</tr>
		<tr>
			<td>Transaction Dates From</td>
			<td><input type="text" name="srchDateFrom" value="#srchDateFrom#" size="15" class="datepicker" /></td>
		</tr>
		<tr>
			<td>Transaction Dates To</td>
			<td><input type="text" name="srchDateTo" value="#srchDateTo#" size="15" class="datepicker" /></td>
		</tr>
		<tr>
			<td>Using Column Name:</td>
			<td>
            	<select name="srchColName" class="select">
                	<cfloop list="#colNames#" index="fld">
                    	<option value="#fld#"<cfif fld is srchColName> selected="selected"</cfif>>#fld#</option>
                    </cfloop>
            	</select>
                Find This: <input type="text" name="srchFilter" value="#srchFilter#" size="15" />
            </td>
		</tr>
		<tr>
			<td>Debit Account</td>
			<td>
				<select name="srchDebit" class="select">
					<option value="">Select...</option>
					<cfloop array="#nominals.nomArray#" index="nom">
						<option value="#nom.nomID#"<cfif nom.nomID is srchDebit> selected="selected"</cfif>>
							#nom.nomTitle# - #nom.nomGroup# - #nom.nomCode# - #NumberFormat(nom.nomID,'0000')#</option>
					</cfloop>
				</select>
			</td>					
		</tr>
		<tr>
			<td>Credit Account</td>
			<td>
				<select name="srchCredit" class="select">
					<option value="">Select...</option>
					<cfloop array="#nominals.nomArray#" index="nom">
						<option value="#nom.nomID#"<cfif nom.nomID is srchCredit> selected="selected"</cfif>>
							#nom.nomTitle# - #nom.nomGroup# - #nom.nomCode# - #NumberFormat(nom.nomID,'0000')#</option>
					</cfloop>
				</select>
			</td>					
		</tr>
		<tr>
			<td>Processing Mode</td>
			<td>
				<input type="radio" name="srchMode" value="1" checked="checked" /> View Only
				<input type="radio" name="srchMode" value="2" /> Import Data
			</td>
		</tr>
		<tr>
			<td>Options:</td>
			<td>
				<input type="checkbox" name="srchUnknown"<cfif srchUnknown eq "on"> checked="checked"</cfif> /> Ignore Unknown Trans?
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<table width="100%" class="tableFiles">
					<tr>
						<th align="left">##</th>
						<th align="left">Select</th>
						<th align="left">File</th>
						<th align="left">Date Modified</th>
						<th align="right">Size</th>
					</tr>
					<cfloop query="QDir">
						<cfif type eq "file">
							<tr>
								<td>#currentrow#</td>
								<td><input type="checkbox" name="srchFile" value="#name#" <cfif ListFind(srchFile,name,",")> checked </cfif> /></td>
								<td><a href="#application.site.url_data#spreadsheets/#name#" title="download spreadsheet">#name#</a></td>
								<td>#acc.FormatDate(datelastmodified,"dd-mmm-yyyy")#</td>
								<td align="right">#acc.FormatBytes(size)#</td>
							</tr>
						</cfif>
					</cfloop>
				</table>
			</td>
		</tr>
		<tr>
			<td colspan="2">
				<input type="submit" name="btnSubmit" value="Process selected files" />
			</td>
		</tr>
	</table>
</form>
</cfoutput>
</body>
</html>