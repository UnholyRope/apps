{{/* Create the name of the service account to use for the deployment */}}
{{- define "mayastor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
  {{ default (printf "%s" (include "common.names.fullname" .)) .Values.serviceAccount.name | trunc 63 | trimSuffix "-" }}
{{- else -}}
  {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor image name */}}
{{- define "mayastor.image" -}}
{{- if or (eq .Values.diagnosticMode.environment "development") (eq .Values.diagnosticMode.environment "dev") -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.imageDev "global" .Values.global) }}
{{- else -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor CSI Node image name */}}
{{- define "mayastor.csi.image" -}}
{{- if or (eq .Values.diagnosticMode.environment "development") (eq .Values.diagnosticMode.environment "dev") -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csi.imageDev "global" .Values.global) }}
{{- else -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csi.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor CSI Node image name */}}
{{- define "mayastor.csiNode.driverRegistrar.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csi.driverRegistrar.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor CSI Controller image name */}}
{{- define "mayastor.csiController.image" -}}
{{- if or (eq .Values.diagnosticMode.environment "development") (eq .Values.diagnosticMode.environment "dev") -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csiController.imageDev "global" .Values.global) }}
{{- else -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csiController.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor CSI Controller Attacher image name */}}
{{- define "mayastor.csiController.attacher.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csiController.attacher.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor CSI Controller Livenessprobe image name */}}
{{- define "mayastor.csiController.livenessprobe.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csiController.livenessprobe.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor CSI Controller Provisioner image name */}}
{{- define "mayastor.csiController.provisioner.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.csiController.provisioner.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Mayastor Core Agent image name */}}
{{- define "mayastor.mcpCore.image" -}}
{{- if or (eq .Values.diagnosticMode.environment "development") (eq .Values.diagnosticMode.environment "dev") -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mcpCore.imageDev "global" .Values.global) }}
{{- else -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mcpCore.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor Rest image name */}}
{{- define "mayastor.mcpRest.image" -}}
{{- if or (eq .Values.diagnosticMode.environment "development") (eq .Values.diagnosticMode.environment "dev") -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mcpRest.imageDev "global" .Values.global) }}
{{- else -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mcpRest.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/* Return the proper Mayastor Operator image name */}}
{{- define "mayastor.mspOperator.image" -}}
{{- if or (eq .Values.diagnosticMode.environment "development") (eq .Values.diagnosticMode.environment "dev") -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mspOperator.imageDev "global" .Values.global) }}
{{- else -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.mspOperator.image "global" .Values.global) }}
{{- end -}}
{{- end -}}

{{/* Return the proper image name (for the init container volume-permissions image) */}}
{{- define "mayastor.volumePermissions.image" -}}
  {{ include "common.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/* Return the proper Docker Image Registry Secret Names */}}
{{- define "mayastor.imagePullSecrets" -}}
  {{- include "common.images.pullSecrets" (dict "images" (list .Values.image .Values.volumePermissions.image) "global" .Values.global) -}}
{{- end -}}

{{/* Generate CPU list specification based on CPU count (-l param of mayastor) */}}
{{- define "mayastorCpuSpec" -}}
{{- range $i, $e := until (int .Values.mayastorCpuCount) }}
{{- if gt $i 0 }}
{{- printf "," }}
{{- end }}
{{- printf "%d" (add $i 1) }}
{{- end }}
{{- end }}