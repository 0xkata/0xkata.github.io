# Use a Ruby base image (Debian-based)
FROM ruby:3.1

# Install Jekyll and Bundler
RUN gem install jekyll bundler

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Create a new user with specific UID/GID (matching the host)
RUN groupadd -r -g 1000 appuser && \
    useradd -m -r -u 1000 -g appuser appuser

# Ensure the necessary directories exist
RUN mkdir -p /srv/jekyll && \
    mkdir -p /usr/local/bundle && \
    chown -R appuser:appuser /srv/jekyll /usr/local/bundle /home/appuser

# Switch to the new non-root user
USER appuser

# Set the working directory
WORKDIR /srv/jekyll

# Copy Gemfile and Gemfile.lock (if exists) first
# This layer will be cached if Gemfile does not change
COPY Gemfile* *.gemspec ./

# Install dependencies
RUN bundle

# Copy the rest of your site files
COPY . .

