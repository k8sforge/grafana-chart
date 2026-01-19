# Grafana Chart - Usage Examples

This document provides practical examples for using the Grafana wrapper chart.

## Basic Installation

```bash
helm install grafana ./charts/grafana
```

## High Availability Configuration

```yaml
# values-ha.yaml
replicaCount: 3

podDisruptionBudget:
  enabled: true
  minAvailable: 2

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - grafana
          topologyKey: kubernetes.io/hostname

grafana:
  enabled: true
  # Use external database for HA
  database:
    type: postgres
    host: postgres.example.com
    name: grafana
    user: grafana
```

```bash
helm install grafana ./charts/grafana -f values-ha.yaml
```

## OIDC/OAuth Configuration (Cognito Example)

```yaml
# values-oidc.yaml
oidc:
  enabled: true
  name: "Cognito"
  issuer: "https://cognito-idp.region.amazonaws.com/pool-id"
  clientId: "your-client-id"
  clientSecret: "your-client-secret"  # Or reference from secret
  scopes:
    - "openid"
    - "profile"
    - "email"
  roleAttributePath: "groups"  # JWT claim path for roles
  groupAttributePath: "groups"  # JWT claim path for groups
  logoutUrl: "https://your-domain.auth.region.amazoncognito.com/logout?client_id=your-client-id&logout_uri=https://grafana.example.com"

grafana:
  enabled: true
  grafana.ini:
    server:
      root_url: "https://grafana.example.com"
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
        auth_url_logout: https://your-domain.auth.region.amazoncognito.com/logout?client_id=your-client-id&logout_uri=https://grafana.example.com
        allow_sign_up: true
        use_pkce: true
```

```bash
helm install grafana ./charts/grafana -f values-oidc.yaml
```

## PostgreSQL Database Configuration

```yaml
# values-postgres.yaml
database:
  type: postgres
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
    # password should be provided via existingSecret
    existingSecret: grafana-db-secret
    existingSecretPasswordKey: password
```

## ServiceMonitor for Prometheus

```yaml
# values-monitoring.yaml
monitoring:
  serviceMonitor:
    enabled: true
    interval: "30s"
    labels:
      release: prometheus
```

```bash
helm install grafana ./charts/grafana -f values-monitoring.yaml
```

## Custom Resource Limits

```yaml
# values-resources.yaml
resources:
  server:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "1Gi"
      cpu: "1000m"

grafana:
  enabled: true
  resources:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
```

## Complete Production Example

```yaml
# values-production.yaml
replicaCount: 3

podDisruptionBudget:
  enabled: true
  minAvailable: 2

resources:
  server:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "1Gi"
      cpu: "1000m"

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

monitoring:
  serviceMonitor:
    enabled: true
    interval: "30s"

grafana:
  enabled: true
  service:
    type: ClusterIP
    port: 80
  ingress:
    enabled: false  # Terraform handles ALB
  persistence:
    enabled: true
    storageClassName: gp3
    size: 50Gi
  database:
    type: postgres
    host: postgres.example.com
    name: grafana
    user: grafana
    existingSecret: grafana-db-secret
    existingSecretPasswordKey: password
  grafana.ini:
    server:
      root_url: "https://grafana.example.com"
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
  resources:
    requests:
      memory: "512Mi"
      cpu: "200m"
    limits:
      memory: "1Gi"
      cpu: "1000m"
```
