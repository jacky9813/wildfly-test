# Containerized WildFly Application with CI/CD

This repository is a demostration of how I would configure GitHub Action to
build / push container image and deploy to Kubernetes cluster with the help
of [Kustomize](https://kustomize.io/).

#### Note

The source code of the WildFly Application is derived from the
[WildFly Quickstart Hello World](https://github.com/wildfly/quickstart/tree/main/helloworld).

I added `/redirect-http` and `redirect-https` for testing purpose.
