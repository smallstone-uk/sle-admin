<html>
	<head>
		<title>add</title>
		<script src="scripts/jquery-1.5.1.min.js"></script>
		<style>
			.dynatable {
				border: solid 1px #000; 
				border-collapse: collapse;
			}
			.dynatable th,
			.dynatable td {
				border: solid 1px #000; 
				padding: 2px 10px;
				width: 170px;
				text-align: center;
			}
			.dynatable .prototype {
				display:none;
			}
		</style>
	</head>
	<body>
		<cfif StructKeyExists(form,"fieldnames")>
			<cfdump var="#form#" label="form" expand="no">
		</cfif>
		<form method="post" enctype="multipart/form-data" id="account-form">
			<table>
				<cfloop from="1" to="10" index="i">
					<tr> 
						 <td><input type="text" id="txtTitle#i#" name="txtTitle#i#"></td> 
						 <td><input type="text" id="txtLink#i#" name="txtLink#i#"></td> 
					</tr>
				</cfloop>
			</table>
			<button>Add Row</button>
			<br/>
			<input type="submit" name="btnSend" value="Save" />
		</form>
		<script>
			$(document).ready(function() {
				var i = 1;
				$("button").click(function(evt) {
				  $("table tr:first").clone().find("input").each(function() {
					$(this).attr({
					  'id': function(_, id) { return id + i },
					  'name': function(_, name) { return name + i },
					  'value': ''               
					});
				  }).end().appendTo("table");
				  i++;
				  evt.preventDefault();
				});
			});
		</script>
	</body>
</html>
