pipeline {
    agent any

    options {
        skipDefaultCheckout(true)
    }

    tools {
        nodejs 'node26'
    }

    environment {
        DOCKER_IMAGE = 'itsyogessh/wokkai-devops-project'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh '''
                    trivy fs --severity HIGH,CRITICAL .
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t $DOCKER_IMAGE:$BUILD_NUMBER .
                '''
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh '''
                    trivy image --severity HIGH,CRITICAL $DOCKER_IMAGE:$BUILD_NUMBER
                '''
            }
        }

        stage('DockerHub Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                            -u "$DOCKER_USERNAME" \
                            --password-stdin

                        docker push $DOCKER_IMAGE:$BUILD_NUMBER

                        docker tag $DOCKER_IMAGE:$BUILD_NUMBER \
                            $DOCKER_IMAGE:latest

                        docker push $DOCKER_IMAGE:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy React App') {
            steps {
                sh '''
                    docker rm -f wokkai-react 2>/dev/null || true

                    docker run -d \
                        --name wokkai-react \
                        --restart unless-stopped \
                        -p 3000:80 \
                        $DOCKER_IMAGE:$BUILD_NUMBER
                '''
            }
        }

        stage('Archive Build Artifacts') {
            steps {
                archiveArtifacts artifacts: 'dist/**', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo '🚀 WOKKAI DEPLOYMENT SUCCESSFUL'
            echo '🌐 Application running on port 3000'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo '❌ PIPELINE FAILED'
            echo 'Check the failed stage logs.'
            echo '======================================'
        }
    }
}