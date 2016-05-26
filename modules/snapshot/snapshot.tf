resource "aws_ami_from_instance" "snapshot" {
    name = "ami-snapshot"
    source_instance_id = "${var.instance_id}"
}