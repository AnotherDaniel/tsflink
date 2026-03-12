# Stage 1: Build environment with OpenJDK
FROM eclipse-temurin:21-jdk-slim AS java

# Stage 2: Final slim image with OpenJDK
FROM python:3.14-slim

# Copy the Java runtime from the java
COPY --from=java /usr/lib/jvm/java-21-openjdk-amd64 /usr/lib/jvm/openjdk-jre-21

# Set JAVA_HOME and PATH
ENV JAVA_HOME=/usr/lib/jvm/openjdk-jre-21
ENV PATH="/root/.local/bin:$JAVA_HOME/bin:$PATH"
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

# Install TSF trudag tool and some associated Python deps
RUN pip install requests
RUN pip install trustable --index-url https://gitlab.eclipse.org/api/v4/projects/12202/packages/pypi/simple

# Install oft tool to support oft requirements references
RUN curl --location -s -o /app/openfasttrace.jar https://github.com/itsallcode/openfasttrace/releases/download/4.2.2/openfasttrace-4.2.2.jar

# Copy application code
COPY scripts/*.sh /app/

# Ensure entrypoint is executable
RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/entrypoint.sh"]
