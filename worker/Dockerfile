FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd -m appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD pgrep -f worker.py || exit 1

CMD ["python", "worker.py"]