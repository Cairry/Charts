{{/* node-exporter.name */}}
{{- define "node-exporter.name" -}}
{{- $name := default .Chart.Name "node-exporter" -}}
{{- printf "%s-%s" .Release.Name $name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* node-exporter.labels */}}
{{- define "node-exporter.labels" -}}
app: node-exporter
{{- end -}}

{{/* prometheus.name */}}
{{- define "prometheus.name" -}}
{{- $name := default .Chart.Name "prometheus-server" -}}
{{- printf "%s-%s" .Release.Name $name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* prometheus.labels */}}
{{- define "prometheus.labels" -}}
app: prometheus
{{- end -}}

{{/* grafana.name */}}
{{- define "grafana.name" -}}
{{- $name := default .Chart.Name "grafana" -}}
{{- printf "%s-%s" .Release.Name $name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* grafana.labels */}}
{{- define "grafana.labels" -}}
app: grafana
{{- end -}}

{{/* kube-state-metrics.labels */}}
{{- define "kube-state-metrics.labels" -}}
app.kubernetes.io/name: kube-state-metrics
app.kubernetes.io/version: v2.2.1
{{- end -}}

{{/* alertmanager.name */}}
{{- define "alertmanager.name" -}}
{{- $name := default .Chart.Name "alertmanager" -}}
{{- printf "%s-%s" .Release.Name $name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* alertmanager.labels */}}
{{- define "alertmanager.labels" -}}
app: alertmanager
version: v0.22.2
{{- end -}}

{{/* prometheusAlert.name */}}
{{- define "prometheusAlert.name" -}}
{{- $name := default .Chart.Name "prometheusalert" -}}
{{- printf "%s-%s" .Release.Name $name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* prometheusAlert.labels */}}
{{- define "prometheusAlert.labels" -}}
app: prometheusalert
{{- end -}}

{{/* pushgateway.name */}}
{{- define "pushgateway.name" -}}
{{- $name := default .Chart.Name "pushgateway" -}}
{{- printf "%s-%s" .Release.Name $name  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* pushgateway.labels */}}
{{- define "pushgateway.labels" -}}
app: pushgateway
{{- end -}}
