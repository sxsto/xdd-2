FROM golang:1.16.7-alpine3.14 AS builder

WORKDIR /builder
COPY . /builder

# 编译xdd
RUN set -eux; \
    sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --virtual .build-deps build-base \
    && cd /builder \
    && go build \
    && chmod 777 xdd

FROM whyour/qinglong:latest

ARG QL_VERSION

LABEL maintainer="gcdd1993 <gcwm99@gmail.com>"
LABEL qinglong_version="${QL_VERSION}"

RUN mkdir -p /ql/xdd/conf

COPY docker-entrypoint.sh /ql/docker/docker-entrypoint.sh
COPY --from=builder /builder/xdd /ql/xdd/

# 复制xdd文件
COPY conf/demo_app.conf /ql/xdd/conf/app.conf
COPY conf/demo_config.yaml /ql/xdd/conf/config.yaml
COPY conf/demo_reply.php /ql/xdd/conf/reply.php
COPY theme /ql/xdd/theme
COPY static /ql/xdd/static

# fix /ql/shell/share.sh: line 311: /ql/log/task_error.log: No such file or directory
RUN mkdir -p /ql/xdd \
    && mkdir -p /ql/log \
    && echo "" > /ql/log/task_error.log

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# 初始化生成目录 && fix "permission denied: unknown"
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 青龙默认端口
EXPOSE 5700
# xdd默认端口
EXPOSE 8080

VOLUME /ql/xdd/conf
VOLUME /ql/xdd/data

ENTRYPOINT ["docker-entrypoint.sh"]