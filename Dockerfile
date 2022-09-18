FROM ruby:2.7.2

RUN apt-get update -qq && apt-get install -y build-essential nodejs yarn imagemagick cron

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN gem install bundler:2.1.2
ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME

COPY package.json ./
COPY yarn.lock ./

ENTRYPOINT bundle exec rake db:setup && \
           bundle exec rails s -b 0.0.0.0
