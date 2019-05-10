## Verificando pods e imagens

Nós instalamos um pod de um webserver no cluster. execute o comando abaixo para visualizá-lo no terminal
`kubectl get pods`{{execute}}

Agora vamos verificar qual a imagem que foi instalada no nosso webserver: digite no terminal o comando
´´´kubectl describe pod <NOME-DO-POD>
  
Substituindo <NOME-DO-POD> pelo resultado obtido no comando anterior. Depois disso procure na saída do comando pelo campo "Image:"

>>Qual é a imagem utilizada pelo nosso webserver?<<
=== ngnix
