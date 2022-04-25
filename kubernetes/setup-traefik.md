# Setup Traefik
Um Traefik für das Routing von HTTP-Anfragen zu werdenden, kann dieser als Ingress-Controller eingesetzt werden. Hierzu wird zunächst die entsprechende Konfiguration in das Cluster-Deployt.

```
kubectl apply -f ./kubernetes/traefik-deamon-set.yaml
```

Das Deamon Set-Sollte dann auch im Kubernetes-Dashboard (falls konfiguriert und mit kubectl proxy erreichbar) angezeigt werden:
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/workloads?namespace=_all


## Das Traefik-Dashboard erreichbar machen
Wenn eine passende Domain Konfguriert ist, kann für den Trafik-Dashboard außerdem eine Ingres-Route definiert werden:
```
kubectl apply -f ./kubernetes/traefik-dashboaerd-service.yaml
```
Nach dem Deployment - und ein paar Sekunden, in denen Traefik das Zertifikat besorgt - sollte der Service dann auch Über 
das Internet verfügbar sein.

## und wenn wir schon dabei sind...
Über densselben Weg kann dann natürlich auch das Kubernetes Dashboard veröffentlicht werden.

```
kubectl apply -f ./kubernetes/kubernetes-dashboard-ingress.yml
```











