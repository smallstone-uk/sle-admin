<script>
	$(document).ready(function(e) {
		$('.searchTitle').virtualKeyboard(function(value) {
			$.ajax({
				type: "POST",
				url: "ajax/productPostSearchForm.cfm",
				data: {"title": value},
				success: function(data) {
					$('.search_results').html(data);
				}
			});
		});
		$('.searchTitle').slideDown(200, function() {
			$('.searchTitle').focus();
		});
	});
</script>

<form method="post" enctype="multipart/form-data" id="SearchForm">
	<input type="text" placeholder="Search product name" name="title" class="searchTitle" id="searchTitleID" style="display:none;" autocomplete="off" />
</form>

<div class="search_results"></div>