pipeline {
  environment {
    registryCredential = 'docker-botirkhuja-password'

    dockerBuildImage = ''
    IMAGE_NAME = 'botirkhuja/jenkins-docker-agent'
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
    stage('Build Docker Image') {
      steps {
        script {
          // Build Docker image from Dockerfile
          // sh "docker build -f Dockerfile -t ${IMAGE_NAME} ."
          dockerBuildImage = docker.build(IMAGE_NAME)
        }
      }
    }

    stage('Push Image to Docker Registry') {
      steps {
        script {
          docker.withRegistry('', registryCredential) {
            dockerBuildImage.push("$BUILD_NUMBER")
            dockerBuildImage.push('latest')
          }
        }
      }
    }

    stage('Delete pushed image') {
      steps {
        script {
          sh "docker rmi ${IMAGE_NAME}:${BUILD_NUMBER}"
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
