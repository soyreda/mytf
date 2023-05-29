provider "aws" {
  region = "us-west-2"
}
module "webserver" {
	source = "../../../modules/services/webserver"
	cluster_name = "webservers-stage"
	instance_type = "t2.micro"
	min_size = 2
	max_size = 2
	custom_tags = {
	Owner = "team-foo"
	ManagedBy = "terraform"
}
}
