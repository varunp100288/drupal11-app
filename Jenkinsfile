pipeline {
    agent any

    stages {
        stage('Check Docker Access') {
            steps {
                sh 'docker ps'
            }
        }
    }
}