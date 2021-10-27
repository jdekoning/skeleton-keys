# Default config found on https://www.boundaryproject.io/docs/configuration/controller and amended

# Disable memory lock: https://www.man7.org/linux/man-pages/man2/mlock.2.html
disable_mlock = false # should be available on linux

# Controller configuration block
controller {
  # This name attr must be unique across all controller instances if running in HA mode
  name = "skeleton-key-0"
  description = "A controller for halloween!"

  # Database URL for postgres. This can be a direct "postgres://"
  # URL, or it can be "file://" to read the contents of a file to
  # supply the url, or "env://" to name an environment variable
  # that contains the URL.
  database {
    url = "postgresql://boundary:boundary@localhost:5432/boundary"
    max_open_connections = 10
  }
}

# API listener configuration block
listener "tcp" {
  # Should be the address of the NIC that the controller server will be reached on
  address = "0.0.0.0:9201"
  # The purpose of this listener block
  purpose = "api"

  tls_disable = "true"
  tls_cert_file = "/opt/boundary/boundary-controller.crt"
  tls_key_file  = "/opt/boundary/boundary-controller.key"

  # Uncomment to enable CORS for the Admin UI. Be sure to set the allowed origin(s)
  # to appropriate values.
  #cors_enabled = true
  #cors_allowed_origins = ["https://yourcorp.yourdomain.com", "serve://boundary"]
}

# TODO remove secrets
# Data-plane listener configuration block (used for worker coordination)
listener "tcp" {
  # Should be the IP of the NIC that the worker will connect on
  address = "127.0.0.1:9200"
  # The purpose of this listener
  purpose = "cluster"
}

# Root KMS configuration block: this is the root key for Boundary
# Use a production KMS such as AWS KMS in production installs
kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "sP1fnF5Xz85RrXyELHFeZg9Ad2qt4Z4bgNHVGtD6ung="
  key_id = "global_root"
}

# Worker authorization KMS
# Use a production KMS such as AWS KMS for production installs
# This key is the same key used in the worker configuration
kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_worker-auth"
}

# Recovery KMS block: configures the recovery key for Boundary
# Use a production KMS such as AWS KMS for production installs
kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "8fZBjCUfN0TzjEGLQldGY4+iE9AkOvCfjh7+p0GtRBQ="
  key_id = "global_recovery"
}
