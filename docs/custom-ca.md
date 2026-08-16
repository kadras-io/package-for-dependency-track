# Trusting a Custom CA

The Java runtime bundled in the Dependency Track container image trusts only well-known public certificate authorities, and it doesn't read the operating system trust store. Connections to endpoints whose TLS certificates are signed by an internal or private CA fail with a `PKIX path building failed` error.

Common scenarios where this happens:

* an intercepting TLS proxy sits between Dependency Track and external services;
* the OIDC provider or the LDAP server uses a privately signed certificate;
* an internal mirror of a vulnerability data source is behind a privately signed certificate.

Provide the PEM-encoded certificate for your CA, and the package imports it into the Java truststore used by the API Server.

```yaml
ca_cert_data: |
  -----BEGIN CERTIFICATE-----
  MIIFZjCCA06gAwIBAgIRAOSy...
  -----END CERTIFICATE-----
```

You can concatenate more than one certificate in the same value. Each one is imported separately.

Under the hood, an init container copies the default Java truststore into a volume, imports the certificates into the copy with `keytool`, and the API Server container mounts the result over the original truststore. Changing `ca_cert_data` triggers a rollout of the API Server.

For more information, check the Dependency Track documentation for [configuring internal CA trust](https://dependencytrack.github.io/docs/next/guides/administration/configuring-internal-ca/).
