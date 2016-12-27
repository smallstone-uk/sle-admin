<cfsetting requesttimeout="300" showdebugoutput="no">
 
<cfset args={}>
<cfset args.datasource=application.site.datasource1>

<cfoutput>
	<cfquery name="QProds" datasource="#args.datasource#">
		SELECT *
		FROM tblProducts
	</cfquery>
	<cfloop query="QProds">
		<cfquery name="QCheckBarcode" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barCode='#prodBarcode#'
			LIMIT 1;
		</cfquery>
		<cfif QCheckBarcode.recordcount is 0>
			<cfquery name="QCheckBarcode" datasource="#args.datasource#">
				INSERT INTO tblBarcodes (
					barCode,
					barType,
					barProdID
				) VALUES (
					'#prodBarcode#',
					'product',
					#prodID#
				)
			</cfquery>
			INSERTED #prodBarcode# - #prodTitle#<br />
		</cfif>
	</cfloop>
</cfoutput>
