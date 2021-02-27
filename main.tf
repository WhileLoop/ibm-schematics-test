terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "~> 1.12.0"
    }
  }
}

provider "ibm" {
  region = "us-south"
}

data "ibm_resource_group" "default_group" {
  name = "Default"
}

data "ibm_is_vpc" "default_vpc" {
  name = "us-south-default-vpc"
}

data "ibm_is_image" "ds_image" {
  name = "ibm-ubuntu-18-04-1-minimal-amd64-2"
}

data "ibm_is_subnet" "default_subnet" {
  name = "us-south-2-default-subnet"
}

resource "ibm_is_security_group" "main_security_group" {
  name = "test-sg"
  vpc  = data.ibm_is_vpc.default_vpc.id
}

resource "ibm_is_security_group_rule" "ssh_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "ftp_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 21
    port_max = 21
  }
}

resource "ibm_is_security_group_rule" "http_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "https_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "sftp_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 2222
    port_max = 2222
  }
}

resource "ibm_is_security_group_rule" "ftp_data_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = 32768
    port_max = 60999
  }
}

resource "ibm_is_security_group_rule" "outbound_security_group_rule" {
  group     = ibm_is_security_group.main_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

resource "ibm_is_instance" "test" {
  name    = "test-vm"
  image   = data.ibm_is_image.ds_image.id
  profile = "bx2-2x8"

  primary_network_interface {
    subnet = data.ibm_is_subnet.default_subnet.id
    security_groups = [ ibm_is_security_group.main_security_group.id ]
  }

  vpc  = data.ibm_is_vpc.default_vpc.id
  zone = "us-south-2"
  keys = []
}
