#!/bin/bash
git clone https://${GIT_TOKEN}@github.com/user-name/petclinic-gitops-app.git
cd petclinic-gitops-config
sed -i "s|tag:.*|tag: \"${BUILD_NUMBER}\"|" charts/petclinic/values.yaml
git config user.email "jenkins@ci.com"
git config user.name "Jenkins"
git add charts/petclinic/values.yaml
git commit -m "ci: update image tag to ${BUILD_NUMBER}"
git push
cd ..
rm -rf petclinic-gitops-config
