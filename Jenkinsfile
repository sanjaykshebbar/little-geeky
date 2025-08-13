/*
 * Author       : Sanjay KS
 * Email        : sanjaykshebbar@gmail.com
 * CreatedDate  : 2025-08-10
 * Version      : 1.4.0
 * Description  : Jenkins pipeline for building and pushing multi-arch Docker images (amd64+arm64) and deploying to Raspberry Pi/Linux.
 * 
 * ---------------- CHANGE LOG ----------------
 * Date         : 2025-08-13
 * ChangesMade  : Fixed Groovy interpolation error with ${IMAGE_NAME}:${IMAGE_TAG} by using single-quoted sh strings & concatenation in Deploy stage.
 * Date         : 2025-08-10
 * ChangesMade  : Added buildx multi-arch build, versioned tags, and health check in deployment.
 */

pipeline {
    agent any

    environment {
        IMAGE_NAME  = 'sanjaykshebbar/little-geeky'
        IMAGE_TAG   = '' // computed in Init Vars
        REMOTE_HOST = 'sanjay.ks@192.168.68.101'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'git@github.com:sanjaykshebbar/little-geeky.git'
            }
        }

        stage('Init Vars') {
            steps {
                script {
                    def shortSha = GIT_COMMIT?.take(7) ?: sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    env.IMAGE_TAG = "${BUILD_NUMBER}-${shortSha}"  // e.g., 42-1a2b3c4
                    echo "Computed IMAGE_TAG = ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
                }
            }
        }

        stage('Build & Push (multi-arch)') {
            steps {
                script {
                    sh '''
                        docker buildx create --name littlegeekybuilder --use || docker buildx use littlegeekybuilder
                        docker buildx inspect --bootstrap
                    '''
                    sh (
                        'docker buildx build ' +
                        '--platform linux/amd64,linux/arm64 ' +
                        '-t ' + IMAGE_NAME + ':' + IMAGE_TAG + ' ' +
                        '-t ' + IMAGE_NAME + ':latest ' +
                        '--push .'
                    )
                }
            }
        }

        stage('Deploy to Linux server') {
    steps {
        withCredentials([sshUserPrivateKey(
            credentialsId: 'jenkins-ssh-credentials-id',
            keyFileVariable: 'SSH_KEY',
            usernameVariable: 'SSH_USER'
        )]) {
            sh(
                'ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no ' +
                SSH_USER + '@192.168.68.104 /bin/bash -lc ' +
                "'set -euo pipefail\n" +

                "# Pull the correct multi-arch image\n" +
                "docker pull ${IMAGE_NAME}:${IMAGE_TAG}\n" +

                "# Restart container with new image\n" +
                "docker stop little-geeky || true\n" +
                "docker rm little-geeky || true\n" +
                "docker run -d --name little-geeky -p 8081:80 ${IMAGE_NAME}:${IMAGE_TAG}\n" +

                "# Health check\n" +
                "sleep 3\n" +
                "if [ \"\$(docker inspect -f '{{.State.Running}}' little-geeky || echo false)\" != \"true\" ]; then\n" +
                "  echo 'Container exited — dumping logs:' >&2\n" +
                "  docker logs little-geeky || true\n" +
                "  exit 1\n" +
                "fi\n" +

                "# Show deployment URL\n" +
                "IP=\$(hostname -I | awk '{print \$1}')\n" +
                "echo \"Deployed and running on http://\$IP:8081\"\n" +
                "'"
            )
        }
    }
}

    }
}
