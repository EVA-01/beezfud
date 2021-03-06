<?php
	$bare = false;
	$lookback = false;
	$max = false;
	$mrange = false;
	$latest = false;
	$earliest = false;
	if(count($_GET) != 0) {
		if(isset($_GET["bare"])) {
			$bare = true;
		}
		if(isset($_GET["lookback"])) {
			$lookback = escapeshellarg($_GET["lookback"]);
		}
		if(isset($_GET["max"])) {
			$max = escapeshellarg($_GET["max"]);
		}
		if(isset($_GET["range"])) {
			$mrange = escapeshellarg($_GET["range"]);
		}
		if(isset($_GET["latest"])) {
			$latest = escapeshellarg($_GET["latest"]);
		}
		if(isset($_GET["earliest"])) {
			$earliest = escapeshellarg($_GET["earliest"]);
		}
	}
	$contents = file_get_contents("archive/data.json");
	$contents = utf8_encode($contents);
	$data = json_decode($contents);
	function get_sentence($l, $m, $r, $e, $c) {
		$la = "";
		$ma = "";
		$ra = "";
		$ea = "";
		$ca = "";
		if($l != false) {
			$la = " -l $l";
		}
		if($m != false) {
			$ma = " -m $m";
		}
		if($r != false) {
			$ra = " -r $r";
		}
		if($e != false) {
			$ek = explode("-", $e);
			$em = $ek[1];
			$ey = $ek[0];
			$ea = " -e $em,$ey";
		}
		if($c != false) {
			$ck = explode("-", $c);
			$cm = $ck[1];
			$cy = $ck[0];
			$ca = " -c $cm,$cy";
		}
		return shell_exec("python titlegen.py$la$ma$ra$ea$ca");
	}
	$sentence = get_sentence($lookback, $max, $mrange, $earliest, $latest);
	if(!$bare) {
		$archiveEarliest = $data->earliest->year . "-" . ($data->earliest->month < 10 ? "0" : "") . $data->earliest->month;
		$archiveLatest = $data->latest->year . "-" . ($data->latest->month < 10 ? "0" : "") . $data->latest->month;
		$html = <<<HTML
<html lang="en">
	<head>
		<title>BeezFud</title>
		<meta name="viewport" content="width=device-width, user-scalable=no">
		<link rel="stylesheet" type="text/css" href="stylesheets/main.css" />
	</head>
	<body>
		<div id="tr-corner">
			<a href="https://github.com/EVA-01/beezfud" id="github">GitHub</a>
		</div>
		<div id="tl-corner">
			<span id="toggleoptions" class="off">Options</span>
			<div id="options">
				<div class="fore">
					<label for="earliest">Earliest</label>
					<input type="month" name="earliest" id="earliest" value="$earliest" min="$archiveEarliest" max="$archiveLatest">
				</div>
				<div class="fore">
					<label for="latest">Latest</label>
					<input type="month" name="latest" id="latest" value="$latest" min="$archiveEarliest" max="$archiveLatest">
				</div>
				<div class="fore">
					<label for="range">Month range</label>
					<input type="number" name="range" id="range" min="0" max="12" value="$mrange">
				</div>
				<div class="fore">
					<label for="max">Maximum character length</label>
					<input type="number" name="max" id="max" min="140" max="300" value="$max">
				</div>
				<div class="fore">
					<label for="lookback">Contextual lookback</label>
					<input type="number" name="lookback" id="lookback" min="1" max="4" value="$lookback">
				</div>
				<div>
					<input type="checkbox" name="bare" id="bare"><label for="bare"> Bare</label>
				</div>
				<button id="applyoptions">Apply</button>
			</div>
		</div>
		<table id="container">
			<tr>
				<td>
					<div id="sentence">
						$sentence
					</div>
					<div id="button">
						<button id="refresh">Refresh</button>
					</div>
				</td>
			</tr>
		</table>
		<script type="text/javascript" src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
		<script type="text/javascript" src="beezfud.js"></script>
	</body>
</html>
HTML;
		echo $html;
	} else {
		echo $sentence;
	}
?>
