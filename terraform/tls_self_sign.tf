# ---------------------------------------------------------------------
# Generate self-signed certificate and private key for HTTPS
# ---------------------------------------------------------------------

# 1. Private key (2048-bit RSA)
resource "tls_private_key" "alb" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# 2. Self-signed certificate valid for 1 year
resource "tls_self_signed_cert" "alb" {
  private_key_pem = tls_private_key.alb.private_key_pem
  validity_period_hours = 8760 # 1 year

  subject {
    common_name  = "${var.project}.local"
    organization = "Example Org"
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

# 3. Import into AWS ACM
resource "aws_acm_certificate" "self_signed" {
  private_key       = tls_private_key.alb.private_key_pem
  certificate_body  = tls_self_signed_cert.alb.cert_pem
  certificate_chain = tls_self_signed_cert.alb.cert_pem

  tags = merge(var.tags, { Name = "${var.project}-self-signed-cert" })
}

output "self_signed_cert_arn" {
  description = "ARN of imported self-signed ACM certificate"
  value       = aws_acm_certificate.self_signed.arn
}
