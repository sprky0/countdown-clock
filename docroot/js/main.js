// Time constants in milliseconds
const TIME_CONSTANTS = {
	YEAR: 365 * 24 * 60 * 60 * 1000,
	DAY: 24 * 60 * 60 * 1000,
	HOUR: 60 * 60 * 1000,
	MINUTE: 60 * 1000,
	SECOND: 1000
};
	
class CountdownTimer {
	constructor() {
		this.state = {
			fontSizeEMs: 20,
			numBgLayers: 1,
			didEnded: false,
			targetYear: new Date().getFullYear() + 1,
			targetMS: null,
			backgroundPositions: {},
			completeMessage: "HAPPY NEW YEAR!"
		};
	
		this.elements = {};
	}
	
	// DOM helper methods
	getElement = (selector, context = document) => context.querySelector(selector);
	getAllElements = (selector, context = document) => context.querySelectorAll(selector);
	
	// Initialize the countdown
	initialize(mode = 'year', quickMS = null) {
		this.state.didEnded = false;
		this.state.targetMS = quickMS ? 
		new Date().getTime() + quickMS : 
		new Date(this.state.targetYear, 0, 1).getTime();
	
		this.freakymode = 1;
		this.freakymodes = 5;

		// Cache DOM elements
		this.elements = {
		body: this.getElement('body'),
		main: this.getElement('#main'),
		tools: this.getElement('#tools'),
		message: this.getElement('#message'),
		freakout: this.getElement('.freakoutframe'),
		countdown: {
			days: this.getElement('#days'),
			hours: this.getElement('#hours'),
			minutes: this.getElement('#minutes'),
			seconds: this.getElement('#seconds'),
			milliseconds: this.getElement('#milliseconds')
		}
		};
	
		this.elements.tools.classList.add('hidden');
	
		switch(mode) {

		case 'test':
		this.elements.message.classList.add('hidden');
		this.elements.tools.classList.remove('hidden');
		this.elements.freakout.classList.add('hidden');
		
		this.startInterval();
		break;

		case 'year':
		this.elements.message.classList.add('hidden');
		this.elements.tools.classList.add('hidden');
		this.elements.freakout.classList.add('hidden');
		this.startInterval();
		break;

		case 'happynewyear':
		this.elements.main.classList.add('hidden');
		this.endedAnimation();
		break;

		}
	
		this.requestFullscreen(this.elements.body);
	}
	
	// Time calculation and display
	numberPad = (num, length, padChar) => String(num).padStart(length, padChar);
	
	updateTime() {
		const now = new Date();
		const remainMS = this.state.targetMS - now.getTime();
	
		if (remainMS < 0) {
			return { remainMS: 0, times: { days: '00', hours: '00', minutes: '00', seconds: '00', milliseconds: '00' } };
		}
	
		const times = {
			days: this.numberPad(Math.floor((remainMS % TIME_CONSTANTS.YEAR) / TIME_CONSTANTS.DAY), 2, '0'),
			hours: this.numberPad(Math.floor((remainMS % TIME_CONSTANTS.DAY) / TIME_CONSTANTS.HOUR), 2, '0'),
			minutes: this.numberPad(Math.floor((remainMS % TIME_CONSTANTS.HOUR) / TIME_CONSTANTS.MINUTE), 2, '0'),
			seconds: this.numberPad(Math.floor((remainMS % TIME_CONSTANTS.MINUTE) / TIME_CONSTANTS.SECOND), 2, '0'),
			milliseconds: this.numberPad(Math.floor((remainMS % TIME_CONSTANTS.SECOND) / 10), 2, '0')
		};
	
		return { remainMS, times };
	}
	
	updateClockDisplay(times) {
		Object.entries(times).forEach(([key, value]) => {
		if (this.elements.countdown[key]) {
			this.elements.countdown[key].textContent = value;
		}
		});
	}
	
	// Background effects
	generateColor = () => {
		const r = Math.floor(Math.random() * 100);
		const g = Math.floor(Math.random() * 255);
		const b = Math.floor(Math.random() * 255);
		const a = Math.random().toFixed(2);
		return `rgba(${r},${g},${b},${a})`;
	};
	
	generateGradient = () => {
		const numGradients = Math.floor(Math.random() * 3);
		return Array(numGradients).fill(null)
		.map(() => {
			const angle = Math.floor(Math.random() * 360);
			const color1 = this.generateColor();
			const color2 = this.generateColor();
			const stop1 = Math.floor(Math.random() * 100);
			const stop2 = Math.floor(Math.random() * 100);
			return `linear-gradient(${angle}deg, ${color1} ${stop1}%, ${color2} ${stop2}%, transparent)`;
		})
		.join(',');
	};
	
	initializeBackgrounds() {
		this.state.numBgLayers = this.getAllElements('.floaty').length;
		
		for (let i = 1; i <= this.state.numBgLayers; i++) {
		this.state.backgroundPositions[`bg${i}`] = {
			obj: this.getElement(`.bg${i}`),
			vars: Array(4).fill(null).map(() => Math.random() * 2000),
			speeds: Array(4).fill(null).map(() => Math.random() * 100 - 50)
		};
		}
	}
	
	updateBackgrounds() {
		Object.values(this.state.backgroundPositions).forEach(bg => {
		bg.vars = bg.vars.map((val, i) => {
			const newVal = val + bg.speeds[i];
			if (newVal < 2 || newVal > 500) {
			bg.speeds[i] *= -1;
			return val + bg.speeds[i];
			}
			return newVal;
		});
	
		bg.obj.style.backgroundPosition = `${bg.vars[0]}px ${bg.vars[1]}px`;
		bg.obj.style.backgroundSize = `${bg.vars[2]}px ${bg.vars[3]}px`;
		});
	}
	
	randomizeBackgrounds() {
		Object.values(this.state.backgroundPositions).forEach(bg => {
		bg.obj.style.background = this.generateGradient();
		});
	}
	
	backgroundMangler = () => {
		this.updateBackgrounds();
		if (Math.random() > 0.5) this.randomizeBackgrounds();
		if (Math.random() > 0.5) this.initializeBackgrounds();
		setTimeout(this.backgroundMangler, Math.random() * 600);
	};
	
	// Animation and display effects
	freakoutFrame = () => {
		this.elements.freakout.classList.remove('hidden');
		// cycle through freakout-mode1, freakout-mode2, freakout-mode3

		this.elements.freakout.classList.remove('freakout-mode' + this.freakymode);
		this.freakymode = (this.freakymode + 1) % this.freakymodes;
		this.elements.freakout.classList.add('freakout-mode' + this.freakymode);
	};
	
	endedAnimation() {
		this.elements.message.textContent = this.state.completeMessage;
	
		const blinker = setInterval(() => {
			this.elements.message.classList.toggle('hidden');
		}, 250);
	
		setTimeout(() => {

			clearInterval(blinker);
			this.elements.message.classList.remove('hidden');
			this.elements.message.textContent = "OH SHIT! HERE WE GO AGAIN!";
		
			setTimeout(() => {
				this.elements.message.classList.add('hidden');
				this.elements.message.textContent = this.state.completeMessage;
				this.initialize('year');
			}, 10 * TIME_CONSTANTS.SECOND);

		}, 45 * TIME_CONSTANTS.SECOND);
	}
	
	// Core animation loop
	startInterval = () => {
		const { remainMS, times } = this.updateTime();
	
		if (!remainMS && !this.state.didEnded) {
			this.state.didEnded = true;
			this.endedAnimation();
		}
	
		if (this.state.didEnded) {
			this.freakoutFrame();
		}
	
		this.updateClockDisplay(times);
		requestAnimationFrame(this.startInterval);
	};
	
	// Fullscreen helper
	requestFullscreen(element) {
		const fullscreenMethods = [
		'requestFullscreen',
		'msRequestFullscreen',
		'mozRequestFullScreen',
		'webkitRequestFullscreen'
		];
	
		const method = fullscreenMethods.find(method => element[method]);
		if (method) {
		element[method]();
		}
	}
}

// Initialize and expose to window
const countdown = new CountdownTimer();
countdown.initializeBackgrounds();
countdown.randomizeBackgrounds();
countdown.backgroundMangler();

window.run = (mode, quickMS) => countdown.initialize(mode, quickMS);