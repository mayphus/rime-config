import { spawn } from "node:child_process";
import path from "node:path";

const children = [];
let shuttingDown = false;
const appDir = process.cwd();
const engineDir = path.resolve(appDir, "engine");

function run(name, command, args, cwd = appDir) {
  const child = spawn(command, args, {
    cwd,
    stdio: "inherit",
    shell: false
  });

  children.push(child);

  child.on("exit", (code, signal) => {
    if (shuttingDown) return;

    shuttingDown = true;
    for (const other of children) {
      if (other !== child && !other.killed) other.kill("SIGTERM");
    }

    if (signal) {
      process.kill(process.pid, signal);
    } else {
      process.exit(code ?? 1);
    }
  });

  return child;
}

run("engine", "racket", ["web.rkt"], engineDir);
run("server", "bun", ["run", "scripts/server.mjs"]);
run("watch", "clojure", ["-M:shadow", "watch", "app"]);

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => {
    if (shuttingDown) return;
    shuttingDown = true;

    for (const child of children) {
      if (!child.killed) child.kill("SIGTERM");
    }

    process.exit(0);
  });
}
