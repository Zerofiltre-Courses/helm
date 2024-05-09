# TP: Sous-charts Helm et ressources externes

Dans ce TP, nous allons explorer l'utilisation des sous-charts Helm et des ressources externes dans un déploiement Kubernetes. Nous allons créer un chart Helm principal pour l'installation de solidinvoice, une application de facturation open-source, et utiliser des sous-charts pour les dépendances externes telles que la base de données MySQL.

**Étape 1 : Création du Chart Helm**

1. **Création du Chart Helm :**

    Commencez par créer un nouveau chart Helm pour notre application solidinvoice.

    ```bash
    helm create my-solidinvoice
    ```

2. **Configuration du Chart :**

    Accédez au répertoire du chart nouvellement créé.

    ```bash
    cd my-solidinvoice
    ```

    Supprimez le contenu du dossier `templates`.

    ```bash
    rm -rf templates/*
    ```

**Étape 2 : Configuration des Templates**

1. **Création des Templates :**

    Créez un fichier de template pour le déploiement de l'application solidinvoice.

    ```bash
    touch templates/deployment.yaml
    ```

    Ajoutez le contenu suivant au fichier `templates/deployment.yaml`.

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: {{ .Release.Name }}-solidinvoice
    labels:
        app: {{ .Release.Name }}-solidinvoice
    spec:
        replicas: 1
    selector:
    matchLabels:
      app: {{ .Release.Name }}-solidinvoice
    template:
        metadata:
      labels:
        app: {{ .Release.Name }}-solidinvoice
    spec:
      containers:
      - name: solidinvoice
        image: solidinvoice/solidinvoice:2.1.2
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "100Mi"
            cpu: "250m"
          limits:
            memory: "200Mi"
            cpu: "500m"
        volumeMounts:
        - name: solidinvoice-secret-volume
          mountPath: /opt/srv/config/env.php
          subPath: env.php
      volumes: 
      - name: solidinvoice-secret-volume
        secret:
          secretName: {{ .Release.Name }}-solidinvoice
    ```
