FROM ruby:2.7.1
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -y build-essential git vim yarn && rm -rf /var/lib/apt/lists/*
WORKDIR /mtk
# Create known_hosts
COPY Gemfile /mtk/Gemfile
COPY Gemfile.lock /mtk/Gemfile.lock

RUN bundle install

COPY docker-entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENTRYPOINT ["docker-entrypoint.sh"]