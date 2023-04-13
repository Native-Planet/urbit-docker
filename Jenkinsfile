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
                        updated=`date -d $updated +"%s"`
                        ours=`date -d $ours +"%s"`
                        if [ $updated -ge $ours ]; then
                            echo "new"
                        else
                            echo "old"
                        fi
                    ''',
                    returnStdout: true
                ).trim()
            }
            steps {
                sh (
                    script: '''#!/bin/bash -x
                        build_img () {
                            docker login --username=nativeplanet --password=$dockerpw
                            docker build --tag nativeplanet/urbit:canary .
                            docker push nativeplanet/urbit:canary
                            edge_hash=`curl -s "https://hub.docker.com/v2/repositories/nativeplanet/urbit/tags/canary/?page_size=100" \
                                |jq -r '.images[]|select(.architecture=="amd64").digest'|sed 's/sha256://g'`
                            curl -X PUT -H "X-Api-Key: ${versionauth}" \
                                https://version.groundseg.app/modify/groundseg/canary/vere/amd64_sha256/${edge_hash}
                        }
                        if [ "$is_new" = "new" ]; then
                            build_img
                        elif [ "${REBUILD}" = "yes" ]; then
                            build_img
                        else
                            echo "No new image"
                        fi
                    ''',
                    returnStdout: true
                )
                }
            }
        }
    }
