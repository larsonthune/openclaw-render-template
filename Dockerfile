FROM node:22.22.2-slim

RUN apt-get update \
    && apt-get install -y \
        git curl procps python3 python3-pip python3-venv make g++ cron unzip openssh-client jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev --prefer-online && npm cache clean --force \
    && ln -sf /app/node_modules/.bin/openclaw /usr/local/bin/openclaw

ENV PATH="/app/node_modules/.bin:$PATH"
ENV ALPHACLAW_ROOT_DIR=/data
RUN mkdir -p /data

RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL=/root/.bun
ENV PATH="/root/.bun/bin:$PATH"

WORKDIR /opt
ARG GBRAIN_CACHE_BUST=2026-06-27
RUN git clone --depth 1 https://github.com/garrytan/gbrain.git
WORKDIR /opt/gbrain
RUN bun install && bun link
RUN ln -sf /root/.bun/bin/gbrain /usr/local/bin/gbrain

RUN mkdir -p /root/.claude/skills
WORKDIR /root/.claude/skills
RUN git clone --depth 1 https://github.com/garrytan/gstack.git

RUN npm install -g @anthropic-ai/claude-code
RUN npm install -g @agentclientprotocol/claude-agent-acp
RUN claude --version && which claude-agent-acp

# --- agent-reach: Reddit, Twitter/X, YouTube, web reader ---
RUN python3 -m venv /opt/agent-reach-venv \
    && /opt/agent-reach-venv/bin/pip install --quiet \
        agent-reach==1.5.0 \
        rdt-cli \
        twitter-cli \
        browser-cookie3 \
    && ln -sf /opt/agent-reach-venv/bin/agent-reach /usr/local/bin/agent-reach \
    && ln -sf /opt/agent-reach-venv/bin/rdt       /usr/local/bin/rdt \
    && ln -sf /opt/agent-reach-venv/bin/twitter   /usr/local/bin/twitter \
    && ln -sf /opt/agent-reach-venv/bin/yt-dlp    /usr/local/bin/yt-dlp \
    && /opt/agent-reach-venv/bin/agent-reach skill --install

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

WORKDIR /app
EXPOSE 3000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["node", "/app/node_modules/@chrysb/alphaclaw/bin/alphaclaw.js", "start"]
