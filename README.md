# Grafana Chart

A Helm chart wrapper for Grafana with HA defaults, resource management, and OIDC support.

This chart wraps the official [grafana/grafana](https://github.com/grafana/helm-charts) Helm chart with sensible defaults for production deployments, following the same pattern as [k8sforge/argocd-chart](https://github.com/k8sforge/argocd-chart).

## Features

- **High Availability**: Configurable replicas, PodDisruptionBudget, and anti-affinity rules
- **Resource Management**: Sensible default resource requests and limits
- **Health Checks**: Pre-configured liveness and readiness probes
- **OIDC/OAuth Support**: Generic OIDC/OAuth configuration template (values-driven)
- **ServiceMonitor**: Optional Prometheus ServiceMonitor for metrics scraping
- **Platform Agnostic**: No AWS-specific code (Terraform handles ALB, Cognito, etc.)

## Quick Start

```bash
# Add the repository (when published)
helm repo add k8sforge https://k8sforge.github.io/grafana-chart
helm repo update

# Install with default values
helm install grafana k8sforge/grafana
```

Or install from local chart:

```bash
helm install grafana ./charts/grafana
```

## Configuration

### High Availability

For HA deployments, configure multiple replicas with PodDisruptionBudget:

```yaml
replicaCount: 3

podDisruptionBudget:
  enabled: true
  minAvailable: 2  # Optional: defaults to replicaCount - 1

grafana:
  enabled: true
  replicaCount: 3  # Must match top-level replicaCount
  # Use external database (PostgreSQL/MySQL) for HA
  database:
    type: postgres
    host: postgres.example.com
    name: grafana
    user: grafana
```

**Note**: When setting `replicaCount` for HA, ensure both the top-level `replicaCount` and `grafana.replicaCount` match.

### OIDC/OAuth Configuration

Configure generic OAuth provider (e.g., AWS Cognito, Okta):

```yaml
oidc:
  enabled: true
  name: "Cognito"
  issuer: "https://cognito-idp.region.amazonaws.com/pool-id"
  clientId: "your-client-id"
  clientSecret: "your-client-secret"
  scopes:
    - "openid"
    - "profile"
    - "email"
  roleAttributePath: "groups"
  groupAttributePath: "groups"

grafana:
  enabled: true
  grafana.ini:
    auth:
      generic_oauth:
        enabled: true
        name: Cognito
        client_id: your-client-id
        client_secret: your-client-secret
        scopes: openid,profile,email
        auth_url: https://your-domain.auth.region.amazoncognito.com/oauth2/authorize
        token_url: https://your-domain.auth.region.amazoncognito.com/oauth2/token
        api_url: https://your-domain.auth.region.amazoncognito.com/oauth2/userInfo
        role_attribute_path: groups
        groups_attribute_path: groups
        allow_sign_up: true
        use_pkce: true
```

See [EXAMPLES.md](EXAMPLES.md) for complete OIDC setup examples.

### Resource Management

Default resources can be customized:

```yaml
resources:
  server:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"

grafana:
  enabled: true
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
```

### ServiceMonitor (Prometheus)

Enable Prometheus ServiceMonitor for metrics scraping:

```yaml
monitoring:
  serviceMonitor:
    enabled: true
    interval: "30s"
    labels:
      release: prometheus
```

### Database Configuration

The chart supports SQLite (default), PostgreSQL, and MySQL:

```yaml
database:
  type: postgres  # sqlite, postgres, mysql
  host: postgres.example.com
  name: grafana
  user: grafana
  # password via secret

grafana:
  enabled: true
  database:
    type: postgres
    host: postgres.example.com
    name: grafana
    user: grafana
    existingSecret: grafana-db-secret
    existingSecretPasswordKey: password
```

**Note**: Database provisioning (RDS, etc.) is handled by Terraform, not this chart.

## Values Reference

### Top-level Values (Wrapper)

| Parameter | Description | Default |
| --------- | ----------- | ------- |
| `replicaCount` | Number of Grafana replicas | `1` |
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |
| `affinity` | Pod affinity/anti-affinity rules | `{}` |
| `resources.server` | Resource requests/limits for server | See values.yaml |
| `healthCheck.enabled` | Enable health checks | `true` |
| `healthCheck.path` | Health check path | `"/api/health"` |
| `ingress.enabled` | Enable ingress (disabled - Terraform handles ALB) | `false` |
| `monitoring.serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `oidc.enabled` | Enable OIDC/OAuth | `false` |
| `oidc.name` | OAuth provider name | `""` |
| `oidc.issuer` | OIDC issuer URL | `""` |
| `oidc.clientId` | OAuth client ID | `""` |
| `oidc.clientSecret` | OAuth client secret | `""` |
| `oidc.scopes` | OAuth scopes | `["openid", "profile", "email"]` |
| `oidc.roleAttributePath` | JWT claim path for roles | `""` |
| `oidc.groupAttributePath` | JWT claim path for groups | `""` |
| `oidc.logoutUrl` | Logout URL | `""` |

### Grafana Subchart Values

All values under `grafana` are passed directly to the official [grafana/grafana](https://github.com/grafana/helm-charts) chart. See the [official chart documentation](https://github.com/grafana/helm-charts/tree/main/charts/grafana) for complete reference.

Key values:

- `grafana.enabled`: Enable Grafana subchart (default: `true`)
- `grafana.service`: Service configuration
- `grafana.ingress`: Ingress configuration (disabled by default)
- `grafana.persistence`: Persistence configuration
- `grafana.database`: Database configuration
- `grafana.grafana.ini`: Grafana configuration file
- `grafana.resources`: Resource requests/limits

## Ingress

**Note**: Ingress is disabled by default. AWS ALB ingress is managed by Terraform modules (following the same pattern as ArgoCD).

For non-AWS deployments, you can enable ingress:

```yaml
ingress:
  enabled: true

grafana:
  enabled: true
  ingress:
    enabled: true
    hosts:
      - grafana.example.com
```

## Examples

See [EXAMPLES.md](EXAMPLES.md) for detailed usage examples including:

- Basic installation
- High availability setup
- OIDC/OAuth configuration
- PostgreSQL database setup
- ServiceMonitor configuration
- Complete production example

## Integration with Terraform

This chart is designed to work with Terraform modules that handle:

- AWS ALB ingress creation
- Cognito OIDC configuration (values passed to chart)
- Database provisioning (RDS)
- Secrets management

Example Terraform usage:

```hcl
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://k8sforge.github.io/grafana-chart"
  chart      = "grafana"
  version    = "0.1.0"

  values = [
    yamlencode({
      replicaCount = 3
      oidc = {
        enabled = true
        name    = "Cognito"
        issuer  = var.cognito_issuer_url
        clientId = var.cognito_client_id
        # ... other OIDC config
      }
      grafana = {
        enabled = true
        # ... Grafana config
      }
    })
  ]
}
```

## Requirements

- Kubernetes 1.19+
- Helm 3.0+
- (Optional) Prometheus Operator for ServiceMonitor

## Upgrading

```bash
helm upgrade grafana k8sforge/grafana
```

## Uninstalling

```bash
helm uninstall grafana
```

## License

This chart is licensed under the MIT License. See [LICENSE](LICENSE) file.

The official Grafana chart is licensed under Apache 2.0.

## Contributing

Contributions are welcome! Please open an issue or pull request.

## References

- [Official Grafana Helm Chart](https://github.com/grafana/helm-charts)
- [Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Grafana HA Setup](https://grafana.com/docs/grafana/latest/setup-grafana/set-up-for-high-availability/)
- [Grafana OIDC Documentation](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/generic-oauth/)
- [k8sforge/argocd-chart](https://github.com/k8sforge/argocd-chart) (similar pattern)
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
