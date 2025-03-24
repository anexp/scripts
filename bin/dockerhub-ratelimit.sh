#!/bin/sh

# https://stackoverflow.com/questions/64736174/how-much-pull-left-for-docker-hub-rate-limit

dockerhub_rate_limit() {

TOKEN=$(curl "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
curl -v -I -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest 2>&1 | grep -i RateLimit

}

dockerhub_rate_limit
