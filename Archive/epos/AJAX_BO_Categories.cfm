<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form = form>
<cfset load=epos.LoadCats(parm)>


<cfoutput>
	<script type="text/javascript">
		$(document).ready(function() {
			$('.tile').click(function(e) {
				var id=$(this).data("id");
				$(this).removeClass("active");
				$('##bocontent').BOLoadCatProducts(id);
				e.preventDefault();
			});
			$('.tile[data-new="true"]').click(function(e) {
				$.virtualKeyboard({
					hint: "Enter the title of the category",
					action: function(title) {
						$.ajax({
							type: "POST",
							url: "AJAX_BO_AddCategory.cfm",
							data: {"title": title},
							success: function(data) {
								$.messageBox(title + " added", "success");
								$.LoadBOFunctions("#parm.form.id#", "#parm.form.file#");
							}
						});
					}
				});
				e.preventDefault();
			});
			$('.tile').touchHold([
				{
					text: "edit title",
					action: function(attrib, elem) {
						$.virtualKeyboard({
							text: $(elem).find('.title').html(),
							action: function(text) {
								$.ajax({
									type: "POST",
									url: "AJAX_BO_EditCatTitle.cfm",
									data: {
										"title": text,
										"catID": attrib.id
									},
									success: function(data) {
										$(elem).attr("data-title", text);
										$(elem).find('.title').html(text);
										$('##leftcontrols').LoadCats();
									}
								});
							}
						});
					}
				},
				{
					text: "remove category",
					action: function(attrib, elem) {
						$.confirmation({
							message: "Are you sure you want to delete this category?",
							action: function() {
								$.ajax({
									type: "POST",
									url: "AJAX_BO_RemoveCat.cfm",
									data: {"catID": attrib.id},
									success: function(data) {
										$.messageBox(attrib.title + " removed", "success");
										$.LoadBOFunctions("#parm.form.id#", "#parm.form.file#");
									}
								});
							}
						});
					}
				}
			]);
		});
	</script>
	<div class="list">
		<cfif ArrayLen(load)>
			<a href="javascript:void(0)" class="tile<cfif ArrayLen(load) gt 12> small</cfif>" data-new="true">
				<div class="inner">
					<div class="title">Add Category</div>
				</div>
			</a>
			<cfloop array="#load#" index="i">
				<cfif NOT len(i.file)>
					<a href="javascript:void(0)" class="tile<cfif ArrayLen(load) gt 12> small</cfif>" data-id="#i.ID#" data-title="#i.title#">
						<div class="inner">
							<div class="title">#i.title#</div>
						</div>
					</a>
				</cfif>
			</cfloop>
		</cfif>
		<div style="clear:both;"></div>
	</div>
</cfoutput>
