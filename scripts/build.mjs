import { cp, mkdir, rm } from "node:fs/promises";
import { spawn } from "node:child_process";
import path from "node:path";

const cwd = process.cwd();
const distDir = path.join(cwd, "dist");
const publicDir = path.join(cwd, "public");

function run(command, args) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd,
      stdio: "inherit",
      shell: false
    });

    child.on("exit", (code) => {
      if (code === 0) resolve();
      else reject(new Error(`${command} ${args.join(" ")} failed with exit code ${code ?? 1}`));
    });
  });
}

await rm(distDir, { recursive: true, force: true });
await run("clojure", ["-M:shadow", "release", "app"]);
await mkdir(distDir, { recursive: true });
await cp(publicDir, distDir, { recursive: true });
