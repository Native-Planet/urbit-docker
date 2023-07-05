pipeline {
    agent any
    environment {
        dockerpw = credentials('Dockerhub PW')
        versionauth = credentials('VersionAuth')
        channel = sh ( 
            script: '''
                environ=`echo $BRANCH_NAME|sed 's@origin/@@g'`
                if [ "${environ}" = "master" ]; then
                    echo "latest"
                elif [ "${environ}" = "staging" ]; then
                    echo "edge"
                else
                    echo "nobuild"
                fi
            ''',
            returnStdout: true
        ).trim()
    }
    stages {
        stage('Build') {
            environment {
                tag = sh ( 
                    script: '''
                        tag=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/urbit/vere 'vere-v*' | cut --delimiter='/' --fields=3 | grep -v 'rc' | tail -n 1 | sed -e "s/^vere-//")
                        echo $tag
                    ''',
                    returnStdout: true
                ).trim()
            }
            steps {
                sh (
                    script: '''
                        docker login --username=nativeplanet --password=$dockerpw
                        docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
                        docker buildx create --use --name xbuilder --node xbuilder0
                        docker buildx build --build-arg TAG=$tag --push --tag nativeplanet/urbit:${tag} --tag nativeplanet/urbit:latest --platform linux/amd64,linux/arm64 .
                        arm64_hash=`curl -s "https://hub.docker.com/v2/repositories/nativeplanet/urbit/tags/${tag}/?page_size=100" \
                        |jq -r '.images[]|select(.architecture=="arm64").digest'|sed 's/sha256://g'`
                        amd64_hash=`curl -s "https://hub.docker.com/v2/repositories/nativeplanet/urbit/tags/${tag}/?page_size=100" \
                        |jq -r '.images[]|select(.architecture=="amd64").digest'|sed 's/sha256://g'`
                        curl -X PUT -H "X-Api-Key: ${versionauth}" \
                            https://version.groundseg.app/modify/groundseg/${channel}/vere/amd64_sha256/${amd64_hash}
                        curl -X PUT -H "X-Api-Key: ${versionauth}" \
                            https://version.groundseg.app/modify/groundseg/${channel}/vere/arm64_sha256/${arm64_hash}
                        curl -X PUT -H "X-Api-Key: ${versionauth}" \
                            https://version.groundseg.app/modify/groundseg/${channel}/vere/tag/${tag}
                    ''',
                    returnStdout: true
                )
                }
            }
        }
    }
