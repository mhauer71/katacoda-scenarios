Nos passos anteriores foram usados alguns comandos, argumentos e conceitos que podem ser um pouco confusos, então aqui estão algumas explicações para ajudar a utilizá-los em outras situações.

## Formatos de saída do gcloud e do kubectl
### gcloud
Além do formato tradicional da saída do comando *gcloud*, voltado para consultas rápidas na linha de comando, temos outro modos accessíveis através da flag *--format* que podem nos fornecer o resultado em formatos mais adequados e com mais dados para o processamento que desejamos fazer. Vamos comparar através da saída do comando *gcloud container clusters list*
* Uso normal: `gcloud container clusters list`{{execute}}
* Saída em json: `gcloud container clusters list --format=json`{{execute}} 
* Saída em yaml: `gcloud container clusters list --format=yaml`{{execute}}
* Saída separada por vírgulas, com os campos *nome*  *endpoint* e *versão de cada nodepool*, sem o cabeçalho: `gcloud container clusters list --format="csv[no-heading](name,endpoint,nodePools.version)"`{{execute}}
* Os mesmos campos da saída anterior, em forma de tabela e com cabeçalho e bordas: `gcloud container clusters list --format="table[box](name,endpoint,nodePools[].version)"`{{execute}}

Isso nos propicia a montar scripts para tratar a saída dos comandos da gcloud, como no exemplo abaixo que lista todos as chaves dos service accounts existentes nos projetos associados à sua credencial gcloud (script retirado [deste blog da Google Cloud](https://cloud.google.com/blog/products/gcp/filtering-and-formatting-fun-with))
`#!/bin/bash
for project in  $(gcloud projects list --format="value(projectId)")
do
  echo "ProjectId:  $project"
  for robot in $(gcloud beta iam service-accounts list --project $project --format="value(email)")
   do
     echo "    -> Robot $robot"
     for key in $(gcloud beta iam service-accounts keys list --iam-account $robot --project $project --format="value(name.basename())")
        do
          echo "        $key" 
     done
   done
done`{{execute}}

### kubectl
A saída do comando *kubectl* pode ser formatada de forma similar utilizando tempmplates JSONPath através da flag *-o*, conforme os exemplos abaixo

* Mostra todos os pods com data e hora de inicialização: `kubectl get pods -o=jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.startTime}{"\n"}{end}'`{{execute}}
* Lista os pods e respectivos containers: `kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
sort`{{execute}}

Para mais informações sobre o suporte ao JSONPath pelo kubectl, veja os links [aqui](https://kubernetes.io/docs/reference/kubectl/jsonpath/) e [aqui](https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/).

## Usando o jq
O jq é um processador de JSON bastante útil para a interpretação e manipulação de arquivos e respostas de servidores que utilizam esse formato. Alguns exemplos do uso do jq em conjunto com o gcloud e o kubectl:

* Campos *nome*  *endpoint* e *versão de cada nodepool*, similar ao filtro direto do gcloud `gcloud container clusters list --format=json | jq -r '.[].name,.[].endpoint,.[].nodePools[].version' | jq`{{execute}}
* Contagem do número de ingress do cluster `kubectl get ingress  -o json | jq '.items|length'`{{execute}}

Para mais exemplos de uso do jq, visite [o tutorial](https://stedolan.github.io/jq/tutorial/).

## Truques do bash
Alguns comandos e procedimentos do *bash* interessantes utilizados
* cut, para extrair determinados campos ou intervalos de caracteres em uma linha: Extraindo apenas o 2o campo, usando o caracter "\" como delimitador  `kubectl get ingress  -o json | jq -r '.items[].metadata.annotations["ingress.kubernetes.io/backends"]' | cut -f2 -d\"`{{execute}}

* rev, para inverter o conteudo de uma string (útil para recuperar o último campo de uma string quando não sabemos o número de campos, como explicado [neste post](https://stackoverflow.com/questions/22727107/how-to-find-the-last-field-using-cut/22727211)): `echo "otrauq oriecret odnuges oriemirp" | rev`{{execute}}

* Remover um prefixo/sufixo de uma string: 
`string="http://hurb.com/app?argumento=a"
prefix="http://hurb.com/"
path=${string#"$prefix"}
echo "PATH: "$path
suffix="?argumento=a"
url=${string%"$suffix"}
echo "URL: "$url`{{execute}}
