#! /bin/bash
version=v$(date "+%Y%m%d")
#version=$QL_VERSION

set -ex
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
# 清理docker镜像
docker rmi whyour/qinglong:latest || true
# 清理build 缓存
docker builder prune

docker build -f Dockerfile -t gcdd1993/qinglong-xdd:latest -t gcdd1993/qinglong-xdd:"$version" .
docker push gcdd1993/qinglong-xdd:latest
docker push gcdd1993/qinglong-xdd:"$version"
