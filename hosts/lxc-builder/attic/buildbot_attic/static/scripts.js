/* Buildbot 4.3 UI extension: mount only inside expanded native build steps.
 * There is no new route, page, navigation, or application shell. Buildbot's
 * plugin API has no step-component slot; the two pinned selectors below are
 * the small DOM bridge to its React step renderer.
 */
(() => {
  'use strict';
  const STEP = '.bb-build-summary-step-line';
  const DETAILS = '.anim-stepdetails';
  const panels = new Map();
  const requests = new Map();
  const snapshots = new Map();
  const defaultedLogs = new WeakSet();
  let scanning = false;
  const element = (tag, cls, text) => {
    const node = document.createElement(tag);
    if (cls) node.className = cls;
    if (text !== undefined) node.textContent = text;
    return node;
  };
  let toastTimer;
  function showToast(message) {
    let toast = document.getElementById('bb-attic-toast');
    if (!toast) {
      toast = element('div', 'bb-attic-toast toast show');
      toast.id = 'bb-attic-toast';
      toast.setAttribute('role', 'status');
      toast.setAttribute('aria-live', 'polite');
      toast.setAttribute('aria-atomic', 'true');
      document.body.append(toast);
    }
    toast.replaceChildren(element('div', 'toast-body', message));
    toast.hidden = false;
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => { toast.hidden = true; }, 2500);
  }
  function bytes(value) {
    if (value >= 1024 ** 3) return `${(value / 1024 ** 3).toFixed(2)} GiB`;
    if (value >= 1024 ** 2) return `${Math.round(value / 1024 ** 2)} MiB`;
    return `${Math.max(1, Math.round(value / 1024))} KiB`;
  }
  function pathRow(job) {
    const row = element('div', 'attic-path'); row.dataset.state = job.state;
    if (job.error) row.title = job.error;
    const name = element('button', 'attic-name', job.path.split('/').pop().replace(/^[^-]+-/, ''));
    name.type = 'button';
    name.title = job.path;
    name.setAttribute('aria-label', `Copy ${job.path}`);
    name.addEventListener('click', async event => {
      event.stopPropagation();
      try {
        await navigator.clipboard.writeText(job.path);
        name.title = `Copied: ${job.path}`;
        showToast('Copied to clipboard');
      } catch {
        name.title = `Could not copy to clipboard: ${job.path}`;
        showToast('Could not copy to clipboard');
      }
    });
    const size = element('span', 'attic-size', bytes(job.size));
    row.append(name, size);
    if (job.state === 'queued') return row;
    const percent = job.size ? Math.min(100, job.sent / job.size * 100) : 0;
    const track = element('div', 'attic-progress'), fill = element('div', 'attic-fill');
    fill.style.width = `${percent}%`; track.append(fill);
    track.setAttribute('role', 'progressbar'); track.setAttribute('aria-label', job.path);
    track.setAttribute('aria-valuemin', '0'); track.setAttribute('aria-valuemax', '100');
    track.setAttribute('aria-valuenow', String(Math.floor(percent)));
    track.setAttribute('aria-valuetext', `${Math.floor(percent)}%, ${job.state}`);
    row.append(track, element('span', 'attic-percentage', `${Math.floor(percent)}%`));
    return row;
  }
  function render(panel, data) {
    const publication = data.publications[0];
    if (!publication) return;
    const tickets = publication.targets.filter(t => !panel.target || t.target === panel.target);
    panel.counts = tickets.some(t => t.state === 'planning') ? null : {
      done: tickets.reduce((sum, t) => sum + t.complete, 0),
      total: tickets.reduce((sum, t) => sum + t.paths, 0),
    };
    const related = [...panels.values()].filter(p => p.card === panel.card);
    const counts = related.every(p => p.counts) ? related.reduce(
      (sum, p) => ({done:sum.done + p.counts.done, total:sum.total + p.counts.total}),
      {done:0, total:0}) : null;
    const label = counts ? `${counts.done}/${counts.total} paths ready` : '';
    if (panel.counter.textContent !== label) panel.counter.textContent = label;
    const fragment = document.createDocumentFragment();
    for (const ticket of tickets) {
      if (panel.target && ticket.target !== panel.target) continue;
      const section = element('div');
      section.setAttribute('aria-label', ticket.target);
      if (ticket.error) section.append(element('div', 'attic-error', ticket.error));
      const order = {uploading:0, cancelling:0, queued:1, failed:2};
      const jobs = (ticket.jobs || [])
        .filter(job => Object.hasOwn(order, job.state))
        .sort((a, b) => order[a.state] - order[b.state]);
      for (const job of jobs) section.append(pathRow(job));
      if (!jobs.length && ticket.state === 'planning') {
        section.append(element('div', 'attic-muted', 'Checking required paths…'));
      }
      fragment.append(section);
    }
    panel.content.replaceChildren(fragment);
    panel.root.hidden = !panel.content.querySelector('.attic-path, .attic-error, .attic-muted');
    panel.card.hidden = related.every(p => p.root.hidden);
    panel.finished = publication.targets.filter(t => !panel.target || t.target === panel.target)
      .every(t => ['complete','failed','cancelled'].includes(t.state));
  }
  function logToggle(card) {
    return card.querySelector('.card-header .flex-grow-3');
  }
  function defaultLogState(card, expanded) {
    if (defaultedLogs.has(card)) return;
    const toggle = logToggle(card);
    if (!toggle) return;
    defaultedLogs.add(card);
    const isExpanded = !!card.querySelector('.card-body, .bb-log-preview-contents');
    if (isExpanded !== expanded) toggle.click();
  }
  function mount(anchor, placeholder, url) {
    // Buildbot's own HTML LogPreview supplies the card, header, and expander.
    // Only its live row contents belong to this extension.
    const root = element('div', 'bb-attic-uploads');
    const content = element('div');
    content.append(element('span', 'attic-muted', 'Loading upload status…'));
    root.append(content);
    placeholder.replaceChildren(root);
    const card = placeholder.closest('.logpreview');
    card.hidden = false;
    let counter = card.querySelector('.attic-ready');
    if (!counter) {
      counter = element('span', 'attic-ready');
      card.querySelector('.card-header .flex-grow-1').append(counter);
    }
    const panel = {root, anchor, content, card, counter, url, target:url.searchParams.get('target'), finished:false};
    panels.set(anchor, panel);
    const ident = url.searchParams.get('publication');
    const cached = snapshots.get(ident);
    if (cached) render(panel, cached);
    refresh(ident);
  }
  function scan() {
    scanning = false;
    for (const [anchor, panel] of panels) {
      if (!panel.card.isConnected || !anchor.isConnected) {
        panel.root.remove();
        panels.delete(anchor);
        const ident = panel.url.searchParams.get('publication');
        if (![...panels.values()].some(p => p.url.searchParams.get('publication') === ident)) {
          snapshots.delete(ident);
        }
      }
    }
    for (const anchor of document.querySelectorAll(`${STEP} a[href]`)) {
      let url;
      try { url = new URL(anchor.href, document.baseURI); } catch { continue; }
      if (url.origin !== location.origin || !url.pathname.endsWith('/plugins/attic_uploads/api') || !url.searchParams.has('publication')) continue;
      const step = anchor.closest(STEP), details = step?.querySelector(DETAILS);
      const item = anchor.closest('li');
      const marker = item && item !== step ? item : anchor;
      if (!marker.classList.contains('bb-attic-marker')) marker.classList.add('bb-attic-marker');
      if (!details) continue;
      const cards = [...details.querySelectorAll('.logpreview')]
        .filter(card => card.closest(STEP) === step);
      // Native defaults change when stdio arrives after the HTML log. Wait for
      // both logs before applying ours, otherwise React can collapse uploads.
      if (!cards.some(card => logToggle(card)?.textContent.trim() === 'stdio')) continue;
      for (const card of cards) {
        const name = logToggle(card)?.textContent.trim();
        if (name === 'stdio') defaultLogState(card, false);
        if (name !== 'uploads') continue;
        card.classList.add('bb-attic-upload-log');
        defaultLogState(card, true);
        const ident = url.searchParams.get('publication');
        const placeholder = [...card.querySelectorAll('[data-attic-publication]')]
          .find(node => node.dataset.atticPublication === ident);
        if (placeholder) {
          const panel = panels.get(anchor);
          if (!panel) mount(anchor, placeholder, url);
          else if (!panel.root.isConnected) placeholder.replaceChildren(panel.root);
        }
      }
    }
  }
  function refresh(ident) {
    if (requests.has(ident)) return requests.get(ident);
    const panel = [...panels.values()].find(p => p.url.searchParams.get('publication') === ident);
    if (!panel) return Promise.resolve();
    const url = new URL(panel.url); url.searchParams.delete('target');
    const request = (async () => {
      const controller = new AbortController(), timeout = setTimeout(() => controller.abort(), 10000);
      try {
        const response = await fetch(url, {cache:'no-store', signal:controller.signal});
        if (!response.ok) throw new Error(response.status === 404 ? 'Upload history is no longer in memory. Check this step’s log for its recorded result.' : `Upload status unavailable (HTTP ${response.status}); retrying…`);
        const data = await response.json();
        const matching = [...panels.values()].filter(p => p.url.searchParams.get('publication') === ident);
        if (matching.length) snapshots.set(ident, data);
        for (const current of matching) render(current, data);
      } catch (error) {
        for (const current of panels.values()) if (current.url.searchParams.get('publication') === ident) {
          current.content.replaceChildren(element('span', 'attic-error', error.message || 'Connection lost; retrying…'));
          current.root.hidden = false;
          current.card.hidden = false;
        }
      } finally {
        clearTimeout(timeout);
        requests.delete(ident);
      }
    })();
    requests.set(ident, request);
    return request;
  }
  async function poll() {
    scan();
    const active = new Set([...panels.values()].filter(p => !p.finished)
      .map(p => p.url.searchParams.get('publication')));
    await Promise.all([...active].map(refresh));
    setTimeout(poll, document.hidden ? 10000 : 2000);
  }
  function start() {
    new MutationObserver(() => {
      if (!scanning) { scanning = true; queueMicrotask(scan); }
    }).observe(document.body, {childList:true, subtree:true});
    poll();
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, {once:true});
  else start();
})();
