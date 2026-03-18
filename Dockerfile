FROM python:3.14-slim

ENV JAVA_HOME=/usr/lib/jvm/openjdk-jre-21
ENV CLASSPATH=/opt/oft/lib
ENV PATH="/root/.local/bin:$JAVA_HOME/bin:$PATH"

ARG TSF_CORE_VERSION=12202
ARG OFT_CORE_VERSION=4.2.2
ARG OFT_ASCIIDOC_PLUGIN_VERSION=0.3.0

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
    openjdk-21-jre-headless \
    wget \
    yq \
    && rm -rf /var/lib/apt/lists/*

# Install TSF trudag tool
RUN <<EOF 
tsf_base_url=https://gitlab.eclipse.org/api/v4/projects
pip install requests
pip install trustable --index-url ${tsf_base_url}/$TSF_CORE_VERSION/packages/pypi/simple
EOF

# Install OpenFastTrace oft tool
RUN <<EOF
mkdir -p $CLASSPATH
oft_base_url=https://github.com/itsallcode
wget -P $CLASSPATH ${oft_base_url}/openfasttrace/releases/download/$OFT_CORE_VERSION/openfasttrace-$OFT_CORE_VERSION.jar
wget -P $CLASSPATH ${oft_base_url}/openfasttrace-asciidoc-plugin/releases/download/$OFT_ASCIIDOC_PLUGIN_VERSION/openfasttrace-asciidoc-plugin-$OFT_ASCIIDOC_PLUGIN_VERSION-with-dependencies.jar
EOF

# Copy application code
COPY scripts/*.sh /app/

# Ensure entrypoint is executable
RUN chmod +x /app/*.sh

ENTRYPOINT ["/app/entrypoint.sh"]
