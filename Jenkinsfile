#!groovy

// https://github.com/feedhenry/fh-pipeline-library
@Library('fh-pipeline-library') _

final String COMPONENT = "nagios4"
final String VERSION = "4.0.8"
final String DOCKER_HUB_ORG = "rhmap"

String BUILD = ""
String DOCKER_HUB_REPO = ""
String CHANGE_URL = ""

stage('Trust') {
    enforceTrustedApproval()
}

fhBuildNode(['label': 'openshift']) {
    BUILD = env.BUILD_NUMBER
    DOCKER_HUB_REPO = COMPONENT
    CHANGE_URL = env.CHANGE_URL

    stage('Platform Update') {
        final Map updateParams = [
                componentName: 'nagios',
                componentVersion: VERSION,
                componentBuild: BUILD,
                changeUrl: CHANGE_URL
        ]
        fhOpenshiftTemplatesComponentUpdate(updateParams)
        fhCoreOpenshiftTemplatesComponentUpdate(updateParams)
    }

    stash "nagios-container"
    archiveArtifacts writeBuildInfo('nagios-container', "${VERSION}-${BUILD}")
}

node('master') {
    stage('Build Image') {
        unstash "nagios-container"

        final Map params = [
                fromDir: '.',
                buildConfigName: COMPONENT,
                imageRepoSecret: "dockerhub",
                outputImage: "docker.io/${DOCKER_HUB_ORG}/${DOCKER_HUB_REPO}:${VERSION}-${BUILD}"
        ]

        try {
            buildWithDockerStrategy params
        } finally {
            sh "rm -rf *"
        }
    }
}
