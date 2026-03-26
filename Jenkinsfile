pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Code checkout stage'
            }
        }

        stage('Build') {
            steps {
                echo 'Build stage'
            }
        }

        stage('Test') {
            steps {
                echo 'Test stage'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}