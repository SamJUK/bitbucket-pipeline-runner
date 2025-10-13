# Bitbucket Pipeline Runner

Self contained dockerized Bitbucket Pipeline Runner based from https://testdriven.io/blog/github-actions-docker/

## Usage

The container requires a few environment variables to be set. 

VAR | Purpose | Example
--- | --- | ---
`WORKSPACE` | Bitbucket workspace to register the runner within `acme`
`AUTH_USER` | Email authentication token is assigned to | `user@example.com`
`AUTH_PWD` | Personal API token | `XXXXXXXXXXXXXXXXX`
`AUTH_TOKEN` | Workspace Authentication Token | `XXXXXXXXXXXXXXXXXX`

### Authentication

This image is designed to work with both personal API tokens & workspace API tokens.

The auth token requires the following scopes:
- `read:runner:bitbucket`
- `write:runner:bitbucket`
- `read:user:bitbucket`

### Docker run
```sh
docker run -e WORKSPACE=acme -e AUTH_USER=user@example.com -e AUTH_PWD=xxxx \
    samjuk/bitbucket-pipeline-runner:latest
```

### Docker Compose
```yaml
services:
  runner:
    image: samjuk/bitbucket-pipeline-runner:latest
    environment:
      WORKSPACE: acme
      AUTH_USER: user@example.com
      AUTH_PWD: xxxx
```

### K8s
```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bpr-runner
  namespace: default
spec:
  replicas: 3
  template:
    spec:
      containers:
        - name: runner
          image: samjuk/bitbucket-pipeline-runner:latest
          imagePullPolicy: IfNotPresent
          env:
            - name: WORKSPACE
              value: ACME
            - name: AUTH_USER
              value: user@example.com
            - name: AUTH_PWD
              value: xxxx
```