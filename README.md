# Shell Script for Deploying .m2 Local Artifacts into Nexus Repository Manager

This repo contains scripts + explanation for sending .m2 local artifacts (pom & jar files) into `SonaType nexus repository manager`.

> [!NOTE]
> Setup Used:
>   * Windows 10, 11
>   * Sonatype Nexus Repository Manager 3.55.0-01.

> [!IMPORTANT]
> If you're going to use this script on Windows, `git bash` is needed which is installed with git installer.

Extracting list of artifacts has been adopted[^1] and a custom argument path has been added to it.
## Steps:
1. copy `extract-artifacts.sh` & `upload-artifacts.sh` scripts to `~/.m2` folder
2. run following command, would create `artifacts` file in current folder:
```shell
./"extract-artifacts.sh"
```

> example 1: This `./extract-artifacts.sh`, will generate list of artifact files under `~/.m2` path

> example 2: `./extract-artifacts.sh './repository/some/path/to/deploy/its/artifacts'`, will generate list of artifact files under `./repository/some/path/to/deploy/its/artifacts` path

3. Supposing `maven-releases` repository of `hosted` type has been already created in Nexus which is hosted at `http://nexus.example.com`
4. fill `NEXUS_BASE_URL` & `NEXUS_REPOSITORY_ID` variables inside `upload-artifacts.sh`
> [!IMPORTANT]
> `NEXUS_REPOSITORY_ID` should be set as `repositoryId` which is set inside settings.xml for maven.
>
> for following maven **settings.xml** file, `NEXUS_REPOSITORY_ID` value should be set equal to `NEXUS-MAVEN-REPO-NAME`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
   .
   .
   <profiles>
      <profile>
         <id>NEXUS-MAVEN-PROFILE-ID</id>
         <repositories>
            <repository>
               <id>NEXUS-MAVEN-REPO-NAME</id>
               <name>Nexus Repository</name>
               <url>http://nexus.example.com/repository/maven-public/</url>
               <releases>
                  <enabled>true</enabled>
               </releases>
               .
               .
            </repository>
         </repositories>
         .
         .
      </profile>
   </profiles>
   .
   .
</settings>
```

5. running following command, all maven artifacts inside generated `artifacts` file, will be deployed to appropriate path in repository:
```shell
./"upload-artifacts.sh"
```

6. username and password with privileges to push to `maven-releases` repository should be updated in corresponding `settings.xml` file located at conf folder for maven
```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
   .
   .
   <servers>
     <server>
       <id>NEXUS-SERVER-ID</id>
       <username>USERNAME</username>
       <password>PASSWORD</password>
     </server>
   </servers>
   .
   .
</settings>
```

7. if deploying project artifact from `pom.xml` file for corresponding project is wanted, add following section to its `pom.xml` file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
.
.
.
    <distributionManagement>
        <repository>
            <id>NEXUS-MAVEN-REPO-NAME</id>
            <name>Nexus Repository</name>
            <url>http://nexus.example.com/repository/maven-releases</url>
        </repository>
    </distributionManagement>
</project>
```

then run following command on dir which contains `pom.xml`
```
mvn clean deploy
```

<hr/>

I needed to deploy local .m2 artifacts into nexus to speed up my work process, so I come up with this script. I wanted to deploy to `maven-releases` repository. You can make your changes for `maven-snapshots` repository. 

Good luck!


[^1]: https://gist.github.com/SanSan-/3acc532687df60cfcc037cc79baedd92?permalink_comment_id=4527488#gistcomment-4527488