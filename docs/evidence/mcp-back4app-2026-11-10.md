# Deploy through the Back4app MCP — sveltekit-container-starter — 2026-11-10

Repo commit uploaded: `f278bf4` (branch `main`, clean tree).

## Context (same for the 9 starters measured this day)

- Date: 2026-11-10 (all times UTC).
- Account kind: permanent, signed in (`whoami` -> `accountKind: "permanent"`, `limits: {freeAppsUsed: 19, maxFreeApps: 50}` before this run). Apps created on the Free plan.
- Client: Claude Code driving the Back4app MCP connector; terminal on macOS (Node v25.8.1, curl 8.7.1); validation requests left from Sao Paulo (CloudFront POP `GRU1-P5`).
- Upload CLI: `@back4app/cli` 0.3.2, run as `npx -y @back4app/cli upload --url <upload-link>` inside the starter folder. The upload link carries a one-time token and is not recorded here. `create_upload` returned `expiresAt` 15 minutes after the call.
- "create -> READY" below = deployment `createdAt` to the `updatedAt` of the `get_deployment` answer that first said `READY`. It is the platform's own clock, not the wall time of the polling.

## Tools called, in order

`whoami` -> `list_web_apps` -> `create_upload` (no appId) -> CLI upload in the folder -> `create_web_app` -> `get_web_app` -> `get_deployment` (x2) -> `get_web_app` -> `get_runtime_logs` (and once more 20 minutes later)

## Upload (CLI output)

```text
Packing .../sveltekit-container-starter ...
178 file(s), 2.8 MB (3 left out)
Left out, as they may hold secrets: .npmrc. Set what the app needs from them as environment variables of the app.
Sending 130 new file(s) ...
Upload ready.
uploadId: 8896bb4f-3661-47dc-ab1d-28745606b831
manifestSha256: 67ac7adfc4c47fb33c51ba73d89c416787f0a701d3124335651349827f3759ae
```

- Wall time: 19 s.
- The repo tracks 19 files; the CLI packed 178. The folder had a local `build/` (84 files), `.svelte-kit/` (76 files) and `.vscode/` from an earlier local build: the CLI does not read `.gitignore`. Of everything in the folder except `node_modules/` and `.git/` (179 files) only `.npmrc` stayed behind. The Dockerfile build ignores those folders anyway (the builder read the starter's `.dockerignore`).
- `.npmrc` here contains one line, `engine-strict=true`, no secret. It was left out all the same. The build passed without it.

## App and deployment

- `create_web_app` arguments: `name: "mcp-sveltekit"`, `port: 8080`, `uploadId`, `manifestSha256`; `builder` not specified.
- appId `f1015a55-f13d-46fd-ac3e-71f5c099ec5a` · deploymentId `3cf34532-0829-449e-9411-e82339bb5e78`
- App `createdAt` 12:41:33.465Z · deployment `createdAt` 12:41:33.626Z
- Status seen: `BUILDING` / phase `FETCHING_CODE` (12:41:33) -> `READY` (`updatedAt` 12:42:35.947Z) -> **62.3 s**
- Public URL: 404 at 12:41:46, first 200 at 12:42:35.

Settings reported by `get_web_app`:

- `builder`: `DOCKERFILE` · `port`: `8080` · `startCommand`: `null` · `healthCheckPath`: `"/"` · `isStaticSite`: `false` · `rootDir`: `""` · `runtimeVersion`: `null` · `envVarNames`: `[]` · `plan`: `Free` · `source.kind`: `UPLOAD`
- `url`: https://mcpsveltekit-cq5dfdtu.back4.app
- `urlExpiresAt`: 2026-11-10T13:41:33.547Z (60 minutes after the app was created)
- `get_deployment` returned no `suggestions` and no `portDetected` on this deployment.

## Validation on the public URL (12:43Z)

- `GET /` -> 200, `content-type: text/html`, `content-encoding: gzip`, `via: 1.1 ... .cloudfront.net (CloudFront)`, no `server` header. 3,965 B identity, 2,008 B transferred with gzip.
- Served HTML contains the rendered `<h1>`: `Welcome to SvelteKit`.
- JS referenced by the HTML (9 `modulepreload` links with `./` relative paths), bytes transferred with `Accept-Encoding: gzip`:

| File | Status | Bytes |
|---|---|---|
| `_app/immutable/entry/start.DIhydsYk.js` | 200 | 308 |
| `_app/immutable/entry/payload.DSmR2FwN.js` | 200 | 77 |
| `_app/immutable/chunks/DclECHGd.js` | 200 | 828 |
| `_app/immutable/chunks/DDV5wmuZ.js` | 200 | 14,526 |
| `_app/immutable/chunks/D9wmIjYr.js` | 200 | 12,772 |
| `_app/immutable/chunks/DWMX4caJ.js` | 200 | 1,930 |
| `_app/immutable/entry/app.rzdF3AJv.js` | 200 | 536 |
| `_app/immutable/nodes/0.n6gN0Cv4.js` | 200 | 979 |
| `_app/immutable/nodes/2.Tsd8tRE_.js` | 200 | 215 |
| **Total** | | **32,171** |

- JS asset headers (`start.DIhydsYk.js`): `content-encoding: gzip`, `cache-control: public,max-age=31536000,immutable`, `via: ... (CloudFront)`, no `server` header.
- `GET /nope-404` -> 404 (SvelteKit error page, 3,887 B).

## Runtime logs

`get_runtime_logs` returned 0 lines at 12:43Z and again 0 lines at 13:03Z, with the app answering requests in between.

## Not tested

- No Part B test used this repo.
- Form actions, server endpoints, `ORIGIN`/CSRF behaviour behind the proxy, env vars.
- Not tested anywhere in this series: `update_web_app` with a confirmationId, `rollback_web_app`, `confirm_action`, custom domains, env vars at creation, GitHub as the code source through MCP, behaviour after `urlExpiresAt`, a temporary (not signed in) account, the `files` upload path for clients with no terminal.
