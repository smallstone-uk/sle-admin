<cfset session.epos_frame.result.balanceDue = 0>
<cfset session.epos_frame.result.totalGiven = 0>
<cfset session.epos_frame.result.changeDue = 0>
<cfset session.epos_frame.result.discount = 0>
<cfset requiredKeys = ["product", "publication", "paypoint", "deal", "payment", "discount", "supplier"]>
<cfset session.epos_frame.basket = {}>
<cfloop array="#requiredKeys#" index="key">
	<cfset StructInsert(session.epos_frame.basket, key, {})>
</cfloop>