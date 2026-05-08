pipeline {
    agent any

    tools {
        maven "Maven3.9.15"
    }

    environment {
        REGISTRY_URL = 'nexus.openhelp.net'
        REPO         = 'docker-private/sreejith'
        IMAGE        = 'mavenwebapp'
        TAG          = "${BUILD_NUMBER}"
        NEXUS_CREDS = credentials('nexus-cred')
    }

    stages {

        stage('Clone Repo') {
            steps {
                git branch: 'main',
                    credentialsId: 'sreejithgit',
                    url: 'https://gitlab.openhelp.net/sreejith/first_devops.git'
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
