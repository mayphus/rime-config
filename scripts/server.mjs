import { existsSync } from "node:fs";
import { readFile } from "node:fs/promises";
import path from "node:path";

const cwd = process.cwd();
const port = Number(process.env.PORT || 4173);
const engineBase = (process.env.RIME_CONFIG_API_URL || "http://127.0.0.1:5001").replace(/\/$/, "");
const staticOnly = process.env.RIME_CONFIG_STATIC === "1";

const publicDir = path.join(cwd, "app", "public");
const distDir = path.join(cwd, "dist");

const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".txt": "text/plain; charset=utf-8"
};

function contentTypeFor(filePath) {
  return contentTypes[path.extname(filePath)] || "application/octet-stream";
}

function safePath(root, pathname) {
  const normalized = pathname === "/" ? "/index.html" : pathname;
  const resolved = path.normalize(path.join(root, normalized));
  return resolved.startsWith(root) ? resolved : null;
}

async function serveFile(filePath) {
  const body = await readFile(filePath);
  return new Response(body, {
    headers: { "content-type": contentTypeFor(filePath) }
  });
}

async function maybeServeStatic(pathname) {
  const publicPath = safePath(publicDir, pathname);
  if (publicPath && existsSync(publicPath)) return serveFile(publicPath);

  const distPath = safePath(distDir, pathname);
  if (distPath && existsSync(distPath)) return serveFile(distPath);

  return null;
}

async function proxyToEngine(request, pathname) {
  const url = new URL(request.url);
  const target = `${engineBase}${pathname.replace(/^\/api\/rime-config/, "")}${url.search}`;

  return fetch(target, {
    method: request.method,
    headers: request.headers,
    body: ["GET", "HEAD"].includes(request.method) ? undefined : request.body,
    duplex: "half"
  });
}

const server = Bun.serve({
  port,
  async fetch(request) {
    const url = new URL(request.url);

    if (!staticOnly && url.pathname.startsWith("/api/rime-config")) {
      return proxyToEngine(request, url.pathname);
    }

    const response = await maybeServeStatic(url.pathname);
    if (response) return response;

    if (!staticOnly) {
      const indexResponse = await maybeServeStatic("/");
      if (indexResponse) return indexResponse;
    }

    return new Response("Not found", { status: 404 });
  }
});

console.log(`rime-config app server listening on http://127.0.0.1:${server.port}`);
if (!staticOnly) {
  console.log(`proxying /api/rime-config/* to ${engineBase}`);
}
