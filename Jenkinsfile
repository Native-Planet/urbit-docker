pipeline {
    parameters {
        choice(
            choices: ['no' , 'yes'],
            description: 'Force image to rebuild even without new base image detected',
            name: 'REBUILD')
    }
    agent any
    triggers {
        cron('0 4 * * *')
    }
    environment {
        dockerpw = credentials('Dockerhub PW')
        versionauth = credentials('VersionAuth')
    }
    stages {
        stage('Build') {
            environment {
                is_new = sh(
                    script: '''#!/bin/bash -x
                        updated=$(curl -s "https://hub.docker.com/v2/repositories/tloncorp/vere/tags/edge/?page_size=100" \
                        |jq -r '.last_updated')
                        ours=$(curl -s "https://hub.docker.com/v2/repositories/nativeplanet/urbit/tags/canary/?page_size=100" \
                        |jq -r '.last_updated')
                        stamp=`date -d $updated +"%s"`
                        yday=`date -d $ours +"%s"`
                        if [ $stamp -le $yday ]; then
                            echo "old"
                        else
                            echo "new"
                        fi
                    ''',
                    returnStdout: true
                ).trim()
            }
            steps {
                sh (
                    script: '''
                        #!/bin/bash -x
                        if [ "$is_new" = "new" ]; then
                            docker login --username=nativeplanet --password=$dockerpw
                            docker build --tag nativeplanet/urbit:canary .
                            docker push nativeplanet/urbit:canary
                            edge_hash=`curl -s "https://hub.docker.com/v2/repositories/nativeplanet/urbit/tags/canary/?page_size=100" \
                                |jq -r '.images[]|select(.architecture=="amd64").digest'|sed 's/sha256://g'`
                            curl -X PUT -H "X-Api-Key: ${versionauth}" \
                                https://version.groundseg.app/modify/groundseg/canary/vere/amd64_sha256/${edge_hash}
                        elif [ "${params.REBUILD}" = "True" ]; then
                            docker login --username=nativeplanet --password=$dockerpw
                            docker build --tag nativeplanet/urbit:canary .
                            docker push nativeplanet/urbit:canary
                            edge_hash=`curl -s "https://hub.docker.com/v2/repositories/nativeplanet/urbit/tags/canary/?page_size=100" \
                                |jq -r '.images[]|select(.architecture=="amd64").digest'|sed 's/sha256://g'`
                            curl -X PUT -H "X-Api-Key: ${versionauth}" \
                                https://version.groundseg.app/modify/groundseg/canary/vere/amd64_sha256/${edge_hash}
                        else
                            echo "Now new image"
                        fi
                    ''',
                    returnStdout: true
                )
                }
            }
        }
    }
