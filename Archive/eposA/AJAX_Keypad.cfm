
<cfobject component="code/epos" name="epos">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>

<script type="text/javascript">
	$(document).ready(function() {
		$('#keypad #numbers span').click(function(e) {
			var number = $(this).html();
			if (number.length > 0) {
				$('#keypad #result').Keypad(number);
			}
			e.preventDefault();
		});
		$('.clearKeypad').click(function(e) {
			$.KeypadClear();
			e.preventDefault();
		});
	});
</script>
<div id="keypad">
	<div id="result">0</div><div style="clear:both;"></div>
	<div id="numbers">
		<span>7</span>
		<span>8</span>
		<span>9</span>
		<span>4</span>
		<span>5</span>
		<span>6</span>
		<span>1</span>
		<span>2</span>
		<span>3</span>
		<span>0</span>
		<span>00</span>
		<span class="clearKeypad">C</span>
	</div>
	<span id="btnEnter">Enter</span>
</div>
