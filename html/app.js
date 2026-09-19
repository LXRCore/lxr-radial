/* LXR-RADIAL — the wheel | © 2026 iBoss21 / LXRCore
   Messages: open { wheel, locale, lang, brand, hold } · close
   Callbacks: pick { id } · close · sound { name }
   An entry: { id, label, icon, state ('on'|'off'), sub: [entries], empty } */
(function () {
  const $ = (id) => document.getElementById(id);
  const RES = (typeof GetParentResourceName === 'function') ? GetParentResourceName() : 'lxr-radial';
  const NS = 'http://www.w3.org/2000/svg';
  const wheel = $('wheel'), ring = $('ring'), label = $('label'), sub = $('sub');
  let L = {}, stack = [], hover = null;
  const t = (k) => L[k] || k.split('.').pop().replace(/_/g, ' ');
  const post = (name, body) => fetch(`https://${RES}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(body || {}) }).catch(() => {});

  /* icons: stroke paths on a 24-box, keyed by the entry's icon name (clothing keys match the wardrobe categories) */
  const ICONS = {
    shirt: 'M7 3l5 2 5-2 3 4-3 2v12H7V9L4 7z', horse: 'M4 20l3-8 3-2 2-5 3-1 3 3-1 3-3 1v9M7 12l-3 2', whistle: 'M4 14a5 5 0 1 0 10 0 5 5 0 0 0-10 0zM14 12l7-4-1-3-8 4', stable: 'M3 21V9l9-6 9 6v12H3zM9 21v-7h6v7',
    satchel: 'M4 8h16v12H4zM8 8V5h8v3', badge: 'M12 2l3 3h4v4l3 3-3 3v4h-4l-3 3-3-3H5v-4l-3-3 3-3V5h4z', paper: 'M6 3h9l4 4v14H6zM15 3v4h4M9 12h6M9 16h6', frame: 'M3 5h18v14H3zM3 9h18M7 5v4',
    undress: 'M7 3l5 2 5-2 3 4-3 2v12H7V9L4 7zM5 21L19 3', dress: 'M7 3l5 2 5-2 3 4-3 2v12H7V9L4 7zM9 14l2 2 4-4',
    hats: 'M4 14l2-8h12l2 8M2 14h20v3H2z', masks: 'M4 8h16v6l-4 5H8l-4-5z', eyewear: 'M2 12h4a3 3 0 0 0 6 0h0a3 3 0 0 0 6 0h4M8 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm8 0a3 3 0 1 0 0-6 3 3 0 0 0 0 6z',
    coats: 'M8 3l4 3 4-3 4 3v15H4V6zM12 6v15', shirts_full: 'M7 3l5 2 5-2 3 4-3 2v12H7V9L4 7z', vests: 'M8 3l4 4 4-4 3 3v14H5V6z', pants: 'M6 3h12l1 18h-5l-2-9-2 9H5z', boots: 'M7 3h6v9l6 4v5H7z',
    gloves: 'M8 21V9l-2-3 2-3 2 3 2-3 2 3 2-3 2 3v12z', neckwear: 'M12 3l4 5-4 13-4-13z', gunbelts: 'M3 10h18v4H3zM10 10v4M14 10v4', satchels: 'M4 8h16v12H4zM8 8V5h8v3', back: 'M15 6l-6 6 6 6',
  };

  const el = (tag, attrs) => { const e = document.createElementNS(NS, tag); for (const k in attrs) e.setAttribute(k, attrs[k]); return e; };
  const polar = (r, a) => [r * Math.cos(a), r * Math.sin(a)];
  function segment(r0, r1, a0, a1) {
    const [x0, y0] = polar(r1, a0), [x1, y1] = polar(r1, a1), [x2, y2] = polar(r0, a1), [x3, y3] = polar(r0, a0);
    const big = a1 - a0 > Math.PI ? 1 : 0;
    return `M${x0} ${y0}A${r1} ${r1} 0 ${big} 1 ${x1} ${y1}L${x2} ${y2}A${r0} ${r0} 0 ${big} 0 ${x3} ${y3}Z`;
  }

  function current() { return stack[stack.length - 1]; }
  function draw() {
    const list = current().list;
    ring.innerHTML = '';
    const n = Math.max(list.length, 1), gap = 0.03, r0 = 80, r1 = 185;
    list.forEach((e, i) => {
      const a0 = -Math.PI / 2 + (i / n) * Math.PI * 2 + gap, a1 = -Math.PI / 2 + ((i + 1) / n) * Math.PI * 2 - gap;
      const seg = el('path', { d: segment(r0, r1, a0, a1), class: 'rd__seg' + (e.state === 'off' ? ' is-off' : '') + (e.empty ? ' is-off' : '') });
      // icon above, name below, both on the segment's middle radius
      const mid = (a0 + a1) / 2, [cx, cy] = polar((r0 + r1) / 2 + 4, mid);
      const g = el('g', { class: 'rd__ico', transform: `translate(${cx - 14} ${cy - 26}) scale(1.17)` });
      g.appendChild(el('path', { d: ICONS[e.icon] || ICONS.paper }));
      const txt = el('text', { x: cx, y: cy + 20, class: 'rd__txt' });
      txt.textContent = (e.label || '').length > 14 ? e.label.slice(0, 13) + '…' : e.label;
      ring.appendChild(seg); ring.appendChild(g); ring.appendChild(txt);
      if (e.sub) { const [mx, my] = polar(r1 - 10, mid); ring.appendChild(el('circle', { cx: mx, cy: my, r: 3, class: 'rd__more' })); }
      if (e.state) { const [sx, sy] = polar(r0 + 12, mid); ring.appendChild(el('circle', { cx: sx, cy: sy, r: 3, class: 'rd__state' + (e.state === 'off' ? ' is-off' : '') })); }
      seg.addEventListener('mouseenter', () => { hover = e; label.textContent = e.label; sub.textContent = e.state ? t('ui.' + e.state) : (e.sub ? '›' : (e.empty ? t('ui.empty') : '')); sub.className = 'rd__sub lxr-mono' + (e.state ? ' is-' + e.state : ''); post('sound', { name: 'NAV_UP' }); });
      seg.addEventListener('mouseleave', () => { if (hover === e) { hover = null; label.textContent = current().title; sub.textContent = ''; sub.className = 'rd__sub lxr-mono'; } });
      seg.addEventListener('click', (ev) => { ev.stopPropagation(); if (e.sub) { stack.push({ title: e.label, list: e.sub }); draw(); post('sound', { name: 'SELECT' }); } else if (!e.empty) post('pick', { id: e.id }); });
    });
    label.textContent = current().title; sub.textContent = ''; sub.className = 'rd__sub lxr-mono';
    $('h-back').textContent = stack.length > 1 ? t('ui.back') : t('ui.close');
    $('h-close').textContent = t('ui.close');
  }
  function back() { if (stack.length > 1) { stack.pop(); draw(); post('sound', { name: 'BACK' }); } else post('close'); }

  document.addEventListener('contextmenu', (e) => { e.preventDefault(); if (!wheel.classList.contains('lxr-hidden')) back(); });
  document.addEventListener('keydown', (e) => { if (e.key === 'Escape') post('close'); });

  window.addEventListener('message', (e) => {
    const m = e.data || {};
    if (m.brand && m.brand.theme) document.documentElement.dataset.theme = m.brand.theme;
    if (m.action === 'open') {
      L = m.locale || {}; document.body.classList.toggle('lang-ka', m.lang === 'ka');
      stack = [{ title: (m.brand && m.brand.name) || '', list: m.wheel || [] }];
      wheel.classList.remove('lxr-hidden'); draw();
    }
    if (m.action === 'close') { wheel.classList.add('lxr-hidden'); ring.innerHTML = ''; stack = []; }
  });
  if (window.__LXR_MOCK__) window.postMessage(window.__LXR_MOCK__, '*');
})();
