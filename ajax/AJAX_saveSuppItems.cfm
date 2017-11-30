<cfsetting showdebugoutput="no" requesttimeout="300">
<cftry>
	<cfobject component="code/accounts" name="acc">
	<cfset callback = true>
	<cfset parm = {}>
	<cfset parm.database = application.site.datasource1>
	<cfset parm.items = DeserializeJSON(items)>
	<cfset parm.header = DeserializeJSON(header)>
	<cfset parm.header.allocate=false>
	<cfif StructKeyExists(parm.header, "paidCOD") AND parm.header.paidCOD AND parm.header.tranType IS 'inv'>
		<cfset parm.header.allocate=true>	<!--- to be allocated to subsequent payment --->
		<cfquery name="loc.QAccountID" datasource="#parm.database#">
			SELECT accAllocID
			FROM tblAccount
			WHERE accID = #val(parm.header.accID)#
			LIMIT 1;
		</cfquery>
		<cfset parm.header.allocID = loc.QAccountID.accAllocID + 1>
	<cfelse>
		<cfset parm.header.allocID = 0>
	</cfif>
	<cfset TransRecord = acc.SaveAccountTransRecord(parm)>

<!---	<cfdump var="#TransRecord#" label="TransRecord" expand="yes" format="html" 
	output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">

	<cfdump var="#parm#" label="parm" expand="yes" format="html" 
	output="#application.site.dir_logs#dump-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
--->
	<cfif parm.header.allocate AND TransRecord.isNew>	<!--- write matching payment --->
		<cfset parm.header.trnID=0>
		<cfset parm.header.PaymentAccounts=491>		<!--- SUPP - was 181 (cash in till) --->
		<cfset parm.header.tranType='pay'>
		<cfset trnTotalNum=val(Replace(parm.header.trnTotal,",","","all"))>
		<cfset parm.header.trnAmnt1=trnTotalNum>
		<cfset parm.header.trnAmnt2=0>
		<cfset parm.header.trnTotal=-trnTotalNum>
		<cfset parm.header.trnRef='SHOP'>
		<cfset parm.header.trnDesc='COD Payment'>
		<cfif StructKeyExists(parm.header,"paidDate")>
			<cfif len(parm.header.paidDate)><cfset parm.header.trnDate=parm.header.paidDate></cfif>
		</cfif>
		<cfset parm.items=[]>
		<cfset paymentRecord = acc.SaveAccountTransRecord(parm)>
		<cfquery name="loc.QAccountIDUpdate" datasource="#parm.database#">
			UPDATE tblAccount
			SET accAllocID = #parm.header.allocID#
			WHERE accID = #val(parm.header.accID)#
			LIMIT 1;
		</cfquery>
	</cfif>
	
	<cfset parm.form = {}>
	<cfif StructKeyExists(TransRecord, "tranID")>
		<cfoutput>#TransRecord.tranID#</cfoutput>
	</cfif>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>
