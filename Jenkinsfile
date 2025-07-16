pipeline {
  environment {
    registryCredential = 'docker-botirkhuja-password'

    dockerBuildImage = ''
    dockerFileName = ''
    IMAGE_NAME = 'botirkhuja/jenkins-docker-agent'
    JENKINS_AGENT_UBUNTU = credentials('jenkins-agent-ubuntu-password')
  }

  parameters {
    choice(name: 'DOCKERFILE', choices: ['ANSIBLE', 'NODE'], description: '')
  }
  
  agent {
    node {
      label 'jenkins_vm'
    }
  }

  stages {
    stage('List items') {
      steps {
        sh 'ls'
      }
    }

    stage('update dockerfile') {
      steps {
        script {
          if (params.DOCKERFILE == 'ANSIBLE') {
            dockerFileName = 'Dockerfile.ansible'
          } else if (params.DOCKERFILE == 'NODE') {
            dockerFileName = 'Dockerfile.node'
          }
          sh "cp ${dockerFileName} Dockerfile"
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Build Docker image from Dockerfile
          // sh "docker build -f Dockerfile -t ${IMAGE_NAME} ."
          dockerBuildImage = docker.build(
            IMAGE_NAME,
            "--build-arg JENKINS_PASSWORD=${JENKINS_AGENT_UBUNTU_PSW} ."
          )
        }
      }
    }

    stage('Push Image to Docker Registry') {
      steps {
        script {
          docker.withRegistry('', registryCredential) {
            dockerBuildImage.push("$BUILD_NUMBER-$DOCKERFILE")
            dockerBuildImage.push('latest')
          }
        }
      }
    }

    stage('Delete pushed image') {
      steps {
        script {
          sh "docker rmi ${IMAGE_NAME}:${BUILD_NUMBER}-$DOCKERFILE"
          sh "docker rmi ${IMAGE_NAME}:latest"
        }
      }
    }
  }
  post {
    success {
      echo 'Build completed successfully.'
    }
    failure {
      echo 'Build failed.'
    }
    always {
      cleanWs()
    }
  }
}
