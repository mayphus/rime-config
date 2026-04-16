#!/usr/bin/env python3

from __future__ import annotations

import argparse
import concurrent.futures
import hashlib
import ipaddress
import json
import os
import posixpath
import re
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode
from urllib.request import Request, urlopen


DEFAULT_REMOTE_ROOT = "/RimeUserData/rime/"
MANIFEST_BASENAME = "yuanshu-sync-manifest"
DEFAULT_PRESERVE_EXACT = {"default.custom.yaml", "installation.yaml", "user.yaml"}
DEFAULT_PRESERVE_DIRS = {"build", "sync"}
DEFAULT_DISCOVERY_CANDIDATES = [
    "192.168.36.157",
    "192.168.36.240",
    "172.20.10.2",
]


@dataclass(frozen=True)
class RemoteItem:
    rel_path: str
    is_dir: bool
    size: int


class SyncError(RuntimeError):
    pass


def info(message: str) -> None:
    print(message, file=sys.stderr)


def normalize_remote_root(path: str) -> str:
    if not path:
        path = DEFAULT_REMOTE_ROOT
    if not path.startswith("/"):
        path = "/" + path
    if not path.endswith("/"):
        path += "/"
    return path


def encode_remote_path(path: str) -> str:
    trailing_slash = path.endswith("/")
    normalized = posixpath.normpath(path)
    if normalized == ".":
        normalized = "/"
    if not normalized.startswith("/"):
        normalized = "/" + normalized
    encoded_parts = [quote(part, safe="") for part in normalized.split("/") if part]
    encoded = "/" + "/".join(encoded_parts)
    if encoded == "//":
        encoded = "/"
    if trailing_slash and encoded != "/" and not encoded.endswith("/"):
        encoded += "/"
    return encoded


def join_remote(root: str, rel_path: str, is_dir: bool = False) -> str:
    joined = posixpath.join(root, rel_path)
    if not joined.startswith("/"):
        joined = "/" + joined
    if is_dir and not joined.endswith("/"):
        joined += "/"
    return joined


def build_url(base_url: str, api_root: str, remote_path: str, query: dict[str, str] | None = None) -> str:
    url = base_url.rstrip("/") + api_root + encode_remote_path(remote_path)
    if query:
        url += "?" + urlencode(query)
    return url


def http_request(
    url: str,
    method: str = "GET",
    data: bytes | None = None,
    headers: dict[str, str] | None = None,
    timeout: float = 10.0,
    retries: int = 3,
) -> tuple[bytes, int, dict[str, str]]:
    headers = headers or {}
    last_error: Exception | None = None
    for attempt in range(1, retries + 1):
        request = Request(url, data=data, headers=headers, method=method)
        try:
            with urlopen(request, timeout=timeout) as response:
                body = response.read()
                return body, response.status, dict(response.headers.items())
        except HTTPError as error:
            body = error.read()
            if error.code >= 500 and attempt < retries:
                time.sleep(0.3 * attempt)
                last_error = error
                continue
            detail = body.decode("utf-8", errors="replace").strip()
            raise SyncError(f"{method} {url} failed with HTTP {error.code}: {detail or error.reason}") from error
        except URLError as error:
            if attempt < retries:
                time.sleep(0.3 * attempt)
                last_error = error
                continue
            raise SyncError(f"{method} {url} failed: {error.reason}") from error
    raise SyncError(f"{method} {url} failed: {last_error}")


def http_json(url: str, timeout: float = 10.0, retries: int = 3) -> tuple[dict, dict[str, str]]:
    body, _, headers = http_request(url, timeout=timeout, retries=retries)
    try:
        return json.loads(body.decode("utf-8")), headers
    except json.JSONDecodeError as error:
        raise SyncError(f"GET {url} returned invalid JSON") from error


def list_remote_dir(base_url: str, remote_dir: str) -> list[RemoteItem]:
    url = build_url(base_url, "/api/resources", remote_dir)
    payload, _ = http_json(url)
    items = []
    for item in payload.get("items", []):
        rel_path = item["name"]
        items.append(
            RemoteItem(
                rel_path=rel_path,
                is_dir=bool(item.get("isDir")),
                size=int(item.get("size") or 0),
            )
        )
    return items


def create_remote_dir(base_url: str, remote_dir: str) -> None:
    url = build_url(base_url, "/api/resources", remote_dir, {"override": "false"})
    http_request(url, method="POST", data=b"", timeout=15.0)


def delete_remote_path(base_url: str, remote_path: str, is_dir: bool) -> None:
    url = build_url(base_url, "/api/resources", remote_path if not is_dir else ensure_dir_path(remote_path))
    http_request(url, method="DELETE", timeout=15.0)


def ensure_dir_path(path: str) -> str:
    return path if path.endswith("/") else path + "/"


def normalize_rel_path(rel_path: str) -> str:
    return rel_path.strip("/")


def path_matches_dir_prefix(rel_path: str, prefixes: Iterable[str]) -> bool:
    clean = normalize_rel_path(rel_path)
    return any(clean == prefix or clean.startswith(prefix + "/") for prefix in prefixes)


def tus_upload_file(base_url: str, remote_file: str, local_file: Path) -> None:
    with local_file.open("rb") as handle:
        tus_upload_bytes(base_url, remote_file, handle.read())


def tus_upload_bytes(base_url: str, remote_file: str, data: bytes) -> None:
    size = len(data)
    url = build_url(base_url, "/api/tus", remote_file, {"override": "true"})
    http_request(
        url,
        method="POST",
        data=b"",
        headers={
            "Tus-Resumable": "1.0.0",
            "Upload-Length": str(size),
        },
        timeout=20.0,
    )
    http_request(
        url,
        method="PATCH",
        data=data,
        headers={
            "Tus-Resumable": "1.0.0",
            "Upload-Offset": "0",
            "Content-Type": "application/offset+octet-stream",
        },
        timeout=max(30.0, size / (256 * 1024)),
    )


def is_preserved(rel_path: str) -> bool:
    clean = normalize_rel_path(rel_path)
    if clean in DEFAULT_PRESERVE_EXACT:
        return True
    if any(clean == directory or clean.startswith(directory + "/") for directory in DEFAULT_PRESERVE_DIRS):
        return True
    parts = [part for part in clean.split("/") if part]
    if any(part.endswith(".userdb") for part in parts):
        return True
    return False


def build_local_tree(source_dir: Path, excluded_dirs: set[str]) -> tuple[set[str], set[str]]:
    local_dirs: set[str] = set()
    local_files: set[str] = set()
    for root, dirs, files in os.walk(source_dir):
        root_path = Path(root)
        rel_root = root_path.relative_to(source_dir).as_posix()
        if rel_root == ".":
            rel_root = ""
        filtered_dirs: list[str] = []
        for directory in dirs:
            rel = posixpath.join(rel_root, directory) if rel_root else directory
            if path_matches_dir_prefix(rel, excluded_dirs):
                continue
            local_dirs.add(rel)
            filtered_dirs.append(directory)
        dirs[:] = filtered_dirs
        for filename in files:
            rel = posixpath.join(rel_root, filename) if rel_root else filename
            if path_matches_dir_prefix(rel, excluded_dirs):
                continue
            local_files.add(rel)
    return local_dirs, local_files


def hash_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build_manifest(source_dir: Path, local_files: set[str]) -> dict[str, dict[str, int | str]]:
    manifest: dict[str, dict[str, int | str]] = {}
    for rel in sorted(local_files):
        local_file = source_dir / rel
        manifest[rel] = {
            "size": local_file.stat().st_size,
            "sha256": hash_file(local_file),
        }
    return manifest


def encode_manifest(manifest: dict[str, dict[str, int | str]]) -> bytes:
    payload = {
        "version": 1,
        "files": manifest,
    }
    return json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")


def manifest_filename(manifest_bytes: bytes) -> str:
    digest = hashlib.sha256(manifest_bytes).hexdigest()[:16]
    return f"{MANIFEST_BASENAME}.{digest}.json"


def is_manifest_marker(rel_path: str) -> bool:
    clean = normalize_rel_path(rel_path)
    return "/" not in clean and clean.startswith(f"{MANIFEST_BASENAME}.") and clean.endswith(".json")


def walk_remote_tree(
    base_url: str,
    remote_root: str,
    excluded_dirs: set[str],
) -> tuple[dict[str, RemoteItem], dict[str, RemoteItem]]:
    remote_dirs: dict[str, RemoteItem] = {}
    remote_files: dict[str, RemoteItem] = {}
    stack: list[tuple[str, str]] = [(remote_root, "")]
    while stack:
        current_remote, rel_root = stack.pop()
        for item in list_remote_dir(base_url, current_remote):
            rel = posixpath.join(rel_root, item.rel_path) if rel_root else item.rel_path
            if item.is_dir:
                remote_dirs[rel] = RemoteItem(rel, True, item.size)
                if not is_preserved(rel) and not path_matches_dir_prefix(rel, excluded_dirs):
                    stack.append((join_remote(remote_root, rel, is_dir=True), rel))
            else:
                remote_files[rel] = RemoteItem(rel, False, item.size)
    return remote_dirs, remote_files


def parse_arp_candidates() -> list[str]:
    try:
        output = subprocess.run(["arp", "-an"], check=True, capture_output=True, text=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return []
    return re.findall(r"\((\d+\.\d+\.\d+\.\d+)\)", output)


def parse_active_subnets() -> list[ipaddress.IPv4Network]:
    try:
        output = subprocess.run(["ifconfig"], check=True, capture_output=True, text=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return []

    active_subnets: list[ipaddress.IPv4Network] = []
    current_iface: str | None = None
    current_ip: str | None = None
    current_mask: str | None = None
    current_active = False

    def flush_current() -> None:
        nonlocal current_iface, current_ip, current_mask, current_active
        if current_active and current_ip and current_mask:
            try:
                network = ipaddress.IPv4Network((current_ip, current_mask), strict=False)
            except ValueError:
                network = None
            if network and current_iface not in {"lo0"} and not current_iface.startswith("utun"):
                if network.num_addresses > 256:
                    network = ipaddress.IPv4Network(f"{current_ip}/24", strict=False)
                active_subnets.append(network)
        current_iface = None
        current_ip = None
        current_mask = None
        current_active = False

    for raw_line in output.splitlines():
        line = raw_line.rstrip()
        if line and not line.startswith("\t") and line.endswith(":") is False and ": flags=" in line:
            flush_current()
            current_iface = line.split(":", 1)[0]
            continue
        if current_iface is None:
            continue
        stripped = line.strip()
        match = re.match(r"inet (\d+\.\d+\.\d+\.\d+) netmask (0x[0-9a-fA-F]+)", stripped)
        if match:
            current_ip = match.group(1)
            mask_int = int(match.group(2), 16)
            current_mask = str(ipaddress.IPv4Address(mask_int))
            continue
        if stripped == "status: active":
            current_active = True
    flush_current()
    unique: list[ipaddress.IPv4Network] = []
    seen = set()
    for network in active_subnets:
        if network not in seen:
            unique.append(network)
            seen.add(network)
    return unique


def candidate_hosts() -> list[str]:
    candidates: list[str] = []
    seen: set[str] = set()

    def add(host: str) -> None:
        if host not in seen:
            seen.add(host)
            candidates.append(host)

    for host in DEFAULT_DISCOVERY_CANDIDATES:
        add(host)
    for host in parse_arp_candidates():
        add(host)
    for network in parse_active_subnets():
        for host in network.hosts():
            add(str(host))
    return candidates


def probe_base_url(base_url: str, timeout: float = 1.5) -> bool:
    try:
        payload, headers = http_json(base_url.rstrip("/") + "/api/resources/", timeout=timeout, retries=1)
    except SyncError:
        return False
    if "GCDWebServer" not in headers.get("Server", ""):
        return False
    items = payload.get("items", [])
    return any(item.get("name") == "RimeUserData" and item.get("isDir") for item in items)


def discover_base_urls(explicit: str | None) -> list[str]:
    if explicit:
        if not probe_base_url(explicit, timeout=3.0):
            raise SyncError(f"Configured Yuanshu base URL is not reachable: {explicit}")
        return [explicit.rstrip("/")]

    candidates = []
    env_base_url = os.environ.get("YUANSHU_BASE_URL")
    if env_base_url and probe_base_url(env_base_url, timeout=3.0):
        candidates.append(env_base_url.rstrip("/"))

    env_host = os.environ.get("YUANSHU_HOST")
    if env_host:
        candidate = env_host if env_host.startswith("http://") or env_host.startswith("https://") else f"http://{env_host}"
        if probe_base_url(candidate, timeout=3.0):
            candidates.append(candidate.rstrip("/"))
            
    if candidates:
        return candidates

    hosts = candidate_hosts()
    info(f"Discovering Yuanshu hosts across {len(hosts)} LAN candidates...")
    valid_urls = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=24) as executor:
        futures = {
            executor.submit(probe_base_url, f"http://{host}"): host
            for host in hosts
        }
        for future in concurrent.futures.as_completed(futures):
            host = futures[future]
            try:
                if future.result():
                    valid_urls.append(f"http://{host}")
            except Exception:
                continue
    if not valid_urls:
        raise SyncError("Unable to discover any reachable Yuanshu WiFi transfer hosts")
    return valid_urls


def sync_bundle(
    source_dir: Path,
    base_url: str,
    remote_root: str,
    dry_run: bool,
    allow_delete: bool,
    excluded_dirs: set[str],
) -> None:
    local_dirs, local_files = build_local_tree(source_dir, excluded_dirs)
    local_manifest = build_manifest(source_dir, local_files)
    local_manifest_bytes = encode_manifest(local_manifest)
    current_manifest_file = manifest_filename(local_manifest_bytes)
    info(f"Using Yuanshu host: {base_url}")
    info(f"Sync source: {source_dir}")
    info(f"Sync destination: {remote_root}")
    if excluded_dirs:
        info("Excluded directories: " + ", ".join(sorted(excluded_dirs)))

    remote_dirs, remote_files = walk_remote_tree(base_url, remote_root, excluded_dirs)
    remote_manifest_files = sorted(rel for rel in remote_files if is_manifest_marker(rel))
    stale_manifest_files = [rel for rel in remote_manifest_files if rel != current_manifest_file]

    deletions: list[tuple[str, bool]] = []
    for rel, item in remote_files.items():
        if is_manifest_marker(rel):
            continue
        if is_preserved(rel) or path_matches_dir_prefix(rel, excluded_dirs):
            continue
        if rel not in local_files:
            deletions.append((rel, False))
    for rel, item in remote_dirs.items():
        if is_preserved(rel) or path_matches_dir_prefix(rel, excluded_dirs):
            continue
        if rel not in local_dirs:
            deletions.append((rel, True))
    deletions.sort(key=lambda entry: entry[0].count("/"), reverse=True)

    creates = sorted(rel for rel in local_dirs if rel not in remote_dirs)
    bundle_in_sync = current_manifest_file in remote_manifest_files and all(
        (rel in remote_files and remote_files[rel].size == local_manifest[rel]["size"])
        for rel in local_files
    )
    uploads = [] if bundle_in_sync else sorted(local_files)
    manifest_changed = not bundle_in_sync

    info(
        "Plan: "
        f"{len(deletions) if allow_delete else 0} delete(s), "
        f"{len(creates)} dir create(s), "
        f"{len(uploads) + (1 if manifest_changed else 0)} file upload(s), "
        f"{len(stale_manifest_files)} marker cleanup(s)"
    )
    if deletions and not allow_delete:
        info("Prune disabled; remote-only files will be left untouched. Use --allow-delete to remove them.")

    if allow_delete:
        for rel, is_dir in deletions:
            action = f"DELETE {'dir' if is_dir else 'file'} {rel}"
            info(action)
            if not dry_run:
                delete_remote_path(base_url, join_remote(remote_root, rel, is_dir=is_dir), is_dir)

    for rel in creates:
        action = f"MKDIR {rel}"
        info(action)
        if not dry_run:
            create_remote_dir(base_url, join_remote(remote_root, rel, is_dir=True))

    for rel in stale_manifest_files:
        action = f"DELETE file {rel}"
        info(action)
        if not dry_run:
            delete_remote_path(base_url, join_remote(remote_root, rel), False)

    for rel in uploads:
        local_file = source_dir / rel
        action = f"UPLOAD {rel}"
        info(action)
        if not dry_run:
            tus_upload_file(base_url, join_remote(remote_root, rel), local_file)
    if manifest_changed:
        action = f"UPLOAD {current_manifest_file}"
        info(action)
        if not dry_run:
            tus_upload_bytes(base_url, join_remote(remote_root, current_manifest_file), local_manifest_bytes)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Sync a built Yuanshu bundle to the app's WiFi file service.")
    parser.add_argument("--source", required=True, help="Local bundle directory to upload")
    parser.add_argument("--remote-root", default=DEFAULT_REMOTE_ROOT, help="Remote Yuanshu directory root")
    parser.add_argument("--base-url", help="Explicit Yuanshu WiFi base URL, for example http://172.20.10.2")
    parser.add_argument("--dry-run", action="store_true", help="Show the sync plan without modifying the phone")
    parser.add_argument(
        "--allow-delete",
        action="store_true",
        help="Delete remote files and directories that are not present locally",
    )
    parser.add_argument(
        "--exclude-dir",
        action="append",
        default=[],
        help="Relative directory under the bundle root to leave untouched on the phone and skip uploading",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    source_dir = Path(args.source).expanduser().resolve()
    if not source_dir.is_dir():
        raise SyncError(f"Source directory does not exist: {source_dir}")

    base_urls = discover_base_urls(args.base_url)
    remote_root = normalize_remote_root(args.remote_root)
    excluded_dirs = {normalize_rel_path(item) for item in args.exclude_dir if normalize_rel_path(item)}
    for base_url in base_urls:
        info(f"--- Syncing to {base_url} ---")
        sync_bundle(source_dir, base_url, remote_root, args.dry_run, args.allow_delete, excluded_dirs)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except SyncError as error:
        print(f"error: {error}", file=sys.stderr)
        raise SystemExit(1)
