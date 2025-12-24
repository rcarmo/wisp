FROM oven/bun:latest AS builder

WORKDIR /app

ARG TARGETARCH

# Build tooling
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
	apt-get install -y --no-install-recommends make ca-certificates && \
	rm -rf /var/lib/apt/lists/*

# Install deps without triggering prepare scripts (we drive builds explicitly)
COPY package.json bun.lock* ./
RUN bun install --no-save --no-scripts

# Copy source and build node-target JS, then compile the CLI binary per arch
COPY . .
RUN JS_RUNTIME=bun make node && \
	case "${TARGETARCH}" in \
		amd64) bun build bin/wisp.js --compile --target=bun-linux-x64 --outfile /wisp ;; \
		arm64) bun build bin/wisp.js --compile --target=bun-linux-arm64 --outfile /wisp ;; \
		*) bun build bin/wisp.js --compile --outfile /wisp ;; \
	esac && \
	chmod +x /wisp

FROM gcr.io/distroless/base-debian12:debug

LABEL org.opencontainers.image.source="https://github.com/rcarmo/wisp" \
		org.opencontainers.image.title="wisp" \
		org.opencontainers.image.description="Wisp CLI compiled with Bun from prebuilt JS" \
		org.opencontainers.image.licenses="BSD-3-Clause"

COPY --from=builder /wisp /wisp

ENTRYPOINT ["/wisp"]
CMD ["--help"]
