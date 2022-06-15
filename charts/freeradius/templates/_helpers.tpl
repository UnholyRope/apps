{{/* Expand the name of the chart. */}}
{{- define "freeradius.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "freeradius.fullname" -}}
{{- if .Values.fullnameOverride }}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
  {{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
  {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "freeradius.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Return the proper FreeRADIUS image name */}}
{{- define "freeradius.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper image name (for the init container volume-permissions image) */}}
{{- define "freeradius.volumePermissions.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "freeradius.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/* Common labels */}}
{{- define "freeradius.labels" -}}
helm.sh/chart: {{ include "freeradius.chart" . }}
{{ include "freeradius.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "freeradius.selectorLabels" -}}
app.kubernetes.io/name: {{ include "freeradius.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Create the name of the service account to use */}}
{{- define "freeradius.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
  {{- default (include "freeradius.fullname" .) .Values.serviceAccount.name }}
{{- else }}
  {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Return the path to the cert file. */}}
{{- define "freeradius.tlsCert" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated }}
  {{- printf "/startechnica/freeradius/certs/tls.crt" -}}
{{- else -}}
  {{- printf "/startechnica/freeradius/certs/%s" .Values.tls.certFilename -}}
{{- end -}}
{{- end -}}

{{/* Return the path to the cert key file. */}}
{{- define "freeradius.tlsCertKey" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated }}
  {{- printf "/startechnica/freeradius/certs/tls.key" -}}
{{- else -}}
  {{- printf "/startechnica/freeradius/certs/%s" .Values.tls.certKeyFilename -}}
{{- end -}}
{{- end -}}

{{/* Return the path to the CA cert file. */}}
{{- define "freeradius.tlsCACert" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated }}
  {{- printf "/startechnica/freeradius/certs/ca.crt" -}}
{{- else -}}
  {{- printf "/startechnica/freeradius/certs/%s" .Values.tls.certCAFilename -}}
{{- end -}}
{{- end -}}

{{/* Create the name of the SSL certificate to use */}}
{{ define "freeradius.tlsSecretName" }}
{{- if .Values.tls.certificatesSecret }}
  {{ .Values.tls.certificatesSecret }}
{{- else }}
  {{- default (printf "%s-tls" (include "freeradius.fullname" .)) }}
{{- end }}
{{- end }}

{{/* Return true if a TLS secret object should be created */}}
{{- define "freeradius.createTlsSecret" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated (not .Values.tls.certificatesSecret) }}
  {{- true }}
{{- end }}
{{- end -}}

{{/* Validate values of FreeRADIUS - Auth TLS enabled */}}
{{- define "freeradius.validateValues.tls" -}}
{{- if and .Values.tls.enabled (not .Values.tls.autoGenerated) (not .Values.tls.certificatesSecret) }}
freeradius: tls.enabled
    In order to enable TLS, you also need to provide
    an existing secret containing the Keystore and Truststore or
    enable auto-generated certificates.
{{- end }}
{{- end -}}

{{/* Create a default fully qualified app name. We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec). */}}
{{- define "freeradius.mariadb.fullname" -}}
{{- include "common.names.dependency.fullname" (dict "chartName" "mariadb" "chartValues" .Values.mariadb "context" $) -}}
{{- end -}}

{{/* Return the Database hostname */}}
{{- define "freeradius.databaseHost" -}}
{{- if eq .Values.mariadb.architecture "replication" }}
    {{- ternary (include "freeradius.mariadb.fullname" .) .Values.externalDatabase.host .Values.mariadb.enabled -}}-primary
{{- else -}}
    {{- ternary (include "freeradius.mariadb.fullname" .) .Values.externalDatabase.host .Values.mariadb.enabled -}}
{{- end -}}
{{- end -}}

{{/* Return the Database port */}}
{{- define "freeradius.databasePort" -}}
{{- ternary "3306" .Values.externalDatabase.port .Values.mariadb.enabled | quote -}}
{{- end -}}

{{/* Return the Database database name */}}
{{- define "freeradius.databaseName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.global.mariadb }}
        {{- if .Values.global.mariadb.auth }}
            {{- coalesce .Values.global.mariadb.auth.database .Values.mariadb.auth.database -}}
        {{- else -}}
            {{- .Values.mariadb.auth.database -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mariadb.auth.database -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/* Return the Database user */}}
{{- define "freeradius.databaseUser" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.global.mariadb }}
        {{- if .Values.global.mariadb.auth }}
            {{- coalesce .Values.global.mariadb.auth.username .Values.mariadb.auth.username -}}
        {{- else -}}
            {{- .Values.mariadb.auth.username -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mariadb.auth.username -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/* Return the Database encrypted password */}}
{{- define "freeradius.databaseSecretName" -}}
{{- if .Values.mariadb.enabled }}
    {{- if .Values.global.mariadb }}
        {{- if .Values.global.mariadb.auth }}
            {{- if .Values.global.mariadb.auth.existingSecret }}
                {{- tpl .Values.global.mariadb.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "freeradius.mariadb.fullname" .) (tpl .Values.mariadb.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (include "common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "context" $)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/* Add environment variables to configure database values */}}
{{- define "freeradius.databaseSecretKey" -}}
{{- if .Values.mariadb.enabled -}}
    {{- print "mariadb-password" -}}
{{- else -}}
    {{- if .Values.externalDatabase.existingSecret -}}
        {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
          {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- else -}}
          {{- print "database-password" -}}
        {{- end -}}
    {{- else -}}
        {{- print "database-password" -}}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/* Return the FreeRADIUS PVC name. */}}
{{- define "freeradius.claimName" -}}
{{- if .Values.persistence.existingClaim }}
  {{- printf "%s" (tpl .Values.persistence.existingClaim $) -}}
{{- else -}}
  {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}