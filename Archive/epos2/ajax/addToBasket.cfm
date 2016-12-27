<cftry>
<cfobject component="epos2/code/epos" name="epos">
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.form = form>
<cfset parm.index = "#parm.form.id#-#parm.form.price#">
<cfset parm.barcode = (StructKeyExists(parm.form, "barcode")) ? parm.form.barcode : 0>
<cfset basketSubType = StructFind(session.epos_frame.basket, parm.form.type)>
<cfset sign = (2 * int(session.epos_frame.mode eq "reg")) - 1>

<cfswitch expression="#parm.form.type#">
	<cfcase value="product|publication|paypoint|deal" delimiters="|">
		<cfset parm.form.price = (-val(parm.form.price)) * sign>
	</cfcase>
</cfswitch>

<cfif NOT StructKeyExists(session.epos_frame, "basket")>
	<cfset session.epos_frame.basket = {product = {}, publication = {}, paypoint = {}, deal = {}, payment = {}, discount = {}, supplier = {}}>
</cfif>

<cfif NOT StructKeyExists(basketSubType, parm.index)>
	<cfset StructInsert(basketSubType, parm.index, {
		id = parm.form.id,
		index = parm.index,
		title = parm.form.title,
		price = parm.form.price,
		qty = 1,
		linetotal = val(parm.form.price),
		barcode = parm.barcode,
		cashonly = parm.form.cashonly,
		timestamp = "#DateFormat(Now(), 'yyyymmdd')##TimeFormat(Now(), 'HHmmss')#"
	})>
<cfelse>
	<cfset inBasket = StructFind(basketSubType, parm.index)>
	<cfif inBasket.id eq parm.form.id AND inBasket.price eq parm.form.price>
		<cfset inBasket.qty++>
		<cfset inBasket.linetotal = val(inBasket.price) * val(inBasket.qty)>
	<cfelse>
		<cfset StructInsert(basketSubType, parm.index, {
			id = parm.form.id,
			index = parm.index,
			title = parm.form.title,
			price = parm.form.price,
			qty = 1,
			linetotal = val(parm.form.price),
			barcode = parm.barcode,
			cashonly = parm.form.cashonly,
			timestamp = "#DateFormat(Now(), 'yyyymmdd')##TimeFormat(Now(), 'HHmmss')#"
		})>
	</cfif>
</cfif>

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>