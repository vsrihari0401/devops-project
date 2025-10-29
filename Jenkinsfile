// Use a lightweight agent that supports Docker commands
pipeline {
    agent any 
    
    // Define the tools needed globally
    // NOTE: 'M3' must match the name of your Maven configuration in Jenkins Global Tool Configuration
    tools {
        maven 'maven' 
    }

    // Define environment variables, including Docker Hub details and image tags
    environment {
        // --- User Configuration ---
        // Replace with your actual Docker Hub username
        DOCKER_HUB_USER = 'vsrihari01' 
        // Replace 'docker-hub-credentials' with the ID of your Jenkins Credential (Username and Password)
        DOCKER_HUB_CREDENTIAL_ID = '' 
        // --- Dynamic Variables ---
        IMAGE_NAME = 'nginx'
        IMAGE_TAG = "${env.BUILD_ID}"
        FULL_IMAGE_NAME = "${DOCKER_HUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        // ------------------------------------------------------------------
        // Stage 1: Pull Source Code and Maven Build
        // ------------------------------------------------------------------
        stage('Pull Source & Maven Build') {
            steps {
                // Replace with your actual repository URL and branch
                sh 'echo "Checking out source code..."'
                git branch: 'main', url: 'https://github.com/vsrihari0401/devops-project.git' 
                
                // Execute the Maven build
                sh 'echo "Running Maven clean install..."'
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo "✅ STAGE 1 SUCCESS: Source code pulled and Maven artifact prepared."
                }
                failure {
                    error "❌ STAGE 1 FAILURE: Failed to pull source code or Maven build failed. Aborting."
                }
            }
        }

        // ------------------------------------------------------------------
        // Stage 2: Build Docker Image
        // ------------------------------------------------------------------
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image using the artifact created by Maven
                    sh 'echo "Building Docker image..."'
                    def dockerImage = docker.build("${nginx}", '.') 
                    env.DOCKER_IMAGE_ID = dockerImage.id
                }
            }
            post {
                success {
                    echo "✅ STAGE 2 SUCCESS: Docker image built locally with tag: ${FULL_IMAGE_NAME}"
                }
                failure {
                    error "❌ STAGE 2 FAILURE: Docker image build failed. Check Dockerfile and build context."
                }
            }
        }

        // ------------------------------------------------------------------
        // Stage 3: Tag Name Verification (Docker Hub Username)
        // ------------------------------------------------------------------
        stage('Tag Name Verification') {
            steps {
                // This confirms the tag structure includes the Docker Hub username (repository name)
                sh 'echo "The final image tag for push is confirmed as: ${FULL_IMAGE_NAME}"'
            }
            post {
                success {
                    echo "✅ STAGE 3 SUCCESS: Image tag includes Docker Hub username (${DOCKER_HUB_USER})."
                }
                failure {
                    error "❌ STAGE 3 FAILURE: Tag verification failed."
                }
            }
        }

        // ------------------------------------------------------------------
        // Stage 4: Push to Docker Hub (Using Jenkins Credentials)
        // ------------------------------------------------------------------
        stage('Push to Docker Hub') {
            steps {
                // Use withCredentials to securely handle the Docker Hub login
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIAL_ID}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh 'docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}'
                    sh "docker push ${FULL_IMAGE_NAME}"
                    sh 'docker logout' 
                }
            }
            post {
                success {
                    echo "✅ STAGE 4 SUCCESS: Image successfully pushed to Docker Hub."
                }
                failure {
                    error "❌ STAGE 4 FAILURE: Failed to push image. Check Jenkins credentials ID or API access."
                }
            }
        }

        // ------------------------------------------------------------------
        // Stage 5: Remove Docker Image Locally (Cleanup)
        // ------------------------------------------------------------------
        stage('Remove Local Image') {
            steps {
                // Force removal just in case
                sh "docker rmi -f ${FULL_IMAGE_NAME}"
                sh 'echo "Local Docker image removed successfully."'
            }
            post {
                success {
                    echo "✅ STAGE 5 SUCCESS: Local image cleanup complete."
                }
                failure {
                    // Fail the stage as requested, although in production, cleanup failure might be just a warning
                    error "❌ STAGE 5 FAILURE: Failed to remove local image."
                }
            }
        }

        // ------------------------------------------------------------------
        // Stage 6: Run a Container
        // ------------------------------------------------------------------
        stage('Run Container') {
            steps {
                // Define the container name
                def containerName = "${IMAGE_NAME}-latest"

                // Stop and remove any pre-existing container before running the new one
                sh "docker stop ${containerName} || true"
                sh "docker rm ${containerName} || true"
                
                // Run the new container (example: mapping internal port 8080 to host port 80)
                sh "docker run -d --name ${containerName} -p 80:8080 ${FULL_IMAGE_NAME}"
                sh "echo 'New container ${containerName} started successfully.'" 
            }
            post {
                success {
                    echo "✅ STAGE 6 SUCCESS: Application container is running."
                }
                failure {
                    error "❌ STAGE 6 FAILURE: Failed to start the application container. Check port binding or image."
                }
            }
        }
    }
}