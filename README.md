# Maven WebApp CI/CD Pipeline with GitLab, Jenkins, Nexus and Kubernetes

This document explains how to build and deploy a Maven web application using Git/GitLab, Jenkins, Docker, Nexus Repository and Kubernetes.

The original commands and outputs are preserved, but the content is reorganized into a GitHub-friendly runbook with clear explanations, notes, command blocks and expected outputs.

> **Security Note**
>
> The original notes contained real-looking GitLab access tokens and passwords. For GitHub safety, they are masked in this document using placeholders like `<GITLAB_TOKEN>`, `<NEXUS_PASSWORD>` and `<JENKINS_PASSWORD>`.
>
> Do not commit real passwords, tokens or secrets into GitHub or GitLab repositories.

---

## Table of Contents

1. [Project Architecture](#1-project-architecture)
2. [Project Goal](#2-project-goal)
3. [Create GitLab Project](#3-create-gitlab-project)
4. [Clone Maven Web Application](#4-clone-maven-web-application)
5. [Verify Project Directory](#5-verify-project-directory)
6. [Check and Change Git Remote](#6-check-and-change-git-remote)
7. [Create Git Branches](#7-create-git-branches)
8. [Create GitLab Access Token](#8-create-gitlab-access-token)
9. [Verify Git References](#9-verify-git-references)
10. [Build Maven Application](#10-build-maven-application)
11. [Build Docker Image](#11-build-docker-image)
12. [List Docker Images](#12-list-docker-images)
13. [Tag and Push Docker Image to Nexus](#13-tag-and-push-docker-image-to-nexus)
14. [Verify Nexus Docker Repository](#14-verify-nexus-docker-repository)
15. [Create Kubernetes Docker Registry Secret](#16-create-kubernetes-docker-registry-secret)
16. [Kubernetes Deployment YAML](#16-create-kubernetes-docker-registry-secret)
17. [Kubernetes Deployment YAML](#17-kubernetes-deployment-yaml)
18. [Verify Jenkins User Kubernetes Access](#18-verify-jenkins-user-kubernetes-access)
19. [Deploy Application Manually to Kubernetes](#19-deploy-application-manually-to-kubernetes)
20. [Create Git Credentials in Jenkins](#20-create-git-credentials-in-jenkins)
21. [Create Jenkins Pipeline Job](#21-create-jenkins-pipeline-job)
22. [Complete Jenkins Pipeline Code](#22-complete-jenkins-pipeline-code)
23. [BUILD_NUMBER and Docker Tag Explanation](#23-build_number-and-docker-tag-explanation)
24. [Verify Application Access](#24-verify-application-access)
25. [Final Jenkins Pipeline Flow Chart](#25-final-jenkins-pipeline-flow-chart)
26. [How the Jenkins Pipeline Works](#26-how-the-jenkins-pipeline-works)
27. [Important Best Practices](#27-important-best-practices)

---

## 1. Project Architecture

```mermaid
flowchart LR
    Dev[Developer Workstation]:::dev --> GitHub[GitHub Source Repo]:::git
    GitHub --> GitLab[GitLab Project<br/>devops_project2_mavenwebapp]:::git
    GitLab --> Jenkins[Jenkins Server<br/>jenkins.openhelp.net]:::jenkins
    Jenkins --> Maven[Maven Build<br/>mvn clean package]:::build
    Maven --> WAR[WAR File<br/>target/maven-web-app.war]:::artifact
    WAR --> Docker[Docker Build<br/>Tomcat Image]:::docker
    Docker --> Nexus[Nexus Docker Registry<br/>nexus.openhelp.net/docker-private/devops]:::nexus
    Nexus --> K8s[Kubernetes Cluster<br/>kube2-kube7]:::k8s
    K8s --> Pods[Deployment<br/>mavenwebappdeployment<br/>2 Replicas]:::k8s
    Pods --> SVC[LoadBalancer Service<br/>mavenwebappsvc]:::svc
    SVC --> User[End User Browser<br/>http://192.168.0.241/maven-web-app/#]:::user

    classDef dev fill:#d5e8ff,stroke:#1b4f9c,stroke-width:2px,color:#000;
    classDef git fill:#fff3cd,stroke:#b8860b,stroke-width:2px,color:#000;
    classDef jenkins fill:#f8d7da,stroke:#b02a37,stroke-width:2px,color:#000;
    classDef build fill:#e2e3ff,stroke:#4b4fd6,stroke-width:2px,color:#000;
    classDef artifact fill:#e7f5ff,stroke:#1971c2,stroke-width:2px,color:#000;
    classDef docker fill:#d3f9d8,stroke:#2b8a3e,stroke-width:2px,color:#000;
    classDef nexus fill:#ffe8cc,stroke:#e8590c,stroke-width:2px,color:#000;
    classDef k8s fill:#e6fcf5,stroke:#087f5b,stroke-width:2px,color:#000;
    classDef svc fill:#f3d9fa,stroke:#9c36b5,stroke-width:2px,color:#000;
    classDef user fill:#dee2e6,stroke:#495057,stroke-width:2px,color:#000;
```

### Explanation

The application source code is stored in Git. Jenkins pulls the code, builds the Java web application using Maven, creates a Docker image, pushes the image to Nexus, and deploys it into Kubernetes. Kubernetes exposes the application using a `LoadBalancer` service.

---

## 2. Project Goal

The goal of this project is to create a complete CI/CD pipeline for a Maven-based Java web application.

| Tool | Purpose |
|---|---|
| GitLab | Source code repository |
| Jenkins | CI/CD pipeline execution |
| Maven | Java application build tool |
| Docker | Creates container image |
| Nexus | Stores Docker images |
| Kubernetes | Runs the application |
| MetalLB | Provides external LoadBalancer IP |

---

## 3. Create GitLab Project

Create a project named `devops_project2_mavenwebapp` from the GitLab UI.

### GitLab project URL

```text
https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git
```

### Important selection

Create the project **without selecting the README file option**.

### Explanation

Creating the project without a README is useful when an existing local repository already has files. This avoids conflicts during the first push.

---

## 4. Clone Maven Web Application

The Maven web application is cloned from GitHub first.

### Command

```bash
sreejith@gitlab:~$ git clone https://github.com/openhelpdevops/devops_project2_mavenwebapp.git
```

### Explanation

This command downloads the existing Maven web application source code from GitHub into the local machine.

### Expected result

Git creates a new local folder named:

```text
devops_project2_mavenwebapp
```

---

## 5. Verify Project Directory

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ pwd
```

### Output

```text
/home/sreejith/devops_project2_mavenwebapp
```

### Explanation

The `pwd` command shows the current working directory. This confirms that we are inside the Maven web application project directory.

---

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ ls -al
```

### Output

```text
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
```

### Explanation of important files

| File or Directory | Purpose |
|---|---|
| `Dockerfile` | Defines how to create the Docker image |
| `pom.xml` | Maven project configuration file |
| `src` | Java web application source files |
| `k8s-deploy.yml` | Kubernetes deployment and service manifest |
| `docker-k8s-jenkinsfile_V1` | Jenkins pipeline example version 1 |
| `docker-k8s-jenkinsfile_V2` | Jenkins pipeline example version 2 |
| `.git` | Git repository metadata |

---

## 6. Check and Change Git Remote

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ git remote -v
```

### Output

```text
origin  https://github.com/openhelpdevops/devops_project2_mavenwebapp.git (fetch)
origin  https://github.com/openhelpdevops/devops_project2_mavenwebapp.git (push)
```

### Explanation

The `git remote -v` command shows the remote repositories configured for the local Git repository. Here the current remote is pointing to GitHub.

### Why change the remote?

Git will not allow adding another `origin` because `origin` already exists. If the requirement is to push this project into GitLab, remove the old GitHub origin and add the GitLab origin.

### Remove old GitHub origin

```bash
sreejith@gitlab:~/maven-web-app$ git remote remove origin
```

### Add GitLab origin

```bash
sreejith@gitlab:~/maven-web-app$ git remote add origin https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git
```

### Verify new remote

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ git remote -v
```

### Output

```text
origin  https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git (fetch)
origin  https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git (push)
```

### Explanation

Now Git is configured to fetch and push code from the GitLab repository.

---

## 7. Create Git Branches

### Create main branch

```bash
git checkout -b main
```

### Explanation

This creates a new branch named `main` and switches to it.

### Push main branch

```bash
git push -u origin main
```

### Explanation

This pushes the local `main` branch to GitLab and sets upstream tracking.

### Create migration branch

```bash
git checkout -b migration
```

### Push migration branch

```bash
git push -u origin migration
```

### Explanation

This creates and pushes another branch named `migration`. Using multiple branches helps separate development, migration and production-ready code.

---

## 8. Create GitLab Access Token

Create a token for user `sreejith` from the GitLab UI.

### Navigation

```text
GitLab UI
  → Projects
  → devops_project2_mavenwebapp
  → Settings
  → Access Tokens
```

### Token page

```text
https://gitlab.openhelp.net/-/user_settings/personal_access_tokens?page=1&state=active&sort=expires_asc
```

### Required permissions

```text
✅ read_repository
✅ write_repository
✅ api
```

### Original token from notes, masked for GitHub safety

```text
glpat-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### Explanation

The GitLab token is used instead of the normal password when Jenkins or Git commands need to authenticate with GitLab.

---

## 9. Verify Git References

This command shows all references such as branches, tags, merge requests and the commit IDs they point to.

### Command

```bash
root@ci:/usr/local/share/ca-certificates# git ls-remote https://sreejith:<GITLAB_TOKEN>@gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git
```

### Output

```text
ad3f85fd85a591c789095c4ea70993b48b113176        HEAD
ad3f85fd85a591c789095c4ea70993b48b113176        refs/heads/main
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/1/head
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/2/head
11116adaad74223713c7192fb52013edca6a69b4        refs/merge-requests/3/head
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/4/head
59e1dde485492a7e99cd2631c01b9f94ff9f927c        refs/merge-requests/4/merge
a07f0e2b9fb6d948722279264386351e0c5878d1        refs/merge-requests/5/head
4921d083eb8dfdef6c403f8b1932a0af36825a32        refs/merge-requests/5/merge
```

### Explanation

`git ls-remote` checks whether the repository is reachable and whether the token has permission to read the repository.

| Reference | Meaning |
|---|---|
| `HEAD` | Default branch pointer |
| `refs/heads/main` | Main branch |
| `refs/merge-requests/*/head` | Source commit of merge request |
| `refs/merge-requests/*/merge` | Merge result commit |

---

## 10. Manually package/Build Maven Application and make sure every steps in piple line works if we execute manually/

### Command

```bash
root@ci:~/bank-app# mvn clean package
```

### What this command does

```text
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
Creates WAR file
```

### Explanation

`mvn clean package` cleans previous build files and creates a new application package. For this project, Maven creates a WAR file because the project packaging type is `war`.

### Verify current directory

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ pwd
```

### Output

```text
/home/sreejith/devops_project2_mavenwebapp
```

### Build the Maven project

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ mvn clean package
```

### Output

```text
[INFO] Scanning for projects...
[INFO]
[INFO] --------------------< in.openhelp:01-maven-web-app >--------------------
[INFO] Building 01-maven-web-app 3.0-RELEASE
[INFO] --------------------------------[ war ]---------------------------------
Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom
Downloaded from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-clean-plugin/2.5/maven-clean-plugin-2.5.pom (3.9 kB at 4.5 kB/s)
Downloading from central: https://repo.maven.apache.org/maven2/org/apache/maven/plugins/maven-plugins/22/maven-plugins-22.pom
Downloaded from central: https://repo.maven.apache.org/maven2/org/codehaus/plexus/plexus-utils/3.3.0.jar (263 kB at 248 kB/s)
[INFO] Packaging webapp
[INFO] Assembling webapp [01-maven-web-app] in [/home/sreejith/devops_project2_mavenwebapp/target/maven-web-app]
[INFO] Processing war project
[INFO] Copying webapp resources [/home/sreejith/devops_project2_mavenwebapp/src/main/webapp]
[INFO] Building war: /home/sreejith/devops_project2_mavenwebapp/target/maven-web-app.war
```

### Explanation of output

| Output Line | Meaning |
|---|---|
| `Scanning for projects` | Maven is reading the project |
| `Building 01-maven-web-app` | Maven found the project name |
| `[ war ]` | Project output type is WAR |
| `Downloading from central` | Maven downloads missing dependencies |
| `Packaging webapp` | Maven prepares the web application |
| `Building war` | WAR file is created successfully |

### Final artifact

```text
/home/sreejith/devops_project2_mavenwebapp/target/maven-web-app.war
```

---

## 11. Build Docker Image

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo docker build -t devops/mavenwebapp:latest .
```

### Output

```text
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
```

### Explanation

This command builds a Docker image from the `Dockerfile`.

| Dockerfile Step | Meaning |
|---|---|
| `FROM tomcat:latest` | Uses Tomcat as the base image |
| `MAINTAINER Sreejith` | Adds image maintainer information |
| `EXPOSE 8080` | Documents that the container listens on port 8080 |
| `COPY target/maven-web-app.war ...` | Copies the Maven WAR file into Tomcat webapps directory |

> The WAR file must exist before running Docker build. Run `mvn clean package` first.

---

## 12. List Docker Images

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo docker image ls | grep mavenwebapp
```

### Output

```text
devops/mavenwebapp:latest
```

### Explanation

This verifies that the Docker image was created successfully.

---

## 13. Tag and Push Docker Image to Nexus

The following commands store the Docker image in Nexus Repository so Kubernetes, Jenkins or other servers can download it later.

### Logout from Nexus

```bash
docker logout nexus.openhelp.net
```

### Login to Nexus

```bash
docker login nexus.openhelp.net
```

### Tag Docker image

```bash
docker tag sreejith/mavenwebapp:latest nexus.openhelp.net/docker-private/devops/mavenwebapp:latest
```

### Push image to Nexus

```bash
docker push nexus.openhelp.net/docker-private/devops/mavenwebapp:latest
```

### Explanation

Docker images must be tagged with the target registry path before pushing to Nexus.

### Industry-style image naming format

```text
nexus.openhelp.net/<repo>/<group>/<app>:<version>
```

### Example

```text
nexus.openhelp.net/docker-private/devops/mavenwebapp:latest
```

---

## 14. Verify Nexus Docker Repository

### List Maven related Docker images locally

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo docker image ls | grep maven
```

### Output

```text
devops/mavenwebapp:latest                                                                                                                   6ea1d310ba69        586MB          155MB
maven:3.9.9-eclipse-temurin-17                                                                                                              f58d59b6273e        759MB          234MB
nexus.openhelp.net/docker-private/devops/mavenwebapp:latest                                                                                 bd79c2027706        586MB          155MB
nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest                                                                               bd79c2027706        586MB          155MB
nexus.openhelp.net/docker-private/sreejith/mavenwebapp:v1                                                                                   90ac4be8f0e6        586MB          155MB
sreejith/mavenwebapp:latest                                                                                                                 bd79c2027706        586MB          155MB
```

### Explanation

This output shows multiple image tags pointing to Maven web application images.

### Remove old unused image tag

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ docker rmi nexus.openhelp.net/docker-private/sreejith/mavenwebapp:v1
sreejith@ci:~/devops_project2_mavenwebapp$ docker rmi nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest
```

### Explanation

`docker rmi` removes local image tags. It does not delete the image from Nexus.

### Tag image and Push image to Nexus


```bash
docker tag sreejith/mavenwebapp:latest nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest
docker push nexus.openhelp.net/docker-private/sreejith/mavenwebapp:latest
```

### List repositories from Docker Registry API

```bash
root@ci:/etc/nginx/sites-enabled# curl -u admin -k https://nexus.openhelp.net/v2/_catalog
```

### Output

```text
Enter host password for user 'admin':
{"repositories":["docker-private/sreejith/mavenwebapp"]}
```

### Explanation

This checks the Docker registry catalog in Nexus and lists available Docker repositories.

### List tags for Maven webapp image

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ curl -u admin -k https://nexus.openhelp.net/v2/docker-private/devops/mavenwebapp/tags/list
```

### Output

```text
Enter host password for user 'admin':
{"name":"docker-private/devops/mavenwebapp","tags":["latest"]}
```

### Explanation

This confirms that the image `docker-private/devops/mavenwebapp` exists in Nexus and has the tag `latest`.

### List Nexus repositories

```bash
root@ci:/etc/nginx/sites-enabled# curl -u admin -k https://nexus.openhelp.net/service/rest/v1/repositories
```

### Output

```text
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
```

### Explanation

This Nexus REST API command lists configured repositories in Nexus. The important repository here is `docker-private`.

---

## 15. Create Kubernetes Docker Registry Secret

Run this command from the Kubernetes controller host `kube2`.

### Command

```bash
root@kube2:~# kubectl create secret docker-registry nexus-secret \
  --docker-server=nexus.openhelp.net \
  --docker-username=admin \
  --docker-password='<NEXUS_PASSWORD>' \
  -n dev
```

### Explanation

This creates a Kubernetes Docker registry secret named `nexus-secret`.

Kubernetes uses this secret to authenticate with Nexus while pulling private Docker images.

This secret is referenced in the Deployment YAML:

```yaml
imagePullSecrets:
- name: nexus-secret
```

---

## 16. Kubernetes Deployment YAML

### Command

```bash
sreejith@gitlab:~/maven-web-app$ cat k8s-deploy.yml
```

### File content

```yaml
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
```

### Explanation of YAML

| YAML Section | Purpose |
|---|---|
| `Namespace` | Creates namespace `dev` |
| `Deployment` | Runs the Maven web application pods |
| `replicas: 2` | Runs two pods |
| `strategy: Recreate` | Stops old pods before creating new pods |
| `imagePullSecrets` | Uses Nexus authentication secret |
| `imagePullPolicy: Always` | Always pulls image from Nexus |
| `Service` | Exposes pods inside/outside the cluster |
| `type: LoadBalancer` | Gets external IP using MetalLB |
| `targetPort: 8080` | Sends traffic to Tomcat container port |

---

## 17. Verify Jenkins User Kubernetes Access

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl get nodes
```

### Output

```text
[sudo] password for sreejith:
NAME                 STATUS   ROLES           AGE   VERSION
kube2.openhelp.net   Ready    control-plane   46d   v1.29.15
kube3.openhelp.net   Ready    control-plane   46d   v1.29.15
kube4.openhelp.net   Ready    control-plane   46d   v1.29.15
kube5.openhelp.net   Ready    <none>          46d   v1.29.15
kube6.openhelp.net   Ready    <none>          46d   v1.29.15
kube7.openhelp.net   Ready    <none>          46d   v1.29.15
```

### Explanation

This confirms that the Linux user `jenkins` can run `kubectl` and connect to the Kubernetes cluster.

### Why this is important

The Jenkins pipeline runs commands as the Jenkins user. If this command fails, the pipeline deployment stage will also fail.

---

## 18. Deploy Application Manually to Kubernetes

### Apply deployment

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl apply -f k8s-deploy.yml
```

### Output

```text
namespace/dev unchanged
deployment.apps/mavenwebappdeployment configured
service/mavenwebappsvc unchanged
```

### Explanation

This applies the Kubernetes YAML file.

| Output | Meaning |
|---|---|
| `namespace/dev unchanged` | Namespace already exists |
| `deployment configured` | Deployment was created or updated |
| `service unchanged` | Service already exists and no changes were needed |

### Check service

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl get svc -n dev
```

### Output

```text
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
mavenwebappsvc   LoadBalancer   10.99.69.199   192.168.0.241   80:32368/TCP   46d
```

### Explanation

This confirms that the Kubernetes service is exposed using an external IP.

### Access URL

```text
http://192.168.0.241/maven-web-app/#
```

### Delete deployment after manual test

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl delete -f k8s-deploy.yml
```

### Explanation

After confirming that manual deployment works, delete the resources so Jenkins can recreate or update them through the pipeline.

---

## 19. Create Git Credentials in Jenkins

Create a Jenkins credential for Git authentication.

### Navigation

```text
Jenkins UI
  → Manage Jenkins
  → Security
  → Credentials
  → Add Credentials
```

### Credential type

```text
Username/password
```

### Values

```text
ID: sreejithgit
Description: Git user object
Username: sreejith
Password: <GITLAB_TOKEN>
```

### Explanation

The pipeline uses this credential ID while cloning the repository:

```groovy
credentialsId: 'sreejithgit'
```

The token is created from:

```text
GitLab
  → Project
  → Settings
  → Access Tokens
```

---



## 20. Prepare Jenkins CI Pipeline

### Jenkins URL

```text
https://jenkins.openhelp.net
```

### Jenkins login

```text
Username: sreejith
Password: <JENKINS_PASSWORD>
```

### Explanation

Jenkins will automate the build, Docker image creation, Nexus push and Kubernetes deployment.

### Install Jenkins plugin

Install the following plugin from Jenkins UI:

```text
Pipeline Stage View
```

### Navigation

```text
Manage Jenkins
  → Plugins
  → Available Plugins
  → Search "Pipeline Stage View"
  → Install
```

### Explanation

Pipeline Stage View helps visualize each stage of the Jenkins pipeline.

### Configure Maven in Jenkins

Navigation:

```text
Manage Jenkins
  → Tools
  → Maven installations
  → Add Maven
```

Configuration:

```text
Name: Maven3.9.15
Binary: maven3.9.15
```

### Explanation

Jenkins uses this configured Maven tool in the pipeline:

```groovy
tools {
    maven "Maven3.9.15"
}
```

### Note

Configuring Maven as a Jenkins global tool is better than installing Maven directly on the Jenkins server because Jenkins can manage tool versions centrally.

---

## 21. Create Jenkins Pipeline Job

### Jenkins UI steps

```text
Jenkins UI
  → New Item
  → Enter item name: project2 pipeline
  → Select: Pipeline
  → Click OK
```

### Explanation

This creates a Jenkins Pipeline job where the pipeline code can be pasted directly into the job configuration.

---

## 22. Complete Jenkins Pipeline Code

Paste the following code in the Jenkins Pipeline script section.

```groovy
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
                    url: 'https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git'
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
```

### Pipeline section explanation

#### `agent any`

```groovy
agent any
```

This tells Jenkins to run the pipeline on any available Jenkins agent.

#### Maven tool

```groovy
tools {
    maven "Maven3.9.15"
}
```

This tells Jenkins to use the Maven tool configured in **Manage Jenkins → Tools**.

#### Environment variables

```groovy
environment {
    REGISTRY_URL = 'nexus.openhelp.net'
    REPO         = 'docker-private/devops'
    IMAGE        = 'mavenwebapp'
    TAG          = "${BUILD_NUMBER}"

    NEXUS_CREDS = credentials('nexus-cred')
}
```

| Variable | Value | Purpose |
|---|---|---|
| `REGISTRY_URL` | `nexus.openhelp.net` | Nexus registry hostname |
| `REPO` | `docker-private/devops` | Nexus Docker repository path |
| `IMAGE` | `mavenwebapp` | Docker image name |
| `TAG` | `${BUILD_NUMBER}` | Unique image version per Jenkins build |
| `NEXUS_CREDS` | `credentials('nexus-cred')` | Nexus login credentials stored in Jenkins |

### Stage 1: Clone Repo

```groovy
stage('Clone Repo') {
    steps {
        git branch: 'main',
            credentialsId: 'sreejithgit',
            url: 'https://gitlab.openhelp.net/sreejith/devops_project2_mavenwebapp.git'
    }
}
```

### Stage 2: Maven Build

```groovy
stage('Maven Build') {
    steps {
        sh 'mvn clean package'
    }
}
```

This compiles the application and creates the WAR file:

```text
target/maven-web-app.war
```

### Stage 3: Docker Build and Push

```groovy
stage('Docker Build & Push') {
    steps {
        sh 'docker build -t $REGISTRY_URL/$REPO/$IMAGE:$TAG .'
        sh 'echo "$NEXUS_CREDS_PSW" | docker login $REGISTRY_URL -u "$NEXUS_CREDS_USR" --password-stdin'
        sh 'docker push $REGISTRY_URL/$REPO/$IMAGE:$TAG'
    }
}
```

This builds the Docker image, logs in to Nexus securely using Jenkins credentials, and pushes the image to Nexus.

### Stage 4: Kubernetes Deployment

```groovy
if kubectl get deployment mavenwebappdeployment -n dev
then
    kubectl set image deployment/mavenwebappdeployment mavenwebappcontainer=$REGISTRY_URL/$REPO/$IMAGE:$TAG -n dev
else
    kubectl apply -f k8s-deploy.yml
fi
```

| Condition | Action |
|---|---|
| Deployment exists | Update container image using `kubectl set image` |
| Deployment does not exist | Create resources using `kubectl apply -f k8s-deploy.yml` |

### Stage 5: Verify

```bash
kubectl rollout status deployment/mavenwebappdeployment -n dev
kubectl get pods -n dev -o wide
kubectl get svc -n dev
```

This verifies whether the deployment is successful.

---

## 23. BUILD_NUMBER and Docker Tag Explanation

### Pipeline variable

```groovy
TAG = "${BUILD_NUMBER}"
```

### Why this is important

`BUILD_NUMBER` is automatically generated by Jenkins for every pipeline run.

| Pipeline Run | BUILD_NUMBER |
|---|---|
| First Run | 1 |
| Second Run | 2 |
| Third Run | 3 |

### First execution

```text
TAG=1
```

Docker image:

```text
nexus.openhelp.net/docker-private/devops/mavenwebapp:1
```

### Second execution

```text
TAG=2
```

Docker image:

```text
nexus.openhelp.net/docker-private/devops/mavenwebapp:2
```

### Explanation

Every Jenkins build creates a new Docker image tag. This makes rollback and tracking easier.

Example rollback:

```bash
kubectl set image deployment/mavenwebappdeployment \
  mavenwebappcontainer=nexus.openhelp.net/docker-private/devops/mavenwebapp:1 \
  -n dev
```

---

## 24. Verify Application Access

After successful deployment, check the LoadBalancer IP.

### Command

```bash
sreejith@ci:~/devops_project2_mavenwebapp$ sudo -u jenkins kubectl get svc -n dev
```

### Output

```text
[sudo] password for sreejith:
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)        AGE
mavenwebappsvc   LoadBalancer   10.110.28.26   192.168.0.241   80:30104/TCP   3h13m
```

### Explanation

The application is exposed using the external IP:

```text
192.168.0.241
```

### Application URL

```text
http://192.168.0.241/maven-web-app/#
```

Open the above URL in a browser to verify the Maven web application.

---

## 25. Final Jenkins Pipeline Flow Chart

```mermaid
flowchart TD
    A[Developer pushes code]:::git --> B[Jenkins pipeline starts]:::jenkins
    B --> C[Clone Repo stage]:::stage
    C --> D[Maven Build stage<br/>mvn clean package]:::stage
    D --> E[WAR file created<br/>target/maven-web-app.war]:::artifact
    E --> F[Docker Build stage<br/>docker build]:::docker
    F --> G[Docker Login to Nexus]:::nexus
    G --> H[Docker Push to Nexus]:::nexus
    H --> I{Deployment exists in Kubernetes?}:::decision
    I -- Yes --> J[kubectl set image<br/>update new image tag]:::k8s
    I -- No --> K[kubectl apply -f k8s-deploy.yml<br/>create deployment]:::k8s
    J --> L[Verify rollout]:::verify
    K --> L
    L --> M[Check pods and service]:::verify
    M --> N[User accesses application]:::user

    classDef git fill:#fff3cd,stroke:#b8860b,stroke-width:2px,color:#000;
    classDef jenkins fill:#f8d7da,stroke:#b02a37,stroke-width:2px,color:#000;
    classDef stage fill:#e7f5ff,stroke:#1971c2,stroke-width:2px,color:#000;
    classDef artifact fill:#e2e3ff,stroke:#4b4fd6,stroke-width:2px,color:#000;
    classDef docker fill:#d3f9d8,stroke:#2b8a3e,stroke-width:2px,color:#000;
    classDef nexus fill:#ffe8cc,stroke:#e8590c,stroke-width:2px,color:#000;
    classDef decision fill:#f3d9fa,stroke:#9c36b5,stroke-width:2px,color:#000;
    classDef k8s fill:#e6fcf5,stroke:#087f5b,stroke-width:2px,color:#000;
    classDef verify fill:#dee2e6,stroke:#495057,stroke-width:2px,color:#000;
    classDef user fill:#d0ebff,stroke:#1864ab,stroke-width:2px,color:#000;
```

---

## 26. How the Jenkins Pipeline Works

### Step 1: Jenkins gets the code

Jenkins starts by cloning the source code from the Git repository. This gives Jenkins access to:

```text
pom.xml
Dockerfile
k8s-deploy.yml
src/
```

### Step 2: Jenkins builds the Java web application

Jenkins runs:

```bash
mvn clean package
```

Maven creates:

```text
target/maven-web-app.war
```

### Step 3: Jenkins builds the Docker image

Jenkins runs:

```bash
docker build -t $REGISTRY_URL/$REPO/$IMAGE:$TAG .
```

Example:

```text
docker build -t nexus.openhelp.net/docker-private/devops/mavenwebapp:10 .
```

### Step 4: Jenkins logs in to Nexus

Jenkins runs:

```bash
echo "$NEXUS_CREDS_PSW" | docker login $REGISTRY_URL -u "$NEXUS_CREDS_USR" --password-stdin
```

This uses Jenkins credentials, not a hardcoded password.

### Step 5: Jenkins pushes image to Nexus

Jenkins runs:

```bash
docker push $REGISTRY_URL/$REPO/$IMAGE:$TAG
```

Example image:

```text
nexus.openhelp.net/docker-private/devops/mavenwebapp:10
```

### Step 6: Jenkins deploys to Kubernetes

If the deployment already exists, Jenkins updates only the container image:

```bash
kubectl set image deployment/mavenwebappdeployment \
  mavenwebappcontainer=$REGISTRY_URL/$REPO/$IMAGE:$TAG \
  -n dev
```

If the deployment does not exist, Jenkins creates it:

```bash
kubectl apply -f k8s-deploy.yml
```

### Step 7: Jenkins verifies deployment

Jenkins checks rollout status:

```bash
kubectl rollout status deployment/mavenwebappdeployment -n dev
```

Then it checks pods and service:

```bash
kubectl get pods -n dev -o wide
kubectl get svc -n dev
```

If all checks pass, the application is available through the LoadBalancer IP.

---

## 27. Important Best Practices

### 1. Do not use `latest` in production

Avoid:

```text
mavenwebapp:latest
```

Use versioned tags:

```text
mavenwebapp:1
mavenwebapp:2
mavenwebapp:3
```

This makes rollback easier.

### 2. Do not store passwords in YAML or README files

Avoid:

```bash
--docker-password='real-password'
```

Use placeholders in documentation:

```bash
--docker-password='<NEXUS_PASSWORD>'
```

Use Kubernetes secrets, Jenkins credentials or Vault for real passwords.

### 3. Use Jenkins credentials

The pipeline correctly uses:

```groovy
NEXUS_CREDS = credentials('nexus-cred')
```

This is better than hardcoding Nexus username and password in the pipeline.

### 4. Verify Jenkins Kubernetes permission before pipeline run

Always test:

```bash
sudo -u jenkins kubectl get nodes
```

If this fails, Jenkins cannot deploy to Kubernetes.

### 5. Validate deployment after every pipeline run

Use:

```bash
kubectl rollout status deployment/mavenwebappdeployment -n dev
kubectl get pods -n dev -o wide
kubectl get svc -n dev
```

These commands confirm whether the new application version is running.

---

## Final Application URL

```text
http://192.168.0.241/maven-web-app/#
```

---

## Summary

This project builds a complete CI/CD process:

```text
Git Repository
  → Jenkins
  → Maven Build
  → Docker Image
  → Nexus Registry
  → Kubernetes Deployment
  → LoadBalancer Access
```

The Jenkins pipeline makes the deployment repeatable, versioned and easier to troubleshoot.
