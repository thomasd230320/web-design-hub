/* WebDesignHub service worker: fast repeat visits and a basic offline fallback. */
var V="wdh-v1";
self.addEventListener("install",function(e){e.waitUntil(caches.open(V).then(function(c){return c.addAll(["./"]);}).then(function(){return self.skipWaiting();}));});
self.addEventListener("activate",function(e){e.waitUntil(caches.keys().then(function(ks){return Promise.all(ks.filter(function(k){return k!==V;}).map(function(k){return caches.delete(k);}));}).then(function(){return self.clients.claim();}));});
self.addEventListener("fetch",function(e){
  var r=e.request,u=new URL(r.url);
  if(r.method!=="GET"||u.origin!==location.origin) return;
  if(r.mode==="navigate"){
    e.respondWith(fetch(r).then(function(res){var c=res.clone();caches.open(V).then(function(k){k.put(r,c);});return res;}).catch(function(){return caches.match(r).then(function(m){return m||caches.match("./");});}));
    return;
  }
  e.respondWith(caches.match(r).then(function(m){
    var net=fetch(r).then(function(res){if(res&&res.ok){var c=res.clone();caches.open(V).then(function(k){k.put(r,c);});}return res;}).catch(function(){return m;});
    return m||net;
  }));
});
