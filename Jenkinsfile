pipeline {
    agent Node1

    environment {
        DOCKERHUB_CREDENTIALS = credentials('ojeranti08-dockerhub')
        DOCKER_IMAGE_NAME     = 'ojeranti08/javaapp'
        CONTAINER_NAME        = 'javaapp'
        TOMCAT_SERVER_LABEL   = 'Node2'
    }

    stages {
        stage('SCM Checkout') {
            agent Node1
            steps {
                git 'https://github.com/Ojeranti08/Project-1.git'
            }
        }
    }

    stage('Build and Test'){
        agent{
            label "JavaApp"
        }
        steps{
            echo "Build and Test"
            sh "mvn clean test"
            stash(name:"javaapp", includes:"target/*.war")
        }
    }

    stage('Build Docker Image'){
        steps {
            script {
                // Remove Unused Docker image' to avoid conflicts
                sh "docker rmi $DOCKER_IMAGE_NAME:$BUILD_NUMBER"
                sh "docker rmi $DOCKER_IMAGE_NAME:latest"
                // Build Docker image
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}."
            }
        }
    }

    stage('Login to DockerHub'){
        steps{
            withCredentials([usernamePassword(credentialsId: 'ojeranti08-dockerhub', passwordVariable: 'DOCKERHUB_CREDENTIAL_PSW', usernameVariable: 'DOCKERHUB_CREDENTIALS_USR')]){
                sh "echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin"
            }
        }
    }

    stage('Push Image to DockerHub'){
        steps{
            sh "docker push ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
        }
    }

    stage('Deploying to Tomcat') {
       agent {
           label "${TOMCAT_SERVER_LABEL}"
       }
       steps {
          echo "Deploying Docker image to Tomcat"
          script {
              // Run the Docker image to Tomcat
              sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${DOCKER_IMAGE_NAME}:${BUILD_NUMBER}"
           }
        }
    }

    stage('Clean Up'){
        steps{
            sh 'docker logout'
        }
    }

    post {
        success {
            script {
                mail to: "Kemiola190@gmail.com",
                     subject: "Build and Deployment Successful - ${currentBuild.fullDisplayName}",
                     body: "Congratulations! The build and deployment were successful.\n\nCheck console output at ${BUILD_URL}"
            }
        } 

        failure {
            script {
                mail to: "Kemiola190@gmail.com",
                     subject: "Build and Deployment Failed - ${currentBuild.fullDisplayName}",
                     body: "Oops! The build and deployment failed.\n\nCheck console output at ${BUILD_URL}" 
            }
        }
    } 
}     