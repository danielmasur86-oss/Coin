// Mikropłatności: Google Play Billing (przez cordova-plugin-purchase) na Androidzie,
// tryb testowy (symulacja) w przeglądarce podczas developmentu.
import { Capacitor } from '@capacitor/core';
import { IAP_PRODUCTS } from './config.js';
import { save } from './save.js';

const listeners = new Set();
const emit = () => listeners.forEach((fn) => fn());

let native = null; // CdvPurchase.store, gdy działamy na urządzeniu
let ready = false;
let onDelivered = () => {};

export const billing = {
  isNative: () => !!native,
  isReady: () => ready,
  onChange: (fn) => listeners.add(fn),
  onDelivered: (fn) => { onDelivered = fn; },

  price(id) {
    const p = native?.get(id);
    return p?.pricing?.price || IAP_PRODUCTS.find((x) => x.id === id)?.fallbackPrice || '';
  },

  owned(id) {
    const s = save.get();
    if (id === 'double_coins') return s.doubleCoins;
    if (id === 'starter_pack') return s.starterGranted;
    return false;
  },

  async buy(id) {
    if (!native) return mockBuy(id);
    const product = native.get(id);
    const offer = product?.getOffer();
    if (!offer) throw new Error('Produkt niedostępny. Spróbuj ponownie później.');
    const err = await offer.order();
    if (err && err.code !== window.CdvPurchase.ErrorCode.PAYMENT_CANCELLED) throw new Error(err.message);
  },

  async restore() {
    if (!native) return;
    await native.restorePurchases();
    syncOwned();
  },

  async init() {
    if (!Capacitor.isNativePlatform()) { ready = true; emit(); return; }
    await new Promise((res) => {
      if (window.CdvPurchase) return res();
      document.addEventListener('deviceready', res, { once: true });
    });
    const { store, ProductType, Platform, LogLevel } = window.CdvPurchase;
    native = store;
    store.verbosity = LogLevel.WARNING;
    store.register(IAP_PRODUCTS.map((p) => ({
      id: p.id,
      platform: Platform.GOOGLE_PLAY,
      type: p.type === 'consumable' ? ProductType.CONSUMABLE : ProductType.NON_CONSUMABLE,
    })));

    store.when()
      .productUpdated(emit)
      .approved((tx) => {
        // W produkcji warto dodać walidację po stronie serwera (store.validator) – patrz README.
        if (tx.isPending) return;
        if (!tx.isAcknowledged) for (const p of tx.products || []) deliver(p.id, tx.transactionId);
        tx.finish(); // potwierdza (acknowledge/consume) – bez tego Google zwraca pieniądze po 3 dniach
      })
      .receiptUpdated(() => { syncOwned(); emit(); });

    const errs = await store.initialize([Platform.GOOGLE_PLAY]);
    if (errs?.length) console.warn('Billing init:', errs);
    ready = true;
    syncOwned();
    emit();
  },
};

function deliver(productId, txId) {
  const s = save.get();
  const product = IAP_PRODUCTS.find((p) => p.id === productId);
  if (!product) return;
  if (product.type === 'consumable') {
    if (txId && s.deliveredTx.includes(txId)) return; // ochrona przed podwójnym naliczeniem
    if (txId) s.deliveredTx = [...s.deliveredTx.slice(-50), txId];
    s.coins += product.coins;
    save.commit();
    onDelivered(product);
  } else {
    grantNonConsumable(productId, true);
  }
  emit();
}

function grantNonConsumable(id, notify) {
  const s = save.get();
  if (id === 'double_coins' && !s.doubleCoins) {
    s.doubleCoins = true; save.commit();
    if (notify) onDelivered(IAP_PRODUCTS.find((p) => p.id === id));
  }
  if (id === 'starter_pack' && !s.starterGranted) {
    const p = IAP_PRODUCTS.find((x) => x.id === id);
    s.starterGranted = true;
    s.coins += p.coins;
    if (!s.ownedSkins.includes(p.skin)) s.ownedSkins.push(p.skin);
    save.commit();
    if (notify) onDelivered(p);
  }
}

function syncOwned() {
  if (!native) return;
  for (const p of IAP_PRODUCTS) {
    if (p.type === 'non-consumable' && native.owned(p.id)) grantNonConsumable(p.id, false);
  }
}

async function mockBuy(id) {
  // Tryb testowy w przeglądarce – żadna płatność nie jest wykonywana.
  await new Promise((r) => setTimeout(r, 400));
  if (!window.confirm(`TRYB TESTOWY\nKupić „${IAP_PRODUCTS.find((p) => p.id === id).title}” za ${billing.price(id)}?`)) return;
  deliver(id, 'mock-' + Date.now());
}
