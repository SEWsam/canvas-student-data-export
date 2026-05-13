# syntax=docker/dockerfile:1
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim as base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    nodejs \
    npm \
    gosu \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=requirements.txt \
    python -m pip install -r requirements.txt

RUN --mount=type=cache,target=/root/.npm \
    --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    npm ci

RUN mkdir /output /config

COPY export.py singlefile.py entrypoint.sh /app/
RUN chmod +x /app/entrypoint.sh

VOLUME /output
VOLUME /config

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["python", "export.py", "-c", "/config/credentials.yaml", "-o", "/output/", "--singlefile"]
