# TP: Exemple concret d'utilisation des structures de contrôle conditionnelles et itératives dans les templates Helm

Dans ce TP, nous allons utiliser Helm pour créer et déployer les bases de données MySQl pour environnements (dev, test, prod) sur Kubernetes. Nous allons générer un mot de passe par défaut en utilisant les fonctions et pipelines Helm, puis l'utiliser comme mot de passe pour nos bases de données MySQL. Nous allons également créer un secret Kubernetes pour stocker ce mot de passe et configurer le déploiement des bases de données pour utiliser ce mot de pass. Le but de ce TP est de montrer comment utiliser les structures de contrôle conditionnelles et itératives dans les templates Helm pour générer des ressources Kubernetes dynamiques en fonction des valeurs de configuration.

**Étape 1 : Création du Chart Helm**

1. **Création du Chart Helm :**

    Commencez par créer un nouveau chart Helm pour notre base de données MySQL.

    ```bash
    helm create mysql-db
    ```

2. **Configuration du Chart :**

    Accédez au répertoire du chart nouvellement créé.

    ```bash
    cd mysql-db
    ```

    Supprimez le contenu du dossier `templates`.

    ```bash
    rm -rf templates/*
    ```

**Étape 2 : Configuration des Templates**

1. **Créons les fichiers de configuration pour les environnements dev, test et prod :**

    Créez un fichier `values.yaml` dans le dossier `mysql-db` avec le contenu suivant :

    ```yaml
    replicaCount: 1
    image:
      repository: mysql
      tag: latest
    service:
      type: ClusterIP
      port: 80

    services:
      - name: dev
        replicaCount: 1
        enabled: true
      - name: staging
        replicaCount: 2
        enabled: true
      - name: prod
        replicaCount: 3
        enabled: true
    ```

    Ce fichier définit les valeurs par défaut pour notre chart Helm, y compris le nombre de réplicas, l'image Docker à utiliser, le type de service Kubernetes, le port du service, et les environnements dev, test et prod avec leur nombre de réplicas respectifs.
  

2. **Création du Secret Kubernetes :**

    Créez un fichier `secret.yaml` dans le dossier `templates` avec le contenu suivant :

    ```yaml
    {{- if .Values.services }}
    {{- range .Values.services }}
    {{- if .enabled }}
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: {{ $.Release.Name }}-{{ .name }}-mysql-secret
      labels:
        app: {{ $.Release.Name }}-{{ .name }}-mysql-secret
    type: Opaque
    data:
      password: {{ randAlphaNum 16 | b64enc | quote }}
    {{- end }}
    {{- end }}
    {{- end }}
    ```

    Ce fichier crée un secret Kubernetes avec un mot de passe généré aléatoirement de 16 caractères pour chaque environnement activé.

3. **Création du Déploiement MySQL :**

    Créez un fichier `deployment.yaml` dans le dossier `templates` avec le contenu suivant :

    ```yaml
    {{- if .Values.services }}
    {{- range .Values.services }}
    {{- if .enabled }}
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ $.Release.Name }}-{{ .name }}-mysql
      labels:
        app: {{ $.Release.Name }}-{{ .name }}-mysql
    spec:
      replicas: {{ .replicaCount }}
      selector:
        matchLabels:
          app: {{ $.Release.Name }}-{{ .name }}-mysql
      template:
        metadata:
          labels:
            app: {{ $.Release.Name }}-{{ .name }}-mysql
        spec:
          containers:
            - name: mysql
              image: {{ $.Values.image.repository }}:{{ $.Values.image.tag }}
              env:
                - name: MYSQL_ROOT_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: {{ $.Release.Name }}-{{ .name }}-mysql-secret
                      key: password
              ports:
                - containerPort: {{ $.Values.service.port }}
    {{- end }}
    {{- end }}
    {{- end }}
    ```

    Ce fichier crée un déploiement Kubernetes pour MySQL avec le nombre de réplicas spécifié pour chaque environnement activé. Il récupère le mot de passe du secret Kubernetes correspondant pour chaque environnement.

4. **Création du Service MySQL :**

    Créez un fichier `service.yaml` dans le dossier `templates` avec le contenu suivant :

    ```yaml
    {{- if .Values.services }}
    {{- range .Values.services }}
    {{- if .enabled }}
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ $.Release.Name }}-{{ .name }}-mysql
      labels:
        app: {{ $.Release.Name }}-{{ .name }}-mysql
    spec:
      type: {{ $.Values.service.type }}
      ports:
        - port: {{ $.Values.service.port }}
          targetPort: {{ $.Values.service.port }}
      selector:
        app: {{ $.Release.Name }}-{{ .name }}-mysql
    {{- end }}
    {{- end }}
    {{- end }}
    ```

    Ce fichier crée un service Kubernetes pour MySQL avec le type de service et le port spécifiés pour chaque environnement activé.

**Étape 3 : Installation du Chart Helm**

1. **Installation du Chart :**

    Installez le chart Helm en utilisant la commande suivante :

    ```bash
    kubectl create ns mysql-db
    helm install mysql-db . -n mysql-db
    ```

2. **Vérification de l'Installation :**

    Vérifiez que les déploiements et services MySQL ont été créés pour les environnements dev, test et prod en utilisant la commande suivante :

    ```bash
    kubectl get deployments,services -n mysql-db
    ```

    Vous devriez voir les déploiements et services MySQL pour chaque environnement avec les réplicas et les ports correspondants.

**Étape 4 : Nettoyage**

1. **Désinstallation du Chart :**

    Désinstallez le chart Helm en utilisant la commande suivante :

    ```bash
    helm uninstall mysql-db -n mysql-db
    kubectl delete ns mysql-db
    ```

Ce TP a montré comment utiliser les structures de contrôle conditionnelles et itératives dans les templates Helm pour générer des ressources Kubernetes dynamiques en fonction des valeurs de configuration. Vous pouvez maintenant personnaliser et étendre ce chart Helm pour répondre à vos besoins spécifiques en matière de déploiement de bases de données MySQL sur Kubernetes.
