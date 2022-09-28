FROM python:3.8.13-slim-bullseye

ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1
ENV PYTHONUNBUFFERED 1
ENV LANG=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1

# Specify label-schema specific arguments and labels.
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="Vyper" \
    org.label-schema.description="Vyper is an experimental programming language" \
    org.label-schema.url="https://vyper.readthedocs.io/en/latest/" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/vyperlang/vyper" \
    org.label-schema.vendor="Vyper Team" \
    org.label-schema.version=$VERSION \
    org.label-schema.schema-version="1.0"

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /code

ADD . /code


# DFLAGS="-Wl,--strip-all"
# coincurve requires libgmp
RUN apt-get update && apt-get install -qqy --no-install-recommends \
        apt-utils \
        gcc \
        git \
        libc6-dev \
        libc-dev \
        libssl-dev \
        libgmp-dev; \
        git reset --hard; \
        pip install --no-cache-dir .[test]; \
        apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
        rm -rf /var/lib/apt/lists/*;


# Remove unecessary libraries
RUN find /python/lib -type d -a \( \
		-name __pycache__ -o \
		-name test -o \
		-name tests -o \
		-name idlelib -o \
		-name idle_test -o \
		-name turtledemo -o \
		-name pydoc_data -o \
		-name tkinter \) \
		-exec rm -rf '{}' +

RUN find /python/lib -type f -a \( \
		-name '*.a' -o \
		-name '*.pyc' -o \
		-name '*.pyo' -o \
		-name '*.exe' \) \
		-exec rm '{}' +

#FROM gcr.io/distroless/python3-debian11:nonroot AS final

#ENV LANG=C.UTF-8 \
#    DEBIAN_FRONTEND=noninteractive \
#    PIP_NO_CACHE_DIR=true

ENTRYPOINT ["/usr/local/bin/vyper"]
