NEXUS_BASE_URL="nexus.example.com"
NEXUS_REPOSITORY_ID="NEXUS-MAVEN-REPO-NAME" # repositoryId which is set inside settings.xml for maven

cat artifacts | while read i; do
  
  # Extract group ID, artifact ID, and version from the directory path
  GROUP_ID=$(echo $i | awk -F'/repository/' '{print $2}' | awk -F'/' '{ for (i=1; i<NF-2; i++) printf("%s.", $i) } {print $(NF-2)}')
  ARTIFACT_ID=$(basename "$(dirname $i)")
  VERSION=$(basename $i)

  # Create a temporary directory & Copy artifacts to it (because of files locking by maven, direct upload from original folders of artifacts is not valid)
  temp_dir=$(mktemp -d)
  cp -R $i/* "$temp_dir"


  POM_PATH=$(find $temp_dir -name *.pom)
  JAR_PATH=$(find $temp_dir -name *.jar)

  # Run Maven from the directory where the POM file exists, to deploy to custom repository
  echo " "
  pushd "$temp_dir"
  
	# choosing upload-strategy, preferring jar-upload
	if test -z "$JAR_PATH"
	then
		echo "uploading $ARTIFACT_ID as pom"
		# a 400 error means that the artifactId already exists
		mvn deploy:deploy-file \
		 -DgroupId=$GROUP_ID \
		 -DartifactId=$ARTIFACT_ID \
		 -Dversion=$VERSION \
		 -Dpackaging=pom \
		 -Dfile="$POM_PATH" \
         -DrepositoryId=$NEXUS_REPOSITORY_ID \
		 -Durl="http://${NEXUS_BASE_URL}/repository/maven-releases/" &   # Run the Maven command in the background

    # Wait for the Maven command to complete
    wait

		echo "uploaded $POM_PATH with groupId: $GROUP_ID; artifactId: $ARTIFACT_ID; version: $VERSION"
	else 
		echo "uploading $ARTIFACT_ID as jar"
		# a 400 error means that the artifactId already exists
		mvn deploy:deploy-file \
		 -DgroupId=$GROUP_ID \
		 -DartifactId=$ARTIFACT_ID \
		 -Dversion=$VERSION \
		 -Dpackaging=jar \
		 -DpomFile="$POM_PATH" \
		 -Dfile="$JAR_PATH" \
         -DrepositoryId=$NEXUS_REPOSITORY_ID \
		 -Durl="http://${NEXUS_BASE_URL}/repository/maven-releases/"	&   # Run the Maven command in the background

    # Wait for the Maven command to complete
    wait

		echo "uploaded $JAR_PATH with groupId: $GROUP_ID; artifactId: $ARTIFACT_ID; version: $VERSION"
	fi 
  
  popd
  rm -rf "$temp_dir"
done 

echo 'done uploading artifacts'