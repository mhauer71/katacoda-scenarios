
Clique na linha abaixo para listar os projetos da sua conta na Google Cloud
`gcloud projects list`{{execute}}

Escolha o projeto que contém os seus clusters e digite no terminal *gcloud config set project [PROJECT_ID]* 

Clique na linha abaixo para listar clusters da GKE disponíveis no projeto

`gcloud container clusters list`{{execute}}

Escolha o cluster desejado para fazer os testes e digite no terminal *gcloud container clusters get-credentials [NAME] --zone [LOCATION]*

Verifique se a configuração foi corretamente baixada com 

`kubectl config view`{{execute}}

e a conexão com o cluster usando 

`kubectl cluster-info`{{execute}}

* Caso você queira trabalhar com mais de um cluster, recuperando a credencial de cada um deles através do comando *get-credentials* acima, um app bem útil é o *kubectx*, que agiliza a identificação e mudança de contexto do kubectl. Com ele fica mais fácil alternar entre clusters e usuários configurados no KUBECONFIG. Ele pode ser instalado com os comandos abaixo:

`git clone https://github.com/ahmetb/kubectx.git ~/.kubectx; export PATH=~/.kubectx:$PATH`{{execute}}

Para visualizar os contextos existentes e qual o selecionado atualmente use:

`kubectx`{{execute}}

e para alternar para outro contexto digite *kubectx NOME_DO_CONTEXTO* e para retornar ao contexto anterior, *kubectx -*.

Junto com o kubectx é instalado também o *kubens* que funciona de forma similar ao kubectx para namespaces.

Visite a página https://github.com/ahmetb/kubectx para mais detalhes sobre o kubectx e o kubens.
