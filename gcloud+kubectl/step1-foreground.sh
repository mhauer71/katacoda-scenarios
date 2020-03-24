#!/bin/bash

install_kubectx () {
    
}
# Script para instalar dependências
#  gcloud cli, jq, pkg-config
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-get update && sudo apt-get -y install google-cloud-sdk jq

#  kubectx
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
ln -sf ~/.kubectx/completion/kubens.bash $COMPDIR/kubens
ln -sf ~/.kubectx/completion/kubectx.bash $COMPDIR/kubectx
export PATH=~/.kubectx:$PATH