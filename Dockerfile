FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Set environment variable untuk Xvfb dan Chrome
ENV DISPLAY=:99
ENV CHROME_PATH=/usr/bin/google-chrome

# 1. Instal dependensi dasar, Python, dan Xvfb
RUN apt-get update && apt-get install -y \
    xvfb \
    wget \
    gnupg \
    ca-certificates \
    libnss3 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    libasound2t64 \
    libxss1 \
    libgbm1 \
    fonts-liberation \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Instal Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 3. Setup Virtual Environment Python & Install library Python (Jaga-jaga jika index.js memanggil bot.py)
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir httpx rich pytz requests urllib3

# 4. INSTAL NODE.JS (Versi 20.x LTS)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 5. Set folder kerja dan copy file
WORKDIR /app
COPY . .

# 6. INSTAL DEPENDENSI NODE.JS (Jika ada file package.json)
RUN if [ -f package.json ]; then npm install; fi

# 7. Jalankan Xvfb di background, lalu jalankan index.js
CMD ["sh", "-c", "Xvfb :99 -screen 0 1280x1024x24 & exec node index.js"]
