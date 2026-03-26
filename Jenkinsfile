pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = 'drupalapp'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/varunp100288/drupal11-app.git'
            }
        }

        stage('Show Files') {
            steps {
                sh 'pwd'
                sh 'ls -la'
            }
        }

        stage('Build Containers') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Stop Old Containers') {
            steps {
                sh 'docker compose down || true'
            }
        }

        stage('Start Containers') {
            steps {
                sh 'docker compose up -d'
            }
        }

        stage('Check Running Containers') {
            steps {
                sh 'docker compose ps'
            }
        }

        stage('App Logs') {
            steps {
                sh 'docker compose logs --tail=50 || true'
            }
        }
    }

    post {
        success {
            echo 'Application build and deployment successful.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}