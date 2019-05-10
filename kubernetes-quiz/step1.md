## Verificando a versão do Kubernetes

Através do comando kubectl você pode ter controle do cluster Kubernetes e obter informações sobre o mesmo. 
Experimente: clique no comando abaixo.

`kubectl get nodes`{{execute}}

>> Com base no comando anterior, quantos nodes o cluster possui? <<
( ) 0
(*) 1
( ) 2
( ) 3
( ) 4

Agora, vamos ver a versão do Kubernetes rodando no cluster

`kubectl version`{{execute}}

>> Qual a versão do Kubernetes (Major.Minor) ? <<
( ) 0.7
( ) 1.0
(*) 1.1
( ) 1.25
( ) 2.0
