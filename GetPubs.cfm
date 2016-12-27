<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfparam name="psSupID" default="351">

<cfobject component="code/functions" name="func">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.wholesaler=psSupID>
<cfset pubs=func.GetPubs(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('#pubList').change(function() {
			$.ajax({
				type: 'POST',
				url: 'GetPub.cfm',
				data : $('#stockForm').serialize(),
				beforeSend:function(){
					$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
				},
				success:function(data){
					$('#pub').html(data);
					$('#UpdateStock').show();
					$('#loading').fadeOut();
					
				},
				error:function(data){
					$('#pub').html(data);
					$('#UpdateStock').hide();
					$('#loading').fadeOut();
				}
			});
			event.preventDefault();
		});
		$('#pubList').focus();
	});
</script>

<cfoutput>
<table border="0" cellpadding="2" cellspacing="0">
	<tr>
		<td width="120">Publication</td>
		<td>
			<select name="psPubID" data-placeholder="Select..." id="pubList" class="pubsdata">
				<option value=""></option>
				<cfloop array="#pubs.list#" index="item">
					<option value="#item.ID#">#item.Title#</option>
				</cfloop>
			</select>
		</td>
	</tr>
</table>
</cfoutput>
<script type="text/javascript">
	$("#pubList").chosen({width: "350px",enable_split_word_search:false});
</script>
