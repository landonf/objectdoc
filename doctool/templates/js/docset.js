function checkForXcode() {
	var userAgent = navigator.userAgent;
	var xcodeVersion = parseFloat(userAgent.slice(userAgent.indexOf("Xcode/") + 6, userAgent.length));
	if (xcodeVersion >= 5) {
		document.body.setAttribute("xcode5", "true");
	}
}

if (addEventListener !== undefined) {
	addEventListener("DOMContentLoaded", checkForXcode);
}
