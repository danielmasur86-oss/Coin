// Proceduralne postacie 3D (low-poly) – bez zewnętrznych modeli, więc bez problemów z licencjami.
// Postać patrzy w stronę +Z, stopy w y = 0, wzrost ok. 1.1 jednostki.
import * as THREE from 'three';

const mat = (color, o = {}) => new THREE.MeshStandardMaterial({ color, roughness: 0.55, metalness: 0.05, ...o });
const glow = (color, i = 1.6) => mat(color, { emissive: color, emissiveIntensity: i });

function mesh(geo, m, x = 0, y = 0, z = 0, parent) {
  const o = new THREE.Mesh(geo, m);
  o.position.set(x, y, z);
  o.castShadow = true;
  parent?.add(o);
  return o;
}

// Wspólny szkielet: nogi, tułów, ręce na „zawiasach”, głowa z oczami.
function humanoid({ skin = 0xffcc9e, shirt, pants, shoes = 0x222222, eyes = 0x2a1a0a, eyeWhite = true, headR = 0.2 }) {
  const g = new THREE.Group();
  const P = {};
  const mSkin = mat(skin), mShirt = mat(shirt), mPants = mat(pants), mShoe = mat(shoes);

  for (const s of [-1, 1]) {
    const hip = new THREE.Group();
    hip.position.set(s * 0.09, 0.34, 0);
    g.add(hip);
    mesh(new THREE.CapsuleGeometry(0.065, 0.2, 4, 8), mPants, 0, -0.16, 0, hip);
    mesh(new THREE.BoxGeometry(0.12, 0.07, 0.19), mShoe, 0, -0.31, 0.03, hip);
    P[s < 0 ? 'legL' : 'legR'] = hip;
  }
  P.torso = mesh(new THREE.CapsuleGeometry(0.16, 0.2, 4, 12), mShirt, 0, 0.52, 0, g);
  P.torso.scale.set(1, 1, 0.8);
  for (const s of [-1, 1]) {
    const sh = new THREE.Group();
    sh.position.set(s * 0.21, 0.64, 0);
    sh.rotation.z = s * 0.25;
    g.add(sh);
    mesh(new THREE.CapsuleGeometry(0.05, 0.2, 4, 8), mShirt, 0, -0.13, 0, sh);
    mesh(new THREE.SphereGeometry(0.055, 10, 8), mSkin, 0, -0.29, 0, sh);
    P[s < 0 ? 'armL' : 'armR'] = sh;
  }
  const head = new THREE.Group();
  head.position.y = 0.74 + headR;
  g.add(head);
  P.head = head;
  P.headMesh = mesh(new THREE.SphereGeometry(headR, 20, 16), mSkin, 0, 0, 0, head);
  if (eyeWhite) {
    for (const s of [-1, 1]) {
      mesh(new THREE.SphereGeometry(0.048, 10, 8), mat(0xffffff), s * 0.075, 0.03, headR * 0.82, head);
      mesh(new THREE.SphereGeometry(0.027, 8, 6), mat(eyes), s * 0.075, 0.03, headR * 0.82 + 0.035, head);
    }
  }
  g.userData = P;
  return { g, P, head, mSkin, mShirt };
}

function cape(color, parent) {
  const pivot = new THREE.Group();
  pivot.position.set(0, 0.7, -0.13);
  const c = mesh(new THREE.BoxGeometry(0.42, 0.55, 0.03), mat(color, { side: THREE.DoubleSide }), 0, -0.27, 0, pivot);
  c.castShadow = false;
  parent.add(pivot);
  return pivot;
}

const BUILDERS = {
  kuba() {
    const { g, P, head } = humanoid({ shirt: 0xe8323c, pants: 0x2c4f9e, shoes: 0xffffff });
    mesh(new THREE.SphereGeometry(0.205, 16, 10, 0, Math.PI * 2, 0, Math.PI / 2), mat(0xd62828), 0, 0.03, 0, head);
    mesh(new THREE.BoxGeometry(0.26, 0.025, 0.2), mat(0xd62828), 0, 0.06, -0.24, head); // daszek do tyłu
    const gog = mesh(new THREE.TorusGeometry(0.205, 0.03, 6, 24), mat(0x333333), 0, 0.13, 0, head);
    gog.rotation.x = Math.PI / 2 - 0.25;
    for (const s of [-1, 1]) mesh(new THREE.CylinderGeometry(0.06, 0.06, 0.05, 14), glow(0x46e0ff, 1), s * 0.08, 0.17, 0.16, head).rotation.x = 1.2;
    mesh(new THREE.BoxGeometry(0.2, 0.22, 0.1), mat(0xffb703), 0, 0.55, -0.15, g); // plecak
    return { g, P };
  },
  mila() {
    const { g, P, head } = humanoid({ skin: 0xf6c7a6, shirt: 0x7b2cbf, pants: 0x1b1b2f, shoes: 0xff4fa3, eyes: 0x3a0ca3 });
    const hair = mat(0xff4fa3);
    const cap = mesh(new THREE.SphereGeometry(0.215, 18, 12, 0, Math.PI * 2, 0, Math.PI * 0.62), hair, 0, 0.01, -0.01, head);
    cap.rotation.x = -0.3;
    const tail = new THREE.Group();
    tail.position.set(0, 0.12, -0.2);
    head.add(tail);
    [0.09, 0.08, 0.07, 0.055].forEach((r, i) => mesh(new THREE.SphereGeometry(r, 10, 8), hair, 0, -i * 0.09, -i * 0.05, tail));
    P.tail = tail;
    const band = mesh(new THREE.TorusGeometry(0.225, 0.022, 6, 24, Math.PI), mat(0x111111), 0, 0.02, 0, head);
    band.rotation.z = 0;
    for (const s of [-1, 1]) mesh(new THREE.CylinderGeometry(0.075, 0.075, 0.06, 16), glow(0x22e6ff, 1.2), s * 0.225, 0, 0, head).rotation.z = Math.PI / 2;
    return { g, P };
  },
  bit() {
    const g = new THREE.Group();
    const P = {};
    const metal = mat(0xb8c4d6, { metalness: 0.8, roughness: 0.3 });
    const dark = mat(0x2b3240, { metalness: 0.6, roughness: 0.4 });
    for (const s of [-1, 1]) {
      const hip = new THREE.Group(); hip.position.set(s * 0.1, 0.32, 0); g.add(hip);
      mesh(new THREE.CylinderGeometry(0.06, 0.07, 0.26, 10), dark, 0, -0.14, 0, hip);
      mesh(new THREE.BoxGeometry(0.14, 0.06, 0.2), metal, 0, -0.29, 0.03, hip);
      P[s < 0 ? 'legL' : 'legR'] = hip;
    }
    P.torso = mesh(new THREE.BoxGeometry(0.38, 0.34, 0.26), metal, 0, 0.5, 0, g);
    mesh(new THREE.CircleGeometry(0.07, 16), glow(0x26e07f, 2), 0, 0.52, 0.131, g);
    for (const s of [-1, 1]) {
      const sh = new THREE.Group(); sh.position.set(s * 0.24, 0.62, 0); sh.rotation.z = s * 0.2; g.add(sh);
      mesh(new THREE.CylinderGeometry(0.045, 0.045, 0.26, 8), dark, 0, -0.13, 0, sh);
      mesh(new THREE.SphereGeometry(0.06, 10, 8), metal, 0, -0.29, 0, sh);
      P[s < 0 ? 'armL' : 'armR'] = sh;
    }
    const head = new THREE.Group(); head.position.y = 0.88; g.add(head); P.head = head;
    mesh(new THREE.BoxGeometry(0.36, 0.28, 0.3), metal, 0, 0, 0, head);
    mesh(new THREE.BoxGeometry(0.3, 0.1, 0.02), mat(0x0a0a14), 0, 0.02, 0.152, head);
    for (const s of [-1, 1]) mesh(new THREE.BoxGeometry(0.07, 0.05, 0.02), glow(0x22e6ff, 3), s * 0.07, 0.02, 0.165, head);
    mesh(new THREE.CylinderGeometry(0.012, 0.012, 0.18, 6), dark, 0, 0.23, 0, head);
    P.antenna = mesh(new THREE.SphereGeometry(0.045, 10, 8), glow(0xff2a55, 3), 0, 0.33, 0, head);
    g.userData = P;
    return { g, P };
  },
  mruczek() {
    const fur = 0xff9f1c;
    const { g, P, head } = humanoid({ skin: fur, shirt: 0x2ec4b6, pants: 0xff9f1c, shoes: 0xffffff, eyes: 0x0b6e4f });
    for (const s of [-1, 1]) {
      const ear = mesh(new THREE.ConeGeometry(0.075, 0.16, 4), mat(fur), s * 0.12, 0.2, 0, head);
      ear.rotation.z = -s * 0.35;
      mesh(new THREE.ConeGeometry(0.04, 0.09, 4), mat(0xffc8dd), s * 0.115, 0.19, 0.03, head).rotation.z = -s * 0.35;
    }
    mesh(new THREE.SphereGeometry(0.03, 8, 6), mat(0xff6b9a), 0, -0.03, 0.2, head);
    mesh(new THREE.SphereGeometry(0.1, 12, 8), mat(0xfff1d6), 0, -0.07, 0.13, head).scale.set(1.2, 0.7, 0.8);
    const tail = new THREE.Group(); tail.position.set(0, 0.36, -0.12); g.add(tail); P.tail = tail;
    for (let i = 0; i < 7; i++) mesh(new THREE.SphereGeometry(0.045, 8, 6), mat(i > 4 ? 0xffffff : fur), 0, i * 0.06, -0.05 - Math.sin(i * 0.4) * 0.12, tail);
    return { g, P };
  },
  astro() {
    const { g, P, head } = humanoid({ shirt: 0xf1f1f1, pants: 0xf1f1f1, shoes: 0x555555, skin: 0xf2c6a0 });
    const helm = mesh(new THREE.SphereGeometry(0.27, 24, 18), new THREE.MeshPhysicalMaterial({ color: 0x9fd8ff, transparent: true, opacity: 0.3, roughness: 0.05, metalness: 0.1 }), 0, 0, 0, head);
    helm.castShadow = false;
    const ring = mesh(new THREE.TorusGeometry(0.2, 0.045, 8, 20), mat(0xff7b00), 0, -0.2, 0, head);
    ring.rotation.x = Math.PI / 2;
    const pack = mesh(new THREE.BoxGeometry(0.3, 0.36, 0.14), mat(0xdedede), 0, 0.52, -0.17, g);
    for (const s of [-1, 1]) mesh(new THREE.CylinderGeometry(0.035, 0.05, 0.08, 10), glow(0x22e6ff, 3), s * 0.08, -0.2, 0, pack);
    mesh(new THREE.BoxGeometry(0.12, 0.08, 0.02), glow(0xff2a55, 1.5), 0.05, 0.56, 0.13, g);
    return { g, P };
  },
  cien() {
    const { g, P, head } = humanoid({ skin: 0x15151c, shirt: 0x15151c, pants: 0x15151c, shoes: 0x0a0a0a, eyeWhite: false });
    mesh(new THREE.BoxGeometry(0.3, 0.08, 0.1), mat(0xf2c6a0), 0, 0.03, 0.15, head);
    for (const s of [-1, 1]) mesh(new THREE.SphereGeometry(0.025, 8, 6), mat(0x111111), s * 0.065, 0.03, 0.2, head);
    const band = mesh(new THREE.TorusGeometry(0.205, 0.035, 6, 24), mat(0xe63946), 0, 0.11, 0, head);
    band.rotation.x = Math.PI / 2;
    const ribbon = new THREE.Group(); ribbon.position.set(0, 0.11, -0.2); head.add(ribbon); P.ribbon = ribbon;
    for (const s of [-1, 1]) mesh(new THREE.BoxGeometry(0.05, 0.02, 0.32), mat(0xe63946), s * 0.03, 0, -0.16, ribbon).rotation.y = s * 0.2;
    const sword = mesh(new THREE.BoxGeometry(0.04, 0.5, 0.02), mat(0xcfd8e3, { metalness: 0.9, roughness: 0.2 }), 0.05, 0.55, -0.16, g);
    sword.rotation.z = 0.6;
    return { g, P };
  },
  iskra() {
    const { g, P, head } = humanoid({ skin: 0xf9d5b5, shirt: 0xffb703, pants: 0x9d0208, shoes: 0xffd60a, eyes: 0xd00000 });
    const flame = glow(0xff6d00, 2.2);
    for (let i = 0; i < 9; i++) {
      const a = (i / 9) * Math.PI * 2;
      const f = mesh(new THREE.ConeGeometry(0.07, 0.26 + (i % 3) * 0.06, 6), flame, Math.cos(a) * 0.13, 0.17, Math.sin(a) * 0.13 - 0.03, head);
      f.rotation.set(Math.sin(a) * -0.5, 0, Math.cos(a) * 0.5);
    }
    mesh(new THREE.ConeGeometry(0.13, 0.12, 5), glow(0xffd60a, 1.5), 0, 0.3, 0, head);
    P.cape = cape(0xd00000, g);
    return { g, P };
  },
  rycerz() {
    const gold = mat(0xffc928, { metalness: 0.95, roughness: 0.22 });
    const { g, P, head } = humanoid({ skin: 0xffc928, shirt: 0xffc928, pants: 0xc9a227, shoes: 0x8a6a00, eyeWhite: false });
    g.traverse((o) => { if (o.isMesh) o.material = gold; });
    mesh(new THREE.BoxGeometry(0.26, 0.04, 0.06), mat(0x111111), 0, 0.02, 0.19, head);
    const plume = mesh(new THREE.BoxGeometry(0.06, 0.18, 0.34), mat(0xd00000), 0, 0.24, -0.05, head);
    plume.rotation.x = 0.3;
    mesh(new THREE.CylinderGeometry(0.17, 0.17, 0.03, 6), gold, -0.27, 0.5, 0.06, g).rotation.z = Math.PI / 2;
    P.cape = cape(0x6a040f, g);
    return { g, P };
  },
  baron() {
    const { g, P, head } = humanoid({ skin: 0xb7b7c9, shirt: 0x3a3a4a, pants: 0x22222c, eyes: 0xff1a1a, shoes: 0x111111 });
    mesh(new THREE.CylinderGeometry(0.16, 0.16, 0.32, 20), mat(0x111116), 0, 0.3, 0, head);
    mesh(new THREE.CylinderGeometry(0.27, 0.27, 0.025, 24), mat(0x111116), 0, 0.15, 0, head);
    mesh(new THREE.CylinderGeometry(0.165, 0.165, 0.05, 20), mat(0x8a0000), 0, 0.18, 0, head);
    const mono = mesh(new THREE.TorusGeometry(0.06, 0.012, 6, 16), mat(0xffc928, { metalness: 1, roughness: 0.2 }), 0.075, 0.03, 0.21, head);
    mono.rotation.y = 0.1;
    for (const s of [-1, 1]) {
      const m = mesh(new THREE.CapsuleGeometry(0.025, 0.1, 4, 6), mat(0x222222), s * 0.06, -0.07, 0.19, head);
      m.rotation.z = s * 1.2;
    }
    P.cape = cape(0x4a0010, g);
    return { g, P };
  },
};

export function buildCharacter(id) {
  const { g, P } = (BUILDERS[id] || BUILDERS.kuba)();
  g.userData = { ...g.userData, ...P };
  return g;
}

// Animacja postaci stojącej na toczącej się kuli.
export function animateCharacter(c, t, { running = false, air = false, lean = 0 } = {}) {
  const P = c.userData;
  const w = running ? 12 : 3;
  const sw = Math.sin(t * w);
  if (P.legL) { P.legL.rotation.x = running ? sw * 0.6 : 0; P.legR.rotation.x = running ? -sw * 0.6 : 0; }
  if (P.armL) {
    if (air) { P.armL.rotation.set(0, 0, -2.6); P.armR.rotation.set(0, 0, 2.6); }
    else {
      P.armL.rotation.set(running ? -sw * 0.5 : Math.sin(t * 2) * 0.1, 0, -0.5 - (running ? 0.4 : 0));
      P.armR.rotation.set(running ? sw * 0.5 : -Math.sin(t * 2) * 0.1, 0, 0.5 + (running ? 0.4 : 0));
    }
  }
  if (P.head) P.head.rotation.z = -lean * 0.3;
  if (P.tail) P.tail.rotation.x = Math.sin(t * 6) * 0.2 - (running ? 0.4 : 0);
  if (P.tail) P.tail.rotation.z = Math.sin(t * 4) * 0.25;
  if (P.cape) P.cape.rotation.x = (running ? 0.7 : 0.1) + Math.sin(t * 14) * (running ? 0.12 : 0.03);
  if (P.ribbon) P.ribbon.rotation.x = (running ? 0.5 : -0.4) + Math.sin(t * 16) * 0.15;
  if (P.antenna) P.antenna.material.emissiveIntensity = 2 + Math.sin(t * 8) * 1.5;
  c.rotation.z = lean;
  c.position.y = running ? Math.abs(sw) * 0.03 : Math.sin(t * 2) * 0.015;
}

// Portrety do UI (renderowane raz, poza ekranem).
export function renderPortraits(ids) {
  const size = 256;
  const r = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
  r.setSize(size, size, false);
  r.toneMapping = THREE.ACESFilmicToneMapping;
  const scene = new THREE.Scene();
  scene.add(new THREE.HemisphereLight(0xffffff, 0x442266, 1.6));
  const d = new THREE.DirectionalLight(0xffffff, 2.2);
  d.position.set(1.5, 2, 3);
  scene.add(d);
  const cam = new THREE.PerspectiveCamera(30, 1, 0.1, 20);
  const out = {};
  for (const id of ids) {
    const c = buildCharacter(id);
    animateCharacter(c, 0.4);
    c.rotation.y = 0.35;
    scene.add(c);
    cam.position.set(0.25, 0.8, 2.6);
    cam.lookAt(0, 0.62, 0);
    r.render(scene, cam);
    out[id] = r.domElement.toDataURL('image/png');
    scene.remove(c);
    c.traverse((o) => { if (o.isMesh) { o.geometry.dispose(); o.material.dispose?.(); } });
  }
  r.dispose();
  r.forceContextLoss?.();
  return out;
}
