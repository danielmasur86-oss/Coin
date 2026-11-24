// Silnik gry 3D: nieskończony bieg po neonowej trasie (Three.js).
import * as THREE from 'three';
import { EffectComposer } from 'three/addons/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/addons/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/addons/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/addons/postprocessing/OutputPass.js';
import { SKINS } from './config.js';

const LANES = [-2.2, 0, 2.2];
const SPAWN_Z = -130;
const DESPAWN_Z = 12;
const BALL_R = 0.45;
const GRAVITY = 34;
const JUMP_V = 11.5;
const START_SPEED = 15;
const MAX_SPEED = 38;

export class Game {
  constructor(canvas, hooks) {
    this.hooks = hooks; // { onCoin, onDeath, onPower, onScore }
    this.canvas = canvas;
    this.renderer = new THREE.WebGLRenderer({ canvas, antialias: true, powerPreference: 'high-performance' });
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.1;

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0a0420);
    this.scene.fog = new THREE.Fog(0x0a0420, 40, 125);

    this.camera = new THREE.PerspectiveCamera(62, 1, 0.1, 300);
    this.camera.position.set(0, 3.6, 7.5);
    this.camLook = new THREE.Vector3(0, 1, -6);

    this.clock = { last: performance.now(), getDelta() { const n = performance.now(); const d = (n - this.last) / 1000; this.last = n; return d; } };
    this.running = false;
    this.paused = false;
    this.time = 0;

    this.#buildWorld();
    this.#buildPlayer();
    this.#buildPools();
    this.setQuality('high');
    this.resize();
    addEventListener('resize', () => this.resize());
    this.renderer.setAnimationLoop(() => this.#tick());
  }

  // ---------- świat ----------
  #buildWorld() {
    const s = this.scene;
    s.add(new THREE.HemisphereLight(0x8a7dff, 0x200a40, 1.1));
    const sun = new THREE.DirectionalLight(0xffffff, 2.2);
    sun.position.set(4, 12, 6);
    sun.castShadow = true;
    sun.shadow.mapSize.set(1024, 1024);
    Object.assign(sun.shadow.camera, { left: -6, right: 6, top: 6, bottom: -6, near: 1, far: 40 });
    sun.target.position.set(0, 0, -2);
    s.add(sun, sun.target);

    // Trasa z przewijaną teksturą pasów
    const tex = this.#trackTexture();
    tex.wrapS = tex.wrapT = THREE.RepeatWrapping;
    tex.repeat.set(1, 30);
    tex.anisotropy = 4;
    this.trackTex = tex;
    const track = new THREE.Mesh(
      new THREE.PlaneGeometry(7.2, 260),
      new THREE.MeshStandardMaterial({ map: tex, roughness: 0.35, metalness: 0.4, emissiveMap: tex, emissive: 0xffffff, emissiveIntensity: 0.35 })
    );
    track.rotation.x = -Math.PI / 2;
    track.position.z = -115;
    track.receiveShadow = true;
    s.add(track);

    // Neonowe krawędzie
    for (const x of [-3.7, 3.7]) {
      const rail = new THREE.Mesh(
        new THREE.BoxGeometry(0.15, 0.15, 260),
        new THREE.MeshBasicMaterial({ color: x < 0 ? 0xff2fd6 : 0x22e6ff })
      );
      rail.position.set(x, 0.08, -115);
      s.add(rail);
    }

    // Wieżowce po bokach (przewijane)
    this.buildings = [];
    const bGeo = new THREE.BoxGeometry(1, 1, 1);
    const winTex = this.#windowTexture();
    for (let i = 0; i < 44; i++) {
      const side = i % 2 ? 1 : -1;
      const h = 4 + Math.random() * 18;
      const hue = Math.random() < 0.5 ? 0xff2fd6 : 0x22e6ff;
      const m = new THREE.Mesh(bGeo, new THREE.MeshStandardMaterial({
        color: 0x140b2e, roughness: 0.8, emissive: hue, emissiveMap: winTex, emissiveIntensity: 0.9,
      }));
      m.scale.set(2 + Math.random() * 3, h, 2 + Math.random() * 3);
      m.position.set(side * (7 + Math.random() * 8), h / 2 - 1, SPAWN_Z + (i / 44) * 140);
      s.add(m);
      this.buildings.push(m);
    }

    // Gwiazdy
    const starGeo = new THREE.BufferGeometry();
    const pts = [];
    for (let i = 0; i < 700; i++) pts.push((Math.random() - 0.5) * 300, 10 + Math.random() * 90, -60 - Math.random() * 180);
    starGeo.setAttribute('position', new THREE.Float32BufferAttribute(pts, 3));
    s.add(new THREE.Points(starGeo, new THREE.PointsMaterial({ color: 0xffffff, size: 0.6, fog: false })));

    // Słońce w stylu synthwave
    const sunDisc = new THREE.Mesh(
      new THREE.CircleGeometry(28, 48),
      new THREE.MeshBasicMaterial({ map: this.#sunTexture(), fog: false, transparent: true })
    );
    sunDisc.position.set(0, 18, -200);
    s.add(sunDisc);
  }

  #trackTexture() {
    const c = document.createElement('canvas');
    c.width = 256; c.height = 256;
    const g = c.getContext('2d');
    g.fillStyle = '#120a2a'; g.fillRect(0, 0, 256, 256);
    g.strokeStyle = '#3d2a7a'; g.lineWidth = 2;
    for (let y = 0; y <= 256; y += 64) { g.beginPath(); g.moveTo(0, y); g.lineTo(256, y); g.stroke(); }
    g.fillStyle = '#b14bff';
    for (const x of [256 / 3, (256 * 2) / 3]) g.fillRect(x - 3, 0, 6, 150);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }

  #windowTexture() {
    const c = document.createElement('canvas');
    c.width = 64; c.height = 128;
    const g = c.getContext('2d');
    g.fillStyle = '#000'; g.fillRect(0, 0, 64, 128);
    for (let y = 4; y < 128; y += 10) for (let x = 4; x < 64; x += 12) {
      if (Math.random() < 0.45) { g.fillStyle = `rgba(255,255,255,${0.3 + Math.random() * 0.7})`; g.fillRect(x, y, 6, 5); }
    }
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }

  #sunTexture() {
    const c = document.createElement('canvas');
    c.width = c.height = 256;
    const g = c.getContext('2d');
    const grad = g.createLinearGradient(0, 0, 0, 256);
    grad.addColorStop(0, '#ffe45e'); grad.addColorStop(0.55, '#ff4fa3'); grad.addColorStop(1, '#7a1cff');
    g.fillStyle = grad;
    g.beginPath(); g.arc(128, 128, 126, 0, Math.PI * 2); g.fill();
    g.globalCompositeOperation = 'destination-out';
    for (let i = 0; i < 7; i++) g.fillRect(0, 150 + i * 15, 256, 3 + i * 1.3);
    const t = new THREE.CanvasTexture(c);
    t.colorSpace = THREE.SRGBColorSpace;
    return t;
  }

  // ---------- gracz ----------
  #buildPlayer() {
    this.player = new THREE.Group();
    this.ballMat = new THREE.MeshStandardMaterial();
    this.ball = new THREE.Mesh(new THREE.IcosahedronGeometry(BALL_R, 4), this.ballMat);
    this.ball.castShadow = true;
    // wzór na kuli, żeby było widać toczenie
    const ring = new THREE.Mesh(new THREE.TorusGeometry(BALL_R * 1.01, 0.04, 8, 32), new THREE.MeshBasicMaterial({ color: 0xffffff }));
    ring.rotation.y = Math.PI / 2;
    this.ball.add(ring);
    this.ballRing = ring;
    this.player.add(this.ball);

    this.shieldMesh = new THREE.Mesh(
      new THREE.IcosahedronGeometry(BALL_R * 1.7, 2),
      new THREE.MeshBasicMaterial({ color: 0x4dfcff, wireframe: true, transparent: true, opacity: 0.6 })
    );
    this.shieldMesh.visible = false;
    this.player.add(this.shieldMesh);

    this.playerLight = new THREE.PointLight(0xffd75e, 3, 5);
    this.playerLight.position.y = 0.5;
    this.player.add(this.playerLight);
    this.scene.add(this.player);

    // Ślad (trail) z cząsteczek
    this.trail = [];
    const tGeo = new THREE.SphereGeometry(0.16, 6, 6);
    this.trailMat = new THREE.MeshBasicMaterial({ color: 0xffd75e, transparent: true });
    for (let i = 0; i < 18; i++) {
      const m = new THREE.Mesh(tGeo, this.trailMat.clone());
      m.visible = false;
      this.scene.add(m);
      this.trail.push({ m, life: 0 });
    }
    this.trailIdx = 0;
    this.setSkin('classic');
  }

  setSkin(id) {
    const sk = SKINS.find((s) => s.id === id) || SKINS[0];
    this.ballMat.color.setHex(sk.color);
    this.ballMat.emissive.setHex(sk.emissive);
    this.ballMat.emissiveIntensity = 0.35;
    this.ballMat.metalness = sk.metal;
    this.ballMat.roughness = sk.rough;
    this.ballRing.material.color.setHex(sk.trail);
    this.playerLight.color.setHex(sk.trail);
    for (const t of this.trail) t.m.material.color.setHex(sk.trail);
  }

  // ---------- pule obiektów ----------
  #buildPools() {
    this.objects = [];
    const coinGeo = new THREE.CylinderGeometry(0.38, 0.38, 0.09, 24);
    coinGeo.rotateX(Math.PI / 2);
    this.mats = {
      coin: new THREE.MeshStandardMaterial({ color: 0xffc928, metalness: 1, roughness: 0.25, emissive: 0xb37400, emissiveIntensity: 0.6 }),
      barrier: new THREE.MeshStandardMaterial({ color: 0xff2a55, emissive: 0xff0040, emissiveIntensity: 0.9, roughness: 0.4 }),
      wall: new THREE.MeshStandardMaterial({ color: 0x2a1660, emissive: 0x7a2bff, emissiveIntensity: 0.25, roughness: 0.5, metalness: 0.3 }),
      wallEdge: new THREE.MeshBasicMaterial({ color: 0xb46bff }),
      magnet: new THREE.MeshStandardMaterial({ color: 0x3d7bff, emissive: 0x1d5bff, emissiveIntensity: 1.5 }),
      shield: new THREE.MeshStandardMaterial({ color: 0x4dfcff, emissive: 0x00d9ff, emissiveIntensity: 1.5 }),
    };
    this.geos = {
      coin: coinGeo,
      barrier: new THREE.BoxGeometry(1.8, 0.7, 0.3),
      wall: new THREE.BoxGeometry(1.8, 2.4, 1.2),
      magnet: new THREE.TorusGeometry(0.35, 0.12, 10, 20, Math.PI * 1.3),
      shield: new THREE.OctahedronGeometry(0.42),
    };
    this.wallEdges = new THREE.EdgesGeometry(this.geos.wall);
    this.pool = {};
  }

  #obtain(type) {
    const list = (this.pool[type] ||= []);
    let o = list.find((x) => !x.active);
    if (!o) {
      const mesh = new THREE.Mesh(this.geos[type], this.mats[type]);
      mesh.castShadow = type !== 'coin';
      if (type === 'wall') mesh.add(new THREE.LineSegments(this.wallEdges, this.mats.wallEdge));
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
    const d = Math.min(1, this.distance / 2500); // trudność 0..1
    const lanes = [0, 1, 2];
    const kinds = ['none', 'none', 'none'];
    const nBlocked = Math.random() < 0.25 - d * 0.2 ? 0 : Math.random() < 0.45 + d * 0.4 ? 2 : 1;
    shuffle(lanes);
    for (let i = 0; i < nBlocked; i++) kinds[lanes[i]] = Math.random() < 0.55 ? 'wall' : 'barrier';
    // zawsze zostaw przynajmniej jeden pas bez ściany
    if (kinds.every((k) => k === 'wall')) kinds[lanes[2]] = 'none';

    kinds.forEach((k, li) => {
      if (k === 'none') return;
      const o = this.#obtain(k);
      o.lane = li;
      o.mesh.position.set(LANES[li], k === 'wall' ? 1.2 : 0.35, z);
      o.mesh.rotation.set(0, 0, 0);
    });

    // monety
    const free = [0, 1, 2].filter((i) => kinds[i] !== 'wall');
    const cl = free[(Math.random() * free.length) | 0];
    if (kinds[cl] === 'barrier') {
      for (let i = 0; i < 5; i++) {
        const c = this.#obtain('coin');
        const t = (i - 2) / 2;
        c.mesh.position.set(LANES[cl], 0.55 + 1.6 * (1 - t * t), z + (i - 2) * 1.7);
      }
    } else if (Math.random() < 0.85) {
      const n = 4 + ((Math.random() * 3) | 0);
      for (let i = 0; i < n; i++) {
        const c = this.#obtain('coin');
        c.mesh.position.set(LANES[cl], 0.55, z + 3 + i * 1.6);
      }
    }

    // power-upy
    if (Math.random() < 0.06) {
      const pl = free.find((i) => i !== cl) ?? cl;
      if (kinds[pl] === 'none') {
        const p = this.#obtain(Math.random() < 0.5 ? 'magnet' : 'shield');
        p.mesh.position.set(LANES[pl], 0.8, z - 4);
      }
    }
  }

  // ---------- sterowanie ----------
  move(dir) {
    if (!this.running || this.paused) return false;
    const n = Math.max(0, Math.min(2, this.lane + dir));
    if (n === this.lane) return false;
    this.lane = n;
    return true;
  }

  jump() {
    if (!this.running || this.paused || this.y > 0.01) return false;
    this.vy = JUMP_V;
    return true;
  }

  drop() { if (this.y > 0.01) this.vy = -JUMP_V * 1.4; }

  // ---------- cykl gry ----------
  start({ skin, magnetTime, shieldTime, coinValue }) {
    for (const o of this.objects) { o.active = false; o.mesh.visible = false; }
    Object.assign(this, {
      running: true, paused: false, lane: 1, x: 0, y: 0, vy: 0,
      speed: START_SPEED, distance: 0, coins: 0, nextRow: 0,
      magnet: 0, shield: 0, invuln: 0, magnetTime, shieldTime, coinValue, shake: 0,
    });
    this.setSkin(skin);
    this.player.position.set(0, BALL_R, 0);
    this.clock.getDelta();
  }

  revive() {
    // usuń przeszkody w pobliżu i daj chwilę nietykalności
    for (const o of this.objects) if (o.active && o.type !== 'coin' && o.mesh.position.z > -40) { o.active = false; o.mesh.visible = false; }
    this.running = true;
    this.paused = false;
    this.invuln = 2;
    this.speed = Math.max(START_SPEED, this.speed * 0.85);
    this.clock.getDelta();
  }

  setPaused(p) { this.paused = p; this.clock.getDelta(); }

  #die() {
    this.running = false;
    this.shake = 0.5;
    this.hooks.onDeath?.({ distance: Math.floor(this.distance), coins: this.coins });
  }

  #tick() {
    const dt = Math.min(this.clock.getDelta(), 1 / 20);
    this.time += dt;
    if (this.running && !this.paused) this.#update(dt);
    else if (!this.running) this.#idle(dt);

    // kamera
    const px = this.player.position.x;
    this.camera.position.x += (px * 0.55 - this.camera.position.x) * Math.min(1, dt * 6);
    this.camLook.x = px * 0.4;
    if (this.shake > 0) {
      this.shake = Math.max(0, this.shake - dt);
      this.camera.position.x += (Math.random() - 0.5) * this.shake;
      this.camera.position.y = 3.6 + (Math.random() - 0.5) * this.shake;
    }
    this.camera.lookAt(this.camLook);

    if (this.composer) this.composer.render();
    else this.renderer.render(this.scene, this.camera);
  }

  #idle(dt) {
    // animacja tła w menu
    const v = 6 * dt;
    this.trackTex.offset.y += v / 8.6;
    for (const b of this.buildings) { b.position.z += v; if (b.position.z > DESPAWN_Z) b.position.z -= 140; }
    this.ball.rotation.x -= v / BALL_R;
    this.ball.rotation.y += dt * 0.5;
    this.player.position.y = BALL_R + Math.abs(Math.sin(this.time * 3)) * 0.15;
    for (const o of this.objects) if (o.active && o.type === 'coin') o.mesh.rotation.y += dt * 3;
  }

  #update(dt) {
    this.speed = Math.min(MAX_SPEED, this.speed + dt * 0.32);
    const v = this.speed * dt;
    this.distance += v;
    this.hooks.onScore?.(Math.floor(this.distance), this.coins);

    // spawn rzędów co określony dystans
    this.nextRow -= v;
    if (this.nextRow <= 0) {
      this.#spawnRow();
      this.nextRow = 11 + Math.random() * 7 + this.speed * 0.12;
    }

    // ruch gracza
    const tx = LANES[this.lane];
    this.x += (tx - this.x) * Math.min(1, dt * 16);
    this.vy -= GRAVITY * dt;
    this.y = Math.max(0, this.y + this.vy * dt);
    if (this.y === 0) this.vy = 0;
    this.player.position.set(this.x, BALL_R + this.y, 0);
    this.ball.rotation.x -= v / BALL_R;
    this.ball.rotation.z = (this.x - tx) * 0.4;

    // power-upy
    this.magnet = Math.max(0, this.magnet - dt);
    this.shield = Math.max(0, this.shield - dt);
    this.invuln = Math.max(0, this.invuln - dt);
    this.shieldMesh.visible = this.shield > 0 && (this.shield > 2 || Math.sin(this.time * 20) > 0);
    this.shieldMesh.rotation.y += dt * 2;
    this.ball.visible = this.invuln <= 0 || Math.sin(this.time * 30) > 0;
    this.hooks.onPower?.(this.magnet / this.magnetTime, this.shield / this.shieldTime);

    // świat
    this.trackTex.offset.y += v / 8.6;
    for (const b of this.buildings) { b.position.z += v; if (b.position.z > DESPAWN_Z) b.position.z -= 140; }

    // ślad
    const t = this.trail[this.trailIdx++ % this.trail.length];
    t.life = 1; t.m.visible = true;
    t.m.position.set(this.x + (Math.random() - 0.5) * 0.2, BALL_R * 0.6 + this.y, 0.3);
    for (const p of this.trail) {
      if (p.life <= 0) continue;
      p.life -= dt * 2.6;
      p.m.position.z += v;
      p.m.scale.setScalar(Math.max(0.01, p.life));
      p.m.material.opacity = p.life;
      if (p.life <= 0) p.m.visible = false;
    }

    // obiekty i kolizje
    const ppos = this.player.position;
    for (const o of this.objects) {
      if (!o.active) continue;
      const m = o.mesh;
      m.position.z += v;

      if (o.type === 'coin') {
        m.rotation.y += dt * 4;
        if (this.magnet > 0 && m.position.z > -22 && m.position.z < 2) o.magnetized = true;
        if (o.magnetized) {
          m.position.lerp(ppos, Math.min(1, dt * 10));
        }
        if (m.position.distanceToSquared(ppos) < 0.9) {
          o.active = false; m.visible = false;
          this.coins += this.coinValue;
          this.hooks.onCoin?.(this.coins);
          continue;
        }
      } else if (o.type === 'magnet' || o.type === 'shield') {
        m.rotation.y += dt * 3;
        m.position.y = 0.8 + Math.sin(this.time * 4) * 0.15;
        if (m.position.distanceToSquared(ppos) < 1.2) {
          o.active = false; m.visible = false;
          if (o.type === 'magnet') this.magnet = this.magnetTime;
          else this.shield = this.shieldTime;
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
            this.hooks.onShieldBreak?.();
          } else {
            this.#die();
            return;
          }
        }
      }
      if (m.position.z > DESPAWN_Z) { o.active = false; m.visible = false; }
    }

    // lekkie przybliżanie FOV przy dużej prędkości
    const fov = 62 + (this.speed - START_SPEED) * 0.35;
    if (Math.abs(this.camera.fov - fov) > 0.05) { this.camera.fov = fov; this.camera.updateProjectionMatrix(); }
  }

  setQuality(q) {
    this.quality = q;
    const dpr = Math.min(devicePixelRatio || 1, q === 'high' ? 2 : 1.25);
    this.renderer.setPixelRatio(dpr);
    this.renderer.shadowMap.enabled = q === 'high';
    if (q === 'high') {
      this.composer = new EffectComposer(this.renderer);
      this.composer.addPass(new RenderPass(this.scene, this.camera));
      this.bloom = new UnrealBloomPass(new THREE.Vector2(256, 256), 0.6, 0.45, 0.72);
      this.composer.addPass(this.bloom);
      this.composer.addPass(new OutputPass());
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
    // na wąskich ekranach (telefon w pionie) cofamy kamerę, żeby widać było 3 pasy
    this.camera.position.z = w / h < 0.7 ? 8.2 : 7;
    this.camera.updateProjectionMatrix();
  }
}

function shuffle(a) {
  for (let i = a.length - 1; i > 0; i--) { const j = (Math.random() * (i + 1)) | 0; [a[i], a[j]] = [a[j], a[i]]; }
  return a;
}
