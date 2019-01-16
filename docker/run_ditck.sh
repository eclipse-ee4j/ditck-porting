#!/bin/bash -xe
#
# Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
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


VER="1.0"
unzip -o ${WORKSPACE}/bundles/330-tck-glassfish-porting-1.0_latest.zip -d ${WORKSPACE}

export TS_HOME=${WORKSPACE}/330-tck-glassfish-porting

#Install Glassfish
echo "Download and install GlassFish 5.0.1 ..."
if [ -z "${GF_BUNDLE_URL}" ]; then
  export GF_BUNDLE_URL="http://download.oracle.com/glassfish/5.0.1/nightly/latest-glassfish.zip"
fi
wget --progress=bar:force --no-cache $GF_BUNDLE_URL -O latest-glassfish.zip
unzip -o ${WORKSPACE}/latest-glassfish.zip -d ${WORKSPACE}

which ant
ant -version

REPORT=${WORKSPACE}/330tck-report
mkdir -p ${REPORT}
if [ -z "${JAVAX_INJECT_TCK_URL}" ];then
  JAVAX_INJECT_TCK_URL=https://github.com/javax-inject/javax-inject/releases/download/1/javax.inject-tck.zip
fi
if [ -z "${JSR299_TCK_URL}" ];then
  JSR299_TCK_URL=https://sourceforge.net/projects/jboss/files/CDI-TCK/1.0.6.Final/jsr299-tck-1.0.6.Final-dist.zip/download
fi

wget ${JAVAX_INJECT_TCK_URL} -O ${WORKSPACE}/javax.inject-tck.zip 
wget ${JSR299_TCK_URL} -O ${WORKSPACE}/jsr299-tck.zip
unzip ${WORKSPACE}/javax.inject-tck.zip  -d ${WORKSPACE}
unzip ${WORKSPACE}/jsr299-tck.zip -d ${WORKSPACE}

#Edit test properties
sed -i "s#ts.home=.*#ts.home=${WORKSPACE}#g" ${TS_HOME}/build.properties
sed -i "s#porting.home=.*#porting.home=${TS_HOME}#g" ${TS_HOME}/build.properties
sed -i "s#glassfish.home=.*#glassfish.home=${WORKSPACE}/glassfish5/glassfish#g" ${TS_HOME}/build.properties
sed -i "s#299.tck.home=.*#299.tck.home=${WORKSPACE}/jsr299-tck-1.0.6.Final#g" ${TS_HOME}/build.properties
sed -i "s#report.dir=.*#report.dir=${REPORT}#g" ${TS_HOME}/build.properties

#Run Tests
cd ${TS_HOME}
ant run

#Generate Reports
cp ${REPORT}/index.html  ${REPORT}/report.html
echo "Saving TCK results"

mv $REPORT/TESTS-TestSuites.xml $REPORT/330tck-junit-report.xml
rm $REPORT/TEST-*.xml 

tar zcvf ${WORKSPACE}/330tck-results.tar.gz ${REPORT}
