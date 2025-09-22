
<cfobject component="code/core" name="core">

<cfset parms = {}>
<cfset parms.datasource = application.site.datasource1>
<cfset parms.form = form>
<cfset data = LoadGroup(parms)>

	<cffunction name="LoadGroup" access="public" returntype="struct">
		<cfargument name="args" type="struct" required="yes">
		<cfset var loc = {}>
		<cfset loc.result = {}>
		
		<cftry>
			<cfquery name="loc.QNomGroups" datasource="#args.datasource#">
				SELECT ngID,ngCode,ngTitle
				FROM tblNomGroups
			</cfquery>
			<cfquery name="loc.QGroup" datasource="#args.datasource#">
				SELECT nomID,nomCode,nomGroup,nomType,nomKey,nomClass,nomTitle
				FROM tblNominal
				WHERE nomID = #args.form.ref#
			</cfquery>
			<script type="text/javascript">
				$(document).ready(function() {
					$('#btnSave').click(function(e) {	<!--- save --->
						$.ajax({
							type: 'POST',
							url: 'ajax/AJAX_accReports.cfm',
							data: $('#editGroup').serialize(),
							beforeSend:function(){
								$('#feedback').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Saving...").fadeIn();
							},
							success:function(data){
								$('#feedback').html(data).show();
							},
							error:function(data){
								$('#feedback').loading(false);
							}
						});
						e.preventDefault();
						e.stopPropagation();
					});			
				});
			</script>
			<cfoutput>
				<form name="editGroup" id="editGroup">
					<input type="hidden" name="mode" id="mode" value="2" />
					<table class="tableList" border="1">
						<cfloop query="loc.QGroup">
							<tr>
								<td>Nominal Heading</td>
								<td>
									<input type="hidden" name="nomID" id="nomID" value="#nomID#" />
									<select name="nomGroup" id="nomGroup">
										<option value="">Select...</option>
										<cfloop query="loc.QNomGroups">
											<option value="#ngCode#"<cfif ngCode eq loc.QGroup.nomGroup> selected="selected"</cfif>>#ngCode# - #ngTitle#</option>
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>Code</td>
								<td><input type="text" size="10" name="nomCode" value="#nomCode#" /></td>
							</tr>
							<tr>
								<td>Title</td>
								<td><input type="text" size="40" name="nomTitle" value="#nomTitle#" /></td>
							</tr>
							<tr>
								<td>Type</td>
								<td>
									<select name="nomType" id="nomType">
										<option value="">Select...</option>
										<cfloop list="sales,purch,nom" index="loc.i">
											<option value="#loc.i#"<cfif nomType eq loc.i> selected="selected"</cfif>>#loc.i#</option>										
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>Class</td>
								<td>
									<select name="nomClass" id="nomClass">
										<option value="">Select...</option>
										<cfloop list="shop,news,ext,other,exclude,bun" index="loc.j">
											<option value="#loc.j#"<cfif nomClass eq loc.j> selected="selected"</cfif>>#loc.j#</option>										
										</cfloop>
									</select>
								</td>
							</tr>
							<tr>
								<td>Bank Key</td>
								<td><input type="text" size="20" name="nomKey" value="#nomKey#" /></td>
							</tr>
						</cfloop>
						<tr>
							<th></th>
							<th><button name="btnSave" id="btnSave">Save</button></th>
						</tr>
					</table>
				</form>
				<div id="feedback"></div>
			</cfoutput>
			
		<cfcatch type="any">
			<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
			output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
		</cfcatch>
		</cftry>
		<cfreturn loc.result>
	</cffunction>

