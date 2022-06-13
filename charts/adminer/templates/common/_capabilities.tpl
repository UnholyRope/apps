{{/* Return the appropriate apiVersion for Istio Networking. */}}
{{- define "common.capabilities.istioNetworking.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "networking.istio.io/v1beta1" -}}
  {{- print "networking.istio.io/v1beta1" -}}
{{- else if .Capabilities.APIVersions.Has "networking.istio.io/v1alpha3" -}}
  {{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
  {{- print "false" -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Security. */}}
{{- define "common.capabilities.istioSecurity.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "security.istio.io/v1beta1" -}}
  {{- print "security.istio.io/v1beta1" -}}
{{- else -}}
  {{- print "false" -}}
{{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Istio Extensions. */}}
{{- define "common.capabilities.istioExtensions.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "extensions.istio.io/v1alpha1" -}}
  {{- print "extensions.istio.io/v1alpha1" -}}
{{- else -}}
  {{- print "false" -}}
{{- end -}}
{{- end -}}