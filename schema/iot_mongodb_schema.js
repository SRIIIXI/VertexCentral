// IoT Data Model - MongoDB Schema Creation Script
// Generated from C header file model definitions

// Use IoT database
use('iot_platform');

// ============================================================================
// ENTERPRISES COLLECTION
// ============================================================================
db.createCollection("enterprises", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["enterprise_id", "enterprise_name"],
      properties: {
        enterprise_id: { bsonType: "string", maxLength: 64 },
        enterprise_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 255 },
        contact_mo: { bsonType: "string", maxLength: 31 },
        contact_email: { bsonType: "string", maxLength: 256 },
        contact_first_name: { bsonType: "string", maxLength: 64 },
        contact_last_name: { bsonType: "string", maxLength: 64 },
        unix_timestamp_created: { bsonType: "long" },
        whitelabel_text: { bsonType: "string", maxLength: 1024 },
        address_line1: { bsonType: "string", maxLength: 256 },
        address_line2: { bsonType: "string", maxLength: 256 },
        address_city: { bsonType: "string", maxLength: 32 },
        address_state: { bsonType: "string", maxLength: 32 },
        address_country: { bsonType: "string", maxLength: 32 },
        address_pin_code: { bsonType: "string", maxLength: 16 },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// USERS COLLECTION
// ============================================================================
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "enterprise_id", "user_name", "email"],
      properties: {
        user_id: { bsonType: "string", maxLength: 64 },
        enterprise_id: { bsonType: "string", maxLength: 64 },
        user_name: { bsonType: "string", maxLength: 64 },
        email: { bsonType: "string", maxLength: 255 },
        contact_mo: { bsonType: "string", maxLength: 31 },
        first_name: { bsonType: "string", maxLength: 64 },
        last_name: { bsonType: "string", maxLength: 64 },
        password_hash: { bsonType: "string", maxLength: 256 },
        password_salt: { bsonType: "string", maxLength: 256 },
        unix_timestamp_last_login: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// CLUSTERS COLLECTION
// ============================================================================
db.createCollection("clusters", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["cluster_id", "cluster_name", "enterprise_id"],
      properties: {
        cluster_id: { bsonType: "string", maxLength: 64 },
        cluster_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        enterprise_id: { bsonType: "string", maxLength: 64 },
        cluster_count: { bsonType: "int" },
        sites: {
          bsonType: "array",
          maxItems: 256,
          items: {
            bsonType: "object",
            properties: {
              site_id: { bsonType: "string", maxLength: 64 },
              site_name: { bsonType: "string", maxLength: 64 },
              description: { bsonType: "string", maxLength: 256 },
              site_type: { enum: ["I", "O"] }, // Indoor/Outdoor
              site_level_count: { bsonType: "int" },
              levels: {
                bsonType: "array",
                maxItems: 256,
                items: {
                  bsonType: "object",
                  properties: {
                    level_id: { bsonType: "string", maxLength: 64 },
                    level_name: { bsonType: "string", maxLength: 64 },
                    description: { bsonType: "string", maxLength: 256 },
                    level_number: { bsonType: "int" },
                    bounds: {
                      bsonType: "object",
                      properties: {
                        area_id: { bsonType: "string", maxLength: 64 },
                        area_name: { bsonType: "string", maxLength: 64 },
                        description: { bsonType: "string", maxLength: 256 },
                        area_points: {
                          bsonType: "array",
                          maxItems: 4096,
                          items: {
                            bsonType: "object",
                            properties: {
                              latitude: { bsonType: "double" },
                              longitude: { bsonType: "double" },
                              altitude: { bsonType: "double" }
                            }
                          }
                        },
                        area_points_count: { bsonType: "int" },
                        is_active: { bsonType: "bool" },
                        is_system: { bsonType: "bool" }
                      }
                    },
                    zones: {
                      bsonType: "array",
                      maxItems: 1024,
                      items: {
                        bsonType: "object",
                        properties: {
                          zone_id: { bsonType: "string", maxLength: 64 },
                          zone_name: { bsonType: "string", maxLength: 64 },
                          description: { bsonType: "string", maxLength: 256 },
                          zone_points: {
                            bsonType: "array",
                            maxItems: 4096,
                            items: {
                              bsonType: "object",
                              properties: {
                                latitude: { bsonType: "double" },
                                longitude: { bsonType: "double" },
                                altitude: { bsonType: "double" }
                              }
                            }
                          },
                          zone_points_count: { bsonType: "int" },
                          is_active: { bsonType: "bool" },
                          is_system: { bsonType: "bool" }
                        }
                      }
                    },
                    zones_count: { bsonType: "int" },
                    is_active: { bsonType: "bool" },
                    is_system: { bsonType: "bool" }
                  }
                }
              },
              is_master_site: { bsonType: "bool" },
              is_active: { bsonType: "bool" },
              is_system: { bsonType: "bool" }
            }
          }
        },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// DEVICES COLLECTION
// ============================================================================
db.createCollection("devices", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["device_id", "device_name"],
      properties: {
        device_id: { bsonType: "string", maxLength: 64 },
        device_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        serial_no: { bsonType: "string", maxLength: 64 },
        hardware_id: { bsonType: "string", maxLength: 64 },
        firmware_version: { bsonType: "string", maxLength: 64 },
        model: { bsonType: "string", maxLength: 64 },
        manufacturer: { bsonType: "string", maxLength: 64 },
        device_type: { bsonType: "int", minimum: 0, maximum: 5 },
        device_sub_type: { bsonType: "int", minimum: 0, maximum: 5 },
        device_inventory_life_cycle: { bsonType: "int", minimum: 0, maximum: 4 },
        is_active: { bsonType: "bool" },
        is_connected: { bsonType: "bool" },
        is_configured: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// ASSETS COLLECTION
// ============================================================================
db.createCollection("assets", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["asset_id", "asset_name"],
      properties: {
        asset_id: { bsonType: "string", maxLength: 64 },
        asset_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        serial_no: { bsonType: "string", maxLength: 64 },
        hardware_id: { bsonType: "string", maxLength: 64 },
        firmware_version: { bsonType: "string", maxLength: 64 },
        model: { bsonType: "string", maxLength: 64 },
        manufacturer: { bsonType: "string", maxLength: 64 },
        category_id: { bsonType: "string", maxLength: 64 },
        subcategory_id: { bsonType: "string", maxLength: 64 },
        site_id: { bsonType: "string", maxLength: 64 },
        level_id: { bsonType: "string", maxLength: 64 },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// ASSET_SENSOR_MAPPINGS COLLECTION
// ============================================================================
db.createCollection("asset_sensor_mappings", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["asset_sensor_mapping_id", "asset_id"],
      properties: {
        asset_sensor_mapping_id: { bsonType: "string", maxLength: 64 },
        asset_id: { bsonType: "string", maxLength: 64 },
        sensor_list: {
          bsonType: "array",
          maxItems: 32,
          items: { bsonType: "string", maxLength: 64 } // Device IDs
        },
        sensor_count: { bsonType: "int" },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_updated: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// DEVICE_HIERARCHIES COLLECTION
// ============================================================================
db.createCollection("device_hierarchies", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["device_hierarchy_id", "parent_device_id", "child_device_id"],
      properties: {
        device_hierarchy_id: { bsonType: "string", maxLength: 64 },
        device_hierarchy_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        parent_device_id: { bsonType: "string", maxLength: 64 },
        child_device_id: { bsonType: "string", maxLength: 64 },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_updated: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// DEVICE_PERMISSIONS COLLECTION
// ============================================================================
db.createCollection("device_permissions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["device_permission_id", "device_id", "user_id"],
      properties: {
        device_permission_id: { bsonType: "string", maxLength: 64 },
        device_permission_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        device_id: { bsonType: "string", maxLength: 64 },
        user_id: { bsonType: "string", maxLength: 64 },
        permission_type: { bsonType: "int", minimum: 0, maximum: 5 },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_updated: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// DEVICE_ATTRIBUTES COLLECTION
// ============================================================================
db.createCollection("device_attributes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["device_attribute_id", "device_id"],
      properties: {
        device_attribute_id: { bsonType: "string", maxLength: 64 },
        device_attribute_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        device_id: { bsonType: "string", maxLength: 64 },
        attribute_type: { enum: ["S", "N", "B", "L"] },
        value_string: { bsonType: "string", maxLength: 256 },
        value_number: { bsonType: "double" },
        value_boolean: { bsonType: "bool" },
        value_location: {
          bsonType: "object",
          properties: {
            latitude: { bsonType: "double" },
            longitude: { bsonType: "double" },
            altitude: { bsonType: "double" }
          }
        },
        unit: { bsonType: "string", maxLength: 32 },
        accuracy: { bsonType: "double" },
        precision: { bsonType: "double" },
        range_min: { bsonType: "double" },
        range_max: { bsonType: "double" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// APPLICATIONS COLLECTION
// ============================================================================
db.createCollection("applications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["application_id", "application_name"],
      properties: {
        application_id: { bsonType: "string", maxLength: 64 },
        application_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        version: { bsonType: "string", maxLength: 64 },
        vendor: { bsonType: "string", maxLength: 64 },
        category_id: { bsonType: "string", maxLength: 64 },
        subcategory_id: { bsonType: "string", maxLength: 64 },
        features: {
          bsonType: "array",
          maxItems: 1024,
          items: {
            bsonType: "object",
            properties: {
              feature_id: { bsonType: "string", maxLength: 64 },
              feature_name: { bsonType: "string", maxLength: 64 },
              description: { bsonType: "string", maxLength: 256 },
              application_id: { bsonType: "string", maxLength: 64 },
              unix_timestamp_created: { bsonType: "long" },
              unix_timestamp_updated: { bsonType: "long" },
              is_active: { bsonType: "bool" },
              is_system: { bsonType: "bool" }
            }
          }
        },
        features_count: { bsonType: "int" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// RULES COLLECTION
// ============================================================================
db.createCollection("rules", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["rule_id", "rule_name"],
      properties: {
        rule_id: { bsonType: "string", maxLength: 64 },
        rule_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        rule_type: { enum: ["A", "C", "E"] }, // Automation/Condition/Event
        rule_expression: { bsonType: "string", maxLength: 1024 },
        priority: { bsonType: "int" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// APPLICATION_PERMISSIONS COLLECTION
// ============================================================================
db.createCollection("application_permissions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["application_permission_id", "application_id", "user_id"],
      properties: {
        application_permission_id: { bsonType: "string", maxLength: 64 },
        application_id: { bsonType: "string", maxLength: 64 },
        user_id: { bsonType: "string", maxLength: 64 },
        permission_type: { bsonType: "int", minimum: 0, maximum: 5 },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_updated: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// ROLES COLLECTION
// ============================================================================
db.createCollection("roles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["role_id", "role_name"],
      properties: {
        role_id: { bsonType: "string", maxLength: 64 },
        role_name: { bsonType: "string", maxLength: 64 },
        description: { bsonType: "string", maxLength: 256 },
        permissions: {
          bsonType: "array",
          maxItems: 1024,
          items: { bsonType: "string", maxLength: 64 } // Permission IDs
        },
        permissions_count: { bsonType: "int" },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_updated: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// USER_ROLE_MAPPINGS COLLECTION
// ============================================================================
db.createCollection("user_role_mappings", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_role_mapping_id", "user_id", "role_id"],
      properties: {
        user_role_mapping_id: { bsonType: "string", maxLength: 64 },
        user_id: { bsonType: "string", maxLength: 64 },
        role_id: { bsonType: "string", maxLength: 64 },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_updated: { bsonType: "long" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// LOGIN_SESSIONS COLLECTION
// ============================================================================
db.createCollection("login_sessions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["session_id", "user_id"],
      properties: {
        session_id: { bsonType: "string", maxLength: 64 },
        user_id: { bsonType: "string", maxLength: 64 },
        unix_timestamp_created: { bsonType: "long" },
        unix_timestamp_expires: { bsonType: "long" },
        location: {
          bsonType: "object",
          properties: {
            latitude: { bsonType: "double" },
            longitude: { bsonType: "double" },
            altitude: { bsonType: "double" }
          }
        },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// TELEMETRY_DATA COLLECTION
// ============================================================================
db.createCollection("telemetry_data", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["telemetry_data_id", "device_id", "unix_timestamp"],
      properties: {
        telemetry_data_id: { bsonType: "string", maxLength: 64 },
        device_id: { bsonType: "string", maxLength: 64 },
        unix_timestamp: { bsonType: "long" },
        data_type: { enum: ["S", "N", "B", "L"] },
        value_string: { bsonType: "string", maxLength: 256 },
        value_number: { bsonType: "double" },
        value_boolean: { bsonType: "bool" },
        value_location: {
          bsonType: "object",
          properties: {
            latitude: { bsonType: "double" },
            longitude: { bsonType: "double" },
            altitude: { bsonType: "double" }
          }
        },
        unit: { bsonType: "string", maxLength: 32 },
        accuracy: { bsonType: "double" },
        precision: { bsonType: "double" },
        range_min: { bsonType: "double" },
        range_max: { bsonType: "double" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// ALARMS COLLECTION
// ============================================================================
db.createCollection("alarms", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["alarm_id", "device_id", "unix_timestamp"],
      properties: {
        alarm_id: { bsonType: "string", maxLength: 64 },
        device_id: { bsonType: "string", maxLength: 64 },
        unix_timestamp: { bsonType: "long" },
        alarm_type: { enum: ["C", "W", "I"] }, // Critical/Warning/Info
        description: { bsonType: "string", maxLength: 256 },
        related_telemetry: {
          bsonType: "array",
          items: { bsonType: "string", maxLength: 64 } // Telemetry data IDs
        },
        related_telemetry_count: { bsonType: "int" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// NOTIFICATIONS COLLECTION
// ============================================================================
db.createCollection("notifications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["notification_id", "user_id", "unix_timestamp"],
      properties: {
        notification_id: { bsonType: "string", maxLength: 64 },
        user_id: { bsonType: "string", maxLength: 64 },
        unix_timestamp: { bsonType: "long" },
        notification_type: { enum: ["A", "T", "E"] }, // Alarm/Telemetry/Event
        description: { bsonType: "string", maxLength: 256 },
        is_read: { bsonType: "bool" },
        is_active: { bsonType: "bool" },
        is_system: { bsonType: "bool" }
      }
    }
  }
});

// ============================================================================
// CREATE INDEXES FOR OPTIMAL PERFORMANCE
// ============================================================================

print("Creating indexes for optimal query performance...");

// Enterprise indexes
db.enterprises.createIndex({ "enterprise_id": 1 }, { unique: true });
db.enterprises.createIndex({ "is_active": 1 });

// User indexes
db.users.createIndex({ "user_id": 1 }, { unique: true });
db.users.createIndex({ "enterprise_id": 1 });
db.users.createIndex({ "email": 1 }, { unique: true });
db.users.createIndex({ "user_name": 1 });
db.users.createIndex({ "is_active": 1 });

// Cluster indexes
db.clusters.createIndex({ "cluster_id": 1 }, { unique: true });
db.clusters.createIndex({ "enterprise_id": 1 });
db.clusters.createIndex({ "is_active": 1 });

// Device indexes
db.devices.createIndex({ "device_id": 1 }, { unique: true });
db.devices.createIndex({ "device_type": 1 });
db.devices.createIndex({ "device_sub_type": 1 });
db.devices.createIndex({ "manufacturer": 1 });
db.devices.createIndex({ "is_active": 1, "is_connected": 1 });
db.devices.createIndex({ "serial_no": 1 });

// Asset indexes
db.assets.createIndex({ "asset_id": 1 }, { unique: true });
db.assets.createIndex({ "site_id": 1 });
db.assets.createIndex({ "level_id": 1 });
db.assets.createIndex({ "category_id": 1, "subcategory_id": 1 });
db.assets.createIndex({ "is_active": 1 });

// Asset sensor mapping indexes
db.asset_sensor_mappings.createIndex({ "asset_sensor_mapping_id": 1 }, { unique: true });
db.asset_sensor_mappings.createIndex({ "asset_id": 1 });
db.asset_sensor_mappings.createIndex({ "sensor_list": 1 });
db.asset_sensor_mappings.createIndex({ "is_active": 1 });

// Device hierarchy indexes
db.device_hierarchies.createIndex({ "device_hierarchy_id": 1 }, { unique: true });
db.device_hierarchies.createIndex({ "parent_device_id": 1 });
db.device_hierarchies.createIndex({ "child_device_id": 1 });
db.device_hierarchies.createIndex({ "is_active": 1 });

// Device permission indexes
db.device_permissions.createIndex({ "device_permission_id": 1 }, { unique: true });
db.device_permissions.createIndex({ "device_id": 1, "user_id": 1 });
db.device_permissions.createIndex({ "user_id": 1 });
db.device_permissions.createIndex({ "is_active": 1 });

// Device attribute indexes
db.device_attributes.createIndex({ "device_attribute_id": 1 }, { unique: true });
db.device_attributes.createIndex({ "device_id": 1 });
db.device_attributes.createIndex({ "attribute_type": 1 });
db.device_attributes.createIndex({ "is_active": 1 });

// Application indexes
db.applications.createIndex({ "application_id": 1 }, { unique: true });
db.applications.createIndex({ "category_id": 1, "subcategory_id": 1 });
db.applications.createIndex({ "vendor": 1 });
db.applications.createIndex({ "is_active": 1 });

// Rules indexes
db.rules.createIndex({ "rule_id": 1 }, { unique: true });
db.rules.createIndex({ "rule_type": 1 });
db.rules.createIndex({ "priority": 1 });
db.rules.createIndex({ "is_active": 1 });

// Application permission indexes
db.application_permissions.createIndex({ "application_permission_id": 1 }, { unique: true });
db.application_permissions.createIndex({ "application_id": 1, "user_id": 1 });
db.application_permissions.createIndex({ "user_id": 1 });
db.application_permissions.createIndex({ "is_active": 1 });

// Role indexes
db.roles.createIndex({ "role_id": 1 }, { unique: true });
db.roles.createIndex({ "is_active": 1 });

// User role mapping indexes
db.user_role_mappings.createIndex({ "user_role_mapping_id": 1 }, { unique: true });
db.user_role_mappings.createIndex({ "user_id": 1 });
db.user_role_mappings.createIndex({ "role_id": 1 });
db.user_role_mappings.createIndex({ "is_active": 1 });

// Login session indexes
db.login_sessions.createIndex({ "session_id": 1 }, { unique: true });
db.login_sessions.createIndex({ "user_id": 1 });
db.login_sessions.createIndex({ "unix_timestamp_expires": 1 });
db.login_sessions.createIndex({ "is_active": 1 });

// Telemetry data indexes (Critical for IoT performance)
db.telemetry_data.createIndex({ "telemetry_data_id": 1 }, { unique: true });
db.telemetry_data.createIndex({ "device_id": 1, "unix_timestamp": -1 });
db.telemetry_data.createIndex({ "unix_timestamp": -1 });
db.telemetry_data.createIndex({ "data_type": 1 });
db.telemetry_data.createIndex({ "is_active": 1 });
// Compound index for time-series queries
db.telemetry_data.createIndex({ "device_id": 1, "data_type": 1, "unix_timestamp": -1 });

// Alarm indexes
db.alarms.createIndex({ "alarm_id": 1 }, { unique: true });
db.alarms.createIndex({ "device_id": 1, "unix_timestamp": -1 });
db.alarms.createIndex({ "alarm_type": 1, "unix_timestamp": -1 });
