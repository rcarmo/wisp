A little Clojure-like LISP in JavaScript — this fork focuses on portable, standalone binaries and a minimal Docker image while keeping browser usage intact.

**Quick start: standalone binaries**
- Prebuilt Bun-compiled CLIs live in `dist/` (e.g., `wisp-bun-linux-x64`).
- Run directly: `./dist/wisp-bun-linux-x64 --help`.
- Build your own: `make cli-bin` (host arch) or `make cli-bin-all` for `bun-linux-x64`, `bun-linux-arm64`, `bun-darwin-x64`, `bun-darwin-arm64`.

**Quick start: Docker image**
- Scratch-based image published to GHCR (built from the Bun-compiled binary).
- Run: `docker run --rm ghcr.io/rcarmo/wisp:latest --help`.
- Use for compilation: `docker run --rm -v "$PWD:/src" -w /src ghcr.io/rcarmo/wisp:latest myscript.wisp`.

**Browser usage (unchanged)**
1. Read about the [language essentials & documentation](./doc/language-essentials.md).
2. Drop [wisp.min.js](https://github.com/Gozala/wisp/raw/gh-pages/dist/wisp.min.js) into your HTML code:

```html
<script src="wisp.min.js"></script>

<script type="application/wisp">
  (alert "Hello world!")
</script>

<!-- Load from a file: -->
<script type="application/wisp" src="my-script.wisp"></script>
```

**Build from source**
- Install deps: `bun install` (preferred) or `npm install`.
- Build everything: `bun run build` (Makefile auto-detects Bun, falls back to Node).
- Tests: `bun run test`.
- Force Node: `JS_RUNTIME=node make all`.

**About this fork**
- Bun-first tooling for faster local builds and minified browser bundles.
- Self-contained Bun-compiled CLI binaries and a scratch-based Docker image targeting multiple architectures.
- Source: https://github.com/rcarmo/wisp

Wisp is currently in maintenance mode. We're merging PRs but not actively writing new code.
