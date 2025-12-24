FROM oven/bun:latest AS builder

WORKDIR /app

ARG TARGETARCH

# Copy prebuilt JS artifacts (produced by the repo tooling) and build a per-arch binary
COPY dist/ ./dist/

RUN case "${TARGETARCH}" in \
		amd64) bun build dist/wisp.js --compile --target=bun-linux-x64 --outfile /wisp ;; \
		arm64) bun build dist/wisp.js --compile --target=bun-linux-arm64 --outfile /wisp ;; \
		*) bun build dist/wisp.js --compile --outfile /wisp ;; \
	esac && \
	chmod +x /wisp

FROM scratch

LABEL org.opencontainers.image.source="https://github.com/rcarmo/wisp" \
		org.opencontainers.image.title="wisp" \
		org.opencontainers.image.description="Wisp CLI compiled with Bun from prebuilt JS" \
		org.opencontainers.image.licenses="BSD-3-Clause"

COPY --from=builder /wisp /wisp

ENTRYPOINT ["/wisp"]
CMD ["--help"]
