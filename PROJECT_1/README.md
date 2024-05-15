Dans ce TP, nous allons créer un chart helm pour installer notre serveur Apache sur un cluster Kubernetes.

### Prérequis :
- Kubernetes cluster
- Helm et Kubectl installés sur votre machine locale

### Étapes :

1. **Création de la chart Helm :**

    Tout d'abord, nous allons créer une chart Helm pour notre serveur Apache.

    ```bash
    helm create mon-apache
    ```

2. **Configuration de la chart :**

    Allez dans le répertoire de la chart nouvellement créée.

    ```bash
    cd mon-apache
    ```

    Effacez le contenu du dossier `templates` 
    
    ```bash
    rm -rf templates/*
    ```


3. **Configuration du déploiement :**

    Nous allons maintenant créer un fichier de déploiement Kubernetes pour notre serveur Apache.

    Pour mieux organiser notre chart, nous allons créer un namespace pour notre deployment.

    Premièrmeent, nous allons créer un namespace pour notre chart dans lequel nous allons déployer notre application Apache.

    ```bash
    kubectl create ns mon-apache
    ```

    Créez ensuite un fichier `deployment.yaml` toujours dans le dossier `templates` et ajoutez le contenu suivant :

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mon-apache
      labels:
        app: mon-apache
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: mon-apache
      template:
        metadata:
          labels:
            app: mon-apache
        spec:
          containers:
          - name: mon-apache
            image: httpd:2.4
            ports:
            - containerPort: 80
    ```

    Puis, créez un fichier `service.yaml` dans le dossier `templates` et ajoutez le contenu suivant :

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: mon-apache
      labels:
        app: mon-apache
    spec:
      ports:
      - port: 80
        targetPort: 80
      selector:
        app: mon-apache
      type: ClusterIP

    ```

    Nos templates sont maintenant prêts. Nous pouvons maintenant déployer notre chart.

4. **Installation de la chart :**

    Allez dans le répertoire racine de votre chart.

    ```bash
    cd ..
    ```

    Puis éxecutez la commande suivant pour installer votre chart sur votre cluster Kubernetes.

    ```bash
    helm install -n mon-apache mon-apache .
    ```

    Vérifiez que votre chart a été installé avec succès.

    ```bash
    helm list -n mon-apache
    ```

    Vous devriez voir votre chart dans la liste des charts installés. Avec le statut `DEPLOYED`.
   
    Vérifiez que votre application Apache est en cours d'exécution en accédant à l'adresse IP du service exposé sur le port 80.

    ```bash
    kubectl get svc -n mon-apache
    ```
    
    Utilisez le port-forwarding pour accéder à votre application via un navigateur web.

    ```bash
    kubectl -n mon-apache port-forward svc/mon-apache 8080:80
    ```
    Puis ouvrez votre navigateur web et accédez à l'adresse `http://localhost:8080`.

    Vous devriez voir la page d'accueil d'Apache.

5. **Nettoyage :**

    Pour désinstaller votre chart et supprimer le namespace, éxecutez la commande suivante :

    ```bash
    helm uninstall mon-apache -n mon-apache
    kubectl delete ns mon-apache
    ```

   

Bravo! Vous venez de créer votre première chart Helm.
