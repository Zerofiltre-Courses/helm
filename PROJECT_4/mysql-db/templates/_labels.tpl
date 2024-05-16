{{- define "mylabels" -}}
app: {{ .relname }}-{{ .envname }}-mysql
{{- end }}
