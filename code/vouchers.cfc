<cfcomponent displayname="vouchers" extends="core">

	<cffunction name="LoadVouchers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var item={}>
		<cfset var QVouchers="">
		<cfset result.list=[]>
		<cfset result.total=0>
		<cfset result.ref="">
		<cfset result.date=Now()>
		
		<cftry>
			<cfquery name="QVouchers" datasource="#args.datasource#">
				SELECT *
				FROM tblVoucherItems,tblVoucherTitles
				WHERE vtSuppID='#args.form.suppID#'
				<cfif len(args.form.ref)>
					AND vtmRef='#args.form.ref#'
				<cfelse>
					AND vtmDate='#LSDateFormat(args.form.date,"yyyy-mm-dd")#'
				</cfif>
				AND vtmTitleID=vtID
				ORDER BY vtTitle asc
			</cfquery>
			<cfloop query="QVouchers">
				<cfset item={}>
				<cfset item.ID=vtmID>
				<cfset item.Title=vtTitle>
				<cfset item.Date=vtmDate>
				<cfset item.Ref=vtmRef>
				<cfset item.Amount=vtmAmount>
				<cfset item.HandAllow=vtmHandAllow>
				<cfset item.Qty=vtmQty>
				<cfset item.Status=vtmStatus>
				<cfset item.LineTotal=(vtmAmount+vtmHandAllow)*vtmQty>
				<cfset result.total=result.total+item.LineTotal>
				<cfset ArrayAppend(result.list,item)>
				<cfset result.ref=item.Ref>
				<cfset result.date=item.Date>
			</cfloop>
	
			<cfcatch type="any">
				<cfset result.error=cfcatch>
			</cfcatch>
		</cftry>
		
		<cfreturn result>
	</cffunction>
	
	<cffunction name="LoadTitles" access="public" returntype="array">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result=[]>
		<cfset var item={}>
		<cfset var QVouchers="">

		<cfquery name="QVouchers" datasource="#args.datasource#">
			SELECT *
			FROM tblVoucherTitles
			ORDER BY vtTitle asc
		</cfquery>
		<cfloop query="QVouchers">
			<cfset item={}>
			<cfset item.ID=vtID>
			<cfset item.Title=vtTitle>
			<cfset item.Amount=vtValue>
			<cfset ArrayAppend(result,item)>
		</cfloop>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="GetBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QBarcode="">
		<cfset result.error=false>
		<cfset result.msg="">
		
		<cfquery name="QBarcode" datasource="#args.datasource#">
			SELECT *
			FROM tblBarcodes
			WHERE barCode='#args.form.barcode#'
			LIMIT 1;
		</cfquery>
		<cfif QBarcode.recordcount is 1>
			<cfset parm={}>
			<cfset parm.datasource=args.datasource>
			<cfset parm.barcode=args.form.barcode>
			<cfset parm.suppID=args.form.suppID>
			<cfset parm.date=args.form.date>
			<cfset parm.ref=args.form.ref>
			<cfset parm.qty=args.form.qty>
			<cfset parm.vchID=QBarcode.barProdID>
			<cfset get=GetVoucher(parm)>
			<cfset result=get>
			<cfset result.msg=get.msg>
		<cfelse>
			<cfset result.msg="Barcode not found">
			<cfset result.error=true>
		</cfif>
		
		<cfreturn result>
	</cffunction>

	<cffunction name="GetVoucher" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QVouchers="">
		<cfset var QCheckVoucher="">
		<cfset var QInsert="">
		<cfset var QUpdate="">
		
		<cftry>
			<cfquery name="QVouchers" datasource="#args.datasource#">
				SELECT *
				FROM tblVoucherTitles
				WHERE vtID=#args.vchID#
				AND vtSuppID='#args.suppID#'
				LIMIT 1;
			</cfquery>
			<cfif QVouchers.recordcount is 1>
				<cfquery name="QCheckVoucher" datasource="#args.datasource#">
					SELECT *
					FROM tblVoucherItems
					WHERE vtmTitleID=#QVouchers.vtID#
					AND vtmDate='#LSDateFormat(args.date,"yyyy-mm-dd")#'
					AND vtmRef='#args.ref#'
					AND vtmStatus='open'
					LIMIT 1;
				</cfquery>
				<cfif QCheckVoucher.recordcount is 0>
					<cfquery name="QInsert" datasource="#args.datasource#">
						INSERT INTO tblVoucherItems (
							vtmDate,
							vtmRef,
							vtmTitleID,
							vtmAmount,
							vtmHandAllow,
							vtmQty,
							vtmStatus
						) VALUES (
							'#LSDateFormat(args.date,"yyyy-mm-dd")#',
							'#args.ref#',
							#QVouchers.vtID#,
							#QVouchers.vtValue#,
							#QVouchers.vtHandAllow#,
							#val(args.qty)#,
							'open'
						)
					</cfquery>
				<cfelse>
					<cfquery name="QUpdate" datasource="#args.datasource#">
						UPDATE tblVoucherItems
						SET vtmQty=#QCheckVoucher.vtmQty+val(args.qty)#
						WHERE vtmID=#QCheckVoucher.vtmID#
					</cfquery>
				</cfif>
				<cfset result.msg="Voucher Added">
			<cfelse>
				<cfset result.msg="Wrong supplier">
			</cfif>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="AddVoucherBarcode" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QInsert="">
		
		<cftry>
			<cfquery name="QInsert" datasource="#args.datasource#">
				INSERT INTO tblBarcodes (
					barCode,
					barType,
					barProdID
				) VALUES (
					'#args.form.barcode#',
					'voucher',
					#args.form.TitleID#
				)
			</cfquery>
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
				output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>

		<cfreturn result>
	</cffunction>

	<cffunction name="DeleteVouchers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QVoucher="">
		
		<cfif StructKeyExists(args.form,"selectitem")>
			<cfquery name="QVoucher" datasource="#args.datasource#">
				DELETE FROM tblVoucherItems
				WHERE vtmID IN (#args.form.selectitem#)
			</cfquery>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="UpdateVouchers" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var result={}>
		<cfset var QUpdate="">
		<cfdump var="#args#" label="args" expand="yes">
		<cfif StructKeyExists(args.form,"selectitem")>
			<cfloop list="#args.form.selectitem#" delimiters="," index="i">
				<cfquery name="QUpdate" datasource="#args.datasource#">
					UPDATE tblVoucherItems
					SET vtmStatus='#args.form.status#'
					WHERE vtmID=#val(i)#
				</cfquery>
			</cfloop>
		</cfif>
		
		<cfreturn result>
	</cffunction>

</cfcomponent>






