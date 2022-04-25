# Setup Sample Application

Wenn das Cluster läuft und Traefik deployt wurde, ist es ein leichtes, eine Anwenung in das Cluster zu bringen.
Dazu werden einfach in einer Yaml-Datei die Pods, Services und Ingres-Element entsprechenden Konfiguriert.

```
kubectl apply -f ./kubernetes/nb-sample.yaml
```