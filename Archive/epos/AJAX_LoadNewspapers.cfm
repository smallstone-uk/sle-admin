<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset parm.daynow=LSDateFormat(Now(),"dddd")>
<cfset load=epos.LoadNewspapers(parm)>

<script type="text/javascript">
	$(document).ready(function() {
		$('a.newstile').click(function(e) {
			var id=$(this).data("id");
			$.LoadProduct(0,id,0,"publication",1);
			$(this).removeClass("active");
			e.preventDefault();
		});
		$('a.backtobasket').click(function(e) {
			$('#overlay').stop().fadeOut();
			e.preventDefault();
		});
		$('.newstile').touchHold([
			{
				text: "hide",
				action: function(attrib) {console.log("edit");}
			}
		]);
	});
</script>

<cfoutput>
	<div class="list">
		<cfif ArrayLen(load)>
			<cfloop array="#load#" index="i">
				<a href="javascript:void(0)" class="tile newstile<cfif ArrayLen(load) gt 12> small</cfif>" data-id="#i.ID#">
					<div class="inner">
						<div class="title">#i.title#</div>
						<cfif i.price neq 0><div class="price">&pound;#DecimalFormat(i.price)#</div></cfif>
					</div>
				</a>
			</cfloop>
		<cfelse>
			<p>No products found in this category (#parm.form.id#)</p>
		</cfif>
		<div style="clear:both;"></div>
	</div>
</cfoutput>
