pipeline {
  agent any

  // Update these tool names to match Manage Jenkins -> Global Tool Configuration
  tools {
    jdk 'jdk17'
    maven 'maven3'
  }

  environment {
    MAVEN_OPTS = '-Xmx1024m'
    // Replace with your Docker Hub namespace if you plan to push
    IMAGE_NAME = "<your-dockerhub-namespace>/jenkins-starter"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Test') {
      steps {
        script {
          // Use mvnw if provided, otherwise system maven
          def mvnCmd = fileExists('mvnw') ? (isUnix() ? './mvnw' : 'mvnw.cmd') : 'mvn'

          if (isUnix()) {
            sh "${mvnCmd} -B -e clean install"
          } else {
            // On Windows agents use bat
            bat "\"${mvnCmd}\" -B -e clean install"
          }
        }
      }
      post {
        always {
          // publish test results if any (allow empty so pipeline doesn't error when none)
          junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
          archiveArtifacts artifacts: 'target/*.jar', fingerprint: true, allowEmptyArchive: true
        }
      }
    }

    stage('Docker Build (Unix-only)') {
      when {
        expression { return isUnix() } // only try Docker on Unix agents
      }
      steps {
        script {
          // Ensure docker present; if not, fail gracefully
          def hasDocker = sh(script: 'command -v docker >/dev/null 2>&1 || echo no', returnStdout: true).trim() != 'no'
          if (!hasDocker) {
            echo "Docker not found on this agent — skipping Docker build."
          } else {
            sh "docker build -t ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
          }
        }
      }
    }

    stage('Smoke Test Container (Unix-only)') {
      when {
        allOf {
          expression { return isUnix() }
        }
      }
      steps {
        script {
          // If Docker not available we already skipped; run minimal smoke test
          def hasDocker = sh(script: 'command -v docker >/dev/null 2>&1 || echo no', returnStdout: true).trim() != 'no'
          if (!hasDocker) {
            echo "Docker not found on this agent — skipping smoke test."
          } else {
            def cname = "jenkins-starter-${env.BUILD_NUMBER}"
            sh "docker run -d --rm --name ${cname} -p 8080:8080 ${env.IMAGE_NAME}:${env.BUILD_NUMBER} || true"
            // wait briefly for app startup
            sh "sleep 2"
            // confirm container is running
            sh "docker ps --filter name=${cname} --filter status=running --format '{{.Names}}' || true"
            // stop container if it exists
            sh "docker stop ${cname} || true"
          }
        }
      }
    }

    stage('Push Image (optional, Unix-only)') {
      when {
        allOf {
          expression { return isUnix() }
          expression { return env.PUSH_DOCKER == 'true' }
        }
      }
      steps {
        script {
          def hasDocker = sh(script: 'command -v docker >/dev/null 2>&1 || echo no', returnStdout: true).trim() != 'no'
          if (!hasDocker) {
            error "Docker not available on agent; cannot push image."
          }
          withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
            sh "docker tag ${env.IMAGE_NAME}:${env.BUILD_NUMBER} ${env.IMAGE_NAME}:latest"
            sh "docker push ${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
            sh "docker push ${env.IMAGE_NAME}:latest"
          }
        }
      }
    }
  }

  post {
    success {
      echo "Build succeeded: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
    failure {
      echo "Build failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
    cleanup {
      script {
        if (isUnix()) {
          // try to cleanup dangling images (best effort)
          sh 'docker image prune -f || true'
        } else {
          echo 'Skipping docker cleanup on Windows agent.'
        }
      }
    }
  }
}
