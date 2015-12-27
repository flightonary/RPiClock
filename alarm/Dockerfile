# Docker base image
FROM ruby:2.2.0
LABEL environment="development"

# install required packages
RUN apt-get update -qq
RUN apt-get install -y mplayer2 libav-tools supervisor

# build app environment
RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
RUN touch /app/Gemfile.lock
RUN bundle install
