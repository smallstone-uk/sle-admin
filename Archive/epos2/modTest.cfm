<script src="../scripts/jquery-1.11.1.min.js"></script>
<script src="../scripts/jquery-ui.js"></script>

<script>
	$(document).ready(function(e) {
		$('.modEnter').click(function(event) {
			var mod1 = $('.mod1').val();
			var mod2 = $('.mod2').val();
			$('.result').html( (mod1 % mod2) );
			event.preventDefault();
		});
	});
</script>

<input type="text" class="mod1" />
MOD
<input type="text" class="mod2" />
<input type="button" class="modEnter" value="Test" />
<div class="result"></div>