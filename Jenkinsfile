pipeline {
    agent any
    tools {
        maven "maven"
    }
    environment {
        ECR_REPO = "ecr_repo_url"
        AWS_REGION = "region"
        SONAR_URL = "http://ip:31000"
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main',
                credentialsId: 'Git_Credentials',
                url: 'https://github.com/user_name/petclinic-gitops-app.git'
            }
        }
        stage('Build with Maven') {
            steps {
                withEnv(['JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64']) {
                    sh "./mvnw package -DskipTests"
                }
            }
        }
        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonar') {
                    withCredentials([string(credentialsId: 'Sonar_Token', variable: 'SONAR_TOKEN')]) {
                        sh "./mvnw sonar:sonar -Dsonar.host.url=${SONAR_URL} -Dsonar.login=${SONAR_TOKEN}"
                    }
                }
            }
        }
        stage('Docker Build') {
            steps {
                sh "docker build -t ${ECR_REPO}:${BUILD_NUMBER} ."
            }
        }
        stage('Trivy Scan') {
            steps {
                sh """
            mkdir -p /var/lib/jenkins/trivy-tmp
            mkdir -p /var/lib/jenkins/trivy-cache
            export TMPDIR=/var/lib/jenkins/trivy-tmp
            export TRIVY_TEMP_DIR=/var/lib/jenkins/trivy-tmp
            trivy image \
              --exit-code 0 \
              --severity CRITICAL \
              --no-progress \
              --cache-dir /var/lib/jenkins/trivy-cache \
              ${ECR_REPO}:${BUILD_NUMBER}
        """
            }
        }
        stage('Push to ECR') {
            steps {
                sh "sh ecr-push.sh"
            }
        }
        stage('Update Config Repo') {
            steps {
                withCredentials([string(credentialsId: 'Git_Token', variable: 'GIT_TOKEN')]) {
                    sh "sh update-config-repo.sh"
                }
            }
        }
    }
}
