import * as THREE from "three";
import { GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { OrbitControls } from "three/examples/jsm/controls/OrbitControls.js";

// 1. Créer la scène
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x444444);

// 2. Ajouter la caméra
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
camera.position.set(0, 5, 15);

// 3. Créer le rendu avec activation des ombres
const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.shadowMap.enabled = true;
document.body.appendChild(renderer.domElement);

// 4. Contrôles de la caméra
const controls = new OrbitControls(camera, renderer.domElement);
controls.enableDamping = true;

// 5. Ajouter une faible lumière d'ambiance
const ambientLight = new THREE.AmbientLight(0xffffff, 0.1);
scene.add(ambientLight);

// 6. Définition des matériaux
const wallMaterial = new THREE.MeshStandardMaterial({ color: 0x87ceeb });
const floorMaterial = new THREE.MeshStandardMaterial({ color: 0x999999 });
const ceilingMaterial = new THREE.MeshStandardMaterial({ color: 0x222222 });

const wallThickness = 1;
const roomWidth = 40;
const roomHeight = 20;
const roomDepth = 40;

const createWall = (geometry, material, position) => {
  const wall = new THREE.Mesh(geometry, material);
  wall.position.set(...position);
  wall.receiveShadow = true;
  scene.add(wall);
};

createWall(
  new THREE.BoxGeometry(wallThickness, roomHeight, roomDepth),
  wallMaterial,
  [-roomWidth / 2, roomHeight / 2, 0]
);
createWall(
  new THREE.BoxGeometry(wallThickness, roomHeight, roomDepth),
  wallMaterial,
  [roomWidth / 2, roomHeight / 2, 0]
);
createWall(
  new THREE.BoxGeometry(roomWidth, roomHeight, wallThickness),
  wallMaterial,
  [0, roomHeight / 2, -roomDepth / 2]
);
createWall(
  new THREE.BoxGeometry(roomWidth, wallThickness, roomDepth),
  ceilingMaterial,
  [0, roomHeight, 0]
);
createWall(
  new THREE.BoxGeometry(roomWidth, wallThickness, roomDepth),
  floorMaterial,
  [0, 0, 0]
);

// 7. Charger les moving heads et configurer WebSocket
const loader = new GLTFLoader();
const animateFunctions = [];
const movingHeads = {};

// Vérifier l'initialisation des moving heads
const loadMovingHead = (positionX, id) => {
  loader.load("./models/VRAI_mh.glb", (gltf) => {
    const movingHead = gltf.scene;
    movingHead.position.set(positionX, wallThickness / 2, 0);
    scene.add(movingHead);

    const uStructure = movingHead.getObjectByName("U_Structure");
    const lightHead = movingHead.getObjectByName("Light_Head");
    const blenderSpotLight = movingHead.getObjectByName("Spot");

    const debugSpotLight = new THREE.SpotLight(0xff0000, 1);
    debugSpotLight.angle = Math.PI / 12;
    debugSpotLight.penumbra = 0.2;
    debugSpotLight.decay = 2;
    debugSpotLight.distance = 100;
    debugSpotLight.castShadow = true;

    if (lightHead) {
      lightHead.add(debugSpotLight);
      debugSpotLight.position.set(0, 0, 0);
      debugSpotLight.target.position.set(0, 1, 0);
      lightHead.add(debugSpotLight.target);
    }

    const blenderSpotHelper = blenderSpotLight
      ? new THREE.SpotLightHelper(blenderSpotLight)
      : null;
    if (blenderSpotHelper) scene.add(blenderSpotHelper);

    const spotLight = new THREE.SpotLight(0xff0000, 1);
    spotLight.angle = Math.PI / 12;
    spotLight.castShadow = true;
    // lightHead.add(spotLight);

    movingHeads[`MH${id + 1}`] = {
      panTarget: 0,
      tiltTarget: 0,
      flashSpeed: 0,
      flashIntensity: 1,
      lerpFactor: 0.1,
      updateDMX: function ({ axis, value }) {
        const parsedValue = parseInt(value, 10);
        console.log(`🔄 Mise à jour de ${axis} avec la valeur ${parsedValue}`); // DEBUG: Afficher la mise à jour de l'axe
        if (axis === "pan") this.panTarget = (parsedValue / 255) * Math.PI * 2;
        if (axis === "tilt")
          this.tiltTarget = (-parsedValue / 255) * 2 * Math.PI - Math.PI;
        if (axis === "flash") this.flashSpeed = parsedValue;
      },
      animate: function () {
        if (uStructure)
          uStructure.rotation.z = THREE.MathUtils.lerp(
            uStructure.rotation.z,
            this.panTarget,
            this.lerpFactor
          );
        if (lightHead)
          lightHead.rotation.x = THREE.MathUtils.lerp(
            lightHead.rotation.x,
            this.tiltTarget,
            this.lerpFactor
          );

        if (this.flashSpeed > 0) {
          const speedFactor = this.flashSpeed / 255;
          this.flashIntensity =
            (Math.sin(Date.now() * 0.01 * speedFactor * Math.PI * 2) + 1) / 2;
        } else {
          this.flashIntensity = 1;
        }
        debugSpotLight.intensity = this.flashIntensity;
        if (blenderSpotHelper) blenderSpotHelper.update();
      },
    };

    console.log(`Moving head MH${id + 1} loaded and added to movingHeads`); // DEBUG: Vérifier l'ajout des moving heads

    animateFunctions.push(() => movingHeads[`MH${id + 1}`].animate());
  });
};

// Charger les moving heads
loadMovingHead(-roomWidth / 2 + 5, 0);
loadMovingHead(roomWidth / 2 - 5, 1);

// Vérifier la réception des données du serveur
const socket = new WebSocket("ws://localhost:3000");
socket.addEventListener("message", (event) => {
  try {
    const data = JSON.parse(event.data);
    console.log("📥 Données reçues du serveur :", data); // DEBUG: Afficher les données reçues
    console.log("📥 Type de données reçues :", typeof data); // DEBUG: Afficher le type de données reçues

    // Appliquer l'état complet sans condition pour tester
    applyFullState(data);

    // if (Array.isArray(data) && data.length === 512) {
    //   // Appliquer l'état complet
    //   applyFullState(data);
    // }
  } catch (error) {
    console.error("Erreur JSON :", error);
  }
});

const applyFullState = (fullState) => {
  console.log("🔄 Application de l'état complet :", fullState); // DEBUG: Afficher l'état complet
  if (fullState.changes) {
    const changes = fullState.changes;
    for (const channel in changes) {
      if (changes.hasOwnProperty(channel)) {
        console.log("loading");
        updateMovingHead(parseInt(channel, 10), changes[channel]);
      }
    }
  } else {
    console.error("Invalid fullState format");
  }
};

// Vérifier la mise à jour des moving heads
const updateMovingHead = (channel, value) => {
  console.log(`🔄 Mise à jour du canal ${channel} avec la valeur ${value}`); // DEBUG: Afficher les mises à jour des canaux
  if (channel === 1 || channel === 2 || channel === 3) {
    if (movingHeads["MH1"]) {
      if (channel === 1) {
        console.log(`🔄 Mise à jour de MH1 pan avec la valeur ${value}`); // DEBUG: Afficher la mise à jour de pan
        movingHeads["MH1"].updateDMX({ axis: "pan", value });
      }
      if (channel === 2) {
        console.log(`🔄 Mise à jour de MH1 tilt avec la valeur ${value}`); // DEBUG: Afficher la mise à jour de tilt
        movingHeads["MH1"].updateDMX({ axis: "tilt", value });
      }
      if (channel === 3) {
        console.log(`🔄 Mise à jour de MH1 flash avec la valeur ${value}`); // DEBUG: Afficher la mise à jour de flash
        movingHeads["MH1"].updateDMX({ axis: "flash", value });
      }
    } else {
      console.error("MH1 not found in movingHeads"); // DEBUG: Vérifier si MH1 est trouvé
    }
  } else if (channel === 4 || channel === 5 || channel === 6) {
    if (movingHeads["MH2"]) {
      if (channel === 4) {
        console.log(`🔄 Mise à jour de MH2 pan avec la valeur ${value}`); // DEBUG: Afficher la mise à jour de pan
        movingHeads["MH2"].updateDMX({ axis: "pan", value });
      }
      if (channel === 5) {
        console.log(`🔄 Mise à jour de MH2 tilt avec la valeur ${value}`); // DEBUG: Afficher la mise à jour de tilt
        movingHeads["MH2"].updateDMX({ axis: "tilt", value });
      }
      if (channel === 6) {
        console.log(`🔄 Mise à jour de MH2 flash avec la valeur ${value}`); // DEBUG: Afficher la mise à jour de flash
        movingHeads["MH2"].updateDMX({ axis: "flash", value });
      }
    } else {
      console.error("MH2 not found in movingHeads"); // DEBUG: Vérifier si MH2 est trouvé
    }
  }
};

function animate() {
  requestAnimationFrame(animate);
  animateFunctions.forEach((fn) => fn());
  controls.update();
  renderer.render(scene, camera);
}

animate();

window.addEventListener("resize", () => {
  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
});
