
# Maven CI/CD Pipeline Project (GitLab + Jenkins + Nexus + Kubernetes)

> Enhanced GitHub-friendly version. Original technical steps are preserved and organized.
> Added architecture diagrams, pipeline flow diagrams, explanations, and notes.

## Architecture Overview

```mermaid
flowchart LR
    A[Developer] --> B[GitLab]
    B --> C[Jenkins Pipeline]
    C --> D[Maven Build]
    D --> E[Docker Build]
    E --> F[Nexus Repository]
    F --> G[Kubernetes Cluster]
    G --> H[LoadBalancer Service]
    H --> I[End Users]
```

## CI/CD Pipeline Flow

```mermaid
flowchart TD
    A[Git Commit] --> B[Jenkins Trigger]
    B --> C[Clone Repository]
    C --> D[Maven Package]
    D --> E[Build Docker Image]
    E --> F[Push Image to Nexus]
    F --> G[Deploy to Kubernetes]
    G --> H[Verify Rollout]
    H --> I[Access Application]
```

## Environment Components

| Component | Purpose |
|------------|----------|
| GitLab | Source Code Management |
| Jenkins | CI/CD Automation |
| Maven | Build Tool |
| Docker | Containerization |
| Nexus | Image Repository |
| Kubernetes | Application Deployment |
| MetalLB | External IP Allocation |

---

# Detailed Implementation Steps



Maven pipe line project with git and jenkins and kubernetes

create a project devops_project2_mavenwebapp from gitlab ui without Readme file option.


https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git



download mavenweb app from git

sreejith@gitlab:~$ git clone https://github.com/openhelpdevops/devops_project2_mavenwebapp.git


sreejith@ci:~/devops_project2_mavenwebapp$ pwd
/home/sreejith/devops_project2_mavenwebapp

sreejith@ci:~/devops_project2_mavenwebapp$ ls -al
total 44
drwxrwxr-x  4 sreejith sreejith 4096 Jun 23 10:17 .
drwxr-x--- 12 sreejith sreejith 4096 Jun 23 10:17 ..
-rw-rw-r--  1 sreejith sreejith  149 Jun 23 10:17 Dockerfile
-rw-rw-r--  1 sreejith sreejith 1358 Jun 23 10:17 docker-k8s-jenkinsfile_V1
-rw-rw-r--  1 sreejith sreejith 1855 Jun 23 10:17 docker-k8s-jenkinsfile_V2
drwxrwxr-x  8 sreejith sreejith 4096 Jun 23 10:17 .git
-rw-rw-r--  1 sreejith sreejith  839 Jun 23 10:17 k8s-deploy.yml
-rw-rw-r--  1 sreejith sreejith  892 Jun 23 10:17 pom.xml
-rw-rw-r--  1 sreejith sreejith    6 Jun 23 10:17 README.md
drwxrwxr-x  3 sreejith sreejith 4096 Jun 23 10:17 src
-rw-rw-r--  1 sreejith sreejith  682 Jun 23 10:17 task.yml



shows the remote repositories configured for your local Git repository.


sreejith@ci:~/devops_project2_mavenwebapp$ git remote -v
origin  https://github.com/openhelpdevops/devops_project2_mavenwebapp.git (fetch)
origin  https://github.com/openhelpdevops/devops_project2_mavenwebapp.git (push)



Git won’t let you add origin again because it’s already set (likely pointing to GitHub).

If you want to push this repo to GitLab instead:

sreejith@gitlab:~/maven-web-app$ git remote remove origin
sreejith@gitlab:~/maven-web-app$ git remote add origin https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git

sreejith@ci:~/devops_project2_mavenwebapp$ git remote -v
origin  https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git (fetch)
origin  https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git (push)

Lets create 2 branches for now:-

git checkout -b main
git push -u origin main

push to new branch

git checkout -b migration
git push -u origin migration



create a token for user sreejith  from gitlab ui>>Projects>>devops_project2_mavenwebapp>>settings>> Access Tokens

https://gitlab.openhelp.net/-/user_settings/personal_access_tokens?page=1&state=active&sort=expires_asc

add new token>> select the below

✅ read_repository
✅ write_repository (if pushing)
✅ api (optional)


token i created:-

glpat-gjhtEH2DGFDDKbOwwjkjzm86MQp1OjMH.01.0w13cv7y9


"Show me all references (branches, tags, merge requests) and the commit IDs they point to."


root@ci:/usr/local/share/ca-certificates# git ls-remote https://sreejith:glpat-gjhtEH2DGFDDKbOwwjkjzm86MQp1OjMH.01.0w13cv7y9@gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git 
ad3f85fd85a591c789095c4ea70993b48b113176        HEAD
ad3f85fd85a591c789095c4ea70993b48b113176        refs/heads/main
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/1/head
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/2/head
11116adaad74223713c7192fb52013edca6a69b4        refs/merge-requests/3/head
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/4/head
59e1dde485492a7e99cd2631c01b9f94ff9f927c        refs/merge-requests/4/merge
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/5/head
4921d083eb8dfdef6c403f8b1932a0af36825a32        refs/merge-requests/5/merge



Run the Maven build command.

root@ci:~/bank-app# mvn clean package
What This Command Does
Java Code
   ↓
Maven reads pom.xml
   ↓
Downloads dependencies
   ↓
Compiles code
   ↓
Runs tests
   ↓
Creates JAR file


sreejith@ci:~/devops_project2_mavenwebapp$ pwd
/home/sreejith/devops_project2_mavenwebapp


sreejith@ci:~/devops_project2_mavenwebapp$ mvn clean package
[INFO] Scanning for projects...
[INFO]
[INFO] --------------------< in.openhelp:01-maven-web-app >--------------------
[INFO] Building 01-maven-web-app 3.0-RELEASE
[INFO] --------------------------------[ war ]---------------------------------
Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom
Downloaded from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom (3.9 kB at 4.5 kB/s)
Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/22/maven-plugins-22.pom
Downloaded from central: https://repo.maven.apache.org/maven2/org/codehaus/plexus/plexus-utils/3.3.0/plexus-utils-3.3.0.jar (263 kB at 248 kB/s)
[INFO] Packaging webapp
[INFO] Assembling webapp [01-maven-web-app] in [/home/sreejith/devops_project2_mavenwebapp/target/maven-web-app]
[INFO] Processing war project
[INFO] Copying webapp resources [/home/sreejith/devops_project2_mavenwebapp/src/main/webapp]
[INFO] Building war: /home/sreejith/devops_project2_mavenwebapp/target/maven-web-app.war



Try to create a docker image as well


sreejith@ci:~/devops_project2_mavenwebapp$ sudo docker build -t devops/mavenwebapp:latest .
[sudo] password for sreejith:
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  485.9kB
Step 1/4 : FROM tomcat:latest
 ---> a5c126eb42eb
Step 2/4 : MAINTAINER Sreejith <sreejithedl@gmail.com>
 ---> Using cache
 ---> 55a041470236
Step 3/4 : EXPOSE 8080
 ---> Using cache
 ---> e06723e4809a
Step 4/4 : COPY target/maven-web-app.war /usr/local/tomcat/webapps/maven-web-app.war
 ---> 6ea1d310ba69
Successfully built 6ea1d310ba69
Successfully tagged devops/mavenwebapp:latest


List the docker images

sreejith@ci:~/devops_project2_mavenwebapp$ sudo docker image ls | grep mavenwebapp
devops/mavenwebapp:latest   


Below 2 commands are used to store your Docker image in Nexus Repository so that Kubernetes, Jenkins, or other servers can download it later.

docker logout nexus.openhelp.net
docker login nexus.openhelp.net

docker tag sreejith/mavenwebapp:latest nexus.openhelp.net/docker-private/devops/mavenwebapp:latest
docker push nexus.openhelp.net/docker-private/devops/mavenwebapp:latest

Recommended “industry-style” tagging

Most CI/CD pipelines use this structure:

nexus.openhelp.net/<repo>/<group>/<app>:<version>


list maven images in repo using

sreejith@ci:~/devops_project2_mavenwebapp$ sudo docker image ls | grep maven
devops/mavenwebapp:latest                                                                                                                   6ea1d310ba69        586MB          155MB
maven:3.9.9-eclipse-temurin-17                                                                                                              f58d59b6273e        759MB          234MB
nexus.openhelp.net/docker-private/devops/mavenwebapp:latest                                                                                 bd79c2027706        586MB          155MB
nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest                                                                               bd79c2027706        586MB          155MB
nexus.openhelp.net/docker-private/sreejith/mavenwebapp:v1                                                                                   90ac4be8f0e6        586MB          155MB
sreejith/mavenwebapp:latest                                                                                                                 bd79c2027706        586MB          155MB


To remove any old unused  images use the below command:-

sreejith@ci:~/devops_project2_mavenwebapp$ docker rmi nexus.openhelp.net/docker-private/sreejith/mavenwebapp:v1

sreejith@ci:~/devops_project2_mavenwebapp$ docker rmi nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest 



Tag and push the image to nexus repo
=========================================

docker tag sreejith/mavenwebapp:latest nexus.openhelp.net/docker-private/sreejith/mavenwebapp:v1
docker push nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest

List repocitories using the below command:-


root@ci:/etc/nginx/sites-enabled# curl -u admin -k https://nexus.openhelp.net/v2/_catalog
Enter host password for user 'admin':
{"repositories":["docker-private/sreejith/mavenwebapp"]}


to list repo and tages and tags for mavenwebapp

sreejith@ci:~/devops_project2_mavenwebapp$ curl -u admin -k https://nexus.openhelp.net/v2/docker-private/devops/mavenwebapp/tags/list
Enter host password for user 'admin':
{"name":"docker-private/devops/mavenwebapp","tags":["latest"]}sreejith@ci:~/devops_project2_mavenwebapp$



to list different repos

root@ci:/etc/nginx/sites-enabled# curl -u admin -k https://nexus.openhelp.net/service/rest/v1/repositories
Enter host password for user 'admin':

  "name" : "nuget-group",
  "format" : "nuget",
  "type" : "group",
  "url" : "https://nexus.openhelp.net/repository/nuget-group",
  "size" : 0,
  "attributes" : { }
}, {
  "name" : "docker-private",
  "format" : "docker",
  "type" : "hosted",
  "url" : "https://nexus.openhelp.net/repository/docker-private",



Lets create CI pipeline



Login to jenkins ui

https://jenkins.openhelp.net

username:sreejith
Password: sreejith

install the plugin from ui:-

Pipeline Stage View

from manage jenkins>> Tools>> add maven

name
Maven3.9.15

binary->maven3.9.15

configure maven as a global tool instead of installing it as a package directly on the jenkins server and it is not recommened in the production environment



To add a secrents for docker registery, execute this command from controller host kube2


root@kube2:~#kubectl create secret docker-registry nexus-secret --docker-server=nexus.openhelp.net --docker-username=admin --docker-password='Lighitha123!' -n dev

we are using this nexus-secret for authentication in the below yaml file .

sreejith@gitlab:~/maven-web-app$ cat k8s-deploy.yml
apiVersion: v1
kind: Namespace
metadata:
  name: dev

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mavenwebappdeployment
  namespace: dev
spec:
  replicas: 2
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: mavenwebapp
  template:
    metadata:
      labels:
        app: mavenwebapp
    spec:
      imagePullSecrets:
      - name: nexus-secret
      containers:
      - name: mavenwebappcontainer
        image: nexus.openhelp.net/docker-private/devops/mavenwebapp:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: mavenwebappsvc
  namespace: dev
  annotations:
    metallb.universe.tf/address-pool: my-ip-pool
spec:
  type: LoadBalancer
  selector:
    app: mavenwebapp
  ports:
  - port: 80
    targetPort: 8080




sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl get nodes
[sudo] password for sreejith:
NAME                 STATUS   ROLES           AGE   VERSION
kube2.openhelp.net   Ready    control-plane   46d   v1.29.15
kube3.openhelp.net   Ready    control-plane   46d   v1.29.15
kube4.openhelp.net   Ready    control-plane   46d   v1.29.15
kube5.openhelp.net   Ready    <none>          46d   v1.29.15
kube6.openhelp.net   Ready    <none>          46d   v1.29.15
kube7.openhelp.net   Ready    <none>          46d   v1.29.15

sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl apply -f k8s-deploy.yml
namespace/dev unchanged
deployment.apps/mavenwebappdeployment configured
service/mavenwebappsvc unchanged



sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl get svc -n dev
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
mavenwebappsvc   LoadBalancer   10.99.69.199   192.168.0.241   80:32368/TCP   46d

Try to access the ui 


http://192.168.0.241/maven-web-app/#


if its working fine remove the deployment again


sreejith@ci:~/devops_project2_mavenwebapp$sudo -u jenkins kubectl delete -f k8s-deploy.yml


create a secret for git credentials in jenkins>> credentials

click on settings>>security>>  Credentials>> Add  credentials>> Username/password

Give ID:-  sreejithgit
Description:- Git user object

git hub username:-sreejith
password:- glpat-eqkB

This password is created from gitlab >><projectname>settings>>Access tokens


Create a new pipeline  from jenkins ui>> +new iteam>> Pipeline

Give name of pipeline as project2 pipeline.

In the configure tab add the below pipe line code


pipeline {
    agent any

    tools {
        maven "Maven3.9.15"
    }

    environment {
        REGISTRY_URL = 'nexus.openhelp.net'
        REPO         = 'docker-private/devops'
        IMAGE        = 'mavenwebapp'
        TAG          = "${BUILD_NUMBER}"

        NEXUS_CREDS = credentials('nexus-cred')
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main',
                    credentialsId: 'sreejithgit',
                    url: 'https://github.com/openhelpdevops/devops_project2_mavenwebapp.git'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t $REGISTRY_URL/$REPO/$IMAGE:$TAG .'

                sh 'echo "$NEXUS_CREDS_PSW" | docker login $REGISTRY_URL -u "$NEXUS_CREDS_USR" --password-stdin'

                sh 'docker push $REGISTRY_URL/$REPO/$IMAGE:$TAG'
            }
        }

        stage('k8s deployment') {
            steps {
                sh '''
                if kubectl get deployment mavenwebappdeployment -n dev
                then
                    echo "Deployment exists → updating image"
                    kubectl set image deployment/mavenwebappdeployment mavenwebappcontainer=$REGISTRY_URL/$REPO/$IMAGE:$TAG -n dev
                else
                    echo "Deployment not found → creating deployment"
                    kubectl apply -f k8s-deploy.yml
                fi
                '''
            }
        }

        stage('Verify') {
            steps {
                sh 'kubectl rollout status deployment/mavenwebappdeployment -n dev'
                sh 'kubectl get pods -n dev -o wide'
                sh 'kubectl get svc -n dev'
            }
        }
    }
}


Note:-

Build Tag
TAG = "${BUILD_NUMBER}"

This is very important.

What is BUILD_NUMBER?

Jenkins automatically creates it.

Example:

Pipeline Run	BUILD_NUMBER
First Run	      1
Second Run	      2

ie 
First Execution
TAG=1

Docker Image:

nexus.openhelp.net/docker-private/devops/mavenwebapp:1
Second Execution
TAG=2

Docker Image:

nexus.openhelp.net/docker-private/devops/mavenwebapp:2

and so on



once the deployemnet is successful you can access application using the below url:-


save and click on deploy anc heck the progress/logs for any errors.

check the LB ip assigned

reejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl get svc -n dev
[sudo] password for sreejith:
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
mavenwebappsvc   LoadBalancer   10.110.28.26   192.168.0.241   80:30104/TCP   3h13m

you will be able to access maven app using the ui below:-


http://192.168.0.241/maven-web-app/#


