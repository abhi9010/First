provider "azurerm" {
  features { }
}

module "network" {
    source = "terraform-azurerm-modules/vnet/azurerm"

    resource_group_name = "my-resource-group"
    address_space = ["10.0.0.0/16"]

    subnet_names = ["frontend", "backend", "database"]
    subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

module "frontend" {
    source = "Azure/compute/azurerm"
    resource_group_name = "my-resource-group"
    vm_name = "frontend-vm"
    location = "East US"
    size = "Standard_DS1_v2"
    admin_username = "myadmin"
  os_disk {
        storage_account_type = "Standard_LRS"
    }
    network_interface_ids = [module.network.network_interface_ids[0]]
}

module "backend" {
    source = "Azure/appservice/azurerm"
    resource_group_name = "my-resource-group"
    app_service_plan_id = module.app_service_plan.app_service_plan_id
    name = "my-backend-app"
    location = "East US"
}

module "database" {
    source = "Azure/database-for-postgresql/azurerm"
    resource_group_name = "my-resource-group"
    location = "East US"
    server_name = "my-db-server"
    sku_name = "B_Gen5_1"
    storage_mb = 5120
    backup_retention_days = 7
    geo_redundant_backup = "Disabled"
}

module "app_service_plan" {
    source = "Azure/app-service-plan/azurerm"
    resource_group_name = "my-resource-group"
    name = "my-app-service-plan"
    location = "East US"
    kind = "Linux"
    reserved = true
    maximum_elastic_worker_count = 1
    per_site_scaling = false
}

output "frontend_ip" {
    value = module.frontend.public_ip_address
}

output "backend_url" {
    value = module.backend.default_site_hostname
}

output "database_connection_string" {
    value = module.database.connection_strings[0]
}
