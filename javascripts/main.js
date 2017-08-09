console.log('This would be the main JS file.');

setTimeout(function() {
    document.getElementById("startup").play();
}, 500);

window.addEventListener('touchstart', function videoStart() {
    $('#.startup').play();
    this.removeEventListener('touchstart', videoStart);
});
