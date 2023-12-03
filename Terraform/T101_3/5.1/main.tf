resource "random_password" "mypw" {
  length           = 16
  special          = true
  override_special = "!#$%"
}
