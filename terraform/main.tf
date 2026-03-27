module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                               = var.vpc_cidr
  routetable_cidr                        = var.routetable_cidr
  public_subnet_1                        = var.public_subnet_1 
  public_subnet_2                        = var.public_subnet_2
  public_subnet_map_public_ip_on_launch  = var.public_subnet_map_public_ip_on_launch
  private_subnet_1                       = var.private_subnet_1
  private_subnet_2                       = var.private_subnet_2
  private_subnet_map_public_ip_on_launch = var.private_subnet_map_public_ip_on_launch
  cidr_ipv4                              = var.cidr_ipv4

}

module "eks" {
  source = "./modules/eks"

  subnet_public1_id                      = module.vpc.public_subnet1_id
  subnet_public2_id                      = module.vpc.public_subnet2_id
  subnet_private1_id                     = module.vpc.private_subnet1_id
  subnet_private2_id                     = module.vpc.private_subnet2_id
}
    