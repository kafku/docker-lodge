FROM ruby:2.2.0

RUN apt-get update
RUN apt-get install -y --no-install-recommends wget nodejs sqlite3
RUN apt-get clean

# download lodge
ENV LODGE_VERSION 0.10.1
RUN wget --no-check-certificate https://github.com/lodge/lodge/archive/v${LODGE_VERSION}.tar.gz
RUN tar xf v${LODGE_VERSION}.tar.gz
RUN ln -s /lodge-${LODGE_VERSION} lodge
WORKDIR /lodge
RUN gem install bundler

# configure database
RUN printf "default: &default\n\
  adapter: sqlite3\n\
  encoding: utf8\n\
  pool: 5\n\
\n\
production:\n\
  <<: *default\n\
  database: /db/lodge_production.sqlite3\n\
"> ./config/database.yml

RUN bundle install --path vendor/bundle
RUN sed -ie 's/serve_static_assets/serve_static_files/' \
  ./config/environments/production.rb

# set env
ENV DELIVERY_METHOD smtp
ENV SMTP_PORT 587
ENV SMTP_AUTH_METHOD plain
ENV SMTP_ENABLE_STARTTLS_AUTO true
ENV LODGE_THEME lodge

RUN mkdir /lodge/tmp/
RUN printf "#!/bin/bash\n\
_term() {\n\
	kill -Term $child 2>/dev/null\n\
}\n\
\n\
export SECRET_KEY_BASE=`bundle exec rake secret`\n\
export DEVISE_SECRET_KEY=`bundle exec rake secret`\n\
if [ ! -e /db/lodge_production.sqlite3 ] \n\
then\n\
	bundle exec rake db:create RAILS_ENV=production\n\
	bundle exec rake db:migrate RAILS_ENV=production\n\
fi\n\
exec bundle exec unicorn -c config/unicorn.rb -E production &\n\
echo Lodge is running\n\
\n\
child=\$!\n\
wait \$child\n" > start_lodge.sh

RUN chmod 775 start_lodge.sh

VOLUME /lodge/log
VOLUME /db
EXPOSE 3000

CMD ./start_lodge.sh
