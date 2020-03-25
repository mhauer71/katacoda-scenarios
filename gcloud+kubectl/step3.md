
Um objeto ingress no GKE define regras para rotear tráfego HTTP(S) para aplicativos executados em um cluster. Um objeto ingress está associado a um ou mais objetos service, e cada um deles está associado a um conjunto de pods.

Você pode listar os ingress do cluster com o comando

`kubectl get ingress`{{execute}}

Nessa forma simples do comando podemos ver o nome do ingress, os hosts aceitos por eles para redirecionamento, o endereço IP e a porta do ingress.

Vamos examinar melhor um desses ingress, escolha um do resultado do comando anterior e execute o comando *kubectl get ingress NOME -o yaml*

Temos agora mais informações do que tínhamos obtido no primeiro comando e, para nosso interesse no funcionamento na GKE, vamos nos fixar nos resultados do campo annotations (alguns dados foram omitidos a partir de um exemplo real):
```yaml
    ingress.gcp.kubernetes.io/pre-shared-cert: YYYYYYY
    ingress.kubernetes.io/backends: '{"k8s-be-ZZZZZ--IDENTIFICADOR":"HEALTHY"}'
    ingress.kubernetes.io/forwarding-rule: k8s-fw-default-NOME--IDENTIFICADOR
    ingress.kubernetes.io/https-forwarding-rule: k8s-fws-default-NOME--IDENTIFICADOR
    ingress.kubernetes.io/https-target-proxy: k8s-tps-default-NOME--IDENTIFICADOR
    ingress.kubernetes.io/ssl-cert: XXXXXXXXXX
    ingress.kubernetes.io/static-ip: k8s-fw-default-NOME--IDENTIFICADOR
    ingress.kubernetes.io/target-proxy: k8s-tp-default-NOME--IDENTIFICADOR
    ingress.kubernetes.io/url-map: k8s-um-default-NOME--IDENTIFICADOR
```
Na GKE esses annotations correspondem a toda a cadeia de objetos da GCP responsável pelo balanceamento de carga de acessos para dentro de um serviço do cluster GKE. Cada um recebe um prefixo de acordo com a sua funcionalidade (k8s-be para backends, k8s-fw/k8s-fws para forward-rules http/https, k8s-um para URL Maps e assim por diante), o nome do ingress e um sufixo IDENTIFICADOR do cluster, todos os objetos da cadeia de um cluster terão o mesmo IDENTIFICADOR. 

O benefício dessa integração das annotations do ingress com os objetos da GCP é que com apenas um comando `kubectl get ingress  -o json`{{execute}} podemos obter quase todos os atributos da cadeia do Healthcheck do baleanceador de carga do ingress, restando apenas o caminho do Healthcheck que pode ser obtido com apenas um comando gcloud conforme demonstrado no script abaixo:

`json=$(kubectl get ingress  -o json)
ingress_count=$(echo $json | jq '.items|length')
for ((i=0;i<$ingress_count;i++)); do
    unset rule_array
    name=$(echo $json | jq -r '.items['$i'].metadata.name')
    ### TODO: Otimizar uso do jq, capturando as variáveis apenas com uma execução do comando
    ip=$(echo $json | jq -r '.items['$i'].status.loadBalancer.ingress[].ip')
    backend=$(echo $json | jq -r '.items['$i'].metadata.annotations["ingress.kubernetes.io/backends"]' | cut -f2 -d\")
    host_and_path=$(gcloud compute health-checks list --format="csv[no-heading](httpHealthCheck.host,httpHealthCheck.requestPath)" --filter="name=('$backend')")
    ### TODO: Trocar uso do "cut" para "read", para capturar as variáveis com apenas com um comando
    lb_host=$(echo $host_and_path | cut -d, -f1)
    healthcheck_path=$(echo $host_and_path | cut -d, -f2)    
    ### Caso o host esteja discriminado dentro do healthcheck, usamos o seu valor para todas os "Host:" headers. Caso contrário, usamos o valor das Forward Rules
    echo "----"
    echo "Ingress: "$name
    echo "IP: "$ip
    if [[ ! $lb_host == "" ]]; then
        rule_count=1
        rule_array[0]=$lb_host
        echo "- "$lb_host
    else
        rule_count=$(echo $json | jq '.items['$i'].spec.rules | length')
        for ((j=0;j<$rule_count;j++)); do
            rule_array[$j]=$(echo $json | jq -r '.items['$i'].spec.rules['$j']?.host')
            if [[ ${rule_array[$j]} =~ "*" ]]; then
                rule_array[$j]="www."${rule_array[$j]#"*."}
            fi
            echo "- "${rule_array[$j]}
        done
    fi
    echo "Caminho do Healthcheck: "$healthcheck_path
done`{{execute}}

Usando esse métdodo, com apenas um acesso ao cluster (o comandos *kubectl get ingress*) e um à API da GCP para cada ingress (*gcloud compute health-checks list*), temos todas as informações sobre os objetos da GCP responsáveis pelo Healthcheck. Para conseguir o mesmo utilizando apenas a ferramenta *gcloud* precisaríamos executar quatro consultas à API da GCP para cada ingress, a fim de obter os detalhes dos objetos *forwarding-rules*, *target-http-proxies*, *url-maps* e *backend-services* deles, tornando a operação bem mais lenta.

