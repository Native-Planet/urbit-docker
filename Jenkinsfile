pipeline {
    agent any
    environment {
        dockerpw = credentials('Dockerhub')
    }
    stages {
        stage('Build') {
            environment {
                tag = sh ( 
                    script: '''
                        git clone https://github.com/urbit/vere
                        cd vere
                        tag=$(git describe --tags --abbrev=0 --exclude "*-rc*")
                        tag=$(echo "$tag" | sed -e "s/^vere-//")
                        cd .. && rm -rf vere
                        echo $tag
                    ''',
                    returnStdout: true
                ).trim()
            }
            steps {
                script: '''
                    docker login --username=nativeplanet --password=$dockerpw
                    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
                    docker buildx create --use --name xbuilder --node xbuilder0
                    docker buildx build --build-arg TAG=$tag --push --tag nativeplanet/urbit:${tag} --platform linux/amd64,linux/arm64 .
                ''',
                returnStdout: true
                }
            }
        }
    }
}