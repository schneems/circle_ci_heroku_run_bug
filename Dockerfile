FROM circleci/ruby:2.7

RUN curl https://cli-assets.heroku.com/install.sh | sh

COPY --chown=circleci:circleci . /sscce

WORKDIR /sscce

CMD ./script.sh
