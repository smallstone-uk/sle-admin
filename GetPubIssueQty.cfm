<cftry>
	<cfset callback=1>
	<cfsetting showdebugoutput="no">
	<cfparam name="print" default="false">
	
	<cfobject component="code/functions" name="func">
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.pub=val(psPubID)>
	<cfset parm.type=GetType>
	<cfset parm.currenttype=psType>
	<cfset parm.issue=psIssue>
	<cfset parm.date=psDate>
	<cfset issue=func.GetPubStockIssue(parm)>

	<cfoutput>
		<cfif NOT StructKeyExists(form,"override")>
			<input type="hidden" name="mode" value="#issue.mode#">		<!---what is this for? --->
			<!---<input type="hidden" name="mode" value="1">--->
			<input type="hidden" name="psID" value="#issue.ID#">
			<input type="hidden" name="checkID" value="#issue.checkID#">
			<b>#issue.qty#</b><br /><span style="font-size:10px;color:##555;">#issue.Date#</span>
			<cfset diff=issue.qty-issue.soldqty>
		<cfelse>
			<input type="hidden" name="mode" value="1">
			<input type="hidden" name="psID" value="0">
			<input type="hidden" name="checkID" value="0">
		</cfif>
		<cfif parm.currenttype is "returned">
			<script type="text/javascript">
				$('##returnedQty').val("#issue.returnQty#");
				$('##Sold').html("#issue.soldqty#");
				$('##returnedQty').focus();
			</script>
		<cfelseif parm.currenttype is "credited">
			<script type="text/javascript">
				$('##creditedQty').val("#issue.qty#");
				$('##returnedQty').focus();
			</script>
		<cfelseif parm.currenttype is "claim">
			<script type="text/javascript">
				$('##claimQty').val("");
				$('##claimRef').val("#issue.ref#").show();
				$('##returnedQty').focus();
			</script>
		</cfif>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="GetPubIssueQty" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

