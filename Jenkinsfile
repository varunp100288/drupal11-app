pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = 'drupalapp'
    }

    stages {
        stage('Force Clean Workspace') {
            steps {
                sh '''
                    sudo rm -rf *
                '''
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/varunp100288/drupal11-app.git'
            }
        }

        stage('Create .env') {
            steps {
                sh '''
                    cat > .env <<EOF
DB_HOST=host.docker.internal
DB_PORT=32772
DB_NAME=db
DB_USER=db
DB_PASSWORD=db
EOF
                '''
            }
        }

        stage('Start Containers') {
            steps {
                sh '''
                    docker compose down --remove-orphans || true
                    docker compose up -d --build
                '''
            }
        }

        stage('Composer Install') {
            steps {
                sh '''
                    docker compose exec -T drupal composer install
                '''
            }
        }

        stage('Fix Permissions (CRITICAL)') {
            steps {
                sh '''
                    sudo chown -R jenkins:jenkins "$WORKSPACE"
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS'
        }
        failure {
            echo 'FAILED'
        }
    }
}