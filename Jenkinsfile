library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/ArshaShiri/DevOpsBootcampJenkinsAssignmentSharedLib.git',
     credentialsId: 'git-credentials'
     ]
)

def gv

pipeline {
    agent any

    stages {

        stage('increment version') {
            steps{
                script {
                    incrementVersion()
                }
            }
        }

        stage('Run tests') {
            steps{
                script {
                    runTests()
                }
            }
        }

        stage('Build and Push docker image') {
            steps {
                script {
                    buildAndPushDockerImage()
                }
            }
        }

        stage('deploy to EC2') {
            steps {
                script {
                   def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                   def ec2Instance = "ec2-user@18.185.254.138"

                   sshagent(['ec2-server-key']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ec2-user@18.185.254.138:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ec2-user@18.185.254.138:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ec2-user@18.185.254.138 ${shellCmd}"
                   }
                }
            }
        }


        // stage('commit version update to github') {
        //     steps {
        //         script {
        //             commitVersionChangeToGit()
        //         }
        //     }
        // }
    }
}