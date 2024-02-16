# EC2 Instance Resources
# VM Based Java Project
resource "aws_instance" "JavaApp" {
  ami                    = "ami-002070d43b0a4f171"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.javaapp-public-subnet.id
  key_name               = "Oje"
  vpc_security_group_ids = [aws_security_group.javaapp-sg.id]
  user_data              = <<-EOF
   #!/bin/bash
   sudo yum update -y
   sudo yum -y install git wget maven* java-11*
   wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
   tar -zxvf apache-maven-3.9.5-bin.tar.gz
   sudo mv apache-maven-3.9.5 /opt/
   echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
   echo "export M2_HOME=/usr/share/maven" >> ~/.bashrc
   echo "export MAVEN_HOME=/usr/share/maven" >> ~/.bashrc
   echo "export PATH=\\\$${M2_HOME}/bin:\\\$${PATH}" >> ~/.bashrc
   sudo git clone https://github.com/Ojeranti08/Project-1.git /home/centos/Project-1
   cd /home/centos/Project-1
   mvn package
   ls target
   EOF
  private_ip             = "10.0.1.13"

  tags = {
    Name = " Node1"
  }
}
resource "aws_instance" "tomcat" {
  ami                    = "ami-002070d43b0a4f171"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.javaapp-public-subnet.id
  key_name               = "Oje"
  vpc_security_group_ids = [aws_security_group.javaapp-sg.id]
  user_data              = <<-EOF
   #!/bin/bash
   sudo yum update -y
   sudo yum -y install wget unzip java-11-openjdk
   echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
   wget https://archive.apache.org/dist/tomcat/tomcat-7/v7.0.94/bin/apache-tomcat-7.0.94.tar.gz -P /home/centos
   tar xvf /home/centos/apache-tomcat-7.0.94.tar.gz -C /home/centos
   sudo /home/centos/apache-tomcat-7.0.94/bin/startup.sh 
   sudo netstat -ntpl | grep 8080
   EOF
  private_ip             = "10.0.1.14"

  tags = {
    Name = " Node2"
  }
}

# Containerised Based Java Project
resource "aws_instance" "Jenkins1" {
  ami                    = "ami-002070d43b0a4f171"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.javaapp-public-subnet.id
  key_name               = "Oje"
  vpc_security_group_ids = [aws_security_group.javaapp-sg.id]
  user_data              = <<-EOF
  #!/bin/bash
   sudo yum update -y
   sudo yum install -y wget git unzip java-11* 
   curl -fsSL https://get.docker.com -o install-docker.sh
   sudo sh install-docker.sh
   sudo systemctl start docker
   sudo systemctl enable docker
   sudo wget -O /etc/yum.repos.d/jenkins.repo \
       https://pkg.jenkins.io/redhat-stable/jenkins.repo
   sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
   sudo yum install -y jenkins
   java -version
   sudo systemctl start jenkins
   echo "Enabling Jenkins to start on boot:"
   sudo systemctl enable jenkins
   echo "Jenkins service status:"
   sudo systemctl status jenkins
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   # echo "Jenkins initial admin password: $jenkins_password"
   echo "Jenkins is now installed and running. Access it at http://your-server-ip:8080"
  EOF
  private_ip             = "10.0.1.16"

  tags = {
    Name = " Jenkins1"
  }
}