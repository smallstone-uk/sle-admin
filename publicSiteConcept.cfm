<cfoutput>
<!DOCTYPE html>
<html>
<head>
<title>Public Site Concept</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/psc.css" rel="stylesheet" type="text/css">
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/enquire.min.js"></script>
</head>

<script>
	$(document).ready(function(e) {
		$('section[data-type="background"]').each(function() {
			var bgobj = $(this);
			$(window).scroll(function(event) {
				var yPos = -($(window).scrollTop() / bgobj.data('speed'));
				var coords = '50% '+ yPos + 'px';
				bgobj.css({ backgroundPosition: coords });
			});
		});
	});
</script>

<body>
	<section id="home" data-type="background" data-speed="10" class="pages">     
		<article>
			<div class="article-inner">
				<h1>#application.company.companyname#</h1>
				<ul class="front-links">
					<li><a href="##">Example</a></li>
					<li><a href="##">Example</a></li>
					<li><a href="##">Example</a></li>
					<li><a href="##">Example</a></li>
				</ul>
				<a href="##about" class="scrollDown">Scroll Down</a>
			</div>
		</article>
	</section>   
	<section id="about" data-type="background" data-speed="10" class="pages">
		<article>Simple Parallax Scroll</article>
	</section>
</body>
</html>
</cfoutput>