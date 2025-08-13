/*
 * Author       : Sanjay KS
 * Email        : sanjaykshebbar@gmail.com
 * CreatedDate  : 2025-08-10
 * Version      : 1.3.0
 * Description  : Jenkins pipeline for building and pushing multi-arch Docker images (amd64+arm64) and deploying to Raspberry Pi.
 * 
 * ---------------- CHANGE LOG ----------------
 * Date         : 2025-08-10
 * ChangesMade  : Switched to docker buildx multi-arch build; added versioned tags; hardened deploy with health check and logs on failure.
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
                    echo "Computed IMAGE_TAG=${env.IMAGE_TAG}"
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
                    // Ensure buildx is ready (idempotent)
                    sh '''
                      docker buildx create --name littlegeekybuilder --use || docker buildx use littlegeekybuilder
                      docker buildx inspect --bootstrap
                    '''

                    // Build & push amd64 + arm64 manifests under both tags
                    sh """
                      docker buildx build \
                        --platform linux/amd64,linux/arm64 \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        --push \
                        .
                    """
                }
            }
        }

        stage('Deploy to Linux server') {
            steps {
                // Using direct -i key avoids ssh-agent key format issues
                withCredentials([sshUserPrivateKey(credentialsId: 'jenkins-ssh-credentials-id', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                    sh """
                      ssh -i "$SSH_KEY" -o IdentitiesOnly=yes -o StrictHostKeyChecking=no ${SSH_USER}@192.168.68.104 /bin/bash -lc '
                        set -euo pipefail

                        # Pull the correct platform variant automatically from the multi-arch tag
                        docker pull ${IMAGE_NAME}:${IMAGE_TAG}

                        # Restart container with the new image
                        docker stop little-geeky || true
                        docker rm little-geeky || true

                        # Optional: force platform only during transition; safe to omit once images are multi-arch
                        docker run -d --name little-geeky -p 8081:80 ${IMAGE_NAME}:${IMAGE_TAG}

                        # Health check: ensure the container stays up; dump logs on failure
                        sleep 3
                        if [ "\$(docker inspect -f {{.State.Running}} little-geeky || echo false)" != "true" ]; then
                          echo "Container exited — dumping logs:" >&2
                          docker logs little-geeky || true
                          exit 1
                        fi

                        echo "Deployed and running on http://$(hostname -I | awk "{print \\$1}"):8081"
                      '
                    """
                }
            }
        }
    }
}
