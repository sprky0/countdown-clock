(function(){

	var backgroundPositions = {};

	// constants
	var yearMS = 365 * 24 * 60 * 60 * 1000;
	var dayMS = 24 * 60 * 60 * 1000;
	var hourMS = 60 * 60 * 1000;
	var minuteMS = 60 * 1000;
	var secondMS = 1000; // ehhhhhhhhhhhhhhh

	var fontSizeEMs = 11;
	var numBgLayers = 1;
	var didEnded = false;
	// variable
	var $body;
	var $main; // wrap
	var $tools;
	var $days,$hours,$minutes,$seconds,$milliseconds;
	var $displayStatuses = {};

	var targetYear = 2018;
	var targetMS;
	var days,hours,minutes,seconds,milliseconds;

	/**
 	 * @param {string} d ID of the target element
	 * @return {HTMLElement} the selected element
	 */
	function getID(d) {
		return document.getElementById(d);
	}

	function run(mode) {

		targetYear = new Date().getFullYear() + 1;
		targetMS = new Date(targetYear, 0, 1).getTime();

		// targetMS = new Date(2016,11,31,18,43,0).getTime();

		$body = document.getElementsByTagName("body")[0];
		$main = getID("main");
		$tools = getID("tools");

		// get ya dom
		$days = getID("days");
		$hours = getID("hours");
		$minutes = getID("minutes");
		$seconds = getID("seconds");
		$milliseconds = getID("milliseconds");

		$tools.classList.add("hidden");

		switch(mode) {
			default:
			case "year":
			interval();
			break;

			case "happynewyear":
			$main.classList.add("hidden");
			endedAnimation();
			break;
		}

		fullscreen($body);
	}

	/**
	 * update the clock view
	 */
	function updateClockDisplay() {
		$days.innerHTML = days;
		$hours.innerHTML = hours;
		$minutes.innerHTML = minutes;
		$seconds.innerHTML = seconds;
		$milliseconds.innerHTML = milliseconds;
	}

	/**
	 * prefix an integer with some arbitrary character, eg '0'
	 * @param {integer} integer - (or whatever) to left pad
	 * @param {integer} stringLength - desired ending length
	 * @return {string} The resulting string
	 */
	function numberPad(integer, stringLength, padChar) {
		var s = '' + integer;
		while(s.length < stringLength) {
			s = padChar + s;
		}
		return s;
	}

	/**
	 * update time values relative to reflect difference b/t 'now' and ending time
	 * @return {bool}
	 */
	function updateTime() {

		var now = new Date(),
			nowMS = now.getTime(),
			remainMS = targetMS - nowMS;

		if (remainMS < 0) {
			remainMS = days = hours = minutes = seconds = milliseconds = 0;
		}

		days = numberPad(parseInt((remainMS % yearMS) / dayMS), 2, '0');
		hours = numberPad(parseInt((remainMS % dayMS) / hourMS), 2, '0');
		minutes = numberPad(parseInt((remainMS % hourMS) / minuteMS), 2, '0');
		seconds = numberPad(parseInt((remainMS % minuteMS) / secondMS), 2, '0');
		milliseconds = numberPad(remainMS % secondMS, 3, '0');

		return remainMS > 0;
	}

	/**
	 * one animation cycle
	 * sets a timeout to run itself again in 1ms
	 * @void
	 */
	function interval() {
		var timeRemains = updateTime();

		if (!timeRemains && !didEnded) {
			didEnded = true;
			endedAnimation();
		}

		updateClockDisplay();
		// scaleToFullWidth();

		requestAnimationFrame(interval);

	}

	function scaleToFullWidth() {
		$main.style.fontSize = fontSizeEMs + "em";
		if ($main.clientWidth < $body.clientWidth)
			fontSizeEMs += 0.01;
		else if ($main.clientWidth > $body.clientWidth)
			fontSizeEMs -= 0.01;
		// $main.style.marginTop = '-' + ($main.clientHeight / 2) + 'px';
	}



	function _c() {
		return 'rgba(' + Math.floor(Math.random() * 100) + ',' + Math.floor(Math.random() * 255) + ',' + Math.floor(Math.random() * 255) + ',' + Math.random().toPrecision(2) + ')';
	}

	function _l() {
		return 'linear-gradient(' + Math.floor(Math.random() * 360) + 'deg, ' + _c() + ' ' + Math.floor(Math.random() * 100) + '%, ' + _c() + ' ' + Math.floor(Math.random() * 100) + '%, transparent)';
	}

	function getGradient() {

		var s = '';

		for(var i = 0; i < Math.random() * 3; i++) {
			if (s != '')
				s += ',';
			s += _l();
		}

		return s;

	}

	function fluffBgs() {

		numBgLayers = document.getElementsByClassName('floaty').length;

		for(var bgi = 1; bgi <= numBgLayers; bgi++) {
			backgroundPositions['bg' + bgi] = {
				'obj' : document.getElementsByClassName('bg' + bgi)[0],
				'vars' : [Math.random() * 2000, Math.random() * 2000, Math.random() * 2000, Math.random() * 2000],
				'speeds' : [Math.random() * 100 - 50, Math.random() * 100 - 50, Math.random() * 100 - 50, Math.random() * 100 - 50]
			};
		}
	}

	function randomBackgrounds() {
		for(var bgi = 1; bgi <= numBgLayers; bgi++) {
			var cur = backgroundPositions['bg' + bgi];
			cur.obj.style.background = getGradient();
		}
	}

	function updateBackgrounds() {
		for(var bgi = 1; bgi <= numBgLayers; bgi++) {
			if (!backgroundPositions['bg' + bgi]) {
				fluffBgs();
			}
			var cur = backgroundPositions['bg' + bgi];
			for(var i = 0; i < cur.vars.length; i++) {
				if (cur.vars[i] + cur.speeds[i] < 2 || cur.vars[i] + cur.speeds[i] > 500)
					cur.speeds[i] *= -1;
				cur.vars[i] += cur.speeds[i];
			}
			// apply across our moving crap
			cur.obj.style.backgroundPosition = cur.vars[0] + 'px ' + cur.vars[1] + 'px';
			cur.obj.style.backgroundSize = cur.vars[2] + 'px ' + cur.vars[3] + 'px';
		}
	}

	function endedAnimation() {
		// HAPPY NEW YEAR!
		setInterval(function(){
			document.getElementById('message').classList.toggle('hidden');
		}, 250);
	}

	function backgroundMangler(noLoop) {
		updateBackgrounds();
		if (Math.random() > .6)
			randomBackgrounds();
		if (Math.random() > .6)
			fluffBgs();
		setTimeout(backgroundMangler,  Math.random() * 600);
	}

	function fullscreen(elem) {
		if (elem.requestFullscreen) {
			elem.requestFullscreen();
		} else if (elem.msRequestFullscreen) {
			elem.msRequestFullscreen();
		} else if (elem.mozRequestFullScreen) {
			elem.mozRequestFullScreen();
		} else if (elem.webkitRequestFullscreen) {
			elem.webkitRequestFullscreen();
		}
	}

	fluffBgs();
	randomBackgrounds();
	backgroundMangler();

	window.run = run;

})();
