### Projet 2 : Utilisation des variables dans un chart Helm

Dans ce projet, nous allons améliorer notre chart Helm pour rendre son déploiement plus flexible en utilisant des variables intégrées et personnalisées.

#### Prérequis :
- Cluster Kubernetes opérationnel
- Helm et Kubectl installés sur votre machine locale

#### Étapes :

1. **Création de la chart Helm :**

    Commencez par créer une chart Helm pour notre serveur Apache.

    ```bash
    helm create mon-apache-flexible
    ```

2. **Configuration de la chart :**

    Accédez au répertoire de la chart nouvellement créée.

    ```bash
    cd mon-apache-flexible
    ```

    Supprimez le contenu du dossier `templates`.

    ```bash
    rm -rf templates/*
    ```

3. **Configuration du déploiement :**

    Créez un fichier `deployment.yaml` dans le dossier `templates` avec le contenu suivant:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ .Release.Name }}-apache
      namespace: {{ .Release.Namespace }}
      labels:
        app: {{ .Release.Name }}-apache
    spec:
      replicas: {{ .Values.replicaCount | default 1 }}
      selector:
        matchLabels:
          app: {{ .Release.Name }}-apache
      template:
        metadata:
          labels:
            app: {{ .Release.Name }}-apache
        spec:
          containers:
          - name: {{ .Release.Name }}-apache
            image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
            ports:
            - containerPort: {{ .Values.containerPort | default 80 }}
    ```

    Dans ce déploiement, nous utilisons des variables telles que `Release.Name`, `Release.Namespace`, `Values.replicaCount`, `Values.image.repository`, `Values.image.tag`, `Values.containerPort` pour rendre notre configuration flexible en fonction des besoins. Nous ferons de même pour le service

    Créez ensuite un fichier `service.yaml` dans le dossier `templates` et utilisez également des variables.

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: {{ .Release.Name }}-apache
      labels:
        app: {{ .Release.Name }}-apache
    spec:
      ports:
      - port: {{ .Values.servicePort | default 80 }}
        targetPort: {{ .Values.containerPort | default 80 }}
      selector:
        app: {{ .Release.Name }}-apache
      type: {{ .Values.serviceType | default "ClusterIP" }}
    ```

4. **Fichiers de valeurs par défaut :**

    Créez un fichier `values.yaml` à la racine de votre chart pour définir les valeurs par défaut des variables.

    ```yaml
    replicaCount: 1

    image:
      repository: httpd
      tag: "2.4"

    containerPort: 80

    servicePort: 80

    serviceType: ClusterIP
    ```

    Bingo! Nous avons notre premier fichier de valeurs par défaut pour notre chart Helm. L'utilisateur pourra donc personnaliser ces valeurs lors de l'installation de la chart.

5. **Installation de la chart :**

    Pour installer votre chart sur votre cluster Kubernetes, exécutez la commande suivante :

    ```bash
    helm install -n mon-apache-flexible mon-apache-flexible .
    ```

    Vérifiez que votre chart a été installé avec succès.

    ```bash
    helm list -n mon-apache-flexible
    ```

    Vous pouvez également vérifier que le déploiement et le service ont été créés avec succès. Avec un port-forwarding.

    ```bash
    kubectl -n mon-apache-flexible port-forward svc/mon-apache-flexible-apache 8080:80
    ```

    Vous devriez voir votre chart dans la liste des charts installés, avec le statut `DEPLOYED`.

6. **Nettoyage :**

    N'oubliez pas de désinstallez votre chart pour liberer les ressources, utilisez la commande suivante :

    ```bash
    helm uninstall mon-apache-flexible -n mon-apache-flexible
    kubectl delete ns mon-apache-flexible
    ```

    Vous pouvez vérifiez que votre chart a été désinstallé avec succès avec la commande list

    ```bash
    helm list -n mon-apache-flexible
    ```

#### Conclusion :

Dans ce projet, nous avons dynamisé notre chart helm (celui du premier TP) pour permettre aux utilisateurs de configurer les valeurs telles que le nombre de réplicas, le port du service, le type de service, etc. lors de l'installation de la chart. Aussi grace aux variables intégrées comme `Release.Name`, `Release.Namespace`, nous avons rendu notre chart réutilisable.