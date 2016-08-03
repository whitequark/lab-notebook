window.injectSolveSpace = function(id, obj, params) {
  var placeholder = document.getElementById(id);
  placeholder.parentElement.replaceChild(solvespace(obj, params), placeholder);
}
