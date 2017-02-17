FROM ruby:2.3-onbuild

ARG APP_ENV=development
ENV RAILS_ENV ${APP_ENV}
ENV RACK_ENV none

CMD ["rake"]
