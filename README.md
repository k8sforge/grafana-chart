# Grafana Helm Chart Repository

![Auto Tag Release](https://github.com/k8sforge/grafana-chart/actions/workflows/chart-releaser.yml/badge.svg)

This is a Helm chart repository for the [Grafana](https://grafana.com/docs/grafana/latest/) Helm chart.

## Quick Start

### Add the Repository

```bash
helm repo add grafana https://k8sforge.github.io/grafana-chart
helm repo update
```

### Install the Chart

```bash
helm install my-grafana grafana/grafana --version <version>
```

### List Available Versions

```bash
helm search repo grafana/grafana --versions
```

## Chart Information

- **Chart Name**: `grafana`
- **Repository**: `https://k8sforge.github.io/grafana-chart`
- **Latest Version**: See [index.yaml](index.yaml) for available versions

## Documentation

For complete documentation, configuration options, and examples, visit the [main repository](https://github.com/k8sforge/grafana-chart).

## Alternative: OCI Installation

This chart is also available via OCI registry:

```bash
helm install my-grafana \
  oci://ghcr.io/k8sforge/grafana-chart/grafana \
  --version <version>
```

## Support

- **Issues**: [GitHub Issues](https://github.com/k8sforge/grafana-chart/issues)
- **Source Code**: [GitHub Repository](https://github.com/k8sforge/grafana-chart)
