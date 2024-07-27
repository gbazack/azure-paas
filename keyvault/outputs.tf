output "key_vault_id" {
    description = "Identifier of Azure Key Vault"
    value       = azurerm_key_vault.cmek.id 
}

output "key_vault_key_id" {
    description = "Identifier of Azure Key Vault key"
    value       = azurerm_key_vault_key.cmek-etcd.id 
}

output "disk_encryption_set_id" {
    description = "The ID of the Disk Encryption Set"
    value       = azurerm_disk_encryption_set.cmek.id 
}

output "vm_disk_encryption_set_id" {
    description = "The ID of the Disk Encryption Set"
    value       = azurerm_disk_encryption_set.cmek-vmdisk.id
}