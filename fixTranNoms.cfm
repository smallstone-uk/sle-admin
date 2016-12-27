
<cfsetting requesttimeout="900">
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT tblTrans.*, niAmount
	FROM tblTrans
	LEFT JOIN tblNomItems ON niTranID=trnID
	WHERE niID IS NULL
	AND trnType IN ('inv','crn')
	AND trnClientRef>0
	ORDER BY trnID
</cfquery>
<cfoutput>
	<cfloop query="QTrans">
		<cfquery name="QAddNom" datasource="#application.site.datasource1#" result="QResult">
			INSERT INTO tblNomItems (
				niTranID,
				niNomID,
				niAmount
			) VALUES (
				#QTrans.trnID#,
				1001,
				#-QTrans.trnAmnt1#
			)
		</cfquery>
		<!---<cfbreak>--->
		#QTrans.trnClientRef# #QTrans.trnDate# #QTrans.trnID# #QTrans.trnAmnt1#<br>
	</cfloop>
</cfoutput>
