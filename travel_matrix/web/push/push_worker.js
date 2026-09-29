// Custom service worker for Web Push (VAPID) — CPS-149. Registered at its
// own scope (/push/), deliberately separate from Flutter's own root-scoped
// asset-caching worker: two service workers registered at the identical
// scope replace each other, which would silently drop this file's
// push/notificationclick handlers.

self.addEventListener('push', (event) => {
  let payload = {};
  try {
    payload = event.data ? event.data.json() : {};
  } catch (e) {
    payload = {};
  }

  const travelId = payload.travelId || null;
  const body = payload.message || 'Você tem uma nova notificação.';

  event.waitUntil(
    self.registration.showNotification('Compass System', {
      body,
      icon: '/icons/Icon-192.png',
      data: { travelId },
    })
  );

  // Lets any open tab refresh its unread badge immediately, even while the
  // tab is focused (foreground) — the OS notification alone wouldn't update
  // the in-app UI. The badge always re-fetches the count from the server,
  // so the message itself carries no data.
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
      clients.forEach((client) => client.postMessage('push-received'));
    })
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientsArr) => {
      for (const client of clientsArr) {
        if ('focus' in client) {
          return client.focus();
        }
      }
      if (self.clients.openWindow) {
        return self.clients.openWindow('/');
      }
    })
  );
});
