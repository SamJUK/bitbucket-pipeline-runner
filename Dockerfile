ARG BITBUCKET_RUNNER_VERSION='3.10.0'
FROM docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner:${BITBUCKET_RUNNER_VERSION}

RUN apt-get update -y && apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends jq uuid-runtime

COPY start.sh start.sh
RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]