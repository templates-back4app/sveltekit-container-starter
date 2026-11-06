# Local measurements — 2026-11-06

Machine: Apple M5, macOS 26.5.2. Docker: colima VM (docker 29.5.2, linux/aarch64, 4 CPUs, 8 GB) — Docker Desktop was not installed on the work machine, so the docker CLI + colima were installed via Homebrew.
Node v22.23.4 / npm 10.9.9 (host builds; images use `node:22-alpine`).

Packages: @sveltejs/kit@3.1.1, @sveltejs/adapter-node@6.0.1, svelte@5.57.3, vite@8.3.6.

| Metric | Value | Command |
|---|---|---|
| npm ci | 2.6–2.8 s | `rm -rf node_modules && time npm ci` |
| npm run build | 1.6 s | `time npm run build` |
| Output folder | 1.6 MB (`build/`) | `du -sh build` |
| docker build (no cache) | 13–15 s | `time docker build --no-cache -t sveltekit-container-starter .` |
| Image size | 237 MB | `docker images --format '{{.Size}}'` |
| First-load JS (gzip) | 32,171 B (~31.4 KB) across 9 files | see method below |

First-load JS method: `docker run -p 8091:8080 …`, `curl http://localhost:8091/`, collect every `.js` URL referenced from the page (script `src` + `rel="modulepreload"` links), then `curl -H 'Accept-Encoding: gzip' -o /dev/null -w '%{size_download}'` each and sum. adapter-node precompresses assets and serves `Content-Encoding: gzip` (verified via response headers), so these are true gzipped transfer sizes.

Notes / pitfalls:
- SvelteKit 3 / sv CLI no longer writes `svelte.config.js` for the minimal template — the adapter is configured inside `vite.config.ts` (`sveltekit({ adapter: adapter() })`). We swapped `@sveltejs/adapter-auto` for `@sveltejs/adapter-node` there.
- `vite build` with adapter-node crashed on Node 25 (`ERR_INVALID_ARG_VALUE: … Received 'grey'` from `util.styleText`); builds were done on Node 22 (the deploy target anyway).
- The built server is `node build` (build/index.js); it binds `HOST`/`PORT` env vars. The minimal app has no production dependencies, so the runtime image needs only `build/` + `package.json` (for `"type": "module"`).
