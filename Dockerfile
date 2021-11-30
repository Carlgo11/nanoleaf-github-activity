FROM ruby:3-alpine
RUN apk add --no-cache ruby-bundler build-base libxml2-dev libxslt-dev
RUN echo -e "#!/bin/sh\ncd /nanoleaf;./main.rb >> /var/log/nanoleaf" > /etc/periodic/15min/nanoleaf
RUN chmod +x /etc/periodic/15min/nanoleaf
RUN adduser -DHu 1001 nanoleaf
RUN touch /var/log/nanoleaf; chown 1001 /var/log/nanoleaf
WORKDIR /nanoleaf
RUN chown 1001 .
USER 1001
COPY --chown=1001 ["main.rb", "Gemfile", "effect.json", "/nanoleaf/"]
ENV HOME="/tmp/"
ENV GEM_HOME="/nanoleaf/vendor/bundle"
ENV PATH $GEM_HOME/bin:$GEM_HOME/gems/bin:$PATH
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
CMD ./main.rb >> /var/log/nanoleaf & tail -F /var/log/nanoleaf
