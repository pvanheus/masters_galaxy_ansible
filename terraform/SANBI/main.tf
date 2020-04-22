resource "openstack_compute_instance_v2" "galaxy-masters2" {
  name        = "galaxy-masters2"
  flavor_name = "m1.xlarge"
  key_pair    = "pvhebmkey"
  image_name  = "ubuntu-18.04-server"

  network {
    port = openstack_networking_port_v2.m_net_1_g_m2_port.id
  }

  network {
    port = openstack_networking_port_v2.c-net_g_m2_port.id
  }

  # provisioner "local-exec" {
  #   command = "python ~/terraform/dns/update_dns.py -a -n ${self.name} -i ${openstack_compute_floatingip_v2.nextcloud_fip.address}"
  # }

  # provisioner "local-exec" {
  #   command = "python ~/terraform/dns/update_dns.py -r -n ${self.name}"
  #   when = "destroy"
  # }  
}

output "g_m2_floatingip_address" {
  value = openstack_compute_floatingip_associate_v2.g_m2_floatingip_associate.floating_ip
}

resource "openstack_compute_keypair_v2" "pvhebmkey" {
  name = "pvhebmkey"
}

resource "openstack_compute_floatingip_associate_v2" "g_m2_floatingip_associate" {
  floating_ip = openstack_compute_floatingip_v2.g_m2_floatingip.address
  instance_id = openstack_compute_instance_v2.galaxy-masters2.id
}

resource "openstack_blockstorage_volume_v2" "g_m2_store" {
  name = "g_m2_store"
  size = 160
}

resource "openstack_compute_volume_attach_v2" "g_m2_store_attach" {
  instance_id = openstack_compute_instance_v2.galaxy-masters2.id
  volume_id = openstack_blockstorage_volume_v2.g_m2_store.id
}

resource "openstack_compute_floatingip_v2" "g_m2_floatingip" {
  pool = "public1"
}

resource "openstack_compute_secgroup_v2" "public_server_secgroup" {
  name = "public_server_secgroup"
  description = "public server security group: SSH and HTTP/S"

  # rule {
  #   from_port = 0
  #   to_port   = 0
  #   ip_protocol = "tcp"
  #   self      = true
  # }

  # rule {
  #   from_port = -1
  #   to_port = -1
  #   ip_protocol = "icmp"
  #   cidr = "0.0.0.0/0"
  # }

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_network_v2" "masters_net_1" {
  name = "masters_net_1"
}

resource "openstack_networking_subnet_v2" "masters_net_1_sn_1" {
  name       = "masters_net_1_sn_1"
  network_id = openstack_networking_network_v2.masters_net_1.id
  cidr       = "192.168.50.0/24"
  allocation_pool {
    start = "192.168.50.50"
    end = "192.168.50.100"
  }
  dns_nameservers = ["192.168.2.75", "192.168.2.8"]
  ip_version = 4
}

resource "openstack_networking_port_v2" "m_net_1_g_m2_port" {
  name               = "m_net_1_g_m2_port"
  network_id         = openstack_networking_network_v2.masters_net_1.id
  security_group_ids = [openstack_compute_secgroup_v2.public_server_secgroup.id]
  admin_state_up     = true
}

resource "openstack_networking_network_v2" "ceph-net" {
  name = "ceph-net"
}

resource "openstack_networking_subnet_v2" "ceph-net_sn_1" {
  name = "ceph-net_sn_1"
  network_id = openstack_networking_network_v2.ceph-net.id
  cidr = "192.168.254.0/24"
  no_gateway = true
  enable_dhcp = false
  ip_version = 4
}

resource "openstack_networking_port_v2" "c-net_g_m2_port" {
  name = "c-net_g_m2_port"
  network_id = openstack_networking_network_v2.ceph-net.id
  security_group_ids = [openstack_compute_secgroup_v2.public_server_secgroup.id]
  admin_state_up = true
}