<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no">
<cfparam name="print" default="false">
<cfset count=0>

<cfobject component="code/functions" name="cust">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.rec.cltID=form.cltID>
<cfset parm.rec.cltRef=form.cltRef>
<cfset parm.rec.OrderID=form.OrderRef>
<cfset holidays=cust.LoadHolidays(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		function LoadHolidays() {
			$.ajax({
				type: 'POST',
				url: 'LoadHolidayList.cfm',
				data : $('#holidayForm').serialize(),
				success:function(data){
					$('#hol-list').html(data);
					$('#orderOverlayForm').center();
				}
			});
		};
		$('#restartOrder').click(function(event) {
			var id=$(this).attr("href");
			$.ajax({
				type: 'POST',
				url: 'AddHolidayRestart.cfm',
				data : {"id":id},
				success:function(data){
					$('#startdate').html(data);
				}
			});
			event.preventDefault();
		});
		$('.checkbox').click(function(){
			var show=false;
			$('.checkbox').each(function(index) {
				if(this.checked) {
					$('#btnDelete').show();
					show=true;
				} else {
					if(show) {
					} else {
						$('#btnDelete').hide();
						show=false;
					};
				};
			});
		});
		$('#btnDelete').click(function(event){
			$.ajax({
				type: 'POST',
				url: 'AddHolidayRemove.cfm',
				data : $('#removeHolidayForm').serialize(),
				success:function(data){
					$('#saveResults').html(data).fadeIn();
					LoadHolidays();
					setTimeout(function(){$("#saveResults").fadeOut("slow");}, 5000 );
				}
			});
			event.preventDefault();
		});
		$('.holOrdLink').click(function(event){
			var id=$(this).attr("href");
			$('#holOrderPubs'+id).fadeToggle();
			event.preventDefault();
		});
	});
</script>


<cfoutput>
	<form method="post" enctype="multipart/form-data" id="removeHolidayForm">
		<table border="1" width="100%" class="tableList">
			<tr>
				<th width="20"><input type="button" id="btnDelete" value="X" style="display:none;padding: 3px 5px;margin: 0px;font-size: 10px;" /></th>
				<th width="45">Items</th>
				<th width="100">Stop Date</th>
				<th width="100">Start Date</th>
				<th>Status</th>
			</tr>
			<cfloop array="#holidays.list#" index="item">
				<tr id="holOrdLinkBG#item.ID#">
					<td><input type="checkbox" name="line" class="lineselect checkbox" value="#item.ID#" /></td>
					<td style="text-align:center;"><a href="#item.ID#" class="holOrdLink" style="cursor:pointer;">#ArrayLen(item.items)#</a></td>
					<td>#item.stop#</td>
					<td id="startdate"><cfif len(item.start)>#item.start#<cfelse><a href="#item.ID#" id="restartOrder">Restart</a></cfif></td>
					<td>
						<cfif item.stop gte Now()>
							Ready
						<cfelseif item.stop lte Now()>
							<cfif len(item.start) AND item.start gte Now()>
								Running
							<cfelseif len(item.start) AND item.start lte Now()>
								Ended
							<cfelse>
								Stop until further notice
							</cfif>
						</cfif>
					</td>
				</tr>
				<cfif ArrayLen(item.items)>
					<tr id="holOrderPubs#item.ID#" style="display:none;">
						<td colspan="5" style="padding:5px;">
							<table border="1" width="100%" class="tableList">
								<tr>
									<th width="75%" align="left">Publication</th>
									<th align="left">Action</th>
								</tr>
								<cfloop array="#item.items#" index="i">
									<tr>
										<td>#i.PubTitle#</td>
										<td>#i.Action#</td>
									</tr>
								</cfloop>
							</table>
						</td>
					</tr>
				</cfif>
			</cfloop>
		</table>
	</form>
</cfoutput>

