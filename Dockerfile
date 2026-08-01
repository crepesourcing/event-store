FROM ruby:3.4.9-slim-trixie AS builder

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app/

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local without 'development test' && \
    bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

FROM ruby:3.4.9-slim-trixie

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libpq5 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app/

COPY --from=builder /usr/local/bundle /usr/local/bundle

COPY app ./app
COPY config ./config
COPY db ./db
COPY lib ./lib
COPY Rakefile ./

CMD ["rake"]
