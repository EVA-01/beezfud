$(document).ready(function() {
	$(this).on("click", "#toggleoptions.off", function() {
		$("#options").slideDown();
		$(this).removeClass("off").addClass("on");
	});
	$(this).on("click", "#toggleoptions.on", function() {
		$("#options").slideUp();
		$(this).removeClass("on").addClass("off");
	});
	$(this).on("click", "#refresh", function() {
		location.reload();
	});
	$(this).on("click", "#applyoptions", function() {
		options = {};
		if($("#bare").is(":checked")) {
			options["bare"] = true;
		}
		if($("#earliest").val() != "") {
			options["earliest"] = $("#earliest").val()
		}
		if($("#latest").val() != "") {
			options["latest"] = $("#latest").val()
		}
		if($("#range").val() != "") {
			options["range"] = $("#range").val()
		}
		if($("#max").val() != "") {
			options["max"] = $("#max").val()
		}
		if($("#lookback").val() != "") {
			options["lookback"] = $("#lookback").val()
		}
		location.href = location.origin + location.pathname + "?" + $.param(options);
	});
});