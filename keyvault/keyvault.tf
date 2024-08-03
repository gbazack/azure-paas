resource "azurerm_key_vault" "cmek" {
    name                        = "${var.prefix_name}-cmek-keyvault"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    sku_name                    = "standard"
    tenant_id                   = var.tenant_id
    enabled_for_disk_encryption = true
    purge_protection_enabled    = true 
    soft_delete_retention_days  = 90

    tags                        = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }
}

resource "azurerm_key_vault_key" "cmek" {
    name         = "${var.prefix_name}-cmek-pvc"
    key_vault_id = azurerm_key_vault.cmek.id
    key_type     = "RSA"
    key_size     = 2048
    key_opts     = [
        "encrypt",
        "decrypt",
        "verify",
        "unwrapKey",
        "wrapKey",
        "sign",
    ]

    tags                        = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }

    depends_on = [ azurerm_key_vault_access_policy.cmek-user ]
}

resource "azurerm_key_vault_key" "cmek-vmdisk" {
    name         = "${var.prefix_name}-cmek-vmdisk"
    key_vault_id = azurerm_key_vault.cmek.id
    key_type     = "RSA"
    key_size     = 2048
    key_opts     = [
        "encrypt",
        "decrypt",
        "verify",
        "unwrapKey",
        "wrapKey",
        "sign",
    ]

    tags                        = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }

    depends_on = [ azurerm_key_vault_access_policy.cmek-user ]
}

resource "azurerm_key_vault_key" "cmek-etcd" {
    name         = "${var.prefix_name}-cmek-etcd"
    key_vault_id = azurerm_key_vault.cmek.id
    key_type     = "RSA"
    key_size     = 2048
    key_opts     = [
        "encrypt",
        "decrypt",
        "verify",
        "unwrapKey",
        "wrapKey",
        "sign",
    ]

    tags                        = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }

    depends_on = [ azurerm_key_vault_access_policy.cmek-user ]
}

resource "azurerm_disk_encryption_set" "cmek" {
    name                = "${var.prefix_name}-cmek-des"
    resource_group_name = var.resource_group_name
    location            = var.location
    key_vault_key_id    = azurerm_key_vault_key.cmek.id

    identity {
      type = "SystemAssigned"
    }

    tags                        = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }

    depends_on = [ azurerm_key_vault_key.cmek ]
}

resource "azurerm_disk_encryption_set" "cmek-vmdisk" {
    name                = "${var.prefix_name}-cmek-vmdes"
    resource_group_name = var.resource_group_name
    location            = var.location
    key_vault_key_id    = azurerm_key_vault_key.cmek-vmdisk.id

    identity {
      type = "SystemAssigned"
    }

    tags                        = {
      "Env"     = "${var.prefix_name}-cluster"
      "Used_by" = var.tag_used_by
      "Purpose" = var.tag_purpose
    }

    depends_on = [ azurerm_key_vault_key.cmek-vmdisk ]
}

resource "azurerm_key_vault_access_policy" "cmek-des" {
  key_vault_id    = azurerm_key_vault.cmek.id

  tenant_id       = azurerm_disk_encryption_set.cmek.identity.0.tenant_id
  object_id       = azurerm_disk_encryption_set.cmek.identity.0.principal_id

  key_permissions = [
        "Backup",
        "Create",
        "Decrypt",
        "Delete",
        "Encrypt",
        "Get",
        "Import",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Sign",
        "UnwrapKey",
        "Update",
        "Verify",
        "WrapKey",
        "Release",
        "Rotate",
        "GetRotationPolicy",
        "SetRotationPolicy",
  ]
  depends_on = [ azurerm_disk_encryption_set.cmek ]
}

resource "azurerm_key_vault_access_policy" "cmek-vmdes" {
  key_vault_id    = azurerm_key_vault.cmek.id

  tenant_id       = azurerm_disk_encryption_set.cmek-vmdisk.identity.0.tenant_id
  object_id       = azurerm_disk_encryption_set.cmek-vmdisk.identity.0.principal_id

  key_permissions = [
        "Backup",
        "Create",
        "Decrypt",
        "Delete",
        "Encrypt",
        "Get",
        "Import",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Sign",
        "UnwrapKey",
        "Update",
        "Verify",
        "WrapKey",
        "Release",
        "Rotate",
        "GetRotationPolicy",
        "SetRotationPolicy",
  ]
  depends_on = [ azurerm_disk_encryption_set.cmek-vmdisk ]
}

resource "azurerm_key_vault_access_policy" "cmek-user" {
    key_vault_id    = azurerm_key_vault.cmek.id
    tenant_id       = var.tenant_id
    object_id       = var.object_id

    key_permissions = [
        "Backup",
        "Create",
        "Decrypt",
        "Delete",
        "Encrypt",
        "Get",
        "Import",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Sign",
        "UnwrapKey",
        "Update",
        "Verify",
        "WrapKey",
        "Release",
        "Rotate",
        "GetRotationPolicy",
        "SetRotationPolicy",
    ]
    certificate_permissions = [
        "Create",
        "Delete",
        "DeleteIssuers",
        "Get",
        "GetIssuers",
        "Import",
        "List",
        "ListIssuers",
        "ManageContacts",
        "ManageIssuers",
        "Purge",
        "SetIssuers",
        "Update",
    ]
    secret_permissions = [
        "Backup",
        "Delete",
        "Get",
        "List",
        "Purge",
        "Recover",
        "Restore",
        "Set",
    ]
    depends_on = [ azurerm_key_vault.cmek ]
}

resource "azurerm_role_assignment" "cmek" {
  scope                = azurerm_key_vault.cmek.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_disk_encryption_set.cmek.identity[0].principal_id
}

resource "azurerm_role_assignment" "cmek-vmdisk" {
  scope                = azurerm_key_vault.cmek.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = azurerm_disk_encryption_set.cmek-vmdisk.identity[0].principal_id
}