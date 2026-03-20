FROM python:3.14-slim

ENV PATH="/root/.local/bin:$PATH"

ARG TSF_CORE_VERSION=12202

WORKDIR /app

# System deps needed to build wheels
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    gh \
    git \
    jq \
    yq \
    && rm -rf /var/lib/apt/lists/*

# Install TSF trudag tool
RUN <<EOF 
tsf_base_url=https://gitlab.eclipse.org/api/v4/projects
pip install requests
pip install trustable --index-url ${tsf_base_url}/$TSF_CORE_VERSION/packages/pypi/simple
EOF

# Copy application code
COPY scripts/*.sh /app/

# Ensure entrypoint is executable
RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/entrypoint.sh"]
