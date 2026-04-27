# STAGE 1: Build
FROM python:3.12-slim AS builder

WORKDIR /app

# Install Poetry
ENV POETRY_VERSION=1.8.2
RUN pip install "poetry==$POETRY_VERSION"

# Copy config files
COPY pyproject.toml poetry.lock ./

# Generate requirements.txt to keep the final image light
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

# STAGE 2: Final
FROM python:3.12-slim
WORKDIR /app

COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Use Gunicorn with Uvicorn workers for production stability
CMD ["gunicorn", "-k", "uvicorn.workers.UvicornWorker", "main:app", "--bind", "0.0.0.0:8000"]