provider "aws" {
	region = "us-west-2"
}

module "webserver" {
	source = "../../../modules/services/webserver"
	cluster_name = "webserver-prod"
	instance_type = "t2.micro"
	min_size = 2
	max_size = 10
}
