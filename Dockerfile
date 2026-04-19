FROM node:22-slim

RUN apt-get update \
    && apt-get install -y \
        git curl procps python3 make g++ cron unzip openssh-client jq \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev --prefer-online && npm cache clean --force

ENV PATH="/app/node_modules/.bin:$PATH"
ENV ALPHACLAW_ROOT_DIR=/data
RUN mkdir -p /data

RUN curl -fsSL https://bun.sh/install | bash
ENV BUN_INSTALL=/root/.bun
ENV PATH="/root/.bun/bin:$PATH"

WORKDIR /opt
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

WORKDIR /app
EXPOSE 3000
CMD ["alphaclaw", "start"]
