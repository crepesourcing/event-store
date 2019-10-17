FROM ruby:2.6.5

RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app/

COPY Gemfile /usr/src/app/Gemfile
COPY Gemfile.lock /usr/src/app/Gemfile.lock
RUN bundle install

COPY app /usr/src/app/app
COPY config /usr/src/app/config
COPY db /usr/src/app/db
COPY lib /usr/src/app/lib
COPY Rakefile /usr/src/app/Rakefile

CMD ["rake"]
