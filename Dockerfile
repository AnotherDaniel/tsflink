FROM python:3.14-slim

ENV PATH="/root/.local/bin:$PATH"
WORKDIR /app

# System deps needed to build wheels
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    gh \
    git \
    jq \
    yq \
    && rm -rf /var/lib/apt/lists/*

# Install TSF trudag tool
RUN pip install trustable --index-url https://gitlab.eclipse.org/api/v4/projects/12202/packages/pypi/simple

# Install custom stuff we need around trudag: custom formatters, implied Python modules
RUN pip install requests
COPY .dotstop_extensions/* /app/.dotstop_extensions/

# Copy application code
COPY scripts/*.sh /app/

# Ensure entrypoint is executable
RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/entrypoint.sh"]
