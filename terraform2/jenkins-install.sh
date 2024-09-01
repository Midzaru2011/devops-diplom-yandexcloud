 #!/bin/bash
    # Installing Java
    sudo apt update -y
    sudo apt install fontconfig openjdk-17-jre -y
    java --version
    # Install docker
    sudo apt install docker.io -y
    sudo docker version
    # Installing Jenkins
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
    :'curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
        /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
        https://pkg.jenkins.io/debian binary/ | sudo tee \
        /etc/apt/sources.list.d/jenkins.list > /dev/null'
    sudo apt-get update -y
    sudo apt-get install jenkins -y
    sudo usermod -a -G docker jenkins
    echo "Print password"
    cat /var/lib/jenkins/secrets/initialAdminPassword