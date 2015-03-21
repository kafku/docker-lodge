#!/bin/bash
_term() {
	kill -Term $child 2>/dev/null
}

export SECRET_KEY_BASE=`bundle exec rake secret`
export DEVISE_SECRET_KEY=`bundle exec rake secret`
if [ ! -e /db/lodge_production.sqlite3 ]
then
	bundle exec rake db:create RAILS_ENV=production
	bundle exec rake db:migrate RAILS_ENV=production
fi
exec bundle exec unicorn -c config/unicorn.rb -E production && \
echo Lodge is running

child=$!
wait $child

