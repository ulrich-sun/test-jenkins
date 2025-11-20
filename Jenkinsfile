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
        string(name: 'SERVER_IP', defaultValue: '20.106.232.57', description: 'Deployment server IP address')
        string(name: 'SERVER_USER', defaultValue: 'azureuser', description: 'Deployment server username')
        string(name: 'DOCKER_IP', defaultValue: '172.17.0.1', description: 'Docker host IP address')
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
                        docker rm -f  $IMAGE_NAME || true
                        docker run --rm -dp $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $IMAGE_NAME:$IMAGE_TAG
                        sleep 5
                        curl -I http://$DOCKER_IP:$HOST_PORT| grep -i "200 OK"
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
                            ssh -o StrictHostKeyChecking=no $SERVER_USER@$SERVER_IP "
                            docker pull $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG ;
                            docker rm -f $IMAGE_NAME || echo "no existing container to remove";
                            docker run -d -p $HOST_PORT:$CONTAINER_PORT --name $IMAGE_NAME $DOCKERHUB_USERNAME/$IMAGE_NAME:$IMAGE_TAG;
                            "
                        '''
                    }
                }
            }
        }
    }
}