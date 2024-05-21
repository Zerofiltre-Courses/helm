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
    {{- $relname := $.Release.Name -}}
    apiVersion: v1
    kind: Secret
    metadata:
      name: {{ $.Release.Name }}-{{ .name }}-mysql-secret
      labels:
    {{ include "mylabels" (dict "relname" $relname "envname" .name) | indent 4 }}
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
    {{- $relname := $.Release.Name -}}
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ $.Release.Name }}-{{ .name }}-mysql
      labels:
    {{ include "mylabels" (dict "relname" $relname "envname" .name) | indent 4 }}
    spec:
      replicas: {{ .replicaCount }}
      selector:
        matchLabels:
    {{ include "mylabels" (dict "relname" $relname "envname" .name) | indent 6 }}
      template:
        metadata:
          labels:
    {{ include "mylabels" (dict "relname" $relname "envname" .name) | indent 8 }}
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

          - name: phpmyadmin
            image: phpmyadmin
            ports:
            - containerPort: 80
            env:
            - name: PMA_HOST
              value: {{ $.Release.Name }}-{{ .name }}-mysql
            - name: PMA_PORT
              value: {{ $.Values.containerPort | default 3306 | quote }}
              
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
    {{- $relname := $.Release.Name -}}
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ $relname }}-{{ .name }}-mysql
      labels:
    {{ include "mylabels" (dict "relname" $relname "envname" .name) | indent 4 }}
    spec:
      type: {{ $.Values.service.type }}
      ports:
        - port: {{ $.Values.service.port }}
          targetPort: {{ $.Values.service.port }}
          name: mysql
        - port: 8080
          targetPort: 80
          name: phpmyadmin
      selector:
    {{ include "mylabels"  (dict "relname" $relname "envname" .name) | indent 4 }}
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

    Pour tester si nous déploiement fonctionne correctement, nous allons nous connecter à la base de donnée de prod par exemple via phpmyadmin en utilsant le mot de passe généré

    Faites un port-forward pour accéder à phpmyadmin.
    ```bash
    kubectl port-forward svc/mysql-db-prod-mysql 8080:8080 -n mysql-db
    ```

    Accédez à `http://localhost:8080` dans votre navigateur et connectez-vous avec les informations suivantes :

    username: root
    password: [mot de passe généré ci-dessus]

    Puis cliquez sur connecter

**Étape 4 : Nettoyage**

1. **Désinstallation du Chart :**

    Désinstallez le chart Helm en utilisant la commande suivante :

    ```bash
    helm uninstall mysql-db -n mysql-db
    kubectl delete ns mysql-db
    ```

Ce TP a montré comment utiliser les structures de contrôle conditionnelles et itératives dans les templates Helm pour générer des ressources Kubernetes dynamiques en fonction des valeurs de configuration. Vous pouvez maintenant personnaliser et étendre ce chart Helm pour répondre à vos besoins spécifiques en matière de déploiement de bases de données MySQL sur Kubernetes.
