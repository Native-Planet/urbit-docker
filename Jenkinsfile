pipeline {
    agent any
    triggers {
        cron('0 4 * * *')
    }
    environment {
        versionauth = credentials('VersionAuth')
    }
    stages {
        stage('Build') {
            environment {
                tlon_edge_vere_amd64_hash = sh(
                    script: '''#!/bin/bash -x
                    curl -s "https://hub.docker.com/v2/repositories/tloncorp/vere/tags/edge/?page_size=100" \
                    |jq -r '.images[]|select(.architecture=="amd64").digest'|sed 's/sha256://g'
                    ''',
                    returnStdout: true
                ).trim()
            }
            steps {
                sh (
                    script: '''
                        curl -X PUT -H "X-Api-Key: ${versionauth}" \
                            https://version.groundseg.app/modify/groundseg/canary/vere/amd64_sha256/${tlon_edge_vere_amd64_hash}
                    ''',
                    returnStdout: true
                )
                }
            }
        }
    }
