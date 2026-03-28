FROM debian:bookworm-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ca-certificates python3 python3-pip python3-venv \
    ripgrep fzf \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash lean
USER lean
WORKDIR /home/lean

# Install elan with no default toolchain
RUN curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | bash -s -- -y --default-toolchain none
ENV PATH="/home/lean/.elan/bin:${PATH}"

# --- Lean project (Mathlib toolchain, not user-facing) ---
RUN mkdir -p /home/lean/lean-project
WORKDIR /home/lean/lean-project

COPY --chown=lean:lean docker/lean-toolchain /home/lean/lean-project/lean-toolchain
COPY --chown=lean:lean docker/lakefile.lean /home/lean/lean-project/lakefile.lean

RUN lake update
RUN lake exe cache get
RUN mkdir -p /home/lean/lean-project/Scratch

# --- Python venv for MCP server ---
RUN python3 -m venv /home/lean/venv
ENV PATH="/home/lean/venv/bin:${PATH}"
RUN pip install --no-cache-dir "mcp[cli]>=1.0.0"

# --- Install OpenCode ---
RUN mkdir -p /home/lean/.local/bin
ARG OPENCODE_VERSION=1.3.3
RUN curl -fsSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-linux-x64.tar.gz" \
    | tar xz -C /home/lean/.local/bin/
ENV PATH="/home/lean/.local/bin:${PATH}"

# --- MCP server (baked into image) ---
COPY --chown=lean:lean mcp_server/ /home/lean/mcp_server/

# --- Lean project path for MCP server ---
ENV LAKE_PROJECT="/home/lean/lean-project"

# --- Workspace is mounted at runtime ---
WORKDIR /home/lean/workspace
ENTRYPOINT ["/bin/bash"]
