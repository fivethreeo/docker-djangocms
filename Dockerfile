FROM gliderlabs/alpine:3.1
MAINTAINER Øyvind Saltvik "oyvind@gmail.com"

# set your values here:
ENV CMS_ADMIN_USERNAME admin
ENV CMS_ADMIN_EMAIL nobody@example.com
ENV CMS_ADMIN_PASSW djangocms

RUN apk add --update \
    python \
    python-dev \
    zlib \
    zlib-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev \
    py-virtualenv \
    uwsgi \
    uwsgi-python \
    build-base \
    curl \
    git \
  && rm -rf /var/cache/apk/*
  
# see http://docs.docker.com/articles/dockerfile_best-practices/

RUN mkdir -p /opt/djangocms
WORKDIR /opt/djangocms

RUN cp -R /lib/* /usr/lib/

COPY requirements.txt /opt/djangocms/
RUN pip install -r requirements.txt

RUN pip install pillow

RUN djangocms \
  --i18n=yes \
  --use-tz=yes \
  --timezone=Europe/London \
  --reversion=yes \
  --permissions=yes \
  --languages=en \
  --django-version=stable \
  --bootstrap=yes \
  --starting-page=no \
  --db="sqlite:////opt/djangocms/default.db" \
  --parent-dir . \
  --cms-version=stable \
  --no-input \
  --no-sync \
  -s \
    default

COPY requirements-django.txt /opt/djangocms/
RUN pip install -r requirements-django.txt

RUN python manage.py migrate --noinput

COPY create_superuser.sh /opt/djangocms/
RUN sh create_superuser.sh

EXPOSE 80

CMD ["uwsgi", "--master", "--http-socket=:80", "--plugin=python", "--module=default.wsgi"]

