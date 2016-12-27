<cfquery name="QList" datasource="#application.site.datasource1#">
	SELECT cltRef,cltDelHouse,stName,oiSat,pubTitle
	FROM tblOrderItem,tblOrder,tblClients,tblPublication,tblStreets
	WHERE oiSat<>0
	AND oiPubID=26581
	AND oiOrderID=ordID
	AND ordClientID=cltID
	AND (cltAccountType='M' OR cltAccountType='W')
	AND oiPubID=pubID
	AND cltStreetCode=stRef
	ORDER BY cltRef asc
</cfquery>

<cfdump var="#QList#" label="QList" expand="yes">