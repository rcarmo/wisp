FROM oven/bun:latest AS builder

WORKDIR /app

# Install dependencies for build
COPY package.json bun.lock* ./
RUN bun install --no-save

# Copy source
COPY . .

# Build JS artifacts needed by the CLI and then compile a per-arch binary
ARG TARGETOS
ARG TARGETARCH
RUN JS_RUNTIME=bun make node && \
		mkdir -p /out && \
		case "${TARGETARCH}" in \
			amd64) bun build bin/wisp.js --compile --target=bun-linux-x64 --outfile /out/wisp ;; \
			arm64) bun build bin/wisp.js --compile --target=bun-linux-arm64 --outfile /out/wisp ;; \
			*) echo "Unsupported TARGETARCH=${TARGETARCH}" && exit 1 ;; \
		esac

FROM scratch

LABEL org.opencontainers.image.source="https://github.com/rcarmo/wisp" \
			org.opencontainers.image.title="wisp" \
			org.opencontainers.image.description="Wisp CLI compiled with Bun" \
			org.opencontainers.image.licenses="BSD-3-Clause"

COPY --from=builder /out/wisp /wisp

ENTRYPOINT ["/wisp"]
CMD ["--help"]
