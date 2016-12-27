
<cfsetting requesttimeout="900">
<cfquery name="QTrans" datasource="#application.site.datasource1#">
	SELECT tblTrans.*, niAmount
	FROM tblTrans
	LEFT JOIN tblNomItems ON niTranID=trnID
	WHERE niID IS NULL
	AND trnType = 'pay'
	AND trnMethod='sv'
	ORDER BY trnID
</cfquery>
<cfdump var="#QTrans#" label="" expand="no">
<cfoutput>
	<cfloop query="QTrans">
		<cfquery name="QAddNom" datasource="#application.site.datasource1#" result="QResult">
			INSERT INTO tblNomItems (
				niTranID,
				niNomID,
				niAmount
			) VALUES 
				(#QTrans.trnID#,1762,#QTrans.trnAmnt1#),
				(#QTrans.trnID#,1,#-QTrans.trnAmnt1#)
		</cfquery>
		#QTrans.trnClientRef# #QTrans.trnDate# #QTrans.trnID# #QTrans.trnAmnt1#<br>
		<!---<cfbreak>--->
	</cfloop>
</cfoutput>
