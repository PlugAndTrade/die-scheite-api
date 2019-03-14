pipeline {
  environment {
    name = 'plugandtrade-diescheite-api'
    dockerRegistryUrl = 'https://pntregistry.azurecr.io/'
    dockerRegistryCredentials = 'dockerregistry'
    dockerImage = ''
    GIT_COMMIT_SHORT = "${sh(returnStdout: true, script: 'git rev-parse --short HEAD')}"
  }
  agent {
    label 'docker && linux'
  }
  stages {
    stage('Build') {
      environment {
        DOCKER_TAGS = "latest,${GIT_COMMIT_SHORT},${ParseGitTag("${BRANCH_NAME}")}"
      }

      steps {
        script {
          dockerImage = docker.build(name)
        }

        script {
          docker.withRegistry(dockerRegistryUrl, dockerRegistryCredentials) {
            def dockerTags = DOCKER_TAGS.split(',')
            for (int i = 0; i < dockerTags.size(); i++) {
              dockerImage.push(dockerTags[i])
            }
          }
        }
      }
    }
  }
}

def ParseGitTag(tagString) {
  def sedPattern = /^\(\(\([0-9]\+\)\.[0-9]\+\)\.[0-9]\+\)\(-[a-zA-Z0-9]\+\)\?$/
  def replacePattern = /\1\4,\2\4,\3\4/
  tagsString = sh([returnStdout: true,
    script: "echo '${tagString}' | sed -e 's%/%-%g'| sed -e 's/${sedPattern}/${replacePattern}/'"
  ])
  return tagsString
}
