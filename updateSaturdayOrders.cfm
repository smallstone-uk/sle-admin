<cfsetting requesttimeout="300">

<cfquery name="QSat" datasource="#application.site.datasource1#">
	SELECT * 
	FROM tblOrderItem,tblPublication
	WHERE oiPubID=pubID
	AND oiSat<>0
	AND pubGroup='News'
	AND pubType<>'Saturday'
</cfquery>

<cfoutput>
	<cfloop query="QSat">
		<cfquery name="QNewPub" datasource="#application.site.datasource1#">
			SELECT * 
			FROM tblPublication
			WHERE pubTitle LIKE '%#QSat.pubTitle#%'
			AND pubType='Saturday'
		</cfquery>
		<cfquery name="QInsertSat" datasource="#application.site.datasource1#">
			INSERT INTO tblOrderItem (
				oiOrderID,
				oiPubID,
				oiSat
			) VALUES (
				#QSat.oiOrderID#,
				#val(QNewPub.pubID)#,
				#QSat.oiSat#
			)
		</cfquery>		
		<cfquery name="QUpdateSat" datasource="#application.site.datasource1#">
			UPDATE tblOrderItem
			SET oiSat=0
			WHERE oiID=#QSat.oiID#
		</cfquery>		
		INSERT INTO tblOrderItem (
			oiOrderID,
			oiPubID,
			oiSat
		) VALUES (
			#QSat.oiOrderID#,
			#val(QNewPub.pubID)#,
			#QSat.oiSat#
		)
		<br />
	</cfloop>
</cfoutput>
