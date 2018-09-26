Steps to run the tests
===========================
- Install V5 refer to this as GF_HOME
- Install the 330 TCK bundle
- Unzip the 330 Glassfish 5.0 porting bundle in a directory.
    Refer to this location as PORTING_HOME
- Install the 299 TCK from http://sourceforge.net/projects/jboss/files/CDI-TCK/1.0.6.Final/ 
  -- This porting package is reusing their porting impl.
- cd to PORTING_HOME and edit the build.properties file
- set tck.home, porting.home, 299.tck.home and glassfish.home in build.properties
- Invoke ant run

