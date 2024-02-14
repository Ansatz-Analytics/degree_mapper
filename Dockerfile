# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-alpine3.19 as base

# Prevents Python from writing pyc files.
ENV PYTHONDONTWRITEBYTECODE=1

# Keeps Python from buffering stdout and stderr to avoid situations where
# the application crashes without emitting any logs due to buffering.
ENV PYTHONUNBUFFERED=1

WORKDIR /degree_mapper

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a cache mount to /root/.cache/pip to speed up subsequent builds.
# Leverage a bind mount to requirements.txt to avoid having to copy them into
# into this layer.
RUN set -xe

RUN apk update && apk upgrade && \
  apk add --no-cache gcc g++ musl-dev curl libffi-dev \
  postgresql-dev zlib-dev jpeg-dev freetype-dev

# Tell Poetry where to place its cache and virtual environment
ENV PATH="/root/.local/bin:$PATH"


# install poetry to manage python dependencies
RUN curl -sSL https://install.python-poetry.org | python3 -

# # install python dependencies

COPY ./pyproject.toml .
COPY ./poetry.lock .
RUN poetry config virtualenvs.create false --local
RUN poetry install

# # Copy the source code into the container.
COPY . .

# # Expose the port that the application listens on.
EXPOSE 8000

# # Run the application.
# RUN cd degree_mapper
CMD ["poetry", "run", "python3", "degree_mapper/manage.py", "runserver"] 
# CMD /app/scripts/start_server.sh