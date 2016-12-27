<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">

<cfobject component="code/products" name="product">
<cfset parm={}>
<cfset parm.form=form>
<cfset parm.datasource=application.site.datasource1>

<script type="text/javascript">
	$(document).ready(function() { 
		$('#btnAdd').click(function(event) {
			$.ajax({
				type: 'POST',
				url: 'ProductSaveCat.cfm',
				data : $('#catForm').serialize(),
				success:function(data){
					$("#orderOverlay").fadeOut();
					$("#orderOverlay-ui").fadeOut();
					<cfoutput>SuppSwitch("#parm.form.type#","#parm.form.supp#");</cfoutput>
				}
			});
			event.preventDefault();
		});
	});
</script>

<cfoutput>
	<h1>Add Category</h1>
	<form method="post" enctype="multipart/form-data" id="catForm">
		<table width="100%">
			<tr>
				<th>Title</th>
				<td><input type="text" name="catTitle" value=""><input type="submit" id="btnAdd" value="Add"></td>
			</tr>
		</table>
	</form>
</cfoutput>
