// Bajkowe postacie 3D w stylu „chibi” (duże głowy, rumieńce, uśmiechy).
// Wszystko budowane w kodzie – bez zewnętrznych modeli i licencji.
// Postać patrzy w stronę +Z, stopy w y = 0, wzrost ok. 1.15 jednostki.
import * as THREE from 'three';

const matCache = new Map();
const mat = (color, o = {}) => {
  const key = color + JSON.stringify(o);
  if (matCache.has(key)) return matCache.get(key);
  const m = new THREE.MeshStandardMaterial({ color, roughness: 0.6, metalness: 0, ...o });
  matCache.set(key, m);
  return m;
};
const glow = (color, i = 1.4) => mat(color, { emissive: color, emissiveIntensity: i, roughness: 0.4 });

function mesh(geo, m, x = 0, y = 0, z = 0, parent) {
  const o = new THREE.Mesh(geo, m);
  o.position.set(x, y, z);
  o.castShadow = true;
  parent?.add(o);
  return o;
}

// Wspólny „chibi” szkielet.
function chibi({ skin = 0xffd6b8, shirt, pants, shoes = 0x6b3e26, eyes = 0x2b1a12, headR = 0.25, face = true, belly = null }) {
  const g = new THREE.Group();
  const P = {};
  const mSkin = mat(skin), mShirt = mat(shirt), mPants = mat(pants), mShoe = mat(shoes);

  for (const s of [-1, 1]) {
    const hip = new THREE.Group();
    hip.position.set(s * 0.085, 0.28, 0);
    g.add(hip);
    mesh(new THREE.CapsuleGeometry(0.065, 0.14, 4, 10), mPants, 0, -0.12, 0, hip);
    const shoe = mesh(new THREE.SphereGeometry(0.085, 14, 10), mShoe, 0, -0.24, 0.035, hip);
    shoe.scale.set(0.9, 0.6, 1.3);
    P[s < 0 ? 'legL' : 'legR'] = hip;
  }
  const body = mesh(new THREE.SphereGeometry(0.19, 20, 16), mShirt, 0, 0.42, 0, g);
  body.scale.set(1, 1.08, 0.88);
  P.torso = body;
  if (belly) mesh(new THREE.SphereGeometry(0.13, 16, 12), mat(belly), 0, 0.4, 0.08, g).scale.set(1, 1.1, 0.6);
  for (const s of [-1, 1]) {
    const sh = new THREE.Group();
    sh.position.set(s * 0.19, 0.52, 0);
    sh.rotation.z = s * 0.35;
    g.add(sh);
    mesh(new THREE.CapsuleGeometry(0.05, 0.13, 4, 8), mShirt, 0, -0.1, 0, sh);
    mesh(new THREE.SphereGeometry(0.058, 12, 10), mSkin, 0, -0.22, 0, sh);
    P[s < 0 ? 'armL' : 'armR'] = sh;
  }
  const head = new THREE.Group();
  head.position.y = 0.6 + headR * 0.92;
  g.add(head);
  P.head = head;
  mesh(new THREE.SphereGeometry(headR, 28, 22), mSkin, 0, 0, 0, head);
  if (face) addFace(head, headR, eyes);
  g.userData = P;
  return { g, P, head, headR };
}

// Duże błyszczące oczy, rumieńce i uśmiech.
function addFace(head, r, eyes = 0x2b1a12, opts = {}) {
  const z = r * 0.86;
  for (const s of [-1, 1]) {
    const e = mesh(new THREE.SphereGeometry(r * 0.2, 16, 12), mat(eyes, { roughness: 0.2 }), s * r * 0.36, r * 0.05, z, head);
    e.scale.set(0.85, 1.1, 0.55);
    mesh(new THREE.SphereGeometry(r * 0.07, 8, 6), mat(0xffffff, { emissive: 0xffffff, emissiveIntensity: 0.6 }), s * r * 0.36 + r * 0.06, r * 0.12, z + r * 0.1, head);
    const blush = mesh(new THREE.CircleGeometry(r * 0.13, 16), mat(opts.blush ?? 0xff8fab, { transparent: true, opacity: 0.75 }), s * r * 0.58, -r * 0.2, z * 0.92, head);
    blush.rotation.y = s * 0.55;
    blush.castShadow = false;
  }
  const smile = mesh(new THREE.TorusGeometry(r * 0.13, r * 0.03, 6, 16, Math.PI), mat(0x7a2e2e), 0, -r * 0.22, z + r * 0.06, head);
  smile.rotation.z = Math.PI;
  smile.castShadow = false;
}

function cape(color, parent, y = 0.58) {
  const pivot = new THREE.Group();
  pivot.position.set(0, y, -0.15);
  const c = mesh(new THREE.BoxGeometry(0.36, 0.42, 0.025), mat(color, { side: THREE.DoubleSide }), 0, -0.2, 0, pivot);
  c.castShadow = false;
  parent.add(pivot);
  return pivot;
}

function wings(parent, color, y = 0.5) {
  const holder = new THREE.Group();
  holder.position.set(0, y, -0.15);
  parent.add(holder);
  const wm = mat(color, { transparent: true, opacity: 0.6, side: THREE.DoubleSide, emissive: color, emissiveIntensity: 0.4 });
  const parts = [];
  for (const s of [-1, 1]) {
    const w = new THREE.Group();
    holder.add(w);
    const big = mesh(new THREE.CircleGeometry(0.2, 20), wm, s * 0.16, 0.08, 0, w);
    big.scale.set(1, 1.35, 1);
    big.rotation.y = s * 0.5;
    const small = mesh(new THREE.CircleGeometry(0.12, 16), wm, s * 0.12, -0.14, 0.01, w);
    small.rotation.y = s * 0.5;
    big.castShadow = small.castShadow = false;
    parts.push(w);
  }
  return parts;
}

const BUILDERS = {
  // Rycerzyk Kuba – mały rycerz z pióropuszem
  kuba() {
    const { g, P, head, headR } = chibi({ shirt: 0x3d7bff, pants: 0x8a8fa3, shoes: 0x6b3e26 });
    const steel = mat(0xd5dbe6, { metalness: 0.85, roughness: 0.25 });
    const helm = mesh(new THREE.SphereGeometry(headR * 1.04, 24, 16, 0, Math.PI * 2, 0, Math.PI * 0.48), steel, 0, 0.02, 0, head);
    helm.rotation.x = -0.15;
    const plume = new THREE.Group(); plume.position.set(0, headR * 1.05, -0.02); head.add(plume); P.plume = plume;
    [0xff3b5c, 0xffc928, 0xff3b5c].forEach((c, i) => {
      const f = mesh(new THREE.SphereGeometry(0.06, 10, 8), mat(c), 0, i * 0.05, -i * 0.06, plume);
      f.scale.set(0.6, 1.4, 1);
    });
    mesh(new THREE.SphereGeometry(0.2, 16, 12), mat(0xffc928), 0, 0.43, 0.02, g).scale.set(1.02, 0.25, 0.95); // pas
    const shield = mesh(new THREE.CylinderGeometry(0.13, 0.13, 0.03, 20), mat(0xff3b5c), -0.25, 0.42, 0.05, g);
    shield.rotation.z = Math.PI / 2;
    mesh(new THREE.CylinderGeometry(0.05, 0.05, 0.035, 5), mat(0xffc928), -0.267, 0.42, 0.05, g).rotation.z = Math.PI / 2;
    const sword = new THREE.Group(); sword.position.set(0, -0.22, 0.03); P.armR.add(sword);
    mesh(new THREE.BoxGeometry(0.035, 0.32, 0.015), steel, 0, 0.16, 0, sword);
    mesh(new THREE.BoxGeometry(0.12, 0.025, 0.03), mat(0xffc928), 0, 0.0, 0, sword);
    return { g, P };
  },
  // Wróżka Mila – skrzydełka, różdżka z gwiazdką, kok
  mila() {
    const { g, P, head, headR } = chibi({ skin: 0xffe0cc, shirt: 0xff8fc8, pants: 0xff8fc8, shoes: 0xb388ff, eyes: 0x5b2a86 });
    const hair = mat(0xffd35c);
    mesh(new THREE.SphereGeometry(headR * 1.05, 22, 16, 0, Math.PI * 2, 0, Math.PI * 0.55), hair, 0, 0.02, -0.02, head).rotation.x = -0.25;
    mesh(new THREE.SphereGeometry(0.1, 14, 10), hair, 0, headR * 0.95, -0.08, head);
    for (const s of [-1, 1]) mesh(new THREE.SphereGeometry(0.07, 12, 10), hair, s * headR * 0.95, -0.02, -0.03, head);
    const skirt = mesh(new THREE.ConeGeometry(0.27, 0.26, 20, 1, true), mat(0xffb3dd, { side: THREE.DoubleSide }), 0, 0.3, 0, g);
    skirt.castShadow = true;
    P.wings = wings(g, 0xb8f2ff, 0.5);
    const wand = new THREE.Group(); wand.position.set(0, -0.22, 0.03); P.armR.add(wand);
    mesh(new THREE.CylinderGeometry(0.012, 0.012, 0.28, 6), mat(0xffffff), 0, 0.14, 0, wand);
    P.star = mesh(new THREE.OctahedronGeometry(0.06), glow(0xffe14d, 2), 0, 0.31, 0, wand);
    return { g, P };
  },
  // Kot w Butach – kapelusz z piórem, wysokie buty, peleryna
  mruczek() {
    const fur = 0xffa94d;
    const { g, P, head, headR } = chibi({ skin: fur, shirt: 0xff6b6b, pants: fur, shoes: 0x5c3317, eyes: 0x1b7f4b, belly: 0xfff1dc });
    for (const s of [-1, 1]) {
      const ear = mesh(new THREE.ConeGeometry(0.08, 0.15, 4), mat(fur), s * 0.15, headR * 0.82, 0, head);
      ear.rotation.z = -s * 0.4;
    }
    mesh(new THREE.SphereGeometry(0.035, 8, 6), mat(0xff6b9a), 0, -0.06, headR * 0.98, head);
    for (const s of [-1, 1]) for (const k of [-1, 1]) {
      const w = mesh(new THREE.CylinderGeometry(0.004, 0.004, 0.16, 4), mat(0x5a3a2a), s * 0.15, -0.07 + k * 0.02, headR * 0.86, head);
      w.rotation.z = Math.PI / 2 + k * s * 0.15;
      w.castShadow = false;
    }
    const hat = new THREE.Group(); hat.position.set(0, headR * 0.85, 0); hat.rotation.z = 0.25; head.add(hat);
    mesh(new THREE.CylinderGeometry(0.3, 0.3, 0.02, 24), mat(0x6a2c91), 0, 0, 0, hat);
    mesh(new THREE.CylinderGeometry(0.13, 0.16, 0.14, 20), mat(0x6a2c91), 0, 0.07, 0, hat);
    const feather = mesh(new THREE.SphereGeometry(0.06, 10, 8), mat(0xffffff), -0.12, 0.16, -0.03, hat);
    feather.scale.set(0.5, 2.6, 0.9); feather.rotation.z = 0.7;
    for (const s of [-1, 1]) mesh(new THREE.CylinderGeometry(0.08, 0.07, 0.12, 12), mat(0x5c3317), 0, -0.13, 0, P[s < 0 ? 'legL' : 'legR']);
    const tail = new THREE.Group(); tail.position.set(0, 0.3, -0.15); g.add(tail); P.tail = tail;
    for (let i = 0; i < 7; i++) mesh(new THREE.SphereGeometry(0.045, 8, 6), mat(i > 4 ? 0xfff1dc : fur), 0, i * 0.055, -0.04 - Math.sin(i * 0.45) * 0.12, tail);
    P.cape = cape(0xd7263d, g, 0.55);
    return { g, P };
  },
  // Smoczek Bzik – mały zielony smok ze skrzydełkami
  bit() {
    const green = 0x5ed36a;
    const { g, P, head, headR } = chibi({ skin: green, shirt: green, pants: green, shoes: 0x3a9a4a, eyes: 0x1d1d1d, belly: 0xfff2a8, headR: 0.26 });
    for (const s of [-1, 1]) {
      const horn = mesh(new THREE.ConeGeometry(0.04, 0.13, 8), mat(0xfff2a8), s * 0.1, headR * 0.9, -0.03, head);
      horn.rotation.z = -s * 0.3;
    }
    mesh(new THREE.SphereGeometry(0.1, 14, 10), mat(0x7be585), 0, -0.07, headR * 0.82, head).scale.set(1.3, 0.8, 0.9);
    for (const s of [-1, 1]) mesh(new THREE.SphereGeometry(0.015, 6, 6), mat(0x1d4a24), s * 0.04, -0.05, headR * 1.08, head);
    [0, 1, 2].forEach((i) => mesh(new THREE.ConeGeometry(0.035, 0.08, 6), mat(0xffa94d), 0, headR * 0.6 - i * 0.12, -headR * 0.85 + i * 0.04, head).rotation.x = -0.6);
    P.wings = wings(g, 0x9ff0a7, 0.52);
    const tail = new THREE.Group(); tail.position.set(0, 0.25, -0.16); g.add(tail); P.tail = tail;
    for (let i = 0; i < 6; i++) mesh(new THREE.SphereGeometry(0.07 - i * 0.008, 10, 8), mat(green), 0, -i * 0.01, -i * 0.07, tail);
    mesh(new THREE.ConeGeometry(0.05, 0.1, 4), mat(0xffa94d), 0, -0.05, -0.45, tail).rotation.x = -Math.PI / 2;
    return { g, P };
  },
  // Księżniczka Ola – korona, suknia, długie włosy
  astro() {
    const { g, P, head, headR } = chibi({ skin: 0xffe0cc, shirt: 0xb388ff, pants: 0xb388ff, shoes: 0xffffff, eyes: 0x2a4d8f });
    const hair = mat(0x8b4a2b);
    mesh(new THREE.SphereGeometry(headR * 1.06, 22, 16, 0, Math.PI * 2, 0, Math.PI * 0.6), hair, 0, 0.02, -0.02, head).rotation.x = -0.3;
    const back = mesh(new THREE.CapsuleGeometry(headR * 0.85, 0.22, 6, 12), hair, 0, -0.16, -0.1, head);
    back.scale.set(1, 1, 0.6);
    const gown = mesh(new THREE.ConeGeometry(0.32, 0.4, 24), mat(0xc9a3ff), 0, 0.22, 0, g);
    gown.castShadow = true;
    mesh(new THREE.TorusGeometry(0.31, 0.025, 6, 30), mat(0xffffff), 0, 0.03, 0, g).rotation.x = Math.PI / 2;
    const crown = new THREE.Group(); crown.position.y = headR * 0.86; head.add(crown);
    mesh(new THREE.CylinderGeometry(0.12, 0.12, 0.06, 16, 1, true), mat(0xffd700, { metalness: 0.9, roughness: 0.2, side: THREE.DoubleSide }), 0, 0, 0, crown);
    for (let i = 0; i < 5; i++) {
      const a = (i / 5) * Math.PI * 2;
      mesh(new THREE.ConeGeometry(0.025, 0.07, 6), mat(0xffd700, { metalness: 0.9, roughness: 0.2 }), Math.sin(a) * 0.12, 0.06, Math.cos(a) * 0.12, crown);
    }
    mesh(new THREE.OctahedronGeometry(0.03), glow(0xff4fa3, 1.5), 0, 0.02, 0.125, crown);
    return { g, P };
  },
  // Skrzat Brodacz – czerwona szpiczasta czapka i wielka broda
  cien() {
    const { g, P, head, headR } = chibi({ skin: 0xffcfb0, shirt: 0x2e8b57, pants: 0x6b3e26, shoes: 0x3b2314, eyes: 0x2b1a12 });
    const hat = mesh(new THREE.ConeGeometry(headR * 1.02, 0.5, 20), mat(0xe63946), 0, headR * 0.8 + 0.18, -0.04, head);
    hat.rotation.x = -0.25;
    P.hat = hat;
    mesh(new THREE.SphereGeometry(0.045, 10, 8), mat(0xffffff), 0, headR * 0.8 + 0.42, -0.14, head);
    const beard = mesh(new THREE.SphereGeometry(0.2, 18, 14), mat(0xffffff, { roughness: 0.9 }), 0, -0.17, headR * 0.45, head);
    beard.scale.set(1, 1.25, 0.6);
    mesh(new THREE.SphereGeometry(0.06, 12, 10), mat(0xffa3a3), 0, -0.02, headR * 1.0, head);
    const lantern = new THREE.Group(); lantern.position.set(0, -0.25, 0.03); P.armL.add(lantern);
    mesh(new THREE.BoxGeometry(0.08, 0.1, 0.08), mat(0x3b2314), 0, -0.04, 0, lantern);
    mesh(new THREE.SphereGeometry(0.04, 10, 8), glow(0xffc14d, 2.5), 0, -0.04, 0, lantern);
    return { g, P };
  },
  // Iskra – ognista czarodziejka
  iskra() {
    const { g, P, head, headR } = chibi({ skin: 0xffe0cc, shirt: 0xffb703, pants: 0xd00000, shoes: 0xffd60a, eyes: 0xb30000 });
    const flame = glow(0xff7a00, 1.8);
    for (let i = 0; i < 10; i++) {
      const a = (i / 10) * Math.PI * 2;
      const f = mesh(new THREE.ConeGeometry(0.075, 0.24 + (i % 3) * 0.06, 8), flame, Math.cos(a) * 0.15, headR * 0.7, Math.sin(a) * 0.15 - 0.05, head);
      f.rotation.set(Math.sin(a) * -0.6, 0, Math.cos(a) * 0.6);
    }
    mesh(new THREE.ConeGeometry(0.14, 0.14, 5), glow(0xffd60a, 1.4), 0, headR * 1.15, -0.02, head);
    const skirt = mesh(new THREE.ConeGeometry(0.26, 0.24, 20, 1, true), mat(0xff6b00, { side: THREE.DoubleSide }), 0, 0.3, 0, g);
    skirt.castShadow = true;
    P.cape = cape(0xd00000, g);
    return { g, P };
  },
  // Złoty Rycerz – legendarna zbroja
  rycerz() {
    const gold = mat(0xffc928, { metalness: 0.95, roughness: 0.22 });
    const { g, P, head, headR } = chibi({ skin: 0xffc928, shirt: 0xffc928, pants: 0xd4a017, shoes: 0x8a6a00, face: false });
    g.traverse((o) => { if (o.isMesh) o.material = gold; });
    mesh(new THREE.BoxGeometry(0.3, 0.05, 0.08), mat(0x1a1a1a), 0, 0.02, headR * 0.86, head);
    for (const s of [-1, 1]) mesh(new THREE.SphereGeometry(0.025, 8, 6), glow(0x4dd2ff, 3), s * 0.07, 0.02, headR * 0.95, head);
    const plume = mesh(new THREE.SphereGeometry(0.08, 12, 10), mat(0xd00000), 0, headR + 0.06, -0.04, head);
    plume.scale.set(0.6, 1.2, 2.2);
    P.cape = cape(0x6a040f, g);
    const sword = new THREE.Group(); sword.position.set(0, -0.22, 0.03); P.armR.add(sword);
    mesh(new THREE.BoxGeometry(0.04, 0.38, 0.015), mat(0xe8f4ff, { metalness: 1, roughness: 0.1, emissive: 0x4dd2ff, emissiveIntensity: 0.4 }), 0, 0.19, 0, sword);
    mesh(new THREE.BoxGeometry(0.14, 0.03, 0.03), gold, 0, 0, 0, sword);
    return { g, P };
  },
  // Czarnoksiężnik Szaruch – złoczyńca
  baron() {
    const { g, P, head, headR } = chibi({ skin: 0xc9c3d6, shirt: 0x4b4560, pants: 0x3a3450, shoes: 0x22202c, eyes: 0x7a00ff });
    const hat = new THREE.Group(); hat.position.y = headR * 0.75; head.add(hat);
    mesh(new THREE.CylinderGeometry(0.34, 0.34, 0.025, 28), mat(0x2d2640), 0, 0, 0, hat);
    const cone = mesh(new THREE.ConeGeometry(0.2, 0.6, 20), mat(0x2d2640), 0.04, 0.3, -0.03, hat);
    cone.rotation.z = -0.25;
    for (let i = 0; i < 4; i++) mesh(new THREE.OctahedronGeometry(0.025), glow(0xb388ff, 1.5), Math.sin(i * 1.7) * 0.12, 0.12 + i * 0.1, 0.12 - i * 0.03, hat);
    const beard = mesh(new THREE.ConeGeometry(0.18, 0.42, 16), mat(0xe6e3ee, { roughness: 0.9 }), 0, -0.3, headR * 0.45, head);
    beard.rotation.x = Math.PI + 0.25;
    for (const s of [-1, 1]) {
      const brow = mesh(new THREE.BoxGeometry(0.1, 0.02, 0.02), mat(0x3a3450), s * 0.09, 0.11, headR * 0.92, head);
      brow.rotation.z = s * 0.4;
    }
    const staff = new THREE.Group(); staff.position.set(0, -0.22, 0.03); P.armR.add(staff);
    mesh(new THREE.CylinderGeometry(0.018, 0.022, 0.75, 8), mat(0x5c3a21), 0, 0.2, 0, staff);
    P.star = mesh(new THREE.OctahedronGeometry(0.07), glow(0x9d4dff, 2.2), 0, 0.6, 0, staff);
    P.cape = cape(0x2d2640, g);
    return { g, P };
  },
};

export function buildCharacter(id) {
  const { g, P } = (BUILDERS[id] || BUILDERS.kuba)();
  g.userData = { ...g.userData, ...P };
  return g;
}

// Animacja postaci jadącej na kuli.
export function animateCharacter(c, t, { running = false, air = false, lean = 0 } = {}) {
  const P = c.userData;
  const w = running ? 12 : 3;
  const sw = Math.sin(t * w);
  if (P.legL) { P.legL.rotation.x = running ? sw * 0.55 : 0; P.legR.rotation.x = running ? -sw * 0.55 : 0; }
  if (P.armL) {
    if (air) { P.armL.rotation.set(0, 0, -2.5); P.armR.rotation.set(0, 0, 2.5); }
    else {
      P.armL.rotation.set(running ? -sw * 0.5 : Math.sin(t * 2) * 0.12, 0, -0.45 - (running ? 0.35 : 0));
      P.armR.rotation.set(running ? sw * 0.5 : -Math.sin(t * 2) * 0.12, 0, 0.45 + (running ? 0.35 : 0));
    }
  }
  if (P.head) { P.head.rotation.z = -lean * 0.3; P.head.rotation.x = running ? 0 : Math.sin(t * 1.5) * 0.05; }
  if (P.tail) { P.tail.rotation.x = Math.sin(t * 6) * 0.2 - (running ? 0.35 : 0); P.tail.rotation.z = Math.sin(t * 4) * 0.25; }
  if (P.cape) P.cape.rotation.x = (running ? 0.7 : 0.1) + Math.sin(t * 14) * (running ? 0.12 : 0.03);
  if (P.plume) P.plume.rotation.x = (running ? -0.5 : -0.1) + Math.sin(t * 10) * 0.08;
  if (P.wings) P.wings.forEach((wg, i) => { wg.rotation.y = (i ? -1 : 1) * (0.25 + Math.sin(t * (air ? 30 : 12)) * 0.35); });
  if (P.star) { P.star.rotation.y = t * 3; P.star.material.emissiveIntensity = 1.6 + Math.sin(t * 6) * 0.8; }
  if (P.hat) P.hat.rotation.x = -0.25 - (running ? 0.25 : 0) + Math.sin(t * 8) * 0.04;
  c.rotation.z = lean;
  c.position.y = running ? Math.abs(sw) * 0.03 : Math.sin(t * 2) * 0.015;
}

// Portrety do UI (renderowane raz, poza ekranem).
export function renderPortraits(ids) {
  const size = 256;
  const r = new THREE.WebGLRenderer({ antialias: true, alpha: true, preserveDrawingBuffer: true });
  r.setSize(size, size, false);
  r.toneMapping = THREE.ACESFilmicToneMapping;
  r.toneMappingExposure = 1.15;
  const scene = new THREE.Scene();
  scene.add(new THREE.HemisphereLight(0xfff6e8, 0xb39ddb, 2));
  const d = new THREE.DirectionalLight(0xffffff, 2.4);
  d.position.set(1.5, 2.5, 3);
  scene.add(d);
  const cam = new THREE.PerspectiveCamera(30, 1, 0.1, 20);
  const out = {};
  for (const id of ids) {
    const c = buildCharacter(id);
    animateCharacter(c, 0.4);
    c.rotation.y = 0.3;
    scene.add(c);
    cam.position.set(0.25, 0.85, 2.75);
    cam.lookAt(0, 0.62, 0);
    r.render(scene, cam);
    out[id] = r.domElement.toDataURL('image/png');
    scene.remove(c);
  }
  r.dispose();
  r.forceContextLoss?.();
  return out;
}
