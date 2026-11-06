# SvelteKit Container Starter

Minimal SvelteKit app (`sv create`, minimal template) configured with `@sveltejs/adapter-node`, ready to run as a Node server in a container. The server honors the `HOST` and `PORT` env vars (defaults to port 3000; the Dockerfile sets 8080).

Run locally with Docker:

```sh
docker build -t sveltekit-starter .
docker run -p 8080:8080 sveltekit-starter
# open http://localhost:8080
```

Deploy guide: see the Back4app blog post for deploying this repo on Back4app Containers (placeholder — link coming with the tutorial).

Measurements for this exact commit are in `docs/evidence/local-measurements-2026-11-06.md`.
