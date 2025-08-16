pipeline {
    agent none

    environment {
        SONAR_SERVER = 'SonarServer' 
        NEXUS_IP = '13.127.150.83'       
        NEXUS_URL = "http://${NEXUS_IP}:31020/repository/bankartifact-repo/webapp-1.jar"
        DOCKER_IMAGE = "${NEXUS_IP}:31503/docker-repo-bank/webapp:${BUILD_NUMBER}"
    }

    stages{
		stage(checkout){
            agent { label 'compile' }
            steps {
                git branch: 'main', url: 'https://github.com/prajwal-d14/webapp.git'
            }
        }

        stage('Build') {
            agent { label 'compile' }
            steps {
                sh '''
                    mvn clean install
                    sleep 5
                    cp target/webapp-0.1.jar ~/builds/
                '''
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'compile' }
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh '''
                        /opt/sonar-scanner/bin/sonar-scanner \
                        -Dsonar.projectKey=web-app \
                        -Dsonar.projectName="web app" \
                        -Dsonar.sources=src \
                        -Dsonar.java.binaries=target/classes \
						-Dsonar.projectVersion=${BUILD_NUMBER} \
						-Dsonar.branch.name=${BRANCH_NAME}
                    '''
                }
            }
        }

        stage('Upload Artifact to Nexus') {
            agent { label 'compile' }
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-cred', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                        curl -u $USERNAME:$PASSWORD \
                          --upload-file ~/builds/ webapp-0.1.jar \
                          $NEXUS_URL
                    """
                }
            }
        }

        stage('Docker Image Creation') {
            agent { label 'image' }
            steps {
                    sh """
                         docker build -t webapp:${BUILD_NUMBER} .
                    """
				}	
            } 

        stage('Docker Image Push to Nexus') {
            agent { label 'image' }
            steps {
                sh """
                    docker tag webapp:${BUILD_NUMBER} $DOCKER_IMAGE
                    docker push $DOCKER_IMAGE
                """
            }
        }

        stage('argocd stage') {
            agent { label 'image' }
            steps {
                sh """
                    cd ~/webapp-deploy
                    sed -i "s/webapp:1/webapp:${BUILD_NUMBER}/g" deployment.yml
                    git add deployment.yml
                    git commit -m "Updated image to build ${BUILD_NUMBER}"
                    git push origin main
                """
            }
        } 
    }
}
