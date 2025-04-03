# Route 53 Zone Data - Fetch the existing hosted zone
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# Create A records for each subdomain dynamically
resource "aws_route53_record" "webapp_ec2" {
  #   for_each = toset(var.subdomains) # Loop through each subdomain

  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name # Create a subdomain (e.g., learning.domain.software)
  type    = "A"
  # ttl     = 300
  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
  // records = [aws_instance.webapp_ec2.public_ip] # Pointing to the EC2 instance's public IP
}
