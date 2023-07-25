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
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image .Values.metrics.image) "global" .Values.global) -}}
{{- end -}}

{{/* Create the name of the service account to use */}}
{{- define "freeradius.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
  {{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
  {{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Return the path to the cert file. */}}
{{- define "freeradius.tlsCert" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated }}
  {{- printf "/opt/startechnica/freeradius/certs/tls.crt" -}}
{{- else -}}
  {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.tls.certFilename -}}
{{- end -}}
{{- end -}}

{{/* Return the path to the cert key file. */}}
{{- define "freeradius.tlsCertKey" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated }}
  {{- printf "/opt/startechnica/freeradius/certs/tls.key" -}}
{{- else -}}
  {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.tls.certKeyFilename -}}
{{- end -}}
{{- end -}}

{{/* Return the path to the CA cert file. */}}
{{- define "freeradius.tlsCACert" -}}
{{- if and .Values.tls.enabled .Values.tls.autoGenerated }}
  {{- printf "/opt/startechnica/freeradius/certs/ca.crt" -}}
{{- else -}}
  {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.tls.certCAFilename -}}
{{- end -}}
{{- end -}}

{{/* Create the name of the SSL certificate to use */}}
{{- define "freeradius.tlsSecretName" -}}
{{- if .Values.tls.certificatesSecret }}
  {{ .Values.tls.certificatesSecret }}
{{- else }}
  {{- default (printf "%s-tls" (include "common.names.fullname" .)) }}
{{- end }}
{{- end -}}

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

{{/* Return the path to the SQL cert file. */}}
{{- define "freeradius.sqlTlsCert" -}}
{{- if and .Values.modsEnabled.sql.tls.enabled .Values.modsEnabled.sql.tls.autoGenerated }}
  {{- printf "/opt/startechnica/freeradius/certs/sql-tls.crt" -}}
{{- else -}}
  {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modsEnabled.sql.tls.certFilename -}}
{{- end }}
{{- end -}}

{{/* Return the path to the SQL cert key file. */}}
{{- define "freeradius.sqlTlsCertKey" -}}
{{- if and .Values.modsEnabled.sql.tls.enabled .Values.modsEnabled.sql.tls.autoGenerated }}
  {{- printf "/opt/startechnica/freeradius/certs/sql-tls.key" -}}
{{- else }}
  {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modsEnabled.sql.tls.certKeyFilename -}}
{{- end }}
{{- end -}}

{{/* Return the path to the SQL CA cert file. */}}
{{- define "freeradius.sqlTlsCACert" -}}
{{- if and .Values.modsEnabled.sql.tls.enabled .Values.modsEnabled.sql.tls.autoGenerated }}
  {{- printf "/opt/startechnica/freeradius/certs/sql-ca.crt" -}}
{{- else }}
  {{- printf "/opt/startechnica/freeradius/certs/%s" .Values.modsEnabled.sql.tls.certCAFilename -}}
{{- end }}
{{- end -}}

{{/* Create the name of the secret for SQL SSL certificate to use */}}
{{- define "freeradius.sqlTlsSecretName" -}}
{{- if .Values.modsEnabled.sql.tls.certificatesSecret }}
  {{ .Values.modsEnabled.sql.tls.certificatesSecret }}
{{- else }}
  {{- default (printf "%s-sql-tls" (include "common.names.fullname" .)) }}
{{- end }}
{{- end -}}

{{/* Return true if a TLS secret object should be created */}}
{{- define "freeradius.createSqlTlsSecret" -}}
{{- if and .Values.modsEnabled.sql.tls.enabled .Values.modsEnabled.sql.tls.autoGenerated (not .Values.modsEnabled.sql.tls.certificatesSecret) }}
  {{- true }}
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
    {{- default (include "common.secrets.name" (dict "existingSecret" .Values.mariadb.auth.existingSecret "context" $)) (tpl .Values.externalDatabase.existingSecret $) -}}
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

{{/* Get the configuration ConfigMap name. */}}
{{- define "freeradius.configurationCM" -}}
{{- if .Values.configurationConfigMap -}}
  {{- printf "%s" (tpl .Values.configurationConfigMap $) -}}
{{- else -}}
  {{- printf "%s-configuration" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* Get the initialization scripts ConfigMap name. */}}
{{- define "freeradius.initdbScriptsCM" -}}
{{- if .Values.initdbScriptsConfigMap -}}
  {{- printf "%s" .Values.initdbScriptsConfigMap -}}
{{- else -}}
  {{- printf "%s-init-scripts" (include "common.names.fullname" .) -}}
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