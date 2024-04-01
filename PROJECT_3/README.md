**TP : Utilisation des Fonctions et Pipelines Helm pour la Génération de Mot de Passe par Défaut et Configuration d'une Base de Données MySQL**

Dans ce TP, nous allons utiliser Helm pour créer et déployer une base de données MySQL sur Kubernetes. Nous allons générer un mot de passe par défaut en utilisant les fonctions et pipelines Helm, puis l'utiliser comme mot de passe pour notre base de données MySQL. Nous allons également créer un secret Kubernetes pour stocker ce mot de passe et configurer le déploiement de la base de données pour utiliser ce mot de passe.

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

1. **Création du Secret Kubernetes :**

    Créez un fichier `secret.yaml` dans le dossier `templates` avec le contenu suivant :

    ```yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: {{ .Release.Name }}-mysql-secret
      labels:
        app: {{ .Release.Name }}-mysql
    type: Opaque
    data:
      password: {{ randAlphaNum 16 | b64enc | quote }}
    ```

    Ce fichier crée un secret Kubernetes avec un mot de passe généré aléatoirement de 16 caractères.

2. **Création du Déploiement MySQL :**

    Créez un fichier `deployment.yaml` dans le dossier `templates` avec le contenu suivant :

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ .Release.Name }}-mysql-deployment
      labels:
        app: {{ .Release.Name }}-mysql
    spec:
      replicas: {{ .Values.replicaCount | default 1 }}
      selector:
        matchLabels:
          app: {{ .Release.Name }}-mysql
      template:
        metadata:
          labels:
            app: {{ .Release.Name }}-mysql
        spec:
          containers:
          - name: {{ .Release.Name }}-mysql-container
            image: mysql:latest
            env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ .Release.Name }}-mysql-secret
                  key: password
            ports:
            - containerPort: {{ .Values.containerPort | default 3306 }}
    ```

    Ce fichier crée un déploiement Kubernetes pour MySQL en utilisant le mot de passe généré à partir du secret.

3. **Création du Service MySQL :**

    Créez un fichier `service.yaml` dans le dossier `templates` comme suit :

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ .Release.Name }}-mysql-service
      labels:
        app: {{ .Release.Name }}-mysql
    spec:
      ports:
      - port: {{ .Values.servicePort | default 3306 }}
        targetPort: {{ .Values.containerPort | default 3306 }}
      selector:
        app: {{ .Release.Name }}-mysql
      type: {{ .Values.serviceType | default "ClusterIP" }}
    ```


**Étape 3 : Définition des Valeurs par Défaut**

Maintenant nous allons créer le fichier de valeurs `values.yaml` à la racine de votre chart pour définir les valeurs par défaut des variables.

```yaml
replicaCount: 1

containerPort: 3306

servicePort: 3306

serviceType: ClusterIP
```

**Étape 4 : Installation et Utilisation du Chart**

1. **Installation du Chart :**

    Installez votre chart sur votre cluster Kubernetes en utilisant la commande suivante :

    ```bash
    helm install mysql-db .
    ```

2. **Vérification de l'Installation :**

    Vérifiez que votre chart a été installé avec succès.

    ```bash
    helm list
    ```

3. **Nettoyage :**

    N'oubliez pas de désinstaller votre chart pour libérer les ressources.

    ```bash
    helm uninstall mysql-db
    ```

    Vérifiez que votre chart a été désinstallé avec succès.

    ```bash
    helm list
    ```

**Conclusion :**

Dans ce TP, nous avons utilisé les fonctions et pipelines Helm pour générer un mot de passe par défaut et l'utiliser comme mot de passe pour une base de données MySQL. Nous avons créé un secret Kubernetes pour stocker ce mot de passe et configuré le déploiement de la base de données pour utiliser ce mot de passe.