pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'sanjaykshebbar'
        DOCKERHUB_PASS = credentials('dockerhub-credentials-id') // from Jenkins credentials
        IMAGE_NAME = 'sanjaykshebbar/little-geeky'
        IMAGE_TAG = 'latest'
        REMOTE_HOST = 'sanjay.ks@192.168.68.101'
    }

    stages {
        stage('Pull from GitHub') {
            steps {
                git branch: 'main', url: 'git@github.com:sanjaykshebbar/little-geeky.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    sh "echo ${DOCKERHUB_PASS} | docker login -u ${DOCKERHUB_USER} --password-stdin"
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Remote Server') {
            steps {
                script {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${REMOTE_HOST} "
                        docker pull ${IMAGE_NAME}:${IMAGE_TAG} &&
                        docker stop little-geeky || true &&
                        docker rm little-geeky || true &&
                        docker run -d --name little-geeky -p 8081:80 ${IMAGE_NAME}:${IMAGE_TAG}
                    "
                    """
                }
            }
        }
    }
}
