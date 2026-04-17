ARG RUBY_VERSION=3.3
FROM ruby:${RUBY_VERSION}-slim AS base

# System dependencies shared between dev and prod
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      curl \
      git \
      libpq-dev \
      libvips \
      libyaml-dev \
      pkg-config \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /rails

# ── Gems layer (cached unless Gemfile changes) ──────────────────────────────
FROM base AS gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 3

# ── Production image ─────────────────────────────────────────────────────────
FROM gems AS production
ENV RAILS_ENV=production

COPY . .

# Precompile assets (TailwindCSS build + propshaft)
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile

EXPOSE 3000
CMD ["./bin/thrust", "./bin/rails", "server", "-b", "0.0.0.0"]

# ── Development image (default for local docker-compose) ─────────────────────
FROM gems AS development
WORKDIR /rails
EXPOSE 3000
CMD ["./bin/dev"]
