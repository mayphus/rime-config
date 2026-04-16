const API_BASE = "/api/rime-config";

async function serveAsset(request, env, pathname) {
  const url = new URL(request.url);
  url.pathname = pathname === "/" ? "/index.html" : pathname;
  return env.ASSETS.fetch(new Request(url.toString(), request));
}

async function proxyEngine(request, env) {
  const incoming = new URL(request.url);
  const origin = (env.RIME_CONFIG_ENGINE_ORIGIN || "http://127.0.0.1:5001").replace(/\/$/, "");
  const target = new URL(origin + incoming.pathname.replace(API_BASE, "") + incoming.search);

  return fetch(target, {
    method: request.method,
    headers: request.headers,
    body: ["GET", "HEAD"].includes(request.method) ? undefined : request.body,
    duplex: "half"
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname.startsWith(API_BASE)) {
      return proxyEngine(request, env);
    }

    return serveAsset(request, env, url.pathname);
  }
};
