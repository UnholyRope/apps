{{/* vim: set filetype=mustache: */}}

{{- define "unifi.metrics.fullname" -}}
  {{- printf "%s-metrics" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{/* Allow the release namespace to be overridden for multi-namespace deployments in combined charts. */}}
{{- define "unifi.serviceMonitor.namespace" -}}
    {{- if .Values.metrics.serviceMonitor.namespace -}}
        {{- print .Values.metrics.serviceMonitor.namespace -}}
    {{- else -}}
        {{- include "common.names.namespace" . -}}
    {{- end }}
{{- end -}}
{{- define "unifi.prometheusRule.namespace" -}}
    {{- if .Values.metrics.prometheusRule.namespace -}}
        {{- print .Values.metrics.prometheusRule.namespace -}}
    {{- else -}}
        {{- include "common.names.namespace" . -}}
    {{- end }}
{{- end -}}

{{/* Return the proper UniFi Controller image name */}}
{{- define "unifi.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper image name (for the metrics image) */}}
{{- define "unifi.metrics.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper image name (for the init container volume-permissions image) */}}
{{- define "unifi.volumePermissions.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "unifi.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/*
Gets the host to be used for this application.
When using Ingress, it will be set to the Ingress hostname.
*/}}
{{- define "unifi.host" -}}
{{- if .Values.ingress.enabled }}
  {{- .Values.ingress.hostname | default "" -}}
{{- else -}}
  {{- .Values.unifiHost | default "" -}}
{{- end -}}
{{- end -}}

{{/* Check if there are rolling tags in the images */}}
{{- define "unifi.checkRollingTags" -}}
{{- include "common.warnings.rollingTag" .Values.image }}
{{- include "common.warnings.rollingTag" .Values.metrics.image }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "unifi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing AppName TLS certificates
*/}}
{{- define "unifi.tlsSecretName" -}}
{{- $secretName := coalesce .Values.auth.tls.existingSecret .Values.auth.tls.jksSecret -}}
{{- if $secretName -}}
  {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
  {{- printf "%s-crt" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* Return true if a TLS secret object should be created */}}
{{- define "unifi.createTlsSecret" -}}
{{- if and .Values.auth.tls.enabled .Values.auth.tls.autoGenerated (not .Values.auth.tls.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
*/}}
{{- define "unifi.ingress.certManagerRequest" -}}
{{ if or (hasKey . "cert-manager.io/cluster-issuer") (hasKey . "cert-manager.io/issuer") }}
  {{- true -}}
{{- end -}}
{{- end -}}

{{/* Create a default fully qualified app name. We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec). */}}
{{- define "unifi.mongodb.fullname" -}}
  {{- include "common.names.dependency.fullname" (dict "chartName" "mongodb" "chartValues" .Values.mongodb "context" $) -}}
{{- end -}}
{{/* 
{{- define "unifi.mongodb.fullname" -}}
    {{- printf "%s-mongodb" (include "common.names.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}
*/}}

{{/* Return the Database hostname */}}
{{- define "unifi.databaseHost" -}}
{{- if eq .Values.mongodb.architecture "replication" }}
    {{- ternary (include "unifi.mongodb.fullname" .) .Values.externalDatabase.host .Values.mongodb.enabled -}}-primary
{{- else -}}
    {{- ternary (include "unifi.mongodb.fullname" .) .Values.externalDatabase.host .Values.mongodb.enabled -}}
{{- end -}}
{{- end -}}

{{/* Return the Database port */}}
{{- define "unifi.databasePort" -}}
    {{- ternary "27017" .Values.externalDatabase.port .Values.mongodb.enabled -}}
{{- end -}}

{{/* Return the Database database name */}}
{{- define "unifi.databaseName" -}}
{{- if .Values.mongodb.enabled }}
    {{- if .Values.global.mongodb }}
        {{- if .Values.global.mongodb.auth }}
            {{- coalesce .Values.global.mongodb.auth.database .Values.mongodb.auth.database -}}
        {{- else -}}
            {{- (index .Values.mongodb.auth.databases 0) -}}
        {{- end -}}
    {{- else -}}
        {{- (index .Values.mongodb.auth.databases 0) -}}
    {{- end -}}
{{- else -}}
  {{- .Values.externalDatabase.database -}}
{{- end -}}
{{- end -}}

{{/* Return the Database user */}}
{{- define "unifi.databaseUser" -}}
{{- if .Values.mongodb.enabled }}
    {{- if .Values.global.mongodb }}
        {{- if .Values.global.mongodb.auth }}
            {{- coalesce .Values.global.mongodb.auth.username .Values.mongodb.auth.username -}}
        {{- else -}}
            {{- .Values.mongodb.auth.username -}}
        {{- end -}}
    {{- else -}}
        {{- .Values.mongodb.auth.username -}}
    {{- end -}}
{{- else -}}
    {{- .Values.externalDatabase.user -}}
{{- end -}}
{{- end -}}

{{/* Return the Database encrypted password */}}
{{- define "unifi.databaseSecretName" -}}
{{- if .Values.mongodb.enabled }}
    {{- if .Values.global.mongodb }}
        {{- if .Values.global.mongodb.auth }}
            {{- if .Values.global.mongodb.auth.existingSecret }}
                {{- tpl .Values.global.mongodb.auth.existingSecret $ -}}
            {{- else -}}
                {{- default (include "unifi.mongodb.fullname" .) (tpl .Values.mongodb.auth.existingSecret $) -}}
            {{- end -}}
        {{- else -}}
            {{- default (include "unifi.mongodb.fullname" .) (tpl .Values.mongodb.auth.existingSecret $) -}}
        {{- end -}}
    {{- else -}}
        {{- default (include "unifi.mongodb.fullname" .) (tpl .Values.mongodb.auth.existingSecret $) -}}
    {{- end -}}
{{- else -}}
    {{- default (include "common.secrets.name" (dict "existingSecret" .Values.auth.existingSecret "context" $)) (tpl .Values.externalDatabase.existingSecret $) -}}
{{- end -}}
{{- end -}}

{{/* Add environment variables to configure database values */}}
{{- define "unifi.databaseSecretKey" -}}
{{- if .Values.mongodb.enabled -}}
  {{- print "mongodb-password" -}}
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

{{/* Return true if a TLS secret object should be created */}}
{{- define "unifi.createTlsSecret" -}}
{{- if and .Values.auth.tls.enabled .Values.auth.tls.autoGenerated (not .Values.auth.tls.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/* Validate values of UniFi MongoDB database */}}
{{- define "unifi.validateValues.database" -}}
{{- if and (not .Values.mongodb.enabled) (not .Values.externalDatabase.host) (not .Values.externalDatabase.existingSecret) -}}
unifi: database
    You disabled the MongoDB sub-chart but did not specify an external MongoDB host.
    Either deploy the MongoDB sub-chart (--set mongodb.enabled=true),
    or set a value for the external database host (--set externalDatabase.host=FOO)
    or set a value for the external database existing secret (--set externalDatabase.existingSecret=BAR).
{{- end -}}
{{- end -}}