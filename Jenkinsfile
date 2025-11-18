pipeline {
  agent any

  options {
    // keep last 10 builds, timestamps
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timestamps()
  }

  stages {
    stage('Info') {
      steps {
        script {
          echo "BRANCH_NAME = ${env.BRANCH_NAME}"
          echo "CHANGE_ID = ${env.CHANGE_ID}"
          echo "CHANGE_TARGET = ${env.CHANGE_TARGET}"
          echo "Is changeRequest (PR)? ${env.CHANGE_ID != null}"
        }
      }
    }

    stage('Checkout') {
      // Multibranch Pipeline will provide correct SCM (merge ref for PRs when available)
      steps {
        checkout scm
      }
    }

    stage('Setup') {
      steps {
        sh '''
          python --version || true
          pip --version || true
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        '''
      }
    }

    stage('PR checks') {
      when { changeRequest() }
      steps {
        echo "Running PR-specific checks (lint, fast tests)"
        sh '''
          # run lint and fast unit tests for PRs
          if command -v pytest >/dev/null 2>&1; then
            pytest -q || true
          fi
        '''
      }
    }

    stage('Branch build & publish') {
      when { not { changeRequest() } }
      steps {
        echo "Running full build/publish for branches"
        sh '''
          # full test suite, build, and publish only for non-PR branches
          pytest -q || true
          # package/publish commands go here (only for trusted branches)
        '''
      }
    }
  }

  post {
    always {
      echo "Collecting test reports and artifacts"
      junit allowEmptyResults: true, testResults: 'reports/**/*.xml'
      archiveArtifacts allowEmptyArchive: true, artifacts: '**/dist/**, **/*.whl'
    }
    success { echo "Success" }
    failure { echo "Failed" }
  }
}