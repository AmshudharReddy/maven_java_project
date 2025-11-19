pipeline {
}


stage('Build & Test') {
steps {
// runs mvn -B -e clean package
sh 'mvn -B -e clean package'
}
post {
always {
junit 'target/surefire-reports/*.xml'
archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
}
}
}


stage('Docker Build') {
steps {
script {
// Build image locally on the agent
sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
}
}
}


stage('Smoke Test Container') {
steps {
script {
// Run the container in the background, wait briefly, then ensure it starts
sh "docker run -d --rm --name jenkins-starter-${env.BUILD_NUMBER} -p 8080:8080 ${IMAGE_NAME}:${env.BUILD_NUMBER}"
// Very small sleep to let app start; adjust if your app needs more startup time
sh 'sleep 2'
// Check container is running
sh "docker ps --filter name=jenkins-starter-${env.BUILD_NUMBER} --filter status=running --format '{{.Names}}'"
// Stop the container
sh "docker stop jenkins-starter-${env.BUILD_NUMBER}"
}
}
}


stage('Push Image (optional)') {
when {
expression { return env.PUSH_DOCKER == 'true' }
}
steps {
withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
sh "docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${IMAGE_NAME}:latest"
sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
sh "docker push ${IMAGE_NAME}:latest"
}
}
}
}


post {
success {
echo "Build succeeded: ${env.BUILD_URL}"
}
failure {
echo "Build failed: ${env.BUILD_URL}"
}
cleanup {
// Remove any dangling images created during pipeline (optional)
sh 'docker image prune -f || true'
}
}
}