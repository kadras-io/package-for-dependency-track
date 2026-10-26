load("@ytt:data", "data")
load("@ytt:struct", "struct")

# Shared constants and helpers for the Dependency Track templates and overlays.
#
# Dependency Track 5 is configured via properties (see `app-config.yml`) which reference
# secrets by file path. The paths below are therefore used both when rendering the
# `application.properties` file and when mounting the volumes into the API Server.

# The CloudNativePG cluster backing Dependency Track. When no bootstrap configuration
# is provided, the operator creates a database named `app`, owned by a user named `app`,
# and stores its credentials in a Secret named after the cluster with an `-app` suffix.
postgresql_cluster_name = "postgresql-dependency-track"
postgresql_secret_name = postgresql_cluster_name + "-app"
_postgresql_database_name = "app"
_postgresql_service_name = postgresql_cluster_name + "-rw"

# The Deployments, and their main containers, of the two Dependency Track components.
api_server_name = "dependency-track-api-server"
frontend_name = "dependency-track-frontend"

# The port of the Services exposing the two components.
web_port = 8080

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

# The PersistentVolumeClaim holding the API Server data directory.
storage_claim_name = "dependency-track-storage"

# Container image repositories. The tag is left out when no version is configured, so that
# the version bundled with this package (see `kbld-config.yml`) is used instead.
api_server_image_repository = "docker.io/dependencytrack/apiserver"
frontend_image_repository = "docker.io/dependencytrack/frontend"

def image_reference(repository):
  if data.values.image.tag != "":
    return "{}:{}".format(repository, data.values.image.tag)
  end
  return repository
end

def labels(component):
  return {
    "app.kubernetes.io/part-of": "dependency-track",
    "app.kubernetes.io/instance": "dependency-track",
    "app.kubernetes.io/name": "dependency-track-" + component,
    "app.kubernetes.io/component": component,
  }
end

def jdbc_url():
  host = "{}.{}.svc.cluster.local".format(_postgresql_service_name, data.values.namespace)
  return "jdbc:postgresql://{}:5432/{}?reWriteBatchedInserts=true".format(host, _postgresql_database_name)
end

# The configuration maps in the values are rendered as properties, environment variables
# and PostgreSQL parameters, all strings, sorted by name. The schema accepts only scalar values.
# Starlark renders booleans as `True`/`False`, which none of them understand.
def format_map(values):
  config = struct.decode(values)
  return {name: _format_value(config[name]) for name in sorted(config.keys())}
end

def _format_value(value):
  return str(value).lower() if type(value) == "bool" else str(value)
end

# The Pods comply with the "restricted" Pod Security Standard. `runAsNonRoot` and `seccompProfile`
# are set for the whole Pod, and the containers inherit them.
# See: https://kubernetes.io/docs/concepts/security/pod-security-standards/#restricted
def pod_security_context(fs_group=None):
  security_context = {
    "runAsNonRoot": True,
    "seccompProfile": {"type": "RuntimeDefault"},
  }
  if fs_group != None:
    security_context["fsGroup"] = fs_group
  end
  return security_context
end

def container_security_context(read_only_root_filesystem=True):
  return {
    "allowPrivilegeEscalation": False,
    "capabilities": {"drop": ["ALL"]},
    "readOnlyRootFilesystem": read_only_root_filesystem,
  }
end
