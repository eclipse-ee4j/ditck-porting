/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0, which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the
 * Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
 * version 2 with the GNU Classpath Exception, which is available at
 * https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 */

env.label = "di-tck-pod-${UUID.randomUUID().toString()}"
pipeline {
  options {
    buildDiscarder(logRotator(numToKeepStr: '5'))
  }
  agent {
    kubernetes {
      label "${env.label}"
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
spec:
  hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "localhost.localdomain"
  containers:
  - name: di-tck
    image: anajosep/cts-base:0.1
    command:
    - cat
    tty: true
    imagePullPolicy: Always
    resources:
      limits:
        memory: "6Gi"
        cpu: "1.25"
"""
    }
  }
  parameters {
    string(name: 'GF_BUNDLE_URL', 
           defaultValue: 'https://download.eclipse.org/ee4j/jakartaee-tck/8.0.1/nightly/glassfish.zip', 
           description: 'URL required for downloading GlassFish Full/Web profile bundle' )
    string(name: 'JAVAX_INJECT_TCK_URL',
           defaultValue: 'https://github.com/javax-inject/javax-inject/releases/download/1/javax.inject-tck.zip',
           description: 'URL required for downloading AT Inject TCK Bundle' )
    string(name: 'JSR299_TCK_URL', 
           defaultValue: 'https://sourceforge.net/projects/jboss/files/CDI-TCK/1.0.6.Final/jsr299-tck-1.0.6.Final-dist.zip/download',
           description: 'URL required for downloading JSR 299 TCK bundle' )
  }

  environment {
    ANT_HOME = "/usr/share/ant"
    MAVEN_HOME = "/usr/share/maven"
    ANT_OPTS = "-Dhttp.proxyHost=${httpProxyHost} -Dhttp.proxyPort=${httpProxyPort} -Djavax.xml.accessExternalStylesheet=all -Djavax.xml.accessExternalSchema=all -Djavax.xml.accessExternalDTD=file,http" 
  }

  stages {
    stage('ditck-build') {
      steps {
        container('di-tck') {
          sh """
            env
            bash -x ${WORKSPACE}/docker/build_ditck.sh
          """
          archiveArtifacts artifacts: 'bundles/*.zip'
        }
      }
    }
  
    stage('ditck-run') {
      steps {
        container('di-tck') {
          sh """
            env
            bash -x ${WORKSPACE}/docker/run_ditck.sh
          """
          archiveArtifacts artifacts: "330tck-results.tar.gz"
          junit testResults: '330tck-report/*.xml', allowEmptyResults: true
        }
      }
    }
  }
}
