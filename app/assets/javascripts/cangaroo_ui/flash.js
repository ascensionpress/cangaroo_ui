window.cangaroo = new Object;

window.cangaroo.updateFlashElements = function(newText){
  var flash = document.getElementsByClassName("js-flash-msg");
  Array.from(flash).forEach(function(element){
    element.innerHTML = newText || "";
  })
};

window.cangaroo.clearFlashMsg = function(){
  window.cangaroo.updateFlashElements("");
};

window.cangaroo.replaceElementById = function(id, newHTML){
  var el = document.getElementById(id);
  el.innerHTML = newHTML;
};
