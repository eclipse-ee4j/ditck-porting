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
           defaultValue: 'https://ci.eclipse.org/jakartaee-tck/job/build-glassfish/lastSuccessfulBuild/artifact/appserver/distributions/glassfish/target/glassfish.zip', 
           description: 'URL required for downloading GlassFish Full/Web profile bundle' )
    string(name: 'JAKARTA_INJECT_TCK_URL',
           defaultValue: 'https://download.eclipse.org/ee4j/cdi/jakarta.inject-tck-2.0.0-RC4-bin.zip',
           description: 'URL required for downloading Jakarta DI TCK Bundle' )
    string(name: 'JAKARTA_INJECT_VERSION',
           defaultValue: '2.0.0-RC4',
           description: 'Jakarta DI TCK VERSION' )
    string(name: 'JSR299_TCK_URL', 
           defaultValue: 'https://download.eclipse.org/ee4j/cdi/cdi-tck-3.0.0-M3-dist.zip',
           description: 'URL required for downloading Jakarta CDI TCK bundle' )
    string(name: 'JSR299_TCK_VERSION', 
           defaultValue: '3.0.0-M3',
           description: 'CDI TCK version' )
    string(name: 'TCK_BUNDLE_BASE_URL',
           defaultValue: '',
           description: 'Base URL required for downloading prebuilt binary TCK Bundle from a hosted location' )
    string(name: 'TCK_BUNDLE_FILE_NAME', 
           defaultValue: '330-tck-glassfish-porting-2.0.0.zip', 
	   description: 'Name of bundle file to be appended to the base url' )
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
