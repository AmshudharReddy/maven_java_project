# Jenkins Starter (Maven Java)


A tiny, reliable Maven Java project configured to build, test, dockerize and optionally push to Docker Hub from Jenkins.


## Quick start


1. Create a new Git repository on GitHub and push these files.
2. In Jenkins, create a new Pipeline job and point it to the GitHub repo (or use Multibranch Pipeline).
3. Make sure Jenkins has the following configured in *Manage Jenkins > Global Tool Configuration*:
- **JDK** installation named `jdk17` that points to Java 17.
- **Maven** installation named `maven3` (or update `Jenkinsfile` to match your tool names).
4. Ensure the Jenkins agent has Docker if you want Docker build steps to run (or remove Docker stages if not available).
5. (Optional) Create a Jenkins credential with ID `docker-hub` (username/password) for Docker Hub.
6. If you want to push images, set pipeline environment variable `PUSH_DOCKER=true` (e.g., in job configuration or using parameters).


## What the pipeline does


- Checks out the repo.
- Runs `mvn -B -e clean package` which compiles and runs unit tests.
- Archives `target/*.jar` and JUnit test reports.
- Builds a Docker image (tagged with build number).
- Runs a short smoke test to ensure the container starts.
- Optionally logs into Docker Hub and pushes the image.


## Security & safety notes


- Do not store credentials in the repository. Use Jenkins credentials.
- The Docker `Push Image` stage is disabled unless you enable `PUSH_DOCKER=true` and provide credentials.
- Keep the pipeline agent trusted — building containers or running untrusted code on shared agents can be risky. Use dedicated build agents for CI.


## Customization


- Replace `<your-dockerhub-namespace>` in `Jenkinsfile` with your Docker Hub username or organization.
- Change Java version in `pom.xml` if you require another release.
- Add integration tests in a separate stage to avoid slowing down the fast unit-test cycle.