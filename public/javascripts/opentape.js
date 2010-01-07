// Key input management code // 

var keyboardControl = true;

document.onkeyup = keyCheck;

function keyCheck(e)
{
	if(keyboardControl) // if taking notice of keypresses (are on audiography and user not trying to add new mp3)
	{
		var keyId = (window.event) ? event.keyCode : e.keyCode;

		switch(keyId)
		{
			// p
			case 80:
			togglePlayback(null);
			break;
  	
			// left arrow
			case 37:
			previousSong();
			break;

			// right arrow  	
			case 39:
			nextSong();
			break;
		}
	}
}

function setKeyboardControl(inKeyboardControl) { keyboardControl = inKeyboardControl; }

// Player management code //

var currentTrack = 0;
var isReady = 0;
var playerStatus = "";
var currentPos = 0;
var previousPos = -1;
var player;

function playerReady(obj) {
	var id = obj['id'];
	var version = obj['version'];
	var client = obj['client'];
	isReady = 1;
	player = document.getElementById(id);
	player.addModelListener('STATE','updatePlayerState');
	player.addModelListener('TIME','updateCurrentPos');
	player.addControllerListener('ITEM','updateCurrentTrack');
}

function updatePlayerState(obj) {
	playerStatus = obj['newstate'];
}


function updateCurrentTrack(obj) {
	cleanTrackDisplay(currentTrack);
	currentTrack = obj['index'];
	setupTrackDisplay(obj['index']);
}


function updateCurrentPos(obj) {
	pos = Math.round(obj['position']);

	if ( pos==currentPos ) { return false; }
	else {

			var string = '';
			var sec = pos % 60;
			var min = (pos - sec) / 60;
			var min_formatted = min ? min+':' : '';
			var sec_formatted = min ? (sec < 10 ? '0'+sec : sec) : sec;
			string = min_formatted + sec_formatted;
		
			songClock.innerHTML = string;

			// switches stop to play when last track finishes
			if(pos == 0 && previousPos > 1)
			{
				Element.show('play_link'+currentTrack);
				Element.hide('stop_link'+currentTrack);
				songClock.innerHTML = ''
			}
		
			previousPos = currentPos
			currentPos = pos;
	}

}

function playTrack() {
	setupTrackDisplay(currentTrack);
	sendEvent('ITEM',currentTrack);
	sendEvent('PLAY',true);
}

function stopTrack() {
	sendEvent('STOP');
	cleanTrackDisplay(currentTrack);
}

function cleanTrackDisplay(id) {
	songClock = document.getElementById('track_clock' + id);
	songItem = $('song'+id);
	songClock.removeClassName('grey');
  songClock.addClassName('green');
	//songItem.removeClassName('hilite');		
	songClock.innerHTML = '';
}

function setupTrackDisplay(id) {
	songClock = document.getElementById('track_clock' + id);
	songItem = $('song'+id);
	
	songClock.innerHTML = '&mdash;';
}

function togglePlayback(id) {
	if(id != null)
		id = id.replace(/song/,'');
	else
		id = currentTrack; // no track number request made

	songClock = document.getElementById('track_clock' + id);

	if (id == currentTrack || id == null) { 
		if(playerStatus == "PAUSED"|| playerStatus=="IDLE") {
			songClock.removeClassName('grey');
			songClock.addClassName('green');
			sendEvent('PLAY', true);
		} else {
			songClock.removeClassName('green');
			songClock.addClassName('grey');	
			sendEvent('PLAY', false);
		}
	} else {
		stopTrack();
		currentTrack = id;
		playTrack();
	}
	
	for (var i=0; i < 10; i++)
	{
		if(i != currentTrack && $('play_link'+i) != null)
		{
			Element.show('play_link'+i);
			Element.hide('stop_link'+i);
		}
	}
}

function nextSong() {
		stopTrack();
		
		potentialNextTrackId = currentTrack + 1;
		songClock = document.getElementById('track_clock' + potentialNextTrackId);
		if(songClock != null)
		{
			currentTrack = currentTrack + 1;
			playTrack();
		}
}

function previousSong() {
		stopTrack();
		
		if(currentTrack > 0 && currentPos < 2)
			currentTrack = currentTrack - 1;
		currentPos = 0;
		
		playTrack();
}

// Player maintenance functions
function sendEvent(typ,prm) { 
	if( isReady ) {	thisMovie('openplayer').sendEvent(typ,prm); }
}

function thisMovie(movieName) {
	if(navigator.appName.indexOf("Microsoft") != -1) { return window[movieName]; }
	else { return document[movieName]; }
}