FROM node:22-slim                                      
                                                                
  RUN apt-get update && apt-get install -y git curl procps python3 make g++ cron unzip
  openssh-client gnupg && rm -rf /var/lib/apt/lists/*                                   
                                                                
  WORKDIR /app                                                                          
                                                                                
  COPY package.json ./                      
  RUN npm install --omit=dev --prefer-online && npm cache clean --force                 
                                   
  ENV PATH="/app/node_modules/.bin:$PATH"                                               
  ENV ALPHACLAW_ROOT_DIR=/data                                                          
                                                                                        
  RUN mkdir -p /data              
                                                                                        
  RUN curl -fsSL https://bun.sh/install | bash                                          
  ENV BUN_INSTALL=/root/.bun                                 
  ENV PATH="/root/.bun/bin:$PATH"                                                       
                                                                                
  RUN git clone --depth 1 https://github.com/garrytan/gbrain.git /opt/gbrain && \
      cd /opt/gbrain && bun install && bun link && \
      ln -sf /root/.bun/bin/gbrain /usr/local/bin/gbrain     
                                   
  RUN mkdir -p /root/.claude/skills && \                                                
      git clone --depth 1 https://github.com/garrytan/gstack.git
  /root/.claude/skills/gstack                                                           
                                                                                
  RUN npm install -g @anthropic-ai/claude-code && claude --version
                                                                                        
  RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd
  of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \                             
      chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \         
      echo "deb [arch=$(dpkg --print-architecture)                                      
  signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg]
  https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
   && \                                                                                 
      apt-get update && apt-get install -y gh && rm -rf /var/lib/apt/lists/*
                                                                                        
  EXPOSE 3000                                                                           
                                                             
  CMD ["alphaclaw", "start"]    
