<cftry>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfquery name="getStockListFromDB" datasource="#parm.datasource#">
	SELECT ctlStockList
	FROM tblControl
	WHERE ctlID = 1
</cfquery>
<cfset parm.type = (IsDefined("type")) ? type : "">
<cfset parm.current = ListToArray(getStockListFromDB.ctlStockList, ",")>
<cfset parm.list = DeserializeJSON(list)>

<cfif parm.type eq "append">
	<cfloop array="#parm.list#" index="item">
		<cfset ArrayAppend(parm.current, item)>
	</cfloop>
	<cfset stockList = ArrayToList(parm.current, ",")>
<cfelse>
	<cfset stockList = ArrayToList(parm.list, ",")>
</cfif>

<cfquery name="saveToDB" datasource="#parm.datasource#">
	UPDATE tblControl
	SET	ctlStockList = '#stockList#'
	WHERE ctlID = 1
</cfquery>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>