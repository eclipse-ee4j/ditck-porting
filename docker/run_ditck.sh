#!/bin/bash -xe
#
# Copyright (c) 2019, 2022 Oracle and/or its affiliates. All rights reserved.
#
# This program and the accompanying materials are made available under the
# terms of the Eclipse Public License v. 2.0, which is available at
# http://www.eclipse.org/legal/epl-2.0.
#
# This Source Code may also be made available under the following Secondary
# Licenses when the conditions for such availability set forth in the
# Eclipse Public License v. 2.0 are satisfied: GNU General Public License,
# version 2 with the GNU Classpath Exception, which is available at
# https://www.gnu.org/software/classpath/license.html.
#
# SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0


VER="2.0"

if ls ${WORKSPACE}/bundles/*330-tck-glassfish-porting-*.zip 1> /dev/null 2>&1; then
  unzip -o ${WORKSPACE}/bundles/*330-tck-glassfish-porting-*.zip -d ${WORKSPACE}
else
  echo "[ERROR] TCK bundle not found"
  exit 1
fi

export TS_HOME=${WORKSPACE}/330-tck-glassfish-porting

#Install Glassfish
echo "Download and install GlassFish 7 ..."
if [ -z "${GF_BUNDLE_URL}" ]; then
  export GF_BUNDLE_URL="https://download.eclipse.org/ee4j/glassfish/glassfish-7.0.0-SNAPSHOT-nightly.zip"
fi
wget --progress=bar:force --no-cache $GF_BUNDLE_URL -O latest-glassfish.zip
unzip -o ${WORKSPACE}/latest-glassfish.zip -d ${WORKSPACE}

which ant
ant -version

if [[ "$JDK" == "JDK17" || "$JDK" == "jdk17" ]];then
  export JAVA_HOME=${JDK17_HOME}
fi
export PATH=$JAVA_HOME/bin:$PATH


which java
java -version

REPORT=${WORKSPACE}/330tck-report
mkdir -p ${REPORT}
if [ -z "${JAKARTA_INJECT_TCK_URL}" ];then
  JAKARTA_INJECT_TCK_URL=https://download.eclipse.org/ee4j/cdi/inject/2.0/jakarta.inject-tck-2.0.2-bin.zip
fi
if [ -z "${JSR299_TCK_URL}" ];then
  JSR299_TCK_URL=https://download.eclipse.org/ee4j/cdi/4.0/cdi-tck-4.0.5-dist.zip
fi

if [ -z "${JAKARTA_INJECT_VERSION}" ]; then
  JAKARTA_INJECT_VERSION="2.0.2"
fi

if [ -z "${JSR299_TCK_VERSION}" ]; then
  JSR299_TCK_VERSION="4.0.5"
fi

wget ${JAKARTA_INJECT_TCK_URL} -O ${WORKSPACE}/jakarta.inject-tck.zip 
wget ${JSR299_TCK_URL} -O ${WORKSPACE}/jsr299-tck.zip
unzip ${WORKSPACE}/jakarta.inject-tck.zip  -d ${WORKSPACE}
unzip ${WORKSPACE}/jsr299-tck.zip -d ${WORKSPACE}

# Install the porting lib
cd ${WORKSPACE}/cdi-tck-${JSR299_TCK_VERSION}/weld/porting-package-lib
sed -i 's/3.0.2/3.0.0/g' pom.xml
mvn install
echo "+++ Installed CDI TCK porting libs"
ls target/dependency
cd ${WORKSPACE}

#Edit test properties
sed -i "s#tck.home=.*#tck.home=${WORKSPACE}/jakarta.inject-tck-${JAKARTA_INJECT_VERSION}#g" ${TS_HOME}/build.properties
sed -i "s#porting.home=.*#porting.home=${TS_HOME}#g" ${TS_HOME}/build.properties
sed -i "s#glassfish.home=.*#glassfish.home=${WORKSPACE}/glassfish7/glassfish#g" ${TS_HOME}/build.properties
sed -i "s#299.tck.home=.*#299.tck.home=${WORKSPACE}/cdi-tck-${JSR299_TCK_VERSION}#g" ${TS_HOME}/build.properties
sed -i "s#report.dir=.*#report.dir=${REPORT}#g" ${TS_HOME}/build.properties

#Run Tests
cd ${TS_HOME}
echo "+++ Ant build.properties:"
cat build.properties
ant run

#Generate Reports
cp ${REPORT}/index.html  ${REPORT}/report.html
echo "Saving TCK results"

mv $REPORT/TESTS-TestSuites.xml $REPORT/330tck-junit-report.xml
rm $REPORT/TEST-*.xml 

tar zcvf ${WORKSPACE}/330tck-results.tar.gz ${REPORT}
