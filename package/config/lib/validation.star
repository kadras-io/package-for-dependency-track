load("@ytt:regexp", "regexp")

# Validation helpers used by the values schema, and by the templates to interpret the values they validate.
# They must not depend on data values, since they run while the schema is evaluated.

_dns_label = "[a-z0-9]([-a-z0-9]*[a-z0-9])?"

def is_dns_label(value):
  return len(value) <= 63 and regexp.match("^" + _dns_label + "$", value)
end

def is_dns_subdomain(value):
  return len(value) <= 253 and regexp.match("^" + _dns_label + "(\\." + _dns_label + ")*$", value)
end

# A plain HTTP URL, optionally with credentials and a port, like `http://user:password@proxy.kadras.io:3128`.
def is_proxy_url(value):
  return regexp.match("^http://[^\\s/]+/?$", value)
end

# A map whose values are strings, numbers or booleans, as the configuration maps rendered as properties,
# environment variables and PostgreSQL parameters. Values of type `any` are YAML fragments here.
def is_flat_map(value):
  return type(value) == "yamlfragment" and all([type(value[key]) in ["string", "int", "float", "bool"] for key in value])
end

access_modes = ["ReadWriteOnce", "ReadWriteMany", "ReadOnlyMany", "ReadWriteOncePod"]
