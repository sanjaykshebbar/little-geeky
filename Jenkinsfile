/*
 * Author       : Sanjay KS
 * Email        : sanjaykshebbar@gmail.com
 * CreatedDate  : 2025-08-10
 * Version      : 1.1.0
 * Description  : Jenkinsfile to build, tag and push Docker images with versioned tags per commit, plus deploy.
 * 
 * ---------------- CHANGE LOG ----------------
 * Date         : 2025-08-10
 * ChangesMade  : Added automatic Docker image versioning using GIT_COMMIT short SHA and BUILD_NUMBER; pushed multiple tags (latest and versioned).
 */

pipeline {
    agent any

    environment {
        IMAGE_NAME   = 'sanjaykshebbar/little-geeky'
        // Will be set dynamically in "Init Vars" stage
        IMAGE_TAG    = '' 
        REMOTE_HOST  = 'sanjay.ks@192.168.68.101'
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
                    // Jenkins provides GIT_COMMIT; derive a short SHA and a semantic-ish build tag
                    def shortSha = GIT_COMMIT?.take(7) ?: sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    // Example combined tag: 1.0.${BUILD_NUMBER}-${shortSha}
                    env.IMAGE_TAG = "${BUILD_NUMBER}-${shortSha}"  // e.g., 42-1a2b3c4
                    echo "Computed IMAGE_TAG=${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build with both a versioned tag and latest
                    sh """
                      docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
                    """
                }
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    script {
                        sh 'echo "Running as user: $(whoami)"'
                        sh 'docker --version'
                        sh 'docker info | grep "Username" || echo "Docker not logged in yet"'

                        sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'

                        // Push both tags
                        sh """
                          docker push ${IMAGE_NAME}:${IMAGE_TAG}
                          docker push ${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Build & Push (Multi-arch)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials-id', usernameVariable: 'DOCKERHUB_USER', passwordVariable: 'DOCKERHUB_PASS')]) {
                    script {
                        sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'

                            // Ensure buildx is available and selected
                            sh '''
                            docker buildx create --use --name littlegeekybuilder || docker buildx use littlegeekybuilder
                            docker buildx inspect --bootstrap
                            '''

                            // Build and push multi-arch image with both tags
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
        }
    }
}
