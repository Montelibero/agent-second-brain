FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# базовые системные зависимости
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    curl \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ---------- Node.js (как в README) ----------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
 && apt-get install -y --no-install-recommends nodejs \
 && npm install -g @anthropic-ai/claude-code \
 && rm -rf /var/lib/apt/lists/*

# ---------- uv ----------
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# ---------- зависимости Python ----------
COPY pyproject.toml uv.lock* ./
RUN uv sync --no-dev --no-install-project

# ---------- код ----------
COPY . .

ENV PYTHONPATH=/app/src

# ---------- запуск ----------
CMD ["uv", "run", "--no-project", "python", "-m", "d_brain"]
