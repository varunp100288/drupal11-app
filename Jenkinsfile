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
stage('Composer Validate') {
    steps {
        sh '''
            docker run --rm \
              -v "$PWD":/app \
              -w /app \
              composer:2 \
              composer validate --no-check-publish
        '''
    }
}

stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('Sonar') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
}

stage('OWASP Dependency Check') {
    steps {
        dependencyCheck additionalArguments: '--scan . --format XML --format HTML', odcInstallation: 'OWASP-DC'
    }
    post {
        always {
            dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        }
    }
}
// stage('PHPCS') {
//     steps {
//         sh '''
//             docker run --rm \
//               -v "$PWD":/app \
//               -w /app \
//               composer:2 sh -c "
//                 git config --global --add safe.directory /app &&
//                 vendor/bin/phpcs --version
//               "
//         '''
//     }
// }

        // stage('Composer Audit') {
        //     steps {
        //         sh '''
        //             docker run --rm \
        //             -v "$PWD":/app \
        //             -w /app \
        //             composer:2 \
        //             composer audit || true
        //         '''
        //     }
        // }
        stage('Trivy Scan') {
            steps {
                sh '''
                trivy --version
                trivy image --severity HIGH,CRITICAL --scanners vuln --exit-code 0 drupal-apps-devops:latest
                '''
            }
        }
stage('Build Docker Image') {
    steps {
        sh '''
            docker build -t varunp100288/drupal11-app:latest \
                         -t varunp100288/drupal11-app:${BUILD_NUMBER} .
        '''
    }
}

stage('Push Docker Image to Docker Hub') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'dockerhub-creds',
            usernameVariable: 'DOCKERHUB_USERNAME',
            passwordVariable: 'DOCKERHUB_TOKEN'
        )]) {
            sh '''
                echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                docker push varunp100288/drupal11-app:latest
                docker push varunp100288/drupal11-app:${BUILD_NUMBER}
                docker logout
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
        // stage('PHPCS') {
        //     steps {
        //         sh 'docker compose -f docker-compose.devops.yml exec -T drupal vendor/bin/phpcs --standard=Drupal web/modules/custom'
        //     }
        // }
        stage('PHPCS') {
            steps {
                sh 'docker compose -f docker-compose.devops.yml exec -T drupal vendor/bin/phpcs --standard=Drupal web/modules || true'
            }
        }
        stage('Drupal Config Import') {
            steps {
                sh 'docker compose -f docker-compose.devops.yml exec -T drupal vendor/bin/drush updb -y'
                sh 'docker compose -f docker-compose.devops.yml exec -T drupal vendor/bin/drush cim -y'
                sh 'docker compose -f docker-compose.devops.yml exec -T drupal vendor/bin/drush cr'
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