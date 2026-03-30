pipeline {
    agent any

    stages {
        stage('Check Docker Access') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Check Workspace Files') {
            steps {
                sh '''
                pwd
                ls -la
                test -f Dockerfile
                test -f docker-compose.devops.yml
                echo "Required files exist"
                '''
            }
        }

        stage('Build & Run Containers') {
            steps {
                sh '''
                echo "Stopping old containers if any..."
                docker compose -f docker-compose.devops.yml down || true

                echo "Building and starting containers..."
                docker compose -f docker-compose.devops.yml up -d --build
                '''
            }
        }

        stage('Verify Containers') {
            steps {
                sh 'docker ps'
            }
        }
    }
}