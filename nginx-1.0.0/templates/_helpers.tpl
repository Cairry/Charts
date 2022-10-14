/*
 * @Author: Xuan.Zu
 * @Email: xuan.zu@js.design
 * @Date: 2022-10-14 17:18:57
 * @Description: 
 */

{{/* Selector labels */}}
{{- define "nginx.selectorLabels" -}}
    app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Volume type */}}
{{- define "nginx.Storage" -}}
    {{- if .Values.UsePVC.enable -}}
        persistentVolumeClaim:
            claimName: {{ .Values.UsePVC.persistentVolumeClaim.claimName }}
    {{- else -}}
        emptyDir: {}
    {{- end -}}
{{- end -}}

{{- define "imagePullSecret" -}}
    {{- if .Values.useImagePullSecrets.enable -}}
        imagePullSecrets: {{ .Values.useImagePullSecrets.ImagePullSecrets }}
    {{- end -}}
{{- end -}}

{{/* Create a default fully qualified js design server name. 连接 server 地址模板 */}}
{{- define "js-design.server" -}}
    {{- if .Values.global.jsdesign.ServerUrl -}}
        {{- .Values.global.jsdesign.ServerUrl -}}
    {{- else -}}
        {{- printf "%s-%s:3002" .Release.Name "server" -}}
    {{- end -}}
{{- end -}}

{{/* Create a default fully qualified js design server name. 连接 hedwig 地址模板 */}}
{{- define "js-design.hedwig" -}}
    {{- if .Values.global.jsdesign.HedwigUrl -}}
        {{- .Values.global.jsdesign.HedwigUrl -}}
    {{- else -}}
        {{- printf "%s-%s:3011" .Release.Name "hedwig" -}}
    {{- end -}}
{{- end -}}


