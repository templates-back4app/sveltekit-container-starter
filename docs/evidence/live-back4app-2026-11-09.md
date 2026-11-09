# Live deploy — Back4app Containers — 2026-11-09

App: spoke-sveltekit (free plan, 0.25 vCPU / 256 MB), created fresh from back4app-templates/container-deploy-lab @ rotation (commit 97c948a = this repo @ ebdb342 + stamp 121b78f3-f3dd-4359-a2a0-d166c5360407). Port 8080 set at creation (the Dockerfile's EXPOSE alone is not adopted — see the React evidence for the failure).

## Why a fresh app per framework
On the free plan with Autodeploy off (paid feature), the dashboard does not learn about new commits: "Deploy the latest commit" rebuilds the commit the platform last saw. Creating the app reads the branch tip fresh — so each framework in this series gets its own app. Recorded as a finding for the tutorials.

## Timeline
- 13:03:59 UTC deploy started at app creation → 13:04:35 public URL serving the stamp. **Creation → live: ~36 s.**

## Public URL (client São Paulo; CloudFront edge; fresh deploy)
- SSR verified: the served HTML contains the rendered page content (<h1>Welcome to SvelteKit) — not an empty shell.
- First-load JS: **32,171 B gzip across 9 files** (all modulepreload entries in the HTML; Content-Encoding: gzip, via CloudFront) — matches the local measurement (32.2 KB).
- TTFB on / (3 requests, illustrative): 1.075 s · 1.078 s · 3.462 s (third request an outlier, reported as observed).
- HTML /: 2,007 B gzip.
- Note: SvelteKit's preload links are relative (./_app/…) — scripts that join URLs naively measure 0 bytes. Ours did, once.

Local measurements: docs/evidence/local-measurements-2026-11-06.md
