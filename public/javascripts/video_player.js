// playback js for h264 encoded video file
// this code is used both from page-file video and asset-file video

if (typeof file_page == "undefined") {
	// playback style for asset-file video
	path = document.location.pathname.substring(0, document.location.pathname.lastIndexOf("/")+1) + file
	autoplay = "false";
	playback_width = "600"
	playback_height = "450"
	flash_playback_height = "510"
	if (typeof width != "undefined"){
		playback_width = width;
	}
	if (typeof height != "undefined"){
		playback_height = height
		// add playback control bar height
		flash_playback_height = ""+(eval(height)+eval(playback_width)/400*35);
	}
	html5_style = "'display:block; max-width:96%; margin:5px auto; width:"+ playback_width + "px; height:" + playback_height+"px;'"
	flash_style = "'display:block; width:"+ playback_width +"px; height:"+flash_playback_height+"px; margin:5px auto;'"
} else {
	// playback style for page-file video
	autoplay = "true";
	html5_style = "'position:absolute; top:0px; bottom:0px; left:0px; right:0px; max-width:100%; max-height:100%; margin:0 1px;'"
	flash_style = "'position:absolute; top:0px; left:0px; width:100%; height:100%; margin:0 1px; z-index:1;'"
}

// function flash_video_player(){
// }

if ((navigator.userAgent.indexOf("Firefox") > -1)||(navigator.userAgent.indexOf("Opera") > -1)) {
	/* Firefox & Opera doesn't support video tag with h264, so Flash player is set as default */
	document.open()
	// flash_video_player()
	document.close()
}else{
	document.open()
	if (autoplay == "true"){
		document.writeln("<video autoplay controls oncontextmenu='return false;' style=" + html5_style + ">")
	}else{
		document.writeln("<video controls oncontextmenu='return false;' style=" + html5_style + ">")
	}
	document.writeln("<source src='"+ path + "' type='video/mp4' />")
	// flash_video_player()
	document.writeln("</video>")
	document.close()
}
