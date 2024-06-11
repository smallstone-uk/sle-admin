var delay = (function(){
	var timer = 0;
	return function(callback, ms){
	clearTimeout (timer);
	timer = setTimeout(callback, ms);
	};
})();
function LoadRoundSheet() {
	$.ajax({
		type: 'POST',
		url: 'rounds6LoadSheet.cfm',
		data : $('#roundForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Building round sheet...").fadeIn();
		},
		success:function(data){
			$('#loading').fadeOut();
			$('#RoundResult').html(data).fadeIn();
		}
	});
}
function LoadIncomeSheet() {
	$.ajax({
		type: 'POST',
		url: 'rounds6IncomeSheet3.cfm',
		data : $('#roundForm').serialize(),
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Building income sheet...").fadeIn();
		},
		success:function(data){
			$('#loading').fadeOut();
			$('#IncomeResult').html(data).fadeIn();
		}
	});
}

function Print() {
	$.ajax({
		type: 'POST',
		url: 'rounds6Print.cfm',
		beforeSend:function(){
			$('#dispatchnotes').remove();
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Preparing Print...").fadeIn();
		},
		success:function(data){
			$('#print-area').append(data).fadeIn(function() {
				$('#btnChargeRound span').html("Charged");
				//Archive();
				delay(function(){
					$('#loading').fadeOut();
					$('#print-area').printArea();
				}, 4000);
			});
		}
	});
};

function LoadRoundChargedList() {
	$.ajax({
		type: 'GET',
		url: 'Rounds6LoadCharged.cfm',
		success:function(data){
			$('#roundChargedList').html(data);
		}
	});
};

function ChargeRounds() {
	$.ajax({
		type: 'POST',
		url: 'rounds6ChargeItems.cfm',
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Charging Rounds...").fadeIn();
		},
		success:function(data){
			$('#loading').fadeOut(function() {
				$('#loading').html(data).fadeIn();
				Print();
			});
		}
	});
}

function Archive() {
	$.ajax({
		type: 'POST',
		url: 'rounds6Archive.cfm',
		data: {'html':$('#print-area').html()},
		beforeSend:function(){
			$('#loading').html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Archiving...").fadeIn();
		},
		success:function(data){
			$('#loading').fadeOut();
			LoadRoundChargedList();
		}
	});
}

function LoadReport(url,form,result) {
	$.ajax({
		type: 'POST',
		url: url,
		data: $(form).serialize(),
		beforeSend:function(){
			$(result).html("<img src='images/loading_2.gif' class='loadingGif'>&nbsp;Loading...").fadeIn();
		},
		success:function(data){
			$(result).html(data);
		}
	});
}




