FROM node:22-slim                                  
                                                                                                                  
  RUN apt-get update && apt-get install -y git curl procps python3 make g++ cron unzip && rm -rf
  /var/lib/apt/lists/*                                                                                            
                                                                                
  WORKDIR /app                                                                                                    
                                                      
  COPY package.json ./                                                                                            
  RUN npm install --omit=dev --prefer-online && npm cache clean --force                                           
                                                                                                                  
  ENV PATH="/app/node_modules/.bin:$PATH"                                                                         
  ENV ALPHACLAW_ROOT_DIR=/data                                                                                    
                                                                                                                  
  RUN mkdir -p /data                                  
                                                                                                                  
  # Install bun for gbrain/gstack                                                                                 
  RUN curl -fsSL https://bun.sh/install | bash
  ENV BUN_INSTALL=/root/.bun                                                                                      
  ENV PATH="/root/.bun/bin:$PATH"                                               
                                                     
  # Install gbrain CLI from source (bun-based)
  RUN git clone --depth 1 https://github.com/garrytan/gbrain.git /opt/gbrain && \
      cd /opt/gbrain && bun install && bun link && \                                                              
      ln -sf /root/.bun/bin/gbrain /usr/local/bin/gbrain
                                                                                                                  
  # Install gstack skills for future CC dispatch                                
  RUN mkdir -p /root/.claude/skills && \                                                                          
      git clone --depth 1 https://github.com/garrytan/gstack.git /root/.claude/skills/gstack
                                                                                                                  
  EXPOSE 3000                                                                   
                                     
  CMD ["alphaclaw", "start"]  
