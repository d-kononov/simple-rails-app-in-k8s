FROM ruby:2.5.1-slim
LABEL Description="Simple rails app" Mainteiner="Dmitriy Kononov"

RUN apt update && apt-get install -y --force-yes libpq-dev libmariadbclient-dev libsqlite3-dev wget nodejs build-essential \
  && wget -q https://github.com/jwilder/dockerize/releases/download/v0.2.0/dockerize-linux-amd64-v0.2.0.tar.gz \
  && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v0.2.0.tar.gz \
  && apt-get clean \
  && cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* \
  && truncate -s 0 /var/log/*log

WORKDIR /app
ENV RAILS_ENV production

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test
ADD . /app
RUN SECRET_KEY_BASE=`bin/rake secret` bin/rake assets:precompile

ENTRYPOINT ["bundle", "exec"]
