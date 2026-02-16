FROM python:3.14-slim AS builder

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

# System deps needed to build wheels
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install TSF
RUN pip install trustable --index-url https://gitlab.eclipse.org/api/v4/projects/12202/packages/pypi/simple

# Copy application code
COPY scripts/*.sh /app

# Ensure entrypoint is executable
RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/entrypoint.sh"]
