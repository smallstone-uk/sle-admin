<!--- SaveAllocIDs.cfm --->
<cfset parm = {}>
<cfset parm.datasource1 = application.site.datasource1>
<cfset clientAllocID = StructFind(form,"cltAllocID")>
<cfset maxAllocID = clientAllocID>
<!---<cfdump var="#form#" label="form" expand="false">--->
<cfoutput>
	<!---clientAllocID starts at #clientAllocID#<br />--->
	<cfset allocated = {}>
	<cfset keys = ListSort(StructKeyList(form,","),"text","asc")>
	<cfloop list="#keys#" index="key">
		<cfset item = StructFind(form,key)>
		<!---#key#: #item#<br>--->
		<cfif Find("ALLOC",key)>
			<cfset tranID = ListFirst(item,",")>
			<cfset allocID = ListLast(item,",")>
			<cfset StructInsert(allocated,tranID,allocID)>
			<!---#key#: tranID = #tranID# - allocID = #allocID#<br>--->
		<cfelseif Find("TRNID",key)>
			<cfset tranID = item>
			<cfif !StructKeyExists(allocated,tranID)>
				<cfset StructInsert(allocated,tranID,0)>	<!--- unallocate item --->
			</cfif>
			<!---#key#: tranID = #tranID#<br>--->
		<cfelse>
			<!---#key#: #item#<br>--->
		</cfif>
	</cfloop>
	<cfif !StructIsEmpty(allocated)>
		<cfset lastID = 0>
		<!---<cfdump var="#allocated#" label="allocated" expand="false">--->
		<cfset allocNonZero = false>
		<cfset keys = ListSort(StructKeyList(allocated,","),"numeric","asc")>
		<cfloop list="#keys#" index="tranID">
			<cfset allocID = StructFind(allocated,tranID)>
			<cfif allocID gt lastID>
				<cfset lastID = allocID>
			</cfif>
			<cfif allocID gte maxAllocID>
				<cfset maxAllocID = allocID>
				<cfset allocNonZero = true> #allocNonZero#<br>
			</cfif>
			<cfset alloc = int(allocID gt 0)>
			<!---Update: #tranID#: allocID = #allocID# and alloc = #alloc# maxAlloc = #maxAllocID# allocNonZero #allocNonZero# lastID = #lastID#<br>--->
			<cfquery name="loc.QUpdate" datasource="#parm.datasource1#">  <!--- update transaction --->
				UPDATE tblTrans
				SET trnAllocID = #allocID#
					<cfif allocID gt 0>,trnAlloc = #alloc#</cfif>
				WHERE trnID = #tranID#
			</cfquery>	
		<!---#maxAllocID# gt #clientAllocID# lastID = #lastID#<br>--->
		</cfloop>
		<cfif lastID gte clientAllocID>
			<!---Update client #form.clientID# to #lastID#<br>--->
			<cfquery name="loc.QUpdateClient" datasource="#parm.datasource1#">  <!--- update transaction --->
				UPDATE tblClients
				SET cltAllocID = #lastID#
				WHERE cltID = #form.clientID#
			</cfquery>
		</cfif>
	</cfif>
</cfoutput>
