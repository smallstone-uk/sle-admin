<cftry>
	<cfobject component="code/ProductStock6" name="pstock">
	<cfset parm = {}>
	<cfset parm.datasource = application.site.datasource1>
	<cfset records = pstock.LoadProductGroups(parm)>

	<cfoutput>
		<div id="groupList">
			<table class="tableList" width="100%" border="1">
				<tr>
					<th>
						<a href="javascript:void(0)" id="btnNewGroup" tabindex="-1">
							<img src="images/icons/Add-icon.png" width="24" height="24" />
						</a>
					</th>
					<th></th>
					<th>Groups</th>
					<th>Target</th>
					<th>Categories</th>
					<th>Live</th>
				</tr>
				<cfloop query="records.groups">
					<tr>
						<td align="center" width="20">
							<a href="?edit=#pgID#" class="editGroup" data-group=#pgID#>
								<img src="images/icons/edit_black.png" width="18" height="18" /></a>
						</td>
						<td align="center" width="20">
							<cfif Categories eq 0><a href="?delete=#pgID#" class="btnDelete" data-group=#pgID#>
								<img src="images/icons/bin_black.png" width="18" height="18" /></a>
							</cfif>
						</td>
						<td><a href="##" data-group=#pgID# class="groupItem">#pgTitle#</a></td>
						<td align="right">#NumberFormat(pgTarget,"0")#%</td>
						<td align="center"><cfif Categories neq 0>#Categories#</cfif></td>
						<td align="center">#pgShow#</td>
					</tr>
				</cfloop>
			</table>
		</div>
		<div id="catList"></div>
		<div id="prodList"></div>
		<div id="cmds" style="clear:both">
		</div>
	</cfoutput>
<cfcatch type="any">
	<cfdump var="#cfcatch#" label="" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
</cfcatch>
</cftry>

