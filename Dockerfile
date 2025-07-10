FROM lscr.io/linuxserver/code-server:latest

# 패키지 업데이트 및 필요한 도구 설치
RUN apt-get update && \
    apt-get install -y \
        clang \
        zsh \
        git \
        curl \
        wget \
        vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# uv 설치
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 칼리 리눅스 스타일 zshrc 다운로드 및 설정
RUN wget -O /config/.zshrc https://gist.githubusercontent.com/noahbliss/4fec4f5fa2d2a2bc857cccc5d00b19b6/raw/kali-zshrc && \
    chown abc:abc /config/.zshrc

ENV PATH="/config/.local/bin:$PATH"
# VIRTUAL_ENV 환경변수 제거
ENV VIRTUAL_ENV=""

# 확장프로그램 설치 스크립트 생성
RUN mkdir -p /etc/services.d/install-extensions && \
    echo '#!/usr/bin/with-contenv bash\n\
if [ ! -f /config/.extensions_installed ]; then\n\
    sleep 10  # code-server 시작 대기\n\
    /app/code-server/lib/vscode/bin/remote-cli/code-server --install-extension llvm-vs-code-extensions.vscode-clangd\n\
    /app/code-server/lib/vscode/bin/remote-cli/code-server --install-extension ms-python.python\n\
    touch /config/.extensions_installed\n\
fi\n\
sleep infinity' > /etc/services.d/install-extensions/run && \
    chmod +x /etc/services.d/install-extensions/run

# abc 사용자의 기본 쉘을 zsh로 변경
RUN chsh -s /bin/zsh abc

# 작업 디렉토리 생성
RUN mkdir -p /config/workspace && \
    chown -R abc:abc /config/workspace
