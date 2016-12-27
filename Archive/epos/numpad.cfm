<cfoutput>
	<script>
		$(document).ready(function(e) {
			var caretPos = 0;
			
			$('.virtual_numpad').find('*').addClass("disable-select");
			$('.virtual_numpad').css("left", Math.max(0, (($(window).width() - $('.virtual_numpad').outerWidth()) / 2) + $(window).scrollLeft()) + "px");
			$('.vkn_digit').click(function(event) {
				var digit = $(this).html();
				var maxLength = window.vkn_maxLength;
				
				if (maxLength < 0) {
					insertAtCaret("vkn_text_id", digit);
				} else {
					if ($('.vkn_text').val().length < maxLength) {
						insertAtCaret("vkn_text_id", digit);
					}
				}
				
				$('.vkn_text').focus();
				caretPos = getCaretPosition(document.getElementById("vkn_text_id"));
				setCaretPosition("vkn_text_id", caretPos);
				
				if ($('.vkn_text').val().length == maxLength) {
					$('.vkn_enter').click();
				}
			});
			
			$('.vkn_clear').click(function(event) {
				$('.vkn_text').val("");
			});
			
			$('.vkn_close').click(function(event) {
				$('.dim').fadeOut(500, function() {$('.dim').remove()});
				$('.virtual_numpad').animate({
					"bottom": "-1000px"
				}, 500, "easeInOutCubic");
				event.preventDefault();
			});
			
			setInterval(function() {
				if (!window.vkn_allowDecimal) {
					$('.vkn_decimal').html("");
				} else {
					$('.vkn_decimal').html(".");
				}
			}, 100);
		});
	</script>
	<div class="virtual_numpad">
		<input type="text" class="vkn_text" id="vkn_text_id" />
		<button class="vkn_close">X</button>
		<div class="vkn_1">
			<span class="vkn_digit">7</span>
			<span class="vkn_digit">8</span>
			<span class="vkn_digit">9</span>
		</div>
		<div class="vkn_2">
			<span class="vkn_digit">4</span>
			<span class="vkn_digit">5</span>
			<span class="vkn_digit">6</span>
		</div>
		<div class="vkn_3">
			<span class="vkn_digit">1</span>
			<span class="vkn_digit">2</span>
			<span class="vkn_digit">3</span>
		</div>
		<div class="vkn_4">
			<span class="vkn_clear">C</span>
			<span class="vkn_digit">0</span>
			<span class="vkn_digit vkn_decimal">.</span>
		</div>
		<div class="vkn_5">
			<span class="vkn_enter">Enter</span>
		</div>
	</div>
</cfoutput>