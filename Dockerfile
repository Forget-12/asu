# Menggunakan Ubuntu 24.04 sebagai base image
FROM ubuntu:24.04

# Menghindari prompt interaktif saat apt-get install
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variable untuk Xvfb (Virtual Display)
ENV DISPLAY=:99

# 1. Instal dependensi dasar (sesuai request Anda) + Python & Xvfb
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

# 2. Tambahkan repo Google dan instal Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 3. Setup Virtual Environment untuk Python (menghindari error PEP 668 di Ubuntu 24.04)
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 4. Setup Working Directory dan copy file
WORKDIR /app

# Copy requirements.txt jika ada, lalu install. 
# Jika tidak ada, kita install manual library yang dipakai script bot Anda
COPY requirements.txt* ./
RUN if [ -f requirements.txt ]; then pip install --no-cache-dir -r requirements.txt; \
    else pip install --no-cache-dir httpx rich pytz requests; fi

# Copy seluruh file project (bot.py, dll)
COPY . .

# 5. Jalankan Xvfb di background, lalu jalankan bot.py
# Menggunakan 'exec' agar signal SIGTERM (Ctrl+C / Docker stop) diteruskan ke Python dengan baik
CMD ["sh", "-c", "Xvfb :99 -screen 0 1280x1024x24 & exec python3 bot.py"]
