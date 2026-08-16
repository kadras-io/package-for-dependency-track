# Shared constants for the Dependency Track manifests.
#
# Dependency Track 5 is configured via properties (see `app-config.yml`) which reference
# secrets by file path. The paths below are therefore used both when rendering the
# `application.properties` file and when mounting the volumes into the API Server.

# The CloudNativePG cluster backing Dependency Track. When no bootstrap configuration
# is provided, the operator creates a database named `app`, owned by a user named `app`,
# and stores its credentials in a Secret named after the cluster with an `-app` suffix.
postgresql_cluster_name = "postgresql-dependency-track"
postgresql_database_name = "app"
postgresql_secret_name = postgresql_cluster_name + "-app"
postgresql_service_name = postgresql_cluster_name + "-rw"

# The working directory of the official container image. Dependency Track loads
# additional properties from `${cwd}/config/application.properties`.
config_directory = "/opt/owasp/dependency-track/config"

# The data directory, backed by a PersistentVolume. It holds the file storage used
# for BOMs and other artifacts uploaded to Dependency Track.
data_directory = "/data"

# The port exposing the management endpoints (health probes and Prometheus metrics).
# It's only reachable from within the Pod, it's not exposed via a Service.
management_port = 9000

# Mount points for the secrets consumed by the API Server.
postgresql_secret_directory = "/etc/dt/secrets/db"
kek_secret_directory = "/etc/dt/secrets/sm/database/kek"
kek_secret_name = "dependency-track-kek"
kek_secret_key = "kek"

# Container image repositories. The tag is left out when no version is configured, so that
# the version bundled with this package (see `kbld-config.yml`) is used instead.
api_server_image_repository = "docker.io/dependencytrack/apiserver"
frontend_image_repository = "docker.io/dependencytrack/frontend"

def image_reference(repository, tag):
  if tag != "":
    return "{}:{}".format(repository, tag)
  end
  return repository
end
