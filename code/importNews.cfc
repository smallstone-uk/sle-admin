<cfcomponent displayname="ImportNews">

	<cffunction name="dumpy" access="public" returntype="void">
		<cfargument name="obj" required="yes" type="any">
		<cfdump var="#obj#" expand="no">
	</cffunction>
	
	<cffunction name="processFile" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc={}>
		<cfset loc.result={}>
		<cfset loc.result.rows=[]>
		<cfset loc.result.args=args>
		<cftry>
			<cffile action="read" file="#args.fileDir##args.sourcefile#" variable="loc.content">
			<cfoutput>
				#args.fileDir##args.sourcefile#<br>
			</cfoutput>
			<cfscript>
				loc.count=0;
				loc.jsoup = createObject("java","org.jsoup.Jsoup");
				loc.doc = loc.jsoup.parse(loc.content);
				loc.tables = loc.doc.select("table:has(tr.tablehead)");
				for (loc.table in loc.tables) {
					loc.rows = loc.table.select("tr");
					for (loc.row in loc.rows) {
						loc.cells=loc.row.select("td");	// get the TDs
						for (loc.cell in loc.cells)	{ // loop cells
							loc.count++;
							loc.fld=loc.cell.text();	// get text in field
							WriteOutput(loc.count & ":" & loc.fld&"<br>");
						}
					}
				//	dumpy(loc.table);
				}
				WriteOutput(loc.count);
//				loc.headrow = loc.doc.select("tr.tablehead");
//				WriteOutput(loc.headrow.text());
//				for (loc.head in loc.headrow) {
//					WriteOutput(loc.head.text());
//					loc.items=loc.head.parent();
//					dumpy(loc.items);
//				}

//				for (loc.table in loc.tables) {
//					loc.rows = loc.table.select("tr");
//					for (loc.row in loc.rows) {
//						loc.count=0;
//						loc.cells=loc.row.select("td");	// get the TDs
//					}
//				}
			</cfscript>
			<!---<cfdump var="#loc#" label="loc" expand="false">--->
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#imp-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>
			
</cfcomponent>