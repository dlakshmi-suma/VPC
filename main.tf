resource "ibm_is_vpc" "vpc2" {
  name = "vpc2"
  resource_group=var.resource_group

}

resource "ibm_is_subnet" "subnet4" {
  name                     = "subnet4"
  vpc                      = ibm_is_vpc.vpc2.id
  zone                     = "us-south-1"
  total_ipv4_address_count = 256
  resource_group=var.resource_group
  # public_gateway = true
}
resource "ibm_is_public_gateway" "gateway1" {
  name = "gateway1"
  vpc  = ibm_is_vpc.vpc2.id
  zone = "us-south-1"
  resource_group=var.resource_group
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet_public_gateway_attachment" "subatt1" {
  subnet                = ibm_is_subnet.subnet4.id
  public_gateway         = ibm_is_public_gateway.gateway1.id
}

data "ibm_container_vpc_cluster" "cluster" {
  name  = "test-cluster1"
  # depends_on = [ ibm_container_vpc_cluster.cluster ]
  
}
locals {
  value1= data.ibm_container_vpc_cluster.cluster.workers
  # depends_on = [ data.ibm_container_vpc_cluster.cluster ]
  
}





resource "ibm_container_vpc_cluster" "cluster5" {
  name              = "test-cluster1"
  vpc_id            = ibm_is_vpc.vpc2.id
  flavor            = "bx2.4x16"
  worker_count      = 2
  resource_group_id=var.resource_group_id
  kube_version      = "1.27.2"  
  update_all_workers     = true
  wait_for_worker_update = true
  depends_on = [ ibm_is_subnet.subnet4]
  # data.ibm_container_vpc_cluster.cluster ]
  zones {
    subnet_id = ibm_is_subnet.subnet4.id
    name      = "us-south-1"
    
  }
}




#To fetch information about the vpc cluster
data "ibm_container_vpc_cluster" "cluster1" {
  name  = "test-cluster1"
  depends_on = [ ibm_container_vpc_cluster.cluster5 ]
  
}
# Print the id's of the workers
locals  {
  value2 = data.ibm_container_vpc_cluster.cluster1.workers
  # depends_on = [ data.ibm_container_vpc_cluster.cluster1 ]
  
}

locals {
  a=local.value1!=local.value2?"Please change the ips in the bluefringe":"The ips are upto date"
}

output "old_ids" {
  value = local.value1
  
}
output "new_ids" {
  value=local.value2
  
}

output "Alert" {
 value = local.a
  
}


