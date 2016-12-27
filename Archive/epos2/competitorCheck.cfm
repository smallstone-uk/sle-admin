<cftry>
<cfset parm = {}>
<cfset parm.datasource = application.site.datasource1>
<cfset parm.url = application.site.normal>

<cfscript>
	function StructToQueryString(struct) {
		var qstr = "";
		var delim1 = "=";
		var delim2 = "&";
		
		switch (ArrayLen(Arguments)) {
			case "3":
				delim2 = Arguments[3];
			case "2":
				delim1 = Arguments[2];
		}
		
		for (key in struct) {
			qstr = ListAppend(qstr, URLEncodedFormat(LCase(key)) & delim1 & URLEncodedFormat(struct[key]), delim2);
		}
		
		return qstr;
	}
</cfscript>

<cfset product = {
	title = "Cadbury Milk Fingers",
	size = "114g",
	price = 1.29
}>

<cfset form = {
	viewTaskName = "ProductDisplayView",
	recipesSearch = true,
	orderBy = "RELEVANCE",
	skipToTrollyDisplay = false,
	favouritesSelection = 0,
	errorViewName = "ProductDisplayErrorView",
	langId = 44,
	productId = 47480,
	storeId = 10151,
	searchTerm = product.title,
	searchType = 2
}>

<!---<cfset url_form = URLEncodedFormat(SerializeJSON(form))>--->
<cfset url_form = StructToQueryString(form)>

<cfdump var="#url_form#" label="url_form" expand="no">
<!---
<cfhttp method="Post" url="http://www.sainsburys.co.uk/sol/index.jsp" result="sbResult"> 
    <cfhttpparam type="Formfield" name="sol_search" value="#url_form#"> 
</cfhttp>

<cfdump var="#sbResult#" label="sbResult" expand="no">

<cfoutput>
	#sbResult.filecontent#
</cfoutput>--->

<cfcatch type="any">
	<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#epos\err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>