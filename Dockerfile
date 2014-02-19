FROM debian:sid

RUN apt-get update && apt-get install -yq make ruby ruby-dev
RUN gem install --no-rdoc --no-ri jekyll

RUN apt-get update && apt-get install -yq python-pygments

ADD . /blog
WORKDIR /blog

EXPOSE 4000
CMD ["jekyll", "serve"]
