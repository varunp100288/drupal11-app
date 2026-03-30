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
    }
}