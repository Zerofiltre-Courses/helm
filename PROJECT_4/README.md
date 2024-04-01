Nous déploierons un serveur web

### Étape 1 : Installation de Helm

Assure-toi d'avoir Helm installé sur ton système. Tu peux suivre les instructions d'installation officielles [ici](https://helm.sh/docs/intro/install/).

### Étape 2 : Initialisation d'un nouveau projet Helm

Commence par créer un nouveau projet Helm en utilisant la commande suivante :

```bash
helm create mon-projet-web
```

### Étape 3 : Structure du répertoire

Voici la structure de répertoire recommandée pour ton projet :

```
mon-projet-web/
├── charts/
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── values.yaml
└── Chart.yaml
```

### Étape 4 : Configuration des valeurs

Modifie le fichier `values.yaml` pour définir les valeurs par défaut de ton déploiement. Voici un exemple de configuration :

```yaml
# values.yaml
replicaCount: 1
image:
  repository: nginx
  tag: stable
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
ingress:
  enabled: false
```

### Étape 5 : Définition du Chart

Édite le fichier `Chart.yaml` pour définir les métadonnées de ta charte :

```yaml
# Chart.yaml
apiVersion: v2
name: mon-projet-web
description: Helm chart pour le déploiement d'un serveur web
version: 0.1.0
```

### Étape 6 : Création des modèles

Crée les modèles Kubernetes dans le répertoire `templates/` pour le déploiement, le service et éventuellement l'ingress. Voici des exemples :

#### `templates/deployment.yaml`

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "mon-projet-web.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "mon-projet-web.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "mon-projet-web.name" . }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
```

#### `templates/service.yaml`

```yaml
# templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "mon-projet-web.fullname" . }}
spec:
  selector:
    app: {{ include "mon-projet-web.name" . }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.port }}
```

#### `templates/ingress.yaml` (si nécessaire)

```yaml
# templates/ingress.yaml
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ include "mon-projet-web.fullname" . }}
spec:
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ include "mon-projet-web.fullname" . }}
                port:
                  number: {{ .Values.service.port }}
{{- end }}
```

### Étape 7 : Installation du Chart

Utilise la commande suivante pour installer ta charte Helm :

```bash
helm install mon-deploiement ./mon-projet-web
```

### Étape 8 : Vérification du déploiement

Vérifie que le déploiement a réussi en utilisant les commandes Kubernetes standard, comme `kubectl get pods`, `kubectl get services`, etc.

### Étape 9 : Personnalisation

N'hésite pas à personnaliser davantage ta charte en fonction de tes besoins spécifiques. Tu peux modifier les valeurs dans `values.yaml` ou ajouter de nouveaux modèles dans `templates/`.

Voilà ! Tu as maintenant créé avec succès une charte Helm pour le déploiement d'un serveur web complet, en suivant les meilleures pratiques de DevOps. Cette charte est réutilisable et facile à maintenir, ce qui te permettra de déployer rapidement des applications web dans ton cluster Kubernetes.