// Jenkinsfile: fail PR builds when gitleaks finds secrets
pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timestamps()
  }

  stages {
    stage('Info') {
      steps {
        script {
          echo "BRANCH_NAME = ${env.BRANCH_NAME}"
          echo "CHANGE_ID   = ${env.CHANGE_ID}"
          echo "CHANGE_TARGET = ${env.CHANGE_TARGET}"
          echo "Is changeRequest (PR)? ${env.CHANGE_ID != null}"
        }
      }
    }

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Setup') {
      steps {
        sh '''
          set -e
          python --version || true
          pip --version || true
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
        '''
      }
    }

    stage('PR secret-scan and tests') {
      when { changeRequest() }
      steps {
        echo "Running secret-scan (gitleaks) and fast tests for PRs"

        sh '''
          set -e

          # Run gitleaks (exit non-zero if leaks found)
          if command -v gitleaks >/dev/null 2>&1; then
            echo "Running local gitleaks..."
            gitleaks detect --source . --report-format json --report-path gitleaks-report.json --exit-code 1
          elif command -v docker >/dev/null 2>&1; then
            echo "Running gitleaks via docker..."
            docker run --rm -v "$PWD":/src zricethezav/gitleaks:8.8.3 detect --source /src --report-format json --report-path /src/gitleaks-report.json --exit-code 1
          else
            echo "ERROR: gitleaks binary or docker not available. Failing build to ensure secret-scanning is enforced."
            exit 2
          fi

          # Fast tests - do not mask failures (will fail build if tests fail)
          if command -v pytest >/dev/null 2>&1; then
            pytest -q
          fi
        '''
      }
    }

    stage('Branch build & publish') {
      when { not { changeRequest() } }
      steps {
        echo "Running full build/publish for branches"
        sh '''
          set -e
          pytest -q
          # package/publish commands go here for trusted branches
        '''
      }
    }
  }

  post {
    always {
      echo "Collecting test reports and artifacts"
      junit allowEmptyResults: true, testResults: 'reports/**/*.xml'
      archiveArtifacts allowEmptyArchive: true, artifacts: '**/dist/**, **/*.whl, gitleaks-report.json'
    }
    success { echo "Success" }
    failure { echo "Failed (check console and gitleaks-report.json)" }
  }
}
Jenkinsfile: fail PR builds when gitleaks finds secrets (Docker agent + runtime gitleaks install)
// pipeline {
//   agent {
//     docker {
//       image 'python:3.11-slim'
//       args '-u root:root'
//     }
//   }

//   options {
//     buildDiscarder(logRotator(numToKeepStr: '10'))
//     timestamps()
//   }

//   stages {
//     stage('Info') {
//       steps {
//         script {
//           echo "BRANCH_NAME = ${env.BRANCH_NAME}"
//           echo "CHANGE_ID   = ${env.CHANGE_ID}"
//           echo "CHANGE_TARGET = ${env.CHANGE_TARGET}"
//           echo "Is changeRequest (PR)? ${env.CHANGE_ID != null}"
//         }
//       }
//     }

//     stage('Checkout') {
//       steps { checkout scm }
//     }

//     stage('Prepare tools') {
//       steps {
//         sh '''
//           set -e
//           apt-get update -y
//           apt-get install -y --no-install-recommends curl ca-certificates tar gzip git
//           python -m pip install --upgrade pip setuptools || true
//           python -m pip install pytest
//           GL_VER="8.8.3"
//           curl -sL -o /tmp/gitleaks.tar.gz "https://github.com/zricethezav/gitleaks/releases/download/v${GL_VER}/gitleaks_${GL_VER}_Linux_x86_64.tar.gz"
//           mkdir -p /usr/local/bin
//           tar -xzf /tmp/gitleaks.tar.gz -C /tmp
//           mv /tmp/gitleaks /usr/local/bin/gitleaks
//           chmod +x /usr/local/bin/gitleaks
//           gitleaks version || true
//         '''
//       }
//     }

//     stage('PR secret-scan and tests') {
//       when { changeRequest() }
//       steps {
//         echo "Running secret-scan (gitleaks) and tests for PRs"
//         sh '''
//           set -e
//           gitleaks detect --source . --report-format json --report-path gitleaks-report.json --exit-code 1
//           if command -v pytest >/dev/null 2>&1; then
//             pytest -q
//           fi
//         '''
//       }
//     }

//     stage('Branch build & publish') {
//       when { not { changeRequest() } }
//       steps {
//         sh '''
//           set -e
//           pytest -q
//         '''
//       }
//     }
//   }

//   post {
//     always {
//       echo "Collecting test reports and artifacts"
//       junit allowEmptyResults: true, testResults: 'reports/**/*.xml'
//       archiveArtifacts allowEmptyArchive: true, artifacts: '**/dist/**, **/*.whl, gitleaks-report.json'
//     }
//     success { echo "Success" }
//     failure { echo "Failed (check console and gitleaks-report.json)" }
//   }
// }