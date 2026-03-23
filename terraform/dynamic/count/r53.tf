resource "aws_route53_record" "www" {
  count   = 5
  zone_id = var.zone_id
  name    = "${var.instances[count.index]}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.Roboshop[count.index].private_ip]
}