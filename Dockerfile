FROM debian:sid

RUN apt-get update && apt-get install -yq build-essential ruby ruby-dev
RUN gem install --no-rdoc --no-ri github-pages

RUN apt-get update && apt-get install -yq python-pygments

ADD . /blog
WORKDIR /blog

EXPOSE 4000
CMD ["jekyll", "serve"]
