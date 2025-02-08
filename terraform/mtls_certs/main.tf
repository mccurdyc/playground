# https://blog.bryantluk.com/post/2018/11/26/terraform-self-signed-tls/
terraform {
  required_version = "~> 1.0"
  required_providers {
    tls = {
      version = "~> 3.1"
    }
  }
}

provider "tls" {}

resource "tls_private_key" "ca" {
  algorithm = "ECDSA"
}

resource "local_file" "ca_private_key_pem" {
  content  = tls_private_key.ca.private_key_pem
  filename = "${path.module}/certs/ca.key"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm     = "ECDSA"
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name         = "Self Signed CA"
    organization        = "Self Signed"
    organizational_unit = "Foo"
    street_address      = ["PO Box 12345"]
    locality            = "San Fransisco"
    province            = "CA"
    country             = "USA"
    postal_code         = "94107"
  }

  validity_period_hours = 175200 # 20 years

  allowed_uses = [
    "signing",
    "key_encipherment",
    "server_auth",
    "client_auth"
  ]
}

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${path.module}/certs/ca_cert.pem"
}

resource "tls_private_key" "server" {
  algorithm = "ECDSA"
}

resource "local_file" "server_private_key_pem" {
  content  = tls_private_key.server.private_key_pem
  filename = "${path.module}/certs/server.key"
}


resource "tls_cert_request" "server" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.server.private_key_pem

  dns_names = ["example.com", "localhost"]

  subject {
    common_name         = "example.com"
    organization        = "Example Self Signed"
    country             = "US"
    organizational_unit = "example.com"
  }
}

resource "local_file" "server_csr_pem" {
  content  = tls_cert_request.server.cert_request_pem
  filename = "${path.module}/certs/server.csr"
}

resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 175200 # 20 years

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

resource "local_file" "server_cert_pem" {
  content  = tls_locally_signed_cert.server.cert_pem
  filename = "${path.module}/certs/server_cert.pem"
}

##########################################################################
# Client
##########################################################################

resource "tls_private_key" "client" {
  algorithm = "ECDSA"
}

resource "local_file" "client_private_key_pem" {
  content  = tls_private_key.client.private_key_pem
  filename = "${path.module}/certs/client.key"
}


resource "tls_cert_request" "client" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.client.private_key_pem

  dns_names = ["example.com", "localhost"]

  subject {
    common_name         = "example.com"
    organization        = "Example Self Signed"
    country             = "US"
    organizational_unit = "example.com"
  }
}

resource "local_file" "client_csr_pem" {
  content  = tls_cert_request.client.cert_request_pem
  filename = "${path.module}/certs/client.csr"
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_key_algorithm   = "ECDSA"
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 175200 # 20 years

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "client_auth",
  ]
}

resource "local_file" "client_cert_pem" {
  content  = tls_locally_signed_cert.client.cert_pem
  filename = "${path.module}/certs/client_cert.pem"
}
