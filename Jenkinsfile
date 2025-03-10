pipeline {
    agent any
    environment {
        TELEGRAM_BOT_TOKEN = '7309710230:AAHVqKKUkJ4yNxLfh8imyGxamgqctNRaHC0'
        TELEGRAM_CHAT_ID = '-4210903621'
        
        // MAIN Image Manager
        DOCKER_HUB_REPOSITORY = "knoeurn"
        DOCKER_HUB_IMAGE = "html_dev_ops_images"
        DOCKER_CREDENTIALS = "docker-hub-credentials"
        CONTAINER_NAME = "html_dev_ops"
        CONTAINER_PORT = "8890"
    
    }
    parameters {
        gitParameter(name: 'TAG', type: 'PT_TAG', defaultValue: '', description: 'Select the Git tag to build.')
        gitParameter(name: 'BRANCH', type: 'PT_BRANCH', defaultValue: '', description: 'Select the Git branch to build.')
          // Parameter for selecting the deployment action
        choice(name: 'ACTION',choices: ['deploy', 'rollback'],description: 'Choose whether to deploy a new version or rollback to a previous version.')
    }
    stages {
        stage('Checkout Code') {
            steps {
                script {
                   try{
                     if (params.TAG) {
                        echo "Checking out tag: ${params.TAG}"
                        checkout([$class: 'GitSCM',
                            branches: [[name: "refs/tags/${params.TAG}"]],
                            userRemoteConfigs: [[url: 'https://github.com/krolnoeurn36/html_dev_ops.git']]
                        ])
                      } else {
                          echo "Checking out branch: ${params.BRANCH}"
                          checkout([$class: 'GitSCM',
                              branches: [[name: "${params.BRANCH}"]],
                              userRemoteConfigs: [[url: 'https://github.com/krolnoeurn36/html_dev_ops.git']]
                          ])
                      }

                      if(params.ACTION == "rollback"){
                            sendTelegramMessage("Status: ${params.ACTION} => on Tag: ${params.TAG}")
                      }else {
                          sendTelegramMessage("Status: ${params.ACTION} => Checked done ${params.BRANCH} with Tag: ${params.TAG}")
                      }  
                   }catch(Exception e) {
                        sendTelegramMessage("Error during checkout process : ${e.message}")
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }
        stage('Build and Push Docker Image') {
            steps {
                script {
                  try{
                    if(params.ACTION == "rollback"){
                          sendTelegramMessage("Status: ${params.ACTION} => on Tag: ${params.TAG}")
                    }else {
                      // Implement your build logic here
                      echo "Status: ${params.ACTION} =>Building from ${env.CHECKOUT_REF}"
                      sendTelegramMessage("Status: ${params.ACTION} =>Building from ${env.CHECKOUT_REF} to Image:${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}")
                      // Example build command
                      withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                      }
                      sh """
                        docker build -t ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} .
                       
                        docker push ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}
                      """
                      sendTelegramMessage("Status: ${params.ACTION} => Build done of ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} and Push to: ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} ")
                    }
                  }catch(Exception e) {
                      sendTelegramMessage("Error during checkout process : ${e.message}")
                      currentBuild.result = 'FAILURE'
                      throw e
                  } 
                }
            }
        }
        stage("Remove Old Contianer"){
            steps{
                script{
                    try{
                        sendTelegramMessage("Status: ${params.ACTION} => Remove old container ${env.CONTAINER_NAME}")
                        // docker rm -f ${env.CONTAINER_NAME}
                        // def commandWrite = """
                           
                        //     docker ps -q --filter "name=$CONTAINER_NAME" | grep -q . && docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME || echo "No running container to remove"
                        // """
                        def commandWrite = """
                            ssh root@3.82.232.57 /var/myscripts/remove_old_image.sh $CONTAINER_NAME
                        """
                        def status = sh(script: commandWrite, returnStatus: true)
                        if(!status){
                            sendTelegramMessage("Status: ${params.ACTION} => Removed old container ${env.CONTAINER_NAME}")
                        }else {
                            currentBuild.result = 'FAILURE'
                            throw e
                        }
                    }catch(Exception e) {
                      sendTelegramMessage("Error during checkout process : ${e.message}")
                      currentBuild.result = 'FAILURE'
                      throw e
                  }  
                }
            }
        }
        stage("Deploying"){
            steps{
              script{
                  try{
                   
                    sendTelegramMessage("Status: ${params.ACTION} => Deploying in ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} ")
                    // def commandWrite = """
                       
                    //     docker run -d --name ${env.CONTAINER_NAME} -p ${env.CONTAINER_PORT}:80 ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG}
                    // """
                    def commandWrite= """
                        ssh root@3.82.232.57 /var/myscripts/deploy_image.sh ${env.CONTAINER_NAME} ${env.CONTAINER_PORT} ${env.DOCKER_HUB_REPOSITORY} ${env.DOCKER_HUB_IMAGE} ${params.TAG}
                    """
                    def status = sh(script: commandWrite, returnStatus: true)
                    if(!status){
                        sendTelegramMessage("Status: ${params.ACTION} => Updated ${env.DOCKER_HUB_REPOSITORY}/${env.DOCKER_HUB_IMAGE}:${params.TAG} ")
                    }else {
                      currentBuild.result = 'FAILURE'
                      throw e
                    }
                  }catch(Exception e) {
                      sendTelegramMessage("Error during checkout process : ${e.message}")
                      currentBuild.result = 'FAILURE'
                      throw e
                  }  
              }
            }
        } 
    }
    post {
        failure {
            sendTelegramMessage( "❌Oops!! Your app was built and deployed fail.")
        }
        success {
            sendTelegramMessage( "✅Congratulations!!!  Your app was built and deployed successfully.")
        }


    }
}


def sendTelegramMessage(String message) {
    httpRequest(
        acceptType: 'APPLICATION_JSON',
        contentType: 'APPLICATION_JSON',
        httpMode: 'POST',
        url: "https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/sendMessage",
        requestBody: "{\"chat_id\": \"${env.TELEGRAM_CHAT_ID}\", \"text\": \"${message}\"}"
    )
}