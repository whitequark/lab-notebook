window.solvespace = function(obj, params) {
  var scene, edgeScene, camera, edgeCamera, renderer;
  var geometry, controls, material, mesh, edges;
  var width, height, edgeBias;
  var directionalLightArray = [];

  if(typeof params === "undefined" || !("width" in params)) {
    width = window.innerWidth;
  } else {
    width = params.width;
  }

  if(typeof params === "undefined" || !("height" in params)) {
    height = window.innerHeight;
  } else {
    height = params.height;
  }

  edgeBias = obj.bounds.edgeBias;

  domElement = init();
  render();
  return domElement;

  function init() {
    scene = new THREE.Scene();
    edgeScene = new THREE.Scene();

    var ratio = (width/height);
    camera = new THREE.OrthographicCamera(-obj.bounds.x * ratio,
      obj.bounds.x * ratio, obj.bounds.y, -obj.bounds.y, obj.bounds.near,
      obj.bounds.far*10);
    camera.position.z = obj.bounds.z*3;

    mesh = createMesh(obj);
    scene.add(mesh);
    edges = createEdges(obj);
    edgeScene.add(edges);

    for(var i = 0; i < obj.lights.d.length; i++) {
      var lightColor = new THREE.Color(obj.lights.d[i].intensity,
        obj.lights.d[i].intensity, obj.lights.d[i].intensity);
      var directionalLight = new THREE.DirectionalLight(lightColor, 1);
      directionalLight.position.set(obj.lights.d[i].direction[0],
        obj.lights.d[i].direction[1], obj.lights.d[i].direction[2]);
      directionalLightArray.push(directionalLight);
      scene.add(directionalLight);
    }

    var lightColor = new THREE.Color(obj.lights.a, obj.lights.a, obj.lights.a);
    var ambientLight = new THREE.AmbientLight(lightColor.getHex());
    scene.add(ambientLight);

    renderer = new THREE.WebGLRenderer();
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setSize(width, height);
    renderer.autoClear = false;

    controls = new THREE.OrthographicTrackballControls(camera, renderer.domElement);
    controls.screen.width = width;
    controls.screen.height = height;
    controls.radius = (width + height)/4;
    controls.rotateSpeed = 2.0;
    controls.zoomSpeed = 2.0;
    controls.panSpeed = 1.0;
    controls.staticMoving = true;
    controls.addEventListener("change", render);
    controls.addEventListener("change", lightUpdate);
    controls.addEventListener("change", setControlsCenter);

    animate();
    return renderer.domElement;
  }

  function animate() {
    requestAnimationFrame(animate);
    controls.update();
  }

  function render() {
    renderer.clear();
    renderer.render(scene, camera);
    var oldFar = camera.far
    camera.far = camera.far + edgeBias;
    camera.updateProjectionMatrix();
    renderer.render(edgeScene, camera);
    camera.far = oldFar;
    camera.updateProjectionMatrix();
  }

  function lightUpdate() {
    var projRight = new THREE.Vector3();
    var projZ = new THREE.Vector3();
    var changeBasis = new THREE.Matrix3();

    // The original light positions were in camera space.
    // Project them into standard space using camera's basis
    // vectors (up, target, and their cross product).
    projRight.copy(camera.up);
    projZ.copy(camera.position).sub(controls.target).normalize();
    projRight.cross(projZ).normalize();
    changeBasis.set(projRight.x, camera.up.x, controls.target.x,
      projRight.y, camera.up.y, controls.target.y,
      projRight.z, camera.up.z, controls.target.z);

    for(var i = 0; i < obj.lights.d.length; i++) {
      var newLightPos = changeBasis.applyToVector3Array(
        [obj.lights.d[i].direction[0], obj.lights.d[i].direction[1],
         obj.lights.d[i].direction[2]]);
      directionalLightArray[i].position.set(newLightPos[0],
        newLightPos[1], newLightPos[2]);
    }
  }

  function setControlsCenter() {
    var rect = renderer.domElement.getBoundingClientRect()
    controls.screen.left = rect.left + document.body.scrollLeft;
    controls.screen.top = rect.top + document.body.scrollTop;
  }

  function createMesh(mesh_obj) {
    var geometry = new THREE.Geometry();
    var materialIndex = 0, materialList = [];
    var opacitiesSeen = {};

    for(var i = 0; i < mesh_obj.points.length; i++) {
      geometry.vertices.push(new THREE.Vector3(mesh_obj.points[i][0],
        mesh_obj.points[i][1], mesh_obj.points[i][2]));
    }

    for(var i = 0; i < mesh_obj.faces.length; i++) {
      var currOpacity = ((mesh_obj.colors[i] & 0xFF000000) >>> 24)/255.0;
      if(opacitiesSeen[currOpacity] === undefined) {
        opacitiesSeen[currOpacity] = materialIndex;
        materialIndex++;
        materialList.push(new THREE.MeshLambertMaterial(
          {vertexColors: THREE.FaceColors, opacity: currOpacity,
            transparent: true}));
      }

      geometry.faces.push(new THREE.Face3(mesh_obj.faces[i][0],
        mesh_obj.faces[i][1], mesh_obj.faces[i][2],
        new THREE.Vector3(mesh_obj.normals[i][0],
          mesh_obj.normals[i][1], mesh_obj.normals[i][2]),
        new THREE.Color(mesh_obj.colors[i] & 0x00FFFFFF),
        opacitiesSeen[currOpacity]));
    }

    geometry.computeBoundingSphere();
    return new THREE.Mesh(geometry, new THREE.MeshFaceMaterial(materialList));
  }

  function createEdges(mesh_obj) {
    var geometry = new THREE.Geometry();
    var material = new THREE.LineBasicMaterial();

    for(var i = 0; i < mesh_obj.edges.length; i++) {
      geometry.vertices.push(new THREE.Vector3(mesh_obj.edges[i][0][0],
        mesh_obj.edges[i][0][1], mesh_obj.edges[i][0][2]),
        new THREE.Vector3(mesh_obj.edges[i][1][0],
        mesh_obj.edges[i][1][1], mesh_obj.edges[i][1][2]));
    }

    return new THREE.Line(geometry, material, THREE.LinePieces);
  }
};

window.injectSolvespace = function(id, obj, params) {
  var placeholder = document.getElementById(id);
  placeholder.parentElement.replaceChild(solvespace(obj, params), placeholder);
}
