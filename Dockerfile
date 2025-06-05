# ---- Builder Stage ----
# Use a lightweight Ruby base image for building
FROM ruby:3.3-slim-bookworm AS builder

# Set environment variables for better behavior in Docker
ENV BUNDLER_VERSION=2.6.9
ENV BUNDLE_PATH=/usr/local/bundle
ENV LANG=C.UTF-8
ENV RACK_ENV=production

# Set the working directory inside the container
WORKDIR /app

# Install required system dependencies for specific gems (e.g., pg, sqlite3)
# build-essential for compiling C extensions, libsqlite3-dev for sqlite3 gem.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock (if you use one) to leverage Docker caching
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
# Configure bundler to exclude development and test groups.
RUN gem install bundler --version "$BUNDLER_VERSION" --no-document && \
    bundle config set without 'development test' && \
    bundle install --jobs $(nproc) --retry 3

# ---- Final Stage ----
# Use a lightweight Ruby base image for the final application
FROM ruby:3.3-slim-bookworm

# Set environment variables for runtime
ENV BUNDLE_PATH=/usr/local/bundle
ENV LANG=C.UTF-8
ENV RACK_ENV=production

# Set the working directory inside the container
WORKDIR /app

# Install only runtime dependencies
# libsqlite3-0 for sqlite3 gem.
# Remove 'sqlite3' (CLI tool) if the application does not use it directly at runtime.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libsqlite3-0 \
    && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user and group for the application
ARG APP_USER=appuser
ARG APP_UID=1001
ARG APP_GID=1001
RUN groupadd --gid $APP_GID $APP_USER && \
    useradd --uid $APP_UID --gid $APP_GID --create-home --shell /bin/bash $APP_USER && \
    mkdir -p /app/db && \
    chown $APP_USER:$APP_USER /app/db

# Copy installed gems from the builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy the rest of your application code
COPY --chown=$APP_USER:$APP_USER . .
# Switch to the non-root user
USER $APP_USER

# Expose the port Sinatra runs on (default is 4567)
EXPOSE 4567

# Command to run the Sinatra application
# 'bundle exec ruby app.rb' ensures gems are loaded from the bundle path
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0"]