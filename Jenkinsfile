pipeline {
    agent any

    environment {
        DB_NAME = 'db'
        DB_HOST = 'db'
        DB_PORT = '3306'
    }

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

        stage('Create Env File') {
            steps {
                withCredentials([
                    string(credentialsId: 'dbuser', variable: 'DB_USER'),
                    string(credentialsId: 'dbpassword', variable: 'DB_PASSWORD'),
                    string(credentialsId: 'dbrootuser', variable: 'DB_ROOT_PASSWORD')
                ]) {
                    sh '''
                    cat > .env <<EOF
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
EOF
                    echo ".env file created"
                    '''
                }
            }
        }

        stage('Build & Run Containers') {
            steps {
                sh '''
                docker compose -f docker-compose.devops.yml down || true
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