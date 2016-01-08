#!/bin/bash

ENV=$1

if [ ! -e db/$ENV.sqlite3 ]
then
  rake db:migrate RAILS_ENV=$ENV
fi

if [ $ENV = 'production' ]
then
  rake assets:precompile RAILS_ENV=$ENV
  export SECRET_KEY_BASE=$(rake secret)
  export RAILS_SERVE_STATIC_FILES=true
fi

bundle exec rails s -e$ENV -p 3000 -b '0.0.0.0'
