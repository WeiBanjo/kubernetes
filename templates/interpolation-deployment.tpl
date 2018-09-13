{{- if (or (.Values.interpolationEnabled) (.Values.interpolation.enabled))  }}
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: pelias-interpolation
spec:
  replicas: {{ .Values.interpolationReplicas | default 1 }}
  template:
    metadata:
      labels:
        app: pelias-interpolation
    spec:
      initContainers:
        - name: interpolation-download
          image: busybox
          command: ["sh", "-c",
            "mkdir -p /data/interpolation/ &&\n
             wget -O- https://s3.amazonaws.com/pelias-data.nextzen.org/interpolation/current/street.db.gz | gunzip > /data/interpolation/street.db &\n
             wget -O- https://s3.amazonaws.com/pelias-data.nextzen.org/interpolation/current/address.db.gz | gunzip > /data/interpolation/address.db" ]
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 3Gi
              cpu: 2
            requests:
              memory: 512Mi
              cpu: 0.1
      containers:
        - name: pelias-interpolation
          image: pelias/interpolation:{{ .Values.interpolationDockerTag | default "latest" }}
          volumeMounts:
            - name: data-volume
              mountPath: /data
          resources:
            limits:
              memory: 3Gi
              cpu: 2
            requests:
              memory: 2Gi
              cpu: 0.1
      volumes:
        - name: data-volume
        {{- if .Values.interpolation.pvc.create }}
          persistentVolumeClaim:
          claimName: {{ .Values.interpolation.pvc.name }}
        {{- else }}
          emptyDir: {}
        {{- end }}
{{- end -}}
