// Silnik gry 3D: bajkowe miasto Bajkogród, nieskończony bieg po złotej drodze (Three.js).
import * as THREE from 'three';
import { mergeGeometries } from 'three/addons/utils/BufferGeometryUtils.js';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';
import { RoomEnvironment } from 'three/addons/environments/RoomEnvironment.js';
import { SKINS, CHAPTERS } from './config.js';
import { buildCharacter, animateCharacter } from './characters.js';

const LANES = [-2.2, 0, 2.2];
const SPAWN_Z = -130;
const DESPAWN_Z = 12;
const SPAN = 150; // długość pętli dekoracji
const BALL_R = 0.45;
const GRAVITY = 34;
const JUMP_V = 11.5;

const WALLS = [0xfff4e0, 0xffe0ec, 0xe4f3ff, 0xfff7c2, 0xe8ffe4, 0xf3e6ff];
const ROOFS = [0xff6f91, 0x5ab8ff, 0xffa94d, 0x9b7bff, 0x4fc98a, 0xff5c5c];
const LEAVES = [0x6fd36b, 0x8fe07a, 0x4fbf6a, 0xffa8d8, 0xffc4e1];
const FLOWERS = [0xff6b9a, 0xffd23f, 0xffffff, 0xb388ff, 0xff8f5a, 0x7ad7ff];

const rnd = Math.random;
const pick = (a) => a[(rnd() * a.length) | 0];

// Łączy wiele prymitywów w jedną geometrię z kolorami wierzchołków (1 wywołanie rysowania na obiekt).
class Builder {
  constructor() { this.parts = []; }
  add(geo, color, pos = [0, 0, 0], rot = [0, 0, 0], scl = [1, 1, 1]) {
    const m = new THREE.Matrix4().compose(
      new THREE.Vector3(...pos),
      new THREE.Quaternion().setFromEuler(new THREE.Euler(...rot)),
      new THREE.Vector3(...scl)
    );
    let g = geo.index ? geo.toNonIndexed() : geo.clone();
    g.applyMatrix4(m);
    for (const k of Object.keys(g.attributes)) if (k !== 'position' && k !== 'normal') g.deleteAttribute(k);
    const c = new THREE.Color(color);
    const n = g.attributes.position.count;
    const arr = new Float32Array(n * 3);
    for (let i = 0; i < n; i++) { arr[i * 3] = c.r; arr[i * 3 + 1] = c.g; arr[i * 3 + 2] = c.b; }
    g.setAttribute('color', new THREE.BufferAttribute(arr, 3));
    this.parts.push(g);
    return this;
  }
  build() {
    const g = mergeGeometries(this.parts);
    g.computeBoundingSphere();
    return g;
  }
}

// Iskierki (system cząsteczek) – zbieranie monet, ślad kuli, zderzenia.
class Sparkles {
  constructor(scene, tex, n = 420) {
    this.n = n;
    this.pos = new Float32Array(n * 3).fill(-999);
    this.col = new Float32Array(n * 3);
    this.base = new Float32Array(n * 3);
    this.vel = new Float32Array(n * 3);
    this.life = new Float32Array(n);
    this.decay = new Float32Array(n);
    this.grav = new Float32Array(n);
    this.i = 0;
    const g = new THREE.BufferGeometry();
    g.setAttribute('position', new THREE.BufferAttribute(this.pos, 3).setUsage(THREE.DynamicDrawUsage));
    g.setAttribute('color', new THREE.BufferAttribute(this.col, 3).setUsage(THREE.DynamicDrawUsage));
    this.points = new THREE.Points(g, new THREE.PointsMaterial({
      size: 0.42, map: tex, vertexColors: true, transparent: true, depthWrite: false, blending: THREE.AdditiveBlending, fog: false,
    }));
    this.points.frustumCulled = false;
    scene.add(this.points);
    this.tmp = new THREE.Color();
  }
  emit(x, y, z, color, count, speed = 3, up = 2, decay = 1.6, grav = 6) {
    for (let k = 0; k < count; k++) {
      const i = this.i++ % this.n;
      const c = this.tmp.set(Array.isArray(color) ? pick(color) : color);
      this.pos.set([x, y, z], i * 3);
      this.base.set([c.r, c.g, c.b], i * 3);
      const a = rnd() * Math.PI * 2, s = speed * (0.4 + rnd() * 0.6);
      this.vel.set([Math.cos(a) * s, up * (0.5 + rnd()), Math.sin(a) * s], i * 3);
      this.life[i] = 1;
      this.decay[i] = decay * (0.7 + rnd() * 0.6);
      this.grav[i] = grav;
    }
  }
  update(dt, scroll) {
    const { pos, vel, col, base, life } = this;
    for (let i = 0; i < this.n; i++) {
      if (life[i] <= 0) continue;
      life[i] -= dt * this.decay[i];
      const j = i * 3;
      if (life[i] <= 0) { pos[j + 1] = -999; col[j] = col[j + 1] = col[j + 2] = 0; continue; }
      vel[j + 1] -= this.grav[i] * dt;
      pos[j] += vel[j] * dt;
      pos[j + 1] += vel[j + 1] * dt;
      pos[j + 2] += vel[j + 2] * dt + scroll;
      const l = life[i];
      col[j] = base[j] * l; col[j + 1] = base[j + 1] * l; col[j + 2] = base[j + 2] * l;
    }
    this.points.geometry.attributes.position.needsUpdate = true;
    this.points.geometry.attributes.color.needsUpdate = true;
  }
}

export class Game {
  constructor(canvas, hooks) {
    this.hooks = hooks;
    this.canvas = canvas;
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.05;

    this.scene = new THREE.Scene();
    this.scene.fog = new THREE.Fog(0xffe3f1, 45, 130);
    // odbicia otoczenia – złoto, metal i bańki ładnie błyszczą
    const pmrem = new THREE.PMREMGenerator(this.renderer);
    this.scene.environment = pmrem.fromScene(new RoomEnvironment(), 0.04).texture;
    this.scene.environmentIntensity = 0.28;
    pmrem.dispose();

    this.camera = new THREE.PerspectiveCamera(62, 1, 0.1, 400);
    this.camera.position.set(0, 3.6, 7.5);
    this.camLook = new THREE.Vector3(0, 1.3, -6);
    this.menuMode = true;
    this.camZ = 7.5;
    this.camPos = new THREE.Vector3();
    this.camTarget = new THREE.Vector3();

    this.clock = { last: performance.now(), getDelta() { const n = performance.now(); const d = (n - this.last) / 1000; this.last = n; return d; } };
    this.running = false;
    this.paused = false;
    this.time = 0;
    this.dying = 0;
    this.squash = 0;
    this.perf = { t: 0, n: 0, done: false };

    this.pal = {};
    this.palTarget = {};
    for (const k of ['skyTop', 'skyBottom', 'grass', 'tint', 'sun', 'lamp']) { this.pal[k] = new THREE.Color(); this.palTarget[k] = new THREE.Color(); }
    this.palNum = { light: 1, rainbow: 0 };
    this.palNumTarget = { light: 1, rainbow: 0 };
    this.chapterIdx = 0;

    this.#buildWorld();
    this.#buildPlayer();
    this.#buildPools();
    this.setChapter(0, true);
    this.setQuality('high');
    this.resize();
    addEventListener('resize', () => this.resize());
    this.renderer.setAnimationLoop(() => this.#tick());
  }

  // ======================= ŚWIAT =======================
  #buildWorld() {
    const s = this.scene;
    this.hemi = new THREE.HemisphereLight(0xbfe6ff, 0x8fdc6a, 1.3);
    s.add(this.hemi);
    const sun = new THREE.DirectionalLight(0xfff1d6, 2.6);
    sun.position.set(6, 14, 8);
    sun.castShadow = true;
    sun.shadow.mapSize.set(1024, 1024);
    sun.shadow.bias = -0.0005;
    Object.assign(sun.shadow.camera, { left: -7, right: 7, top: 8, bottom: -8, near: 1, far: 50 });
    sun.target.position.set(0, 0, -3);
    s.add(sun, sun.target);
    this.sun = sun;

    // Niebo – gradient
    this.skyMat = new THREE.ShaderMaterial({
      side: THREE.BackSide, depthWrite: false, fog: false,
      uniforms: { top: { value: new THREE.Color() }, bottom: { value: new THREE.Color() } },
      vertexShader: 'varying vec3 vP; void main(){ vP = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0); }',
      fragmentShader: `uniform vec3 top; uniform vec3 bottom; varying vec3 vP;
        void main(){ float h = clamp(vP.y * 3.0 + 0.02, 0.0, 1.0); gl_FragColor = vec4(mix(bottom, top, pow(h, 0.55)), 1.0);
        #include <colorspace_fragment>
        }`,
    });
    const sky = new THREE.Mesh(new THREE.SphereGeometry(320, 32, 16), this.skyMat);
    sky.renderOrder = -10;
    s.add(sky);

    // Słońce (miękka poświata)
    const sunTex = this.#radialTexture(['rgba(255,255,240,1)', 'rgba(255,240,200,0.6)', 'rgba(255,220,180,0)']);
    this.sunSprite = new THREE.Sprite(new THREE.SpriteMaterial({ map: sunTex, fog: false, depthWrite: false, transparent: true }));
    this.sunSprite.scale.set(70, 70, 1);
    this.sunSprite.position.set(40, 55, -260);
    s.add(this.sunSprite);

    // Tęcza
    this.rainbow = new THREE.Group();
    [0xff5c5c, 0xffa94d, 0xffe14d, 0x6fe07a, 0x5ab8ff, 0x7b6bff, 0xc37bff].forEach((c, i) => {
      const arc = new THREE.Mesh(new THREE.TorusGeometry(95 - i * 2.2, 1.15, 6, 64, Math.PI),
        new THREE.MeshBasicMaterial({ color: c, transparent: true, opacity: 0, fog: false, depthWrite: false }));
      this.rainbow.add(arc);
    });
    this.rainbow.position.set(-20, -8, -280);
    s.add(this.rainbow);

    // Chmury
    this.cloudMat = new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 1, emissive: 0xffffff, emissiveIntensity: 0.35, fog: false });
    const cloudGeos = [0, 1, 2].map(() => {
      const B = new Builder();
      const n = 5 + ((rnd() * 3) | 0);
      for (let i = 0; i < n; i++) {
        const r = 2.2 + rnd() * 2.2;
        B.add(new THREE.SphereGeometry(r, 14, 10), 0xffffff, [(i - n / 2) * 2.6, rnd() * 1.6 + (i % 2) * 0.8, rnd() * 2]);
      }
      return B.build();
    });
    this.clouds = [];
    for (let i = 0; i < 16; i++) {
      const c = new THREE.Mesh(pick(cloudGeos), this.cloudMat);
      c.position.set((rnd() - 0.5) * 260, 25 + rnd() * 45, -90 - rnd() * 170);
      c.scale.setScalar(0.8 + rnd() * 1.2);
      c.userData.v = 0.6 + rnd() * 1.5;
      s.add(c);
      this.clouds.push(c);
    }

    // Zamek na horyzoncie
    this.castleMat = new THREE.MeshStandardMaterial({ vertexColors: true, roughness: 0.8, fog: false });
    const castle = new THREE.Mesh(this.#castleGeometry(), this.castleMat);
    castle.position.set(0, -1, -230);
    castle.scale.setScalar(2.6);
    s.add(castle);
    this.castle = castle;

    // Trawa
    const grassTex = this.#grassTexture();
    grassTex.wrapS = grassTex.wrapT = THREE.RepeatWrapping;
    grassTex.repeat.set(30, 34);
    this.grassTex = grassTex;
    this.grassMat = new THREE.MeshStandardMaterial({ map: grassTex, roughness: 1 });
    const grass = new THREE.Mesh(new THREE.PlaneGeometry(240, 272), this.grassMat);
    grass.rotation.x = -Math.PI / 2;
    grass.position.set(0, -0.03, -120);
    grass.receiveShadow = true;
    s.add(grass);

    // Złota ceglana droga
    const roadTex = this.#roadTexture();
    roadTex.wrapS = roadTex.wrapT = THREE.RepeatWrapping;
    roadTex.repeat.set(1, 36);
    roadTex.anisotropy = 8;
    this.roadTex = roadTex;
    this.roadMat = new THREE.MeshStandardMaterial({ map: roadTex, roughness: 0.7 });
    const road = new THREE.Mesh(new THREE.PlaneGeometry(7.2, 260), this.roadMat);
    road.rotation.x = -Math.PI / 2;
    road.position.z = -115;
    road.receiveShadow = true;
    s.add(road);
    const curbMat = new THREE.MeshStandardMaterial({ color: 0xfff6ea, roughness: 0.6 });
    for (const x of [-3.75, 3.75]) {
      const curb = new THREE.Mesh(new THREE.BoxGeometry(0.34, 0.2, 260), curbMat);
      curb.position.set(x, 0.08, -115);
      curb.receiveShadow = true;
      s.add(curb);
    }

    // Dekoracje: domki, drzewa, grzybki, kwiaty, latarnie
    this.decoMat = new THREE.MeshStandardMaterial({ vertexColors: true, roughness: 0.75 });
    this.lampGlowMat = new THREE.MeshStandardMaterial({ color: 0xfff1b0, emissive: 0xffc94d, emissiveIntensity: 1.2 });
    const houseGeos = Array.from({ length: 12 }, (_, i) => this.#houseGeometry(i % 4));
    const treeGeos = Array.from({ length: 8 }, (_, i) => this.#treeGeometry(i % 4));
    const flowerGeos = Array.from({ length: 4 }, () => this.#flowerPatchGeometry());
    const lampGeo = this.#lampGeometry();
    const glowGeo = new THREE.SphereGeometry(0.22, 12, 10);
    this.deco = [];
    const addDeco = (geo, x, z, opts = {}) => {
      const m = new THREE.Mesh(geo, this.decoMat);
      m.position.set(x, 0, z);
      m.rotation.y = opts.ry ?? 0;
      m.castShadow = !!opts.shadow;
      m.receiveShadow = true;
      this.scene.add(m);
      m.userData = { ...opts, baseX: x };
      this.deco.push(m);
      return m;
    };
    for (let i = 0; i < 26; i++) {
      const side = i % 2 ? 1 : -1;
      const z = SPAWN_Z + (i / 26) * SPAN;
      const h = addDeco(pick(houseGeos), side * (8 + rnd() * 3), z, { ry: side < 0 ? Math.PI / 2 : -Math.PI / 2, kind: 'house', houses: houseGeos });
      h.scale.setScalar(0.9 + rnd() * 0.35);
    }
    for (let i = 0; i < 34; i++) {
      const side = i % 2 ? 1 : -1;
      const t = addDeco(pick(treeGeos), side * (5.4 + rnd() * 1.6 + (i % 3 === 0 ? 8 : 0)), SPAWN_Z + rnd() * SPAN, { ry: rnd() * 6, kind: 'tree', shadow: true });
      t.scale.setScalar(0.8 + rnd() * 0.5);
    }
    for (let i = 0; i < 24; i++) {
      const side = i % 2 ? 1 : -1;
      addDeco(pick(flowerGeos), side * (4.4 + rnd() * 1.2), SPAWN_Z + rnd() * SPAN, { ry: rnd() * 6, kind: 'flower' });
    }
    this.lampGlows = [];
    for (let i = 0; i < 14; i++) {
      const side = i % 2 ? 1 : -1;
      const z = SPAWN_Z + Math.floor(i / 2) * (SPAN / 7);
      const lamp = addDeco(lampGeo, side * 4.25, z, { kind: 'lamp', shadow: true });
      const g = new THREE.Mesh(glowGeo, this.lampGlowMat);
      g.position.set(0, 2.55, 0);
      lamp.add(g);
    }

    // Motylki
    this.butterflies = [];
    const wingGeo = new THREE.CircleGeometry(0.16, 12);
    for (let i = 0; i < 8; i++) {
      const b = new THREE.Group();
      const m = new THREE.MeshBasicMaterial({ color: pick([0xff8fc8, 0xffd23f, 0x7ad7ff, 0xb388ff]), side: THREE.DoubleSide });
      for (const sd of [-1, 1]) {
        const w = new THREE.Mesh(wingGeo, m);
        w.position.x = sd * 0.14;
        const piv = new THREE.Group(); piv.add(w); b.add(piv);
      }
      b.position.set((rnd() < 0.5 ? -1 : 1) * (4.5 + rnd() * 3), 0.8 + rnd() * 1.5, SPAWN_Z + rnd() * SPAN);
      b.userData.ph = rnd() * 10;
      this.scene.add(b);
      this.butterflies.push(b);
    }

    // Czarnoksiężnik Szaruch – zjawa nad zamkiem (rozdział 4)
    this.baron = buildCharacter('baron');
    this.baron.traverse((o) => {
      if (o.isMesh) { o.material = o.material.clone(); o.material.fog = false; o.material.transparent = true; o.material.opacity = 0; o.castShadow = false; }
    });
    this.baron.scale.setScalar(24);
    this.baron.position.set(0, 55, -225);
    this.baron.visible = false;
    s.add(this.baron);
    this.baronAlpha = 0;

    // Iskierki
    this.sparkles = new Sparkles(s, this.#starTexture());
  }

  #castleGeometry() {
    const B = new Builder();
    const wall = 0xfff0f6, roofA = 0xff6f91, roofB = 0x7b9bff, dark = 0x8f6aa8;
    B.add(new THREE.BoxGeometry(16, 7, 6), wall, [0, 3.5, 0]);
    B.add(new THREE.BoxGeometry(7, 11, 5), wall, [0, 5.5, -1]);
    B.add(new THREE.ConeGeometry(5, 6, 4), roofA, [0, 14, -1], [0, Math.PI / 4, 0]);
    B.add(new THREE.CylinderGeometry(1.8, 1.8, 3.8, 20, 1, false, 0, Math.PI), dark, [0, 1.9, 3.01], [0, -Math.PI / 2, 0]);
    for (const [x, h, r, roof] of [[-8, 11, 1.8, roofB], [8, 11, 1.8, roofB], [-4.5, 15, 1.4, roofA], [4.5, 15, 1.4, roofA], [0, 19, 1.2, roofB]]) {
      B.add(new THREE.CylinderGeometry(r, r * 1.08, h, 20), wall, [x, h / 2, x === 0 ? -1 : 0]);
      B.add(new THREE.ConeGeometry(r * 1.35, r * 3, 20), roof, [x, h + r * 1.5, x === 0 ? -1 : 0]);
      B.add(new THREE.BoxGeometry(0.1, 1.6, 0.1), 0x8a6a4a, [x, h + r * 3 + 0.8, x === 0 ? -1 : 0]);
      B.add(new THREE.BoxGeometry(1.1, 0.6, 0.05), pick([0xffd23f, 0xff5c5c, 0x5ab8ff]), [x + 0.55, h + r * 3 + 1.3, x === 0 ? -1 : 0]);
      for (let k = 0; k < 3; k++) B.add(new THREE.CircleGeometry(0.35, 12), 0xfff3b0, [x, 2.5 + k * (h / 3.2), (x === 0 ? -1 : 0) + r + 0.02]);
    }
    for (let i = -7; i <= 7; i += 2) B.add(new THREE.BoxGeometry(0.9, 0.9, 6.2), wall, [i, 7.45, 0]);
    return B.build();
  }

  #houseGeometry(kind) {
    const B = new Builder();
    const wall = pick(WALLS), roof = pick(ROOFS), door = 0x9a5b34, win = 0xfff3b0, frame = 0xffffff;
    if (kind === 0) { // chatka
      const w = 2.6 + rnd(), h = 2.2 + rnd(), d = 2.6;
      B.add(new THREE.BoxGeometry(w, h, d), wall, [0, h / 2, 0]);
      B.add(new THREE.ConeGeometry(Math.max(w, d) * 0.82, 2, 4), roof, [0, h + 1, 0], [0, Math.PI / 4, 0], [1, 1, 1]);
      B.add(new THREE.BoxGeometry(0.4, 1.1, 0.4), 0xd98b6a, [w * 0.25, h + 1.3, -0.3]);
      B.add(new THREE.BoxGeometry(0.7, 1.2, 0.1), door, [0, 0.6, d / 2 + 0.03]);
      B.add(new THREE.SphereGeometry(0.06, 6, 6), 0xffd23f, [0.22, 0.6, d / 2 + 0.1]);
      for (const sx of [-1, 1]) {
        B.add(new THREE.CircleGeometry(0.36, 16), frame, [sx * w * 0.3, h * 0.62, d / 2 + 0.02]);
        B.add(new THREE.CircleGeometry(0.28, 16), win, [sx * w * 0.3, h * 0.62, d / 2 + 0.03]);
        B.add(new THREE.BoxGeometry(0.8, 0.18, 0.25), 0x9a5b34, [sx * w * 0.3, h * 0.62 - 0.42, d / 2 + 0.1]);
        for (let k = 0; k < 3; k++) B.add(new THREE.SphereGeometry(0.1, 6, 6), pick(FLOWERS), [sx * w * 0.3 + (k - 1) * 0.24, h * 0.62 - 0.28, d / 2 + 0.12]);
      }
    } else if (kind === 1) { // wieżyczka
      const h = 3.6 + rnd() * 2;
      B.add(new THREE.CylinderGeometry(1.2, 1.3, h, 22), wall, [0, h / 2, 0]);
      B.add(new THREE.ConeGeometry(1.6, 2.8, 22), roof, [0, h + 1.4, 0]);
      B.add(new THREE.SphereGeometry(0.16, 10, 8), 0xffd23f, [0, h + 2.9, 0]);
      B.add(new THREE.BoxGeometry(0.7, 1.2, 0.1), door, [0, 0.6, 1.28]);
      for (let k = 0; k < 2; k++) {
        B.add(new THREE.CircleGeometry(0.34, 16), frame, [0, 1.9 + k * 1.3, 1.24]);
        B.add(new THREE.CircleGeometry(0.26, 16), win, [0, 1.9 + k * 1.3, 1.25]);
      }
    } else if (kind === 2) { // domek-grzybek
      B.add(new THREE.CylinderGeometry(1.1, 1.35, 2.4, 22), 0xfff1dc, [0, 1.2, 0]);
      B.add(new THREE.SphereGeometry(2.1, 24, 14, 0, Math.PI * 2, 0, Math.PI / 2), pick([0xff5c5c, 0xff6f91, 0xffa94d, 0x9b7bff]), [0, 2.2, 0], [0, 0, 0], [1, 0.75, 1]);
      for (let k = 0; k < 8; k++) {
        const a = (k / 8) * Math.PI * 2 + rnd(), el = 0.35 + rnd() * 0.7;
        B.add(new THREE.SphereGeometry(0.24, 10, 8), 0xffffff, [Math.cos(a) * Math.cos(el) * 2.08, 2.2 + Math.sin(el) * 1.56, Math.sin(a) * Math.cos(el) * 2.08], [0, 0, 0], [1, 0.5, 1]);
      }
      B.add(new THREE.BoxGeometry(0.65, 1.1, 0.1), door, [0, 0.55, 1.33]);
      B.add(new THREE.CircleGeometry(0.26, 16), win, [0.55, 1.6, 1.22], [0, 0.4, 0]);
    } else { // piętrowy domek z balkonem
      const w = 3, h = 4.2, d = 2.8;
      B.add(new THREE.BoxGeometry(w, h, d), wall, [0, h / 2, 0]);
      B.add(new THREE.CylinderGeometry(1.7, 1.7, w + 0.4, 3), roof, [0, h + 0.85, 0], [0, 0, Math.PI / 2], [1, 1, 1]);
      B.add(new THREE.BoxGeometry(0.75, 1.3, 0.1), door, [0, 0.65, d / 2 + 0.03]);
      B.add(new THREE.BoxGeometry(2.2, 0.12, 0.7), 0xffffff, [0, 2.3, d / 2 + 0.35]);
      for (let k = -2; k <= 2; k++) B.add(new THREE.BoxGeometry(0.06, 0.5, 0.06), 0xffffff, [k * 0.5, 2.6, d / 2 + 0.66]);
      for (const sx of [-1, 1]) {
        B.add(new THREE.BoxGeometry(0.7, 0.8, 0.05), frame, [sx * 0.85, 3.2, d / 2 + 0.02]);
        B.add(new THREE.BoxGeometry(0.55, 0.65, 0.05), win, [sx * 0.85, 3.2, d / 2 + 0.04]);
        B.add(new THREE.CircleGeometry(0.3, 14), win, [sx * 1.05, 1.1, d / 2 + 0.03]);
      }
    }
    return B.build();
  }

  #treeGeometry(kind) {
    const B = new Builder();
    const trunk = 0x9a6b45;
    if (kind === 0 || kind === 3) { // drzewko-lizak
      const leaf = kind === 3 ? pick([0xffa8d8, 0xffc4e1]) : pick(LEAVES);
      B.add(new THREE.CylinderGeometry(0.14, 0.2, 1.6, 8), trunk, [0, 0.8, 0]);
      B.add(new THREE.SphereGeometry(1.1, 18, 14), leaf, [0, 2.3, 0]);
      B.add(new THREE.SphereGeometry(0.7, 14, 10), leaf, [0.6, 2.0, 0.3]);
      B.add(new THREE.SphereGeometry(0.65, 14, 10), leaf, [-0.55, 2.1, -0.2]);
      if (kind === 0) for (let k = 0; k < 5; k++) B.add(new THREE.SphereGeometry(0.12, 8, 6), 0xff5c5c, [Math.cos(k * 1.3) * 0.95, 2.1 + Math.sin(k * 2) * 0.5, Math.sin(k * 1.3) * 0.95]);
    } else if (kind === 1) { // choinka
      B.add(new THREE.CylinderGeometry(0.15, 0.2, 0.8, 8), trunk, [0, 0.4, 0]);
      const c = pick([0x3fae6a, 0x4fbf8f, 0x56b870]);
      [[1.2, 1.4, 1.2], [0.95, 1.2, 2.0], [0.65, 1.0, 2.7]].forEach(([r, h, y]) => B.add(new THREE.ConeGeometry(r, h, 10), c, [0, y, 0]));
      B.add(new THREE.OctahedronGeometry(0.16), 0xffd23f, [0, 3.3, 0]);
    } else { // grzybki i krzaczek
      B.add(new THREE.SphereGeometry(0.7, 14, 10), pick(LEAVES), [0, 0.45, 0], [0, 0, 0], [1.3, 0.8, 1]);
      for (let k = 0; k < 3; k++) {
        const x = (k - 1) * 0.7 + 1.2, sc = 0.6 + k * 0.25;
        B.add(new THREE.CylinderGeometry(0.1 * sc, 0.13 * sc, 0.5 * sc, 8), 0xfff1dc, [x, 0.25 * sc, 0.4]);
        B.add(new THREE.SphereGeometry(0.32 * sc, 12, 8, 0, Math.PI * 2, 0, Math.PI / 2), 0xff5c5c, [x, 0.48 * sc, 0.4]);
        B.add(new THREE.SphereGeometry(0.06 * sc, 6, 6), 0xffffff, [x + 0.12 * sc, 0.68 * sc, 0.48]);
      }
    }
    return B.build();
  }

  #flowerPatchGeometry() {
    const B = new Builder();
    for (let k = 0; k < 9; k++) {
      const x = (rnd() - 0.5) * 1.8, z = (rnd() - 0.5) * 1.8, h = 0.25 + rnd() * 0.3, c = pick(FLOWERS);
      B.add(new THREE.CylinderGeometry(0.02, 0.02, h, 4), 0x4fbf6a, [x, h / 2, z]);
      for (let p = 0; p < 5; p++) {
        const a = (p / 5) * Math.PI * 2;
        B.add(new THREE.SphereGeometry(0.07, 6, 4), c, [x + Math.cos(a) * 0.08, h, z + Math.sin(a) * 0.08], [0, 0, 0], [1, 0.5, 1]);
      }
      B.add(new THREE.SphereGeometry(0.05, 6, 4), 0xffd23f, [x, h + 0.02, z]);
    }
    return B.build();
  }

  #lampGeometry() {
    const B = new Builder();
    const post = 0x3d6b5a;
    B.add(new THREE.CylinderGeometry(0.07, 0.1, 2.4, 8), post, [0, 1.2, 0]);
    B.add(new THREE.CylinderGeometry(0.2, 0.2, 0.08, 8), post, [0, 2.38, 0]);
    B.add(new THREE.ConeGeometry(0.32, 0.3, 8), post, [0, 2.88, 0]);
    B.add(new THREE.SphereGeometry(0.06, 6, 6), 0xffd23f, [0, 3.06, 0]);
    return B.build();
  }

  #radialTexture(stops) {
    const c = document.createElement('canvas');
    c.width = c.height = 128;
    const g = c.getContext('2d');
    const grad = g.createRadialGradient(64, 64, 0, 64, 64, 64);
    stops.forEach((s, i) => grad.addColorStop(i / (stops.length - 1), s));
    g.fillStyle = grad;
    g.fillRect(0, 0, 128, 128);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }

  #starTexture() {
    const c = document.createElement('canvas');
    c.width = c.height = 64;
    const g = c.getContext('2d');
    const grad = g.createRadialGradient(32, 32, 0, 32, 32, 32);
    grad.addColorStop(0, 'rgba(255,255,255,1)');
    grad.addColorStop(0.25, 'rgba(255,255,255,0.8)');
    grad.addColorStop(1, 'rgba(255,255,255,0)');
    g.fillStyle = grad;
    g.fillRect(0, 0, 64, 64);
    g.fillStyle = 'rgba(255,255,255,0.9)';
    g.fillRect(30, 2, 4, 60);
    g.fillRect(2, 30, 60, 4);
    return new THREE.CanvasTexture(c);
  }

  #roadTexture() {
    const c = document.createElement('canvas');
    c.width = c.height = 512;
    const g = c.getContext('2d');
    g.fillStyle = '#d99a2b';
    g.fillRect(0, 0, 512, 512);
    const rows = 16, bw = 512 / 8;
    for (let r = 0; r < rows; r++) {
      const off = r % 2 ? bw / 2 : 0;
      for (let b = -1; b < 9; b++) {
        const x = b * bw + off, y = r * (512 / rows);
        const l = 58 + Math.random() * 10;
        g.fillStyle = `hsl(${42 + Math.random() * 6}, 95%, ${l}%)`;
        g.beginPath();
        g.roundRect(x + 3, y + 3, bw - 6, 512 / rows - 6, 6);
        g.fill();
        g.fillStyle = 'rgba(255,255,255,0.35)';
        g.fillRect(x + 8, y + 6, bw - 22, 4);
      }
    }
    g.fillStyle = 'rgba(255,255,255,0.55)';
    for (const x of [512 / 3, (512 * 2) / 3]) for (let y = 0; y < 512; y += 64) g.fillRect(x - 4, y + 8, 8, 34);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }

  #grassTexture() {
    const c = document.createElement('canvas');
    c.width = c.height = 128;
    const g = c.getContext('2d');
    g.fillStyle = '#ffffff';
    g.fillRect(0, 0, 128, 128);
    for (let i = 0; i < 500; i++) {
      g.fillStyle = `rgba(${Math.random() < 0.5 ? '40,90,30' : '255,255,220'},${0.05 + Math.random() * 0.12})`;
      g.fillRect(Math.random() * 128, Math.random() * 128, 2 + Math.random() * 3, 4 + Math.random() * 6);
    }
    for (let i = 0; i < 10; i++) {
      g.fillStyle = pick(['#fff', '#ffe36b', '#ffb3d9']);
      g.beginPath(); g.arc(Math.random() * 128, Math.random() * 128, 1.6, 0, Math.PI * 2); g.fill();
    }
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }

  // ======================= PALETY ROZDZIAŁÓW =======================
  setChapter(i, instant = false) {
    const c = CHAPTERS[Math.min(i, CHAPTERS.length - 1)];
    this.chapterIdx = i;
    for (const k of Object.keys(this.palTarget)) this.palTarget[k].setHex(c[k]);
    this.palNumTarget.light = c.light;
    this.palNumTarget.rainbow = c.rainbow ? 1 : 0;
    this.villainWanted = !!c.villain;
    if (instant) {
      for (const k of Object.keys(this.pal)) this.pal[k].copy(this.palTarget[k]);
      Object.assign(this.palNum, this.palNumTarget);
    }
    this.#applyPalette();
  }

  #applyPalette() {
    const p = this.pal;
    this.skyMat.uniforms.top.value.copy(p.skyTop);
    this.skyMat.uniforms.bottom.value.copy(p.skyBottom);
    this.scene.fog.color.copy(p.skyBottom);
    this.grassMat.color.copy(p.grass);
    this.decoMat.color.copy(p.tint);
    this.castleMat.color.copy(p.tint);
    this.roadMat.color.copy(p.tint);
    this.cloudMat.color.copy(p.tint);
    this.sun.color.copy(p.sun);
    this.sun.intensity = 2.1 * this.palNum.light;
    this.hemi.color.copy(p.skyTop).lerp(new THREE.Color(0xffffff), 0.5);
    this.hemi.groundColor.copy(p.grass);
    this.hemi.intensity = 0.95 * this.palNum.light;
    this.lampGlowMat.emissive.copy(p.lamp);
    this.lampGlowMat.emissiveIntensity = 2.2 - this.palNum.light;
    this.sunSprite.material.color.copy(p.sun);
    for (const arc of this.rainbow.children) arc.material.opacity = this.palNum.rainbow * 0.55;
    this.rainbow.visible = this.palNum.rainbow > 0.01;
  }

  #worldTick(dt, v) {
    // płynne przejście kolorów
    const k = Math.min(1, dt * 1.2);
    let moving = false;
    for (const key of Object.keys(this.pal)) {
      if (!this.pal[key].equals(this.palTarget[key])) { this.pal[key].lerp(this.palTarget[key], k); moving = true; }
    }
    for (const key of Object.keys(this.palNum)) {
      const d = this.palNumTarget[key] - this.palNum[key];
      if (Math.abs(d) > 0.001) { this.palNum[key] += d * k; moving = true; }
    }
    if (moving) this.#applyPalette();

    this.roadTex.offset.y += v / 7.2;
    this.grassTex.offset.y += v / 8;
    for (const d of this.deco) {
      d.position.z += v;
      if (d.position.z > DESPAWN_Z + 6) {
        d.position.z -= SPAN;
        if (d.userData.kind === 'house') {
          d.geometry = pick(d.userData.houses);
          d.scale.setScalar(0.9 + rnd() * 0.35);
        }
      }
    }
    for (const c of this.clouds) {
      c.position.x += c.userData.v * dt;
      if (c.position.x > 140) c.position.x = -140;
    }
    for (const b of this.butterflies) {
      b.position.z += v;
      const ph = (b.userData.ph += dt);
      b.position.y += Math.sin(ph * 2) * dt * 0.6;
      b.position.x += Math.cos(ph * 1.3) * dt * 0.8;
      b.children[0].rotation.y = Math.sin(ph * 22) * 1.1;
      b.children[1].rotation.y = -Math.sin(ph * 22) * 1.1;
      b.rotation.y = Math.sin(ph) * 0.8;
      if (b.position.z > DESPAWN_Z) b.position.z -= SPAN;
    }
    // Szaruch pojawia się nad zamkiem
    const want = this.running && this.villainWanted ? 0.6 : 0;
    this.baronAlpha += (want - this.baronAlpha) * Math.min(1, dt * 0.8);
    this.baron.visible = this.baronAlpha > 0.01;
    if (this.baron.visible) {
      this.baron.traverse((o) => { if (o.isMesh) o.material.opacity = this.baronAlpha; });
      animateCharacter(this.baron, this.time * 0.6);
      this.baron.rotation.y = Math.sin(this.time * 0.4) * 0.3;
      this.baron.position.y = 55 + Math.sin(this.time) * 2;
    }
  }

  // ======================= GRACZ =======================
  #buildPlayer() {
    this.player = new THREE.Group();
    this.ballMat = new THREE.MeshPhysicalMaterial({ clearcoat: 1, clearcoatRoughness: 0.15 });
    this.ball = new THREE.Mesh(new THREE.SphereGeometry(BALL_R, 32, 24), this.ballMat);
    this.ball.castShadow = true;
    // wzór na kuli (paski + gwiazdki), żeby było widać toczenie
    this.ballRingMat = new THREE.MeshStandardMaterial({ color: 0xffffff, roughness: 0.3 });
    const ring = new THREE.Mesh(new THREE.TorusGeometry(BALL_R * 1.005, 0.045, 8, 40), this.ballRingMat);
    ring.rotation.y = Math.PI / 2;
    this.ball.add(ring);
    const ring2 = ring.clone();
    ring2.rotation.set(0, Math.PI / 2, Math.PI / 2.5);
    this.ball.add(ring2);
    this.player.add(this.ball);

    this.charHolder = new THREE.Group();
    this.charHolder.position.y = BALL_R - 0.03;
    this.player.add(this.charHolder);
    this.charFacing = 0;

    // Bańka-tarcza
    this.shieldMesh = new THREE.Mesh(
      new THREE.SphereGeometry(BALL_R * 2, 32, 20),
      new THREE.MeshPhysicalMaterial({ color: 0xffffff, transparent: true, opacity: 0.35, roughness: 0, iridescence: 1, iridescenceIOR: 1.3, depthWrite: false })
    );
    this.shieldMesh.visible = false;
    this.shieldMesh.scale.y = 1.45;
    this.shieldMesh.position.y = 0.45;
    this.player.add(this.shieldMesh);

    // Cień-kółko pod kulą (czytelny także przy wyłączonych cieniach)
    const blob = new THREE.Mesh(new THREE.CircleGeometry(BALL_R * 1.1, 24), new THREE.MeshBasicMaterial({ color: 0x000000, transparent: true, opacity: 0.22, depthWrite: false }));
    blob.rotation.x = -Math.PI / 2;
    this.scene.add(blob);
    this.blob = blob;

    this.scene.add(this.player);
    this.trailColor = 0xffd75e;
    this.setSkin('classic');
  }

  setCharacter(id) {
    if (this.character) {
      this.charHolder.remove(this.character);
      this.character.traverse((o) => { if (o.isMesh) o.geometry.dispose(); });
    }
    this.character = buildCharacter(id);
    this.charHolder.add(this.character);
  }

  setSkin(id) {
    const sk = SKINS.find((s) => s.id === id) || SKINS[0];
    this.ballMat.color.setHex(sk.color);
    this.ballMat.emissive.setHex(sk.emissive);
    this.ballMat.emissiveIntensity = 0.25;
    this.ballMat.metalness = sk.metal;
    this.ballMat.roughness = sk.rough;
    this.ballRingMat.color.setHex(sk.trail);
    this.trailColor = sk.trail;
  }

  // ======================= PRZESZKODY I ZNAJDŹKI =======================
  #buildPools() {
    this.objects = [];
    this.pool = {};
    const gold = new THREE.MeshStandardMaterial({ color: 0xffc928, metalness: 0.9, roughness: 0.22, emissive: 0xb37400, emissiveIntensity: 0.45 });
    this.mats = {
      coin: gold,
      deco: new THREE.MeshStandardMaterial({ vertexColors: true, roughness: 0.6 }),
      bubble: new THREE.MeshPhysicalMaterial({ color: 0xbff6ff, transparent: true, opacity: 0.55, roughness: 0, iridescence: 1, emissive: 0x58d8ff, emissiveIntensity: 0.35 }),
    };
    // moneta z gwiazdką
    const star = new THREE.Shape();
    for (let i = 0; i < 10; i++) {
      const r = i % 2 ? 0.1 : 0.22, a = (i / 10) * Math.PI * 2 + Math.PI / 2;
      i ? star.lineTo(Math.cos(a) * r, Math.sin(a) * r) : star.moveTo(Math.cos(a) * r, Math.sin(a) * r);
    }
    const coinB = new Builder();
    coinB.add(new THREE.CylinderGeometry(0.38, 0.38, 0.08, 28), 0xffffff, [0, 0, 0], [Math.PI / 2, 0, 0]);
    coinB.add(new THREE.TorusGeometry(0.36, 0.04, 6, 28), 0xffffff);
    coinB.add(new THREE.ExtrudeGeometry(star, { depth: 0.1, bevelEnabled: false }), 0xffffff, [0, 0, -0.05]);
    const coinGeo = coinB.build();
    coinGeo.deleteAttribute('color');

    // płotek z cukierkowymi słupkami (przeskocz)
    const fence = new Builder();
    for (const x of [-0.8, 0, 0.8]) {
      fence.add(new THREE.CylinderGeometry(0.08, 0.08, 0.85, 10), 0xffffff, [x, 0.42, 0]);
      for (let k = 0; k < 3; k++) fence.add(new THREE.CylinderGeometry(0.085, 0.085, 0.1, 10), 0xff3b5c, [x, 0.15 + k * 0.25, 0]);
      fence.add(new THREE.SphereGeometry(0.11, 10, 8), 0xff3b5c, [x, 0.88, 0]);
    }
    fence.add(new THREE.BoxGeometry(1.8, 0.14, 0.08), 0xc98a5a, [0, 0.62, 0.05]);
    fence.add(new THREE.BoxGeometry(1.8, 0.14, 0.08), 0xc98a5a, [0, 0.32, 0.05]);

    // dynia (omiń)
    const pumpkin = new Builder();
    for (let k = 0; k < 8; k++) {
      const a = (k / 8) * Math.PI * 2;
      pumpkin.add(new THREE.SphereGeometry(0.55, 16, 12), k % 2 ? 0xff8c1a : 0xff9f2e, [Math.cos(a) * 0.38, 0.8, Math.sin(a) * 0.38], [0, -a, 0], [0.7, 1.35, 1]);
    }
    pumpkin.add(new THREE.CylinderGeometry(0.08, 0.12, 0.4, 8), 0x4f8a2b, [0, 1.55, 0], [0, 0, 0.3]);
    pumpkin.add(new THREE.SphereGeometry(0.22, 10, 8), 0x5fbf3a, [0.25, 1.48, 0.1], [0, 0, 0], [1.4, 0.3, 1]);
    for (const sx of [-1, 1]) pumpkin.add(new THREE.ConeGeometry(0.12, 0.18, 3), 0x3a1a00, [sx * 0.25, 0.95, 0.88], [Math.PI / 2, 0, 0]);
    pumpkin.add(new THREE.TorusGeometry(0.26, 0.05, 6, 12, Math.PI), 0x3a1a00, [0, 0.62, 0.86], [0, 0, Math.PI]);

    // wieża z prezentów (omiń)
    const gifts = new Builder();
    [[1.5, 0.9, 0, 0xff6f91, 0xffd23f], [1.15, 0.75, 0.82, 0x5ab8ff, 0xffffff], [0.8, 0.6, 1.5, 0x9b7bff, 0xffd23f]].forEach(([w, h, y, c, rib], i) => {
      const ry = i * 0.35;
      gifts.add(new THREE.BoxGeometry(w, h, w), c, [0, y + h / 2, 0], [0, ry, 0]);
      gifts.add(new THREE.BoxGeometry(w + 0.02, h + 0.02, 0.16), rib, [0, y + h / 2, 0], [0, ry, 0]);
      gifts.add(new THREE.BoxGeometry(0.16, h + 0.02, w + 0.02), rib, [0, y + h / 2, 0], [0, ry, 0]);
    });
    gifts.add(new THREE.TorusGeometry(0.16, 0.06, 6, 12), 0xffd23f, [-0.14, 2.2, 0], [0, 0, 0.6]);
    gifts.add(new THREE.TorusGeometry(0.16, 0.06, 6, 12), 0xffd23f, [0.14, 2.2, 0], [0, 0, -0.6]);

    // magnes-podkowa
    const magnet = new Builder();
    magnet.add(new THREE.TorusGeometry(0.3, 0.11, 10, 20, Math.PI), 0xff3b5c, [0, 0, 0], [0, 0, Math.PI]);
    for (const sx of [-1, 1]) magnet.add(new THREE.CylinderGeometry(0.11, 0.11, 0.22, 10), 0xe8eef7, [sx * 0.3, 0.1, 0]);

    this.geos = {
      coin: coinGeo,
      barrier: fence.build(),
      wallPumpkin: pumpkin.build(),
      wallGifts: gifts.build(),
      magnet: magnet.build(),
      shield: new THREE.SphereGeometry(0.42, 24, 16),
    };
  }

  #obtain(type, variant) {
    const key = variant || type;
    const list = (this.pool[key] ||= []);
    let o = list.find((x) => !x.active);
    if (!o) {
      const mat = type === 'coin' ? this.mats.coin : type === 'shield' ? this.mats.bubble : this.mats.deco;
      const mesh = new THREE.Mesh(this.geos[key], mat);
      mesh.castShadow = type !== 'coin';
      this.scene.add(mesh);
      o = { type, mesh, active: false };
      list.push(o);
      this.objects.push(o);
    }
    o.active = true;
    o.mesh.visible = true;
    o.mesh.scale.setScalar(1);
    o.magnetized = false;
    return o;
  }

  #spawnRow() {
    const z = SPAWN_Z;
    const d = Math.min(1, this.distance / 2500);
    const lanes = shuffle([0, 1, 2]);
    const kinds = ['none', 'none', 'none'];
    const dens = this.diff.density;
    const nBlocked = rnd() < (0.3 - d * 0.2) / dens ? 0 : rnd() < (0.35 + d * 0.4) * dens ? 2 : 1;
    for (let i = 0; i < nBlocked; i++) kinds[lanes[i]] = rnd() < 0.55 ? 'wall' : 'barrier';
    if (kinds.every((k) => k === 'wall')) kinds[lanes[2]] = 'none';

    kinds.forEach((k, li) => {
      if (k === 'none') return;
      const o = this.#obtain(k, k === 'wall' ? (rnd() < 0.5 ? 'wallPumpkin' : 'wallGifts') : undefined);
      o.mesh.position.set(LANES[li], 0, z);
      o.mesh.rotation.set(0, k === 'wall' ? (rnd() - 0.5) * 0.6 : 0, 0);
    });

    // monety
    const free = [0, 1, 2].filter((i) => kinds[i] !== 'wall');
    const cl = free[(rnd() * free.length) | 0];
    if (kinds[cl] === 'barrier') {
      for (let i = 0; i < 5; i++) {
        const t = (i - 2) / 2;
        this.#obtain('coin').mesh.position.set(LANES[cl], 0.6 + 1.6 * (1 - t * t), z + (i - 2) * 1.7);
      }
    } else if (kinds.every((k) => k === 'none') && rnd() < 0.4) {
      // zygzak przez wszystkie pasy
      for (let i = 0; i < 9; i++) this.#obtain('coin').mesh.position.set(LANES[[0, 1, 2, 1][i % 4]], 0.6, z + 2 + i * 1.5);
    } else if (rnd() < 0.85) {
      const n = 4 + ((rnd() * 3) | 0);
      for (let i = 0; i < n; i++) this.#obtain('coin').mesh.position.set(LANES[cl], 0.6, z + 3 + i * 1.6);
    }

    // power-upy
    if (rnd() < 0.06) {
      const pl = free.find((i) => i !== cl) ?? cl;
      if (kinds[pl] === 'none') {
        const p = this.#obtain(rnd() < 0.5 ? 'magnet' : 'shield');
        p.mesh.position.set(LANES[pl], 0.9, z - 4);
      }
    }
  }

  // ======================= STEROWANIE =======================
  move(dir) {
    if (!this.running || this.paused || this.dying > 0) return false;
    const n = Math.max(0, Math.min(2, this.lane + dir));
    if (n === this.lane) return false;
    this.lane = n;
    return true;
  }

  jump() {
    if (!this.running || this.paused || this.dying > 0 || this.y > 0.01) return false;
    this.vy = JUMP_V;
    this.squash = -0.6; // rozciągnięcie przy wybiciu
    return true;
  }

  drop() { if (this.y > 0.01) this.vy = -JUMP_V * 1.4; }

  // ======================= CYKL GRY =======================
  start({ skin, character, diff, magnetTime, shieldTime, coinValue }) {
    this.diff = diff;
    this.menuMode = false;
    this.setChapter(0, true);
    for (const o of this.objects) { o.active = false; o.mesh.visible = false; }
    Object.assign(this, {
      running: true, paused: false, lane: 1, x: 0, y: 0, vy: 0, dying: 0,
      speed: diff.start, distance: 0, coins: 0, nextRow: 0,
      magnet: 0, shield: 0, invuln: 0, magnetTime, shieldTime, coinValue, shake: 0,
    });
    this.setSkin(skin);
    if (character) this.setCharacter(character);
    this.player.position.set(0, BALL_R, 0);
    this.player.rotation.set(0, 0, 0);
    this.clock.getDelta();
  }

  revive() {
    for (const o of this.objects) if (o.active && o.type !== 'coin' && o.mesh.position.z > -40) { o.active = false; o.mesh.visible = false; }
    this.running = true;
    this.paused = false;
    this.dying = 0;
    this.invuln = 2;
    this.player.rotation.set(0, 0, 0);
    this.speed = Math.max(this.diff.start, this.speed * 0.85);
    this.sparkles.emit(this.x, 1, 0, [0xffd23f, 0xff8fc8, 0x7ad7ff], 30, 4, 4);
    this.clock.getDelta();
  }

  setMenuMode(on) {
    this.menuMode = on;
    if (on) this.setChapter(0);
    if (on) for (const o of this.objects) { o.active = false; o.mesh.visible = false; }
    this.player.rotation.set(0, 0, 0);
  }

  setPaused(p) { this.paused = p; this.clock.getDelta(); }

  #die() {
    this.running = false;
    this.hooks.onDeath?.({ distance: Math.floor(this.distance), coins: this.coins });
  }

  #tick() {
    const dt = Math.min(this.clock.getDelta(), 1 / 20);
    this.time += dt;
    if (this.running && !this.paused) this.#update(dt);
    else if (!this.running) this.#idle(dt);
    this.sparkles.update(this.paused ? 0 : dt, 0);

    // automatyczne obniżenie jakości na słabych telefonach
    if (this.running && !this.paused && !this.perf.done && this.quality === 'high') {
      this.perf.t += dt; this.perf.n++;
      if (this.perf.t > 4) {
        this.perf.done = true;
        if (this.perf.n / this.perf.t < 40) { this.setQuality('low'); this.hooks.onAutoQuality?.('low'); }
      }
    }

    // kamera: w menu przy bohaterze, w grze – za nim, z delikatnym przechyłem
    const px = this.player.position.x;
    if (this.menuMode) { this.camPos.set(0, 1.3, 6.4); this.camTarget.set(0, 0.2, 0); }
    else { this.camPos.set(px * 0.55, 3.6 + this.player.position.y * 0.25, this.camZ); this.camTarget.set(px * 0.4, 1.3, -6); }
    const k = 1 - Math.exp(-dt * (this.menuMode ? 3 : 7));
    this.camera.position.lerp(this.camPos, k);
    this.camLook.lerp(this.camTarget, k);
    if (this.shake > 0) {
      this.shake = Math.max(0, this.shake - dt);
      this.camera.position.x += (Math.random() - 0.5) * this.shake;
      this.camera.position.y += (Math.random() - 0.5) * this.shake;
    }
    this.camera.lookAt(this.camLook);
    if (!this.menuMode && this.running) this.camera.rotateZ((px - LANES[this.lane]) * 0.025);

    if (this.composer) this.composer.render();
    else this.renderer.render(this.scene, this.camera);
  }

  #idle(dt) {
    const v = this.menuMode ? 5 * dt : 0;
    this.#worldTick(dt, v);
    this.ball.rotation.x -= v / BALL_R;
    if (!this.menuMode) return; // ekran końca gry – kula leży nieruchomo
    this.player.position.set(0, BALL_R + Math.abs(Math.sin(this.time * 3)) * 0.12, 0);
    this.ball.scale.setScalar(1);
    this.ball.visible = true;
    this.blob.position.set(0, 0.02, 0);
    this.charFacing += (0 - this.charFacing) * Math.min(1, dt * 4);
    if (this.character) { this.character.visible = true; this.character.rotation.y = this.charFacing; animateCharacter(this.character, this.time); }
    if (rnd() < dt * 8) this.sparkles.emit((rnd() - 0.5) * 2, 0.3 + rnd() * 1.5, (rnd() - 0.5), this.trailColor, 1, 0.5, 0.6, 0.8, 0);
  }

  #update(dt) {
    // efekt spowolnienia po zderzeniu
    if (this.dying > 0) {
      this.dying -= dt;
      const sdt = dt * 0.18;
      const v = this.speed * sdt;
      this.#worldTick(sdt, v);
      this.player.rotation.x -= dt * 3;
      this.player.position.y += dt * 0.6;
      if (this.dying <= 0) this.#die();
      return;
    }

    this.speed = Math.min(this.diff.max, this.speed + dt * this.diff.accel);
    const v = this.speed * dt;
    this.distance += v;
    this.hooks.onScore?.(Math.floor(this.distance), this.coins);

    this.nextRow -= v;
    if (this.nextRow <= 0) {
      this.#spawnRow();
      this.nextRow = Math.max(9, 11 + rnd() * 7 + this.speed * 0.12 + this.diff.gap);
    }

    // ruch gracza (płynne przejście między pasami)
    const tx = LANES[this.lane];
    this.x += (tx - this.x) * (1 - Math.exp(-dt * 14));
    const wasAir = this.y > 0;
    this.vy -= GRAVITY * dt;
    this.y = Math.max(0, this.y + this.vy * dt);
    if (this.y === 0) {
      if (wasAir && this.vy < -3) { this.squash = 1; this.sparkles.emit(this.x, 0.1, 0.2, 0xffffff, 8, 2.5, 1, 2.2, 4); }
      this.vy = 0;
    }
    this.squash += (0 - this.squash) * (1 - Math.exp(-dt * 10));
    const sq = this.squash;
    this.ball.scale.set(1 + sq * 0.22, 1 - sq * 0.25, 1 + sq * 0.22);
    this.player.position.set(this.x, BALL_R + this.y - sq * BALL_R * 0.25, 0);
    this.charHolder.position.y = BALL_R - 0.03 - sq * BALL_R * 0.25;
    this.blob.position.set(this.x, 0.02, 0);
    this.blob.scale.setScalar(Math.max(0.4, 1 - this.y * 0.25));
    this.ball.rotation.x -= v / BALL_R;
    this.ball.rotation.z = (this.x - tx) * 0.4;
    this.charFacing += (Math.PI - this.charFacing) * Math.min(1, dt * 6);
    if (this.character) {
      animateCharacter(this.character, this.time, { running: true, air: this.y > 0.15, lean: (this.x - tx) * 0.35 });
      this.character.rotation.y = this.charFacing;
    }

    // rozdziały historii
    const next = CHAPTERS[this.chapterIdx + 1];
    if (next && this.distance >= next.at) {
      this.setChapter(this.chapterIdx + 1);
      this.hooks.onChapter?.(this.chapterIdx);
    }

    // power-upy
    this.magnet = Math.max(0, this.magnet - dt);
    this.shield = Math.max(0, this.shield - dt);
    this.invuln = Math.max(0, this.invuln - dt);
    this.shieldMesh.visible = this.shield > 0 && (this.shield > 2 || Math.sin(this.time * 20) > 0);
    this.shieldMesh.rotation.y += dt * 2;
    const blink = this.invuln <= 0 || Math.sin(this.time * 30) > 0;
    this.ball.visible = blink;
    if (this.character) this.character.visible = blink;
    this.hooks.onPower?.(this.magnet / this.magnetTime, this.shield / this.shieldTime);

    this.#worldTick(dt, v);

    // iskierkowy ślad kuli
    if (rnd() < 0.7) this.sparkles.emit(this.x + (rnd() - 0.5) * 0.4, 0.15 + this.y + rnd() * 0.3, 0.45, this.trailColor, 1, 0.4, 0.3, 2.4, 0);
    this.sparkles.update(0, v); // przesunięcie iskierek razem ze światem

    // obiekty i kolizje
    const ppos = this.player.position;
    for (const o of this.objects) {
      if (!o.active) continue;
      const m = o.mesh;
      m.position.z += v;

      if (o.type === 'coin') {
        m.rotation.y += dt * 4;
        if (this.magnet > 0 && m.position.z > -22 && m.position.z < 2) o.magnetized = true;
        if (o.magnetized) m.position.lerp(ppos, 1 - Math.exp(-dt * 10));
        if (m.position.distanceToSquared(ppos) < 0.9) {
          o.active = false; m.visible = false;
          this.coins += this.coinValue;
          this.sparkles.emit(m.position.x, m.position.y, m.position.z, [0xffd23f, 0xfff3b0, 0xffffff], 7, 2.2, 2.2, 2.6, 5);
          this.hooks.onCoin?.(this.coins);
          continue;
        }
      } else if (o.type === 'magnet' || o.type === 'shield') {
        m.rotation.y += dt * 3;
        m.position.y = 0.9 + Math.sin(this.time * 4) * 0.15;
        if (m.position.distanceToSquared(ppos) < 1.2) {
          o.active = false; m.visible = false;
          if (o.type === 'magnet') this.magnet = this.magnetTime;
          else this.shield = this.shieldTime;
          this.sparkles.emit(m.position.x, m.position.y, m.position.z, o.type === 'magnet' ? [0xff3b5c, 0xffffff] : [0x7ad7ff, 0xffffff, 0xff8fc8], 18, 3.5, 3);
          this.hooks.onPickup?.(o.type);
          continue;
        }
      } else {
        const depth = o.type === 'wall' ? 0.6 : 0.15;
        const hitZ = Math.abs(m.position.z) < depth + BALL_R * 0.8;
        const hitX = Math.abs(m.position.x - this.x) < 0.9 + BALL_R * 0.6;
        const hitY = o.type === 'wall' || this.y < 0.6;
        if (hitZ && hitX && hitY && this.invuln <= 0) {
          if (this.shield > 0) {
            this.shield = 0;
            this.invuln = 0.6;
            o.active = false; m.visible = false;
            this.shake = 0.25;
            this.sparkles.emit(m.position.x, 1, 0, [0x7ad7ff, 0xffffff, 0xff8fc8, 0xffd23f], 30, 5, 4);
            this.hooks.onShieldBreak?.();
          } else {
            // zderzenie: gwiazdki, wstrząs i spowolnienie
            this.dying = 0.7;
            this.shake = 0.6;
            this.sparkles.emit(this.x, 0.8, 0, [0xffd23f, 0xff6b9a, 0x7ad7ff, 0xffffff], 40, 5, 5, 1.2, 4);
            this.hooks.onCrash?.();
            return;
          }
        }
      }
      if (m.position.z > DESPAWN_Z) { o.active = false; m.visible = false; }
    }

    const fov = 62 + (this.speed - this.diff.start) * 0.35;
    if (Math.abs(this.camera.fov - fov) > 0.05) { this.camera.fov = fov; this.camera.updateProjectionMatrix(); }
  }

  setQuality(q) {
    this.quality = q;
    const dpr = Math.min(devicePixelRatio || 1, q === 'high' ? 2 : 1.25);
    this.renderer.setPixelRatio(dpr);
    this.renderer.shadowMap.enabled = q === 'high';
    this.scene.traverse((o) => { if (o.material) o.material.needsUpdate = true; });
    if (q === 'high') {
      if (!this.composer) {
        this.composer = new EffectComposer(this.renderer);
        this.composer.addPass(new RenderPass(this.scene, this.camera));
        this.composer.addPass(new UnrealBloomPass(new THREE.Vector2(256, 256), 0.3, 0.4, 1.05));
        this.composer.addPass(new OutputPass());
      }
    } else {
      this.composer?.dispose();
      this.composer = null;
    }
    this.resize();
  }

  resize() {
    const w = innerWidth, h = innerHeight;
    this.renderer.setSize(w, h, false);
    this.composer?.setPixelRatio(this.renderer.getPixelRatio());
    this.composer?.setSize(w, h);
    this.camera.aspect = w / h;
    this.camZ = w / h < 0.7 ? 8.2 : 7;
    this.camera.updateProjectionMatrix();
  }
}

function shuffle(a) {
  for (let i = a.length - 1; i > 0; i--) { const j = (rnd() * (i + 1)) | 0; [a[i], a[j]] = [a[j], a[i]]; }
  return a;
}
