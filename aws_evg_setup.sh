#
# This script is used to set up a spawned Evergreen host to easily run a Linkbench benchmark. The
# script expects the appropriate MongoDB compilation artifacts to already exists on the spawned host.
#

# Install Maven and Java so we can build and run Linkbench.
yum install default-jdk
wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
yum install apache-maven

# Clone linkbench.
git clone https://github.com/10gen/linkbench

# Build linkbench.
mvn clean package -DskipTests