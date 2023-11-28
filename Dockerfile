FROM alpine
RUN apk add --no-cache make gcc libc-dev ruby-dev ruby-bundler && \
    echo -e "#!/bin/sh\ncd /nanoleaf;./main.rb >> /var/log/nanoleaf" > /etc/periodic/15min/nanoleaf && \
    chmod +x /etc/periodic/15min/nanoleaf && \
    adduser -DHu 1001 nanoleaf && \
    touch /var/log/nanoleaf; chown 1001 /var/log/nanoleaf
WORKDIR /nanoleaf
RUN chown 1001 .
USER 1001
COPY --chown=1001 ["main.rb", "Gemfile", "effect.json", "colors.json", "/nanoleaf/"]
ENV HOME="/tmp/"
ENV GEM_HOME="/nanoleaf/vendor/bundle"
RUN bundle install --jobs=4
CMD ./main.rb >> /var/log/nanoleaf & tail -F /var/log/nanoleaf
