FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Set DISPLAY untuk Xvfb
ENV DISPLAY=:99

# TAMBAHKAN CHROME_PATH (Penting untuk memperbaiki error di log Anda)
ENV CHROME_PATH=/usr/bin/google-chrome

# 1. Instal dependensi dasar + Python & Xvfb
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

# 3. Setup Virtual Environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# 4. Copy & Install Python Requirements
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; \
    else pip install --no-cache-dir httpx rich pytz requests playwright; fi
    # (Saya tambahkan 'playwright' jaga-jaga jika bot Anda menggunakan library ini)

# 5. Copy Sisa File
COPY . .

# 6. Jalankan Xvfb di background, lalu jalankan bot
CMD ["sh", "-c", "Xvfb :99 -screen 0 1280x1024x24 & exec python3 bot.py"]
