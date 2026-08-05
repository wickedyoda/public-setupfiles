FROM python:3.12-alpine

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY uptime-bot.py /app/uptime-bot.py
COPY config.yml /app/config.yml
COPY container-monitor-map.yaml /app/container-monitor-map.yaml

ENV UPTIME_BOT_CONFIG=/app/config.yml
ENV UPTIME_BOT_MAP=/app/container-monitor-map.yaml

CMD ["python", "/app/uptime-bot.py"]
