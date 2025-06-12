---
title: Project Information
---

# REMLA A1 - Team 17

operation: https://github.com/remla25-team17/operation/tree/a3 \
model training: https://github.com/remla25-team17/model-training/tree/a1 \
model service: https://github.com/remla25-team17/model-service/tree/a1 \
lib-ml: https://github.com/remla25-team17/lib-ml/tree/a1 \
lib-version: https://github.com/remla25-team17/lib-version/tree/a1 \
app: https://github.com/remla25-team17/app/tree/a3

## Comments for A1:

### Versioning & Releases

**Automated Release Process**
We have implemented everything up to the excellent requirements apart from

- _The Dockerfile uses multiple stages, e.g., to reduce image size by avoiding apt cache in image._

**Software Reuse in Libraries**
We have implemented everything up to and including the excellent requirements.

### Containers & Orchestration

**Exposing a Model via REST**
We have implemented everything up to and including the excellent requirements.

**Docker Compose Operation**
We have implemented everything up to and including the excellent requirements.

## Comments for A2:

### Setting up (Virtual) Infrastructure

We have implemented everything up to and including the excellent requirements.

### Setting up Software Environment

We have implemented everything up to and including the excellent requirements.

### Setting up Kubernetes

We have implemented everything up to and including the excellent requirements.

## Comments for A3:

### Kubernetes Usage

We have implemented everything up to and including the excellent requirements.

### Helm Installation

We have implemented everything up to and including the excellent requirements.

### App Monitoring

We have implemented everything up to and including the excellent requirements.

### Grafana

We have implemented everything up to and including the sufficient requirements and also the excellent requirement.
From the good requirements, we have implemented the following:

- The dashboard employs variable timeframe selectors to parameterize the queries.
- The dashboard applies functions (like rate or avg ) to enhance the plots.
  From the good requirements, we have not implemented the following:
- The dashboard contains specific visualizations for Gauges and Counters

## Comments for A4:

For more information on each step, please visit the README in model-training.

### Automated Tests

We have implemented everything up to and including the excellent requirements.

### Continuous Training

We have implemented everything up to and including the excellent requirements.

### Project Organization

We have implemented everything up to and including the excellent requirements.

### Pipeline Management with DVC

We have implemented everything up to and including the excellent requirements.

### Code quality

We have implemented everything up to and including part of the excellent requirements. The test adequacy score we have not implemented it yet.

## Comments for A5:

### Traffic Management

We have implemented everything up to and including the excellent requirements.

### Additional Use Case

We have implemented everything up to and including the excellent requirements.

### Continuous Experimentation

We have implemented everything up to the sufficient requirement 'The system implements the metric that allows exploring the concrete hypothesis.' The requirements missing are:

**Sufficient**

- The documentation describes the experiment. It explains the implemented changes, the expected effect that gets experimented on, and the relevant metric that is tailored to the experiment.
- The experiment involves two deployed versions of at least one container image.
- Both component versions are reachable through the deployed experiment.

**Good**

- Prometheus picks up the metric.
- Grafana has a dashboard to visualize the differences and support the decision process.
- The documentation contains a screenshot of the visualization.

**Excellent**

- The documentation explains the decision process for accepting or rejecting the experiment in details,
  ie.g., which criteria is used and how the available dashboard supports the decision.

### Deployment Documentation

We have implemented everything up to and including the excellent requirements.

### Extension Proposal

We have implemented everything up to and including the excellent requirements.
