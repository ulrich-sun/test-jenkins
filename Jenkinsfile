pipeline {
    environment {
        // IMAGE_NAME = credentials('image-name')
        // IMAGE_TAG = credentials('image-tag')
        // HOST_PORT = credentials('host-port')
        // CONTAINER_PORT = credentials('container-port')

        DOCKERHUB_PASSWORD = credentials('dockerhub-password')
        DOCKERHUB_USERNAME = credentials("dockerhub-username")
    }
    parameters {
        string(name: 'IMAGE_NAME', defaultValue: 'myapp', description: 'Docker image name')
        string(name: 'IMAGE_TAG', defaultValue: 'latest', description: 'Docker image tag')
        string(name: 'HOST_PORT', defaultValue: '8081', description: 'Host port to map')
        string(name: 'CONTAINER_PORT', defaultValue: '80', description: 'Container port to expose')
        string(name: 'SERVER_IP', defaultValue: '127.0.0.1', description: 'Deployment server IP address')
        string(name: 'SERVER_USER', defaultValue: 'user', description: 'Deployment server username')
    }
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    sh '''
                        docker build --no-cache -t $IMAGE_NAME:$IMAGE_TAG .
                    '''
                }
            }
        }
        stage('Test') {
            steps {
                script {
                     sh '''
                        docker run --rm -dp $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                        curl -I http://localhost:$HOST_PORT| grep -i "200 OK"
                        sleep 2
                        docker stop $IMAGE_NAME
                    '''
                }
            }
        }
        stage('Release') {
            steps {
                script {
                    sh '''
                        echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_USERNAME --password-stdin
                        docker tag $IMAGE_NAME:$IMAGE_TAG $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                        docker push $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                '''
                }
            }
        }
        stage('Deploy') {
            // environment {
            //     SERVER_IP = credentials('server-ip')
            //     SERVER_USER = credentials('server-user')
            // }
            steps {
                script {
                    timeout(time: 1, unit: 'MINUTES'){
                        input message: 'Approve Deployment?', ok: 'Deploy'
                    }
                    sshagent (['server-ssh-credentials']) {
                        sh '''
                            ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP << EOF
                            docker pull $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                            docker stop $IMAGE_NAME || true
                            docker rm $IMAGE_NAME || true
                            docker run -d -p $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG
                            EOF
                        '''
                    }
                }
            }
        }
    }
}