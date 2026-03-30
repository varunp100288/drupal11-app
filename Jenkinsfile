pipeline {
    agent any

    environment {
        DB_NAME = 'db'
        DB_HOST = 'db'
        DB_PORT = '3306'
        APP_URL = 'http://localhost:8081'
    }

    stages {
        stage('Validate Docker Access') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Validate Workspace Files') {
            steps {
                sh '''
                    pwd
                    ls -la
                    test -f Dockerfile
                    test -f docker-compose.devops.yml
                    echo "Required files are present"
                '''
            }
        }

        stage('Generate Environment File') {
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
echo ".env file created successfully"
'''
                }
            }
        }

        stage('Deploy Application Containers') {
            steps {
                sh '''
                    docker compose -f docker-compose.devops.yml down || true
                    docker compose -f docker-compose.devops.yml up -d --build
                '''
            }
        }

        stage('Verify Running Containers') {
            steps {
                sh 'docker ps'
            }
        }

        stage('Run Application Health Check') {
            steps {
                sh '''
                    echo "Waiting for application..."
                    sleep 20

                    STATUS=$(curl -o /dev/null -s -w "%{http_code}" ${APP_URL} || true)

                    if [ "$STATUS" = "200" ] || [ "$STATUS" = "302" ]; then
                        echo "Application is healthy. Status: $STATUS"
                    else
                        echo "Health check failed. Status: $STATUS"
                        exit 1
                    fi
                '''
            }
        }
    }
}