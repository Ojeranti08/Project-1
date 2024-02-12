pipeline {
    agent {
        label "Node1"
    } 
    
    stages {
        stage('SCM Checkout') {
            steps {
                script {
                    git tool: 'Default', credentialsId: 'git-creds', url: 'https://github.com/Ojeranti08/Project-1.git', branch: 'main'
                }
            }
        }

        stage('Build and Test'){
            agent {
                label "Node1"
            }
            steps {
                echo "Build and Test"
                sh "mvn test"
                stash(name:"javaapp", includes:"target/*.war")
            }
        }

        stage('Deploying to Tomcat-server') {
            agent {
                label "Node2"
            }
            steps {
                echo "Deploying the application"
                // Define deployment steps here
                unstash "javaapp" 
                sh "sudo /home/centos/apache-tomcat-7.0.94/bin/startup.sh"
                sh "sudo rm -rf ~/apache*/webapps/*.war"
                sh "sudo mkdir -p /home/centos/apache-tomcat-7.0.94/webapps/"
                sh "sudo mv target/*.war /home/centos/apache-tomcat-7.0.94/webapps/"
                sh "sudo systemctl daemon-reload"
                sh "sudo /home/centos/apache-tomcat-7.0.94/bin/startup.sh"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    sh "sudo docker build -t ojeranti08/javaapp:1.3.5 ."
                }
            }
        }

        stage('Login and Push Image to DockerHub') {
            steps {
                script {
                    withCredentials([string(credentialsId:'docker-pwd', variable: 'dockerHubPwd')]) {
                        sh "sudo docker login -u ojeranti08 -p ${dockerHubPwd}"
                        sh "sudo docker push ojeranti08/javaapp:1.3.5"
                    }
                }
            }
        }

        stage ('Run Container on Tomcat-server') {
            steps {
                script {
                    def containerName = "javaApp-${env.BUILD_ID}-${new Date().format("yyyyMMdd-HHmmss")}"
                    // Stop and remove existing container if it exists
                    sh "sudo docker stop ${containerName} || true"
                    sh "sudo docker container rm -f ${containerName} || true" 
                    // Build and run the new container with the unique name
                    def dockerRun = "docker container run -dt --name ${containerName} -p 8080:8080 ojeranti08/javaapp:1.3.5"
                    sshagent(['javaapp']){
                        sh "ssh -o StrictHostChecking=no centos@10.0.1.14 ${dockerRun}"
                    }
                }
            }
        }

        stage('Clean Up'){
            agent any
            steps {
                sh "sudo docker logout"
            }
        }
    }

    post {
        success {
            mail to: "Kemiola190@gmail.com",
                 subject: "Build and Deployment Successful - ${currentBuild.fullDisplayName}",
                 body: "Congratulations! The build and deployment were successful.\n\nCheck console output at ${BUILD_URL}"
        } 

        failure {
            mail to: "Kemiola190@gmail.com",
                 subject: "Build and Deployment Failed - ${currentBuild.fullDisplayName}",
                 body: "Oops! The build and deployment failed.\n\nCheck console output at ${BUILD_URL}" 
        }
    } 
}
