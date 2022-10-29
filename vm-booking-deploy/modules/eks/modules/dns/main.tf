resource "aws_route53_zone" "vm_booking" {
  name = var.app_host
}

data "aws_route53_zone" "main" {
  name = "jdobc.link"
}

resource "aws_route53_record" "vm_booking_ns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_route53_zone.vm_booking.name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.vm_booking.name_servers
}
