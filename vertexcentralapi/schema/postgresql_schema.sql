-- IoT Data Model - PostgreSQL Schema Creation Script (Pascal Case with Double Quotes)
-- Converted from snake_case to PascalCase with proper PostgreSQL quoting

-- Create database (run this separately if needed)
-- CREATE DATABASE "IotPlatform";
-- \c "IotPlatform";

-- Enable PostGIS extension for geographic data (if needed)
-- CREATE EXTENSION IF NOT EXISTS postgis;

-- Create custom data types for enums
CREATE TYPE "SiteTypeEnum" AS ENUM ('I', 'O'); -- Indoor, Outdoor
CREATE TYPE "AlarmTypeEnum" AS ENUM ('C', 'W', 'I'); -- Critical, Warning, Info
CREATE TYPE "NotificationTypeEnum" AS ENUM ('A', 'T', 'E'); -- Alarm, Telemetry, Event
CREATE TYPE "TelemetryDataTypeEnum" AS ENUM ('S', 'N', 'B', 'L'); -- String, Number, Boolean, Location
CREATE TYPE "PermissionTypeEnum" AS ENUM ('READ', 'WRITE', 'EXECUTE', 'DELETE', 'ADMIN', 'CUSTOM');
CREATE TYPE "DeviceTypeEnum" AS ENUM ('SENSOR', 'ACTUATOR', 'CONTROLLER', 'GATEWAY', 'VIRTUAL', 'OTHER');
CREATE TYPE "DeviceSubTypeEnum" AS ENUM ('TEMPERATURE_SENSOR', 'HUMIDITY_SENSOR', 'PRESSURE_SENSOR', 'LIGHT_SENSOR', 'MOTION_SENSOR', 'OTHER');
CREATE TYPE "DeviceLifeCycleEnum" AS ENUM ('NEW', 'IN_USE', 'DECOMMISSIONED', 'RETIRED', 'OTHER');
CREATE TYPE "DeviceAttributeTypeEnum" AS ENUM ('S', 'N', 'B', 'L'); -- String, Number, Boolean, Location
CREATE TYPE "RuleTypeEnum" AS ENUM ('A', 'C', 'E'); -- Automation, Condition, Event

-- Create composite type for coordinates
CREATE TYPE "CoordinateType" AS (
    "Latitude" DOUBLE PRECISION,
    "Longitude" DOUBLE PRECISION,
    "Altitude" DOUBLE PRECISION
);

-- ============================================================================
-- ENTERPRISES TABLE
-- ============================================================================
CREATE TABLE "Enterprises" (
    "EnterpriseId" VARCHAR(64) PRIMARY KEY,
    "EnterpriseName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(255),
    "ContactMo" VARCHAR(31),
    "ContactEmail" VARCHAR(256),
    "ContactFirstName" VARCHAR(64),
    "ContactLastName" VARCHAR(64),
    "UnixTimestampCreated" BIGINT,
    "WhitelabelText" VARCHAR(1024),
    "AddressLine1" VARCHAR(256),
    "AddressLine2" VARCHAR(256),
    "AddressCity" VARCHAR(32),
    "AddressState" VARCHAR(32),
    "AddressCountry" VARCHAR(32),
    "AddressPinCode" VARCHAR(16),
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE "Users" (
    "UserId" VARCHAR(64) PRIMARY KEY,
    "EnterpriseId" VARCHAR(64) NOT NULL,
    "UserName" VARCHAR(64) NOT NULL UNIQUE,
    "Email" VARCHAR(255) NOT NULL UNIQUE,
    "ContactMo" VARCHAR(31),
    "FirstName" VARCHAR(64),
    "LastName" VARCHAR(64),
    "PasswordHash" VARCHAR(256),
    "PasswordSalt" VARCHAR(256),
    "UnixTimestampLastLogin" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("EnterpriseId") REFERENCES "Enterprises"("EnterpriseId") ON DELETE CASCADE
);

-- ============================================================================
-- CLUSTERS TABLE
-- ============================================================================
CREATE TABLE "Clusters" (
    "ClusterId" VARCHAR(64) PRIMARY KEY,
    "ClusterName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "EnterpriseId" VARCHAR(64) NOT NULL,
    "ClusterCount" INTEGER DEFAULT 0,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("EnterpriseId") REFERENCES "Enterprises"("EnterpriseId") ON DELETE CASCADE
);

-- ============================================================================
-- SITES TABLE
-- ============================================================================
CREATE TABLE "Sites" (
    "SiteId" VARCHAR(64) PRIMARY KEY,
    "ClusterId" VARCHAR(64) NOT NULL,
    "SiteName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "SiteType" "SiteTypeEnum" NOT NULL,
    "SiteLevelCount" INTEGER DEFAULT 0,
    "IsMasterSite" BOOLEAN DEFAULT FALSE,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("ClusterId") REFERENCES "Clusters"("ClusterId") ON DELETE CASCADE
);

-- ============================================================================
-- AREAS TABLE
-- ============================================================================
CREATE TABLE "Areas" (
    "AreaId" VARCHAR(64) PRIMARY KEY,
    "AreaName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "AreaPoints" "CoordinateType"[],
    "AreaPointsCount" INTEGER DEFAULT 0,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "MaxAreaPoints" CHECK ("AreaPointsCount" <= 4096)
);

-- ============================================================================
-- LEVELS TABLE
-- ============================================================================
CREATE TABLE "Levels" (
    "LevelId" VARCHAR(64) PRIMARY KEY,
    "SiteId" VARCHAR(64) NOT NULL,
    "LevelName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "LevelNumber" INTEGER NOT NULL,
    "BoundsAreaId" VARCHAR(64),
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("SiteId") REFERENCES "Sites"("SiteId") ON DELETE CASCADE,
    FOREIGN KEY ("BoundsAreaId") REFERENCES "Areas"("AreaId") ON DELETE SET NULL
);

-- ============================================================================
-- ZONES TABLE
-- ============================================================================
CREATE TABLE "Zones" (
    "ZoneId" VARCHAR(64) PRIMARY KEY,
    "LevelId" VARCHAR(64) NOT NULL,
    "ZoneName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "ZonePoints" "CoordinateType"[],
    "ZonePointsCount" INTEGER DEFAULT 0,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("LevelId") REFERENCES "Levels"("LevelId") ON DELETE CASCADE,
    CONSTRAINT "MaxZonePoints" CHECK ("ZonePointsCount" <= 4096)
);

-- ============================================================================
-- DEVICES TABLE
-- ============================================================================
CREATE TABLE "Devices" (
    "DeviceId" VARCHAR(64) PRIMARY KEY,
    "DeviceName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "SerialNo" VARCHAR(64),
    "HardwareId" VARCHAR(64),
    "FirmwareVersion" VARCHAR(64),
    "Model" VARCHAR(64),
    "Manufacturer" VARCHAR(64),
    "DeviceType" "DeviceTypeEnum" NOT NULL,
    "DeviceSubType" "DeviceSubTypeEnum" NOT NULL,
    "DeviceInventoryLifeCycle" "DeviceLifeCycleEnum" NOT NULL,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsConnected" BOOLEAN DEFAULT FALSE,
    "IsConfigured" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- ASSETS TABLE
-- ============================================================================
CREATE TABLE "Assets" (
    "AssetId" VARCHAR(64) PRIMARY KEY,
    "AssetName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "SerialNo" VARCHAR(64),
    "HardwareId" VARCHAR(64),
    "FirmwareVersion" VARCHAR(64),
    "Model" VARCHAR(64),
    "Manufacturer" VARCHAR(64),
    "CategoryId" VARCHAR(64),
    "SubcategoryId" VARCHAR(64),
    "SiteId" VARCHAR(64),
    "LevelId" VARCHAR(64),
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("SiteId") REFERENCES "Sites"("SiteId") ON DELETE SET NULL,
    FOREIGN KEY ("LevelId") REFERENCES "Levels"("LevelId") ON DELETE SET NULL
);

-- ============================================================================
-- ASSET_DEVICE_MAPPINGS TABLE
-- ============================================================================
CREATE TABLE "AssetDeviceMappings" (
    "AssetDeviceMappingId" VARCHAR(64) PRIMARY KEY,
    "AssetId" VARCHAR(64) NOT NULL,
    "DeviceCount" INTEGER DEFAULT 0,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("AssetId") REFERENCES "Assets"("AssetId") ON DELETE CASCADE,
    CONSTRAINT "MaxDevicePerAsset" CHECK ("DeviceCount" <= 32)
);

-- ============================================================================
-- ASSET_DEVICES TABLE (Junction table for asset-device many-to-many relationship)
-- ============================================================================
CREATE TABLE "AssetDevices" (
    "Id" SERIAL PRIMARY KEY,
    "AssetDeviceMappingId" VARCHAR(64) NOT NULL,
    "DeviceId" VARCHAR(64) NOT NULL,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("AssetDeviceMappingId") REFERENCES "AssetDeviceMappings"("AssetDeviceMappingId") ON DELETE CASCADE,
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE,
    UNIQUE("AssetDeviceMappingId", "DeviceId")
);

-- ============================================================================
-- DEVICE_HIERARCHIES TABLE
-- ============================================================================
CREATE TABLE "DeviceHierarchies" (
    "DeviceHierarchyId" VARCHAR(64) PRIMARY KEY,
    "DeviceHierarchyName" VARCHAR(64),
    "Description" VARCHAR(256),
    "ParentDeviceId" VARCHAR(64) NOT NULL,
    "ChildDeviceId" VARCHAR(64) NOT NULL,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("ParentDeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE,
    FOREIGN KEY ("ChildDeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE,
    CONSTRAINT "NoSelfReference" CHECK ("ParentDeviceId" != "ChildDeviceId")
);

-- ============================================================================
-- DEVICE_PERMISSIONS TABLE
-- ============================================================================
CREATE TABLE "DevicePermissions" (
    "DevicePermissionId" VARCHAR(64) PRIMARY KEY,
    "DevicePermissionName" VARCHAR(64),
    "Description" VARCHAR(256),
    "DeviceId" VARCHAR(64) NOT NULL,
    "UserId" VARCHAR(64) NOT NULL,
    "PermissionType" "PermissionTypeEnum" NOT NULL,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE,
    FOREIGN KEY ("UserId") REFERENCES "Users"("UserId") ON DELETE CASCADE
);

-- ============================================================================
-- DEVICE_ATTRIBUTES TABLE
-- ============================================================================
CREATE TABLE "DeviceAttributes" (
    "DeviceAttributeId" VARCHAR(64) PRIMARY KEY,
    "DeviceAttributeName" VARCHAR(64),
    "Description" VARCHAR(256),
    "DeviceId" VARCHAR(64) NOT NULL,
    "AttributeType" "DeviceAttributeTypeEnum" NOT NULL,
    "ValueString" VARCHAR(256),
    "ValueNumber" DOUBLE PRECISION,
    "ValueBoolean" BOOLEAN,
    "ValueLocation" "CoordinateType",
    "Unit" VARCHAR(32),
    "Accuracy" DOUBLE PRECISION,
    "PrecisionVal" DOUBLE PRECISION, -- 'precision' is reserved keyword
    "RangeMin" DOUBLE PRECISION,
    "RangeMax" DOUBLE PRECISION,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE
);

-- ============================================================================
-- APPLICATIONS TABLE
-- ============================================================================
CREATE TABLE "Applications" (
    "ApplicationId" VARCHAR(64) PRIMARY KEY,
    "ApplicationName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "Version" VARCHAR(64),
    "Vendor" VARCHAR(64),
    "CategoryId" VARCHAR(64),
    "SubcategoryId" VARCHAR(64),
    "FeaturesCount" INTEGER DEFAULT 0,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "MaxFeaturesPerApp" CHECK ("FeaturesCount" <= 1024)
);

-- ============================================================================
-- FEATURES TABLE
-- ============================================================================
CREATE TABLE "Features" (
    "FeatureId" VARCHAR(64) PRIMARY KEY,
    "FeatureName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "ApplicationId" VARCHAR(64) NOT NULL,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("ApplicationId") REFERENCES "Applications"("ApplicationId") ON DELETE CASCADE
);

-- ============================================================================
-- RULES TABLE
-- ============================================================================
CREATE TABLE "Rules" (
    "RuleId" VARCHAR(64) PRIMARY KEY,
    "RuleName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "RuleType" "RuleTypeEnum" NOT NULL,
    "RuleExpression" VARCHAR(1024),
    "Priority" INTEGER DEFAULT 0,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- APPLICATION_PERMISSIONS TABLE
-- ============================================================================
CREATE TABLE "ApplicationPermissions" (
    "ApplicationPermissionId" VARCHAR(64) PRIMARY KEY,
    "ApplicationId" VARCHAR(64) NOT NULL,
    "UserId" VARCHAR(64) NOT NULL,
    "PermissionType" "PermissionTypeEnum" NOT NULL,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("ApplicationId") REFERENCES "Applications"("ApplicationId") ON DELETE CASCADE,
    FOREIGN KEY ("UserId") REFERENCES "Users"("UserId") ON DELETE CASCADE
);

-- ============================================================================
-- ROLES TABLE
-- ============================================================================
CREATE TABLE "Roles" (
    "RoleId" VARCHAR(64) PRIMARY KEY,
    "RoleName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "PermissionsCount" INTEGER DEFAULT 0,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "MaxPermissionsPerRole" CHECK ("PermissionsCount" <= 1024)
);

-- ============================================================================
-- ROLE_PERMISSIONS TABLE (Junction table for role-permission many-to-many relationship)
-- ============================================================================
CREATE TABLE "RolePermissions" (
    "Id" SERIAL PRIMARY KEY,
    "RoleId" VARCHAR(64) NOT NULL,
    "ApplicationPermissionId" VARCHAR(64) NOT NULL,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("RoleId") REFERENCES "Roles"("RoleId") ON DELETE CASCADE,
    FOREIGN KEY ("ApplicationPermissionId") REFERENCES "ApplicationPermissions"("ApplicationPermissionId") ON DELETE CASCADE,
    UNIQUE("RoleId", "ApplicationPermissionId")
);

-- ============================================================================
-- USER_ROLE_MAPPINGS TABLE
-- ============================================================================
CREATE TABLE "UserRoleMappings" (
    "UserRoleMappingId" VARCHAR(64) PRIMARY KEY,
    "UserId" VARCHAR(64) NOT NULL,
    "RoleId" VARCHAR(64) NOT NULL,
    "UnixTimestampCreated" BIGINT,
    "UnixTimestampUpdated" BIGINT,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("UserId") REFERENCES "Users"("UserId") ON DELETE CASCADE,
    FOREIGN KEY ("RoleId") REFERENCES "Roles"("RoleId") ON DELETE CASCADE
);

-- ============================================================================
-- SESSION_LOGS TABLE
-- ============================================================================
CREATE TABLE "SessionLogs" (
    "SessionId" VARCHAR(64) PRIMARY KEY,
    "UserId" VARCHAR(64) NOT NULL,
    "TimestampLoggedIn" TIMESTAMP WITH TIME ZONE,
    "TimestampLoggedOut" TIMESTAMP WITH TIME ZONE,
    "Location" "CoordinateType",
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "TimestampCreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("UserId") REFERENCES "Users"("UserId") ON DELETE CASCADE
);

-- ============================================================================
-- TELEMETRY_DATA TABLE (Partitioned by time for better performance)
-- ============================================================================
CREATE TABLE "TelemetryData" (
    "TelemetryDataId" VARCHAR(64) NOT NULL,
    "DeviceId" VARCHAR(64) NOT NULL,
    "UnixTimestamp" BIGINT NOT NULL,
    "DataType" "TelemetryDataTypeEnum" NOT NULL,
    "ValueString" VARCHAR(256),
    "ValueNumber" DOUBLE PRECISION,
    "ValueBoolean" BOOLEAN,
    "ValueLocation" "CoordinateType",
    "Unit" VARCHAR(32),
    "Accuracy" DOUBLE PRECISION,
    "PrecisionVal" DOUBLE PRECISION,
    "RangeMin" DOUBLE PRECISION,
    "RangeMax" DOUBLE PRECISION,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("TelemetryDataId", "UnixTimestamp"),
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE
) PARTITION BY RANGE ("UnixTimestamp");

-- Create monthly partitions for telemetry data (example for 2024-2025)
-- You can create more partitions as needed
CREATE TABLE "TelemetryData202401" PARTITION OF "TelemetryData"
    FOR VALUES FROM (1704067200) TO (1706745599); -- Jan 2024

CREATE TABLE "TelemetryData202402" PARTITION OF "TelemetryData"
    FOR VALUES FROM (1706745600) TO (1709251199); -- Feb 2024

-- Add more partition tables as needed...

-- ============================================================================
-- ALARMS TABLE
-- ============================================================================
CREATE TABLE "Alarms" (
    "AlarmId" VARCHAR(64) PRIMARY KEY,
    "DeviceId" VARCHAR(64) NOT NULL,
    "UnixTimestamp" BIGINT NOT NULL,
    "AlarmType" "AlarmTypeEnum" NOT NULL,
    "Description" VARCHAR(256),
    "RelatedTelemetryCount" INTEGER DEFAULT 0,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE
);

-- ============================================================================
-- ALARM_TELEMETRY_RELATIONS TABLE (Junction table for alarm-telemetry relationship)
-- ============================================================================
CREATE TABLE "AlarmTelemetryRelations" (
    "Id" SERIAL PRIMARY KEY,
    "AlarmId" VARCHAR(64) NOT NULL,
    "TelemetryDataId" VARCHAR(64) NOT NULL,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("AlarmId") REFERENCES "Alarms"("AlarmId") ON DELETE CASCADE
    -- Note: FK to "TelemetryData" is complex due to partitioning
);

-- ============================================================================
-- NOTIFICATIONS TABLE
-- ============================================================================
CREATE TABLE "Notifications" (
    "NotificationId" VARCHAR(64) PRIMARY KEY,
    "UserId" VARCHAR(64) NOT NULL,
    "UnixTimestamp" BIGINT NOT NULL,
    "NotificationType" "NotificationTypeEnum" NOT NULL,
    "Description" VARCHAR(256),
    "IsRead" BOOLEAN DEFAULT FALSE,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("UserId") REFERENCES "Users"("UserId") ON DELETE CASCADE
);

-- ============================================================================
-- CREATE INDEXES FOR OPTIMAL PERFORMANCE
-- ============================================================================

-- Enterprise indexes
CREATE INDEX "IdxEnterprisesIsDeleted" ON "Enterprises"("IsDeleted");
CREATE INDEX "IdxEnterprisesCreatedAt" ON "Enterprises"("CreatedAt");

-- User indexes
CREATE INDEX "IdxUsersEnterpriseId" ON "Users"("EnterpriseId");
CREATE INDEX "IdxUsersIsDeleted" ON "Users"("IsDeleted");
CREATE INDEX "IdxUsersEmail" ON "Users"("Email");
CREATE INDEX "IdxUsersCreatedAt" ON "Users"("CreatedAt");

-- Cluster indexes
CREATE INDEX "IdxClustersEnterpriseId" ON "Clusters"("EnterpriseId");
CREATE INDEX "IdxClustersIsDeleted" ON "Clusters"("IsDeleted");

-- Site indexes
CREATE INDEX "IdxSitesClusterId" ON "Sites"("ClusterId");
CREATE INDEX "IdxSitesSiteType" ON "Sites"("SiteType");
CREATE INDEX "IdxSitesIsDeleted" ON "Sites"("IsDeleted");

-- Level indexes
CREATE INDEX "IdxLevelsSiteId" ON "Levels"("SiteId");
CREATE INDEX "IdxLevelsLevelNumber" ON "Levels"("LevelNumber");
CREATE INDEX "IdxLevelsIsDeleted" ON "Levels"("IsDeleted");

-- Zone indexes
CREATE INDEX "IdxZonesLevelId" ON "Zones"("LevelId");
CREATE INDEX "IdxZonesIsDeleted" ON "Zones"("IsDeleted");

-- Device indexes
CREATE INDEX "IdxDevicesDeviceType" ON "Devices"("DeviceType");
CREATE INDEX "IdxDevicesDeviceSubType" ON "Devices"("DeviceSubType");
CREATE INDEX "IdxDevicesManufacturer" ON "Devices"("Manufacturer");
CREATE INDEX "IdxDevicesIsDeletedConnected" ON "Devices"("IsDeleted", "IsConnected");
CREATE INDEX "IdxDevicesSerialNo" ON "Devices"("SerialNo");
CREATE INDEX "IdxDevicesCreatedAt" ON "Devices"("CreatedAt");

-- Asset indexes
CREATE INDEX "IdxAssetsSiteId" ON "Assets"("SiteId");
CREATE INDEX "IdxAssetsLevelId" ON "Assets"("LevelId");
CREATE INDEX "IdxAssetsCategory" ON "Assets"("CategoryId", "SubcategoryId");
CREATE INDEX "IdxAssetsIsDeleted" ON "Assets"("IsDeleted");

-- Asset device mapping indexes
CREATE INDEX "IdxAssetDeviceMappingsAssetId" ON "AssetDeviceMappings"("AssetId");
CREATE INDEX "IdxAssetDeviceMappingsIsDeleted" ON "AssetDeviceMappings"("IsDeleted");
CREATE INDEX "IdxAssetDevicesDeviceId" ON "AssetDevices"("DeviceId");

-- Device hierarchy indexes
CREATE INDEX "IdxDeviceHierarchiesParentId" ON "DeviceHierarchies"("ParentDeviceId");
CREATE INDEX "IdxDeviceHierarchiesChildId" ON "DeviceHierarchies"("ChildDeviceId");
CREATE INDEX "IdxDeviceHierarchiesIsDeleted" ON "DeviceHierarchies"("IsDeleted");

-- Device permission indexes
CREATE INDEX "IdxDevicePermissionsDeviceUser" ON "DevicePermissions"("DeviceId", "UserId");
CREATE INDEX "IdxDevicePermissionsUserId" ON "DevicePermissions"("UserId");
CREATE INDEX "IdxDevicePermissionsIsDeleted" ON "DevicePermissions"("IsDeleted");

-- Device attribute indexes
CREATE INDEX "IdxDeviceAttributesDeviceId" ON "DeviceAttributes"("DeviceId");
CREATE INDEX "IdxDeviceAttributesAttributeType" ON "DeviceAttributes"("AttributeType");
CREATE INDEX "IdxDeviceAttributesIsDeleted" ON "DeviceAttributes"("IsDeleted");

-- Application indexes
CREATE INDEX "IdxApplicationsCategory" ON "Applications"("CategoryId", "SubcategoryId");
CREATE INDEX "IdxApplicationsVendor" ON "Applications"("Vendor");
CREATE INDEX "IdxApplicationsIsDeleted" ON "Applications"("IsDeleted");

-- Feature indexes
CREATE INDEX "IdxFeaturesApplicationId" ON "Features"("ApplicationId");
CREATE INDEX "IdxFeaturesIsDeleted" ON "Features"("IsDeleted");

-- Rule indexes
CREATE INDEX "IdxRulesRuleType" ON "Rules"("RuleType");
CREATE INDEX "IdxRulesPriority" ON "Rules"("Priority");
CREATE INDEX "IdxRulesIsDeleted" ON "Rules"("IsDeleted");

-- Application permission indexes
CREATE INDEX "IdxAppPermissionsAppUser" ON "ApplicationPermissions"("ApplicationId", "UserId");
CREATE INDEX "IdxAppPermissionsUserId" ON "ApplicationPermissions"("UserId");
CREATE INDEX "IdxAppPermissionsIsDeleted" ON "ApplicationPermissions"("IsDeleted");

-- Role indexes
CREATE INDEX "IdxRolesIsDeleted" ON "Roles"("IsDeleted");

-- User role mapping indexes
CREATE INDEX "IdxUserRoleMappingsUserId" ON "UserRoleMappings"("UserId");
CREATE INDEX "IdxUserRoleMappingsRoleId" ON "UserRoleMappings"("RoleId");
CREATE INDEX "IdxUserRoleMappingsIsDeleted" ON "UserRoleMappings"("IsDeleted");

-- Session logs indexes
CREATE INDEX "IdxSessionLogsUserId" ON "SessionLogs"("UserId");
CREATE INDEX "IdxSessionLogsExpires" ON "SessionLogs"("TimestampCreatedAt");
CREATE INDEX "IdxSessionLogsIsDeleted" ON "SessionLogs"("IsDeleted");

-- Telemetry data indexes (Critical for IoT performance)
CREATE INDEX "IdxTelemetryDeviceTimestamp" ON "TelemetryData"("DeviceId", "UnixTimestamp" DESC);
CREATE INDEX "IdxTelemetryTimestamp" ON "TelemetryData"("UnixTimestamp" DESC);
CREATE INDEX "IdxTelemetryDataType" ON "TelemetryData"("DataType");
CREATE INDEX "IdxTelemetryIsDeleted" ON "TelemetryData"("IsDeleted");
CREATE INDEX "IdxTelemetryDeviceTypeTimestamp" ON "TelemetryData"("DeviceId", "DataType", "UnixTimestamp" DESC);

-- Alarm indexes
CREATE INDEX "IdxAlarmsDeviceTimestamp" ON "Alarms"("DeviceId", "UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsAlarmTypeTimestamp" ON "Alarms"("AlarmType", "UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsTimestamp" ON "Alarms"("UnixTimestamp" DESC);
CREATE INDEX "IdxAlarmsIsDeleted" ON "Alarms"("IsDeleted");

-- Notification indexes
CREATE INDEX "IdxNotificationsUserTimestamp" ON "Notifications"("UserId", "UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsUserRead" ON "Notifications"("UserId", "IsRead");
CREATE INDEX "IdxNotificationsTypeTimestamp" ON "Notifications"("NotificationType", "UnixTimestamp" DESC);
CREATE INDEX "IdxNotificationsIsDeleted" ON "Notifications"("IsDeleted");

-- ============================================================================
-- CREATE FUNCTIONS AND TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update the "UpdatedAt" column
CREATE OR REPLACE FUNCTION "UpdateUpdatedAtColumn"()
RETURNS TRIGGER AS $
BEGIN
    NEW."UpdatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$ language 'plpgsql';

-- Create triggers for all tables with "UpdatedAt" columns
CREATE TRIGGER "UpdateEnterprisesUpdatedAt" BEFORE UPDATE ON "Enterprises" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateUsersUpdatedAt" BEFORE UPDATE ON "Users" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateClustersUpdatedAt" BEFORE UPDATE ON "Clusters" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateSitesUpdatedAt" BEFORE UPDATE ON "Sites" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateAreasUpdatedAt" BEFORE UPDATE ON "Areas" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateLevelsUpdatedAt" BEFORE UPDATE ON "Levels" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateZonesUpdatedAt" BEFORE UPDATE ON "Zones" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateDevicesUpdatedAt" BEFORE UPDATE ON "Devices" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateAssetsUpdatedAt" BEFORE UPDATE ON "Assets" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateAssetDeviceMappingsUpdatedAt" BEFORE UPDATE ON "AssetDeviceMappings" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateDeviceHierarchiesUpdatedAt" BEFORE UPDATE ON "DeviceHierarchies" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateDevicePermissionsUpdatedAt" BEFORE UPDATE ON "DevicePermissions" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateDeviceAttributesUpdatedAt" BEFORE UPDATE ON "DeviceAttributes" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateApplicationsUpdatedAt" BEFORE UPDATE ON "Applications" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateFeaturesUpdatedAt" BEFORE UPDATE ON "Features" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateRulesUpdatedAt" BEFORE UPDATE ON "Rules" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateApplicationPermissionsUpdatedAt" BEFORE UPDATE ON "ApplicationPermissions" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateRolesUpdatedAt" BEFORE UPDATE ON "Roles" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateUserRoleMappingsUpdatedAt" BEFORE UPDATE ON "UserRoleMappings" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateSessionLogsUpdatedAt" BEFORE UPDATE ON "SessionLogs" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateAlarmsUpdatedAt" BEFORE UPDATE ON "Alarms" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "UpdateNotificationsUpdatedAt" BEFORE UPDATE ON "Notifications" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();

-- ============================================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View for active devices with their hierarchies
CREATE VIEW "ActiveDevicesWithHierarchy" AS
SELECT 
    d."DeviceId",
    d."DeviceName",
    d."DeviceType",
    d."DeviceSubType",
    d."IsConnected",
    dh."ParentDeviceId",
    pd."DeviceName" AS "ParentDeviceName"
FROM "Devices" d
LEFT JOIN "DeviceHierarchies" dh ON d."DeviceId" = dh."ChildDeviceId" AND dh."IsDeleted" = FALSE
LEFT JOIN "Devices" pd ON dh."ParentDeviceId" = pd."DeviceId"
WHERE d."IsDeleted" = FALSE;

-- View for user permissions across devices and applications
CREATE VIEW "UserPermissionsSummary" AS
SELECT 
    u."UserId",
    u."UserName",
    u."Email",
    'DEVICE' AS "PermissionScope",
    dp."DeviceId" AS "ScopeId",
    d."DeviceName" AS "ScopeName",
    dp."PermissionType"
FROM "Users" u
JOIN "DevicePermissions" dp ON u."UserId" = dp."UserId"
JOIN "Devices" d ON dp."DeviceId" = d."DeviceId"
WHERE u."IsDeleted" = FALSE AND dp."IsDeleted" = FALSE AND d."IsDeleted" = FALSE

UNION ALL

SELECT 
    u."UserId",
    u."UserName",
    u."Email",
    'APPLICATION' AS "PermissionScope",
    ap."ApplicationId" AS "ScopeId",
    a."ApplicationName" AS "ScopeName",
    ap."PermissionType"
FROM "Users" u
JOIN "ApplicationPermissions" ap ON u."UserId" = ap."UserId"
JOIN "Applications" a ON ap."ApplicationId" = a."ApplicationId"
WHERE u."IsDeleted" = FALSE AND ap."IsDeleted" = FALSE AND a."IsDeleted" = FALSE;

-- View for enterprise hierarchy
CREATE VIEW "EnterpriseHierarchy" AS
SELECT 
    e."EnterpriseId",
    e."EnterpriseName",
    c."ClusterId",
    c."ClusterName",
    s."SiteId",
    s."SiteName",
    s."SiteType",
    l."LevelId",
    l."LevelName",
    l."LevelNumber"
FROM "Enterprises" e
LEFT JOIN "Clusters" c ON e."EnterpriseId" = c."EnterpriseId" AND c."IsDeleted" = FALSE
LEFT JOIN "Sites" s ON c."ClusterId" = s."ClusterId" AND s."IsDeleted" = FALSE
LEFT JOIN "Levels" l ON s."SiteId" = l."SiteId" AND l."IsDeleted" = FALSE
WHERE e."IsDeleted" = FALSE;

-- View for recent alarms with device information
CREATE VIEW "RecentAlarmsWithDevices" AS
SELECT 
    a."AlarmId",
    a."DeviceId",
    d."DeviceName",
    d."DeviceType",
    d."Manufacturer",
    a."AlarmType",
    a."Description",
    a."UnixTimestamp",
    a."CreatedAt"
FROM "Alarms" a
JOIN "Devices" d ON a."DeviceId" = d."DeviceId"
WHERE a."IsDeleted" = FALSE AND d."IsDeleted" = FALSE
ORDER BY a."UnixTimestamp" DESC;

-- View for telemetry data with device context
CREATE VIEW "TelemetryDataWithDeviceContext" AS
SELECT 
    td."TelemetryDataId",
    td."DeviceId",
    d."DeviceName",
    d."DeviceType",
    d."DeviceSubType",
    d."Manufacturer",
    td."UnixTimestamp",
    td."DataType",
    td."ValueString",
    td."ValueNumber",
    td."ValueBoolean",
    td."ValueLocation",
    td."Unit",
    td."CreatedAt"
FROM "TelemetryData" td
JOIN "Devices" d ON td."DeviceId" = d."DeviceId"
WHERE td."IsDeleted" = FALSE AND d."IsDeleted" = FALSE;

-- ============================================================================
-- ADDITIONAL UTILITY FUNCTIONS
-- ============================================================================

-- Function to get device count by type for an enterprise
CREATE OR REPLACE FUNCTION "GetDeviceCountByType"("EnterpriseIdParam" VARCHAR(64))
RETURNS TABLE("DeviceType" "DeviceTypeEnum", "DeviceCount" BIGINT) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        d."DeviceType",
        COUNT(*)::BIGINT AS "DeviceCount"
    FROM "Devices" d
    JOIN "AssetDevices" ad ON d."DeviceId" = ad."DeviceId"
    JOIN "AssetDeviceMappings" adm ON ad."AssetDeviceMappingId" = adm."AssetDeviceMappingId"
    JOIN "Assets" a ON adm."AssetId" = a."AssetId"
    JOIN "Sites" s ON a."SiteId" = s."SiteId"
    JOIN "Clusters" c ON s."ClusterId" = c."ClusterId"
    WHERE c."EnterpriseId" = "EnterpriseIdParam"
    AND d."IsDeleted" = FALSE
    AND a."IsDeleted" = FALSE
    AND s."IsDeleted" = FALSE
    AND c."IsDeleted" = FALSE
    GROUP BY d."DeviceType";
END;
$$ LANGUAGE plpgsql;

-- Function to get active alarms count for a device
CREATE OR REPLACE FUNCTION "GetActiveAlarmCount"("DeviceIdParam" VARCHAR(64))
RETURNS INTEGER AS $$
DECLARE
    "AlarmCount" INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO "AlarmCount"
    FROM "Alarms"
    WHERE "DeviceId" = "DeviceIdParam"
    AND "IsDeleted" = FALSE;
    
    RETURN COALESCE("AlarmCount", 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get latest telemetry value for a device
CREATE OR REPLACE FUNCTION "GetLatestTelemetryValue"(
    "DeviceIdParam" VARCHAR(64),
    "DataTypeParam" "TelemetryDataTypeEnum"
)
RETURNS TABLE(
    "ValueString" VARCHAR(256),
    "ValueNumber" DOUBLE PRECISION,
    "ValueBoolean" BOOLEAN,
    "ValueLocation" "CoordinateType",
    "UnixTimestamp" BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        td."ValueString",
        td."ValueNumber",
        td."ValueBoolean",
        td."ValueLocation",
        td."UnixTimestamp"
    FROM "TelemetryData" td
    WHERE td."DeviceId" = "DeviceIdParam"
    AND td."DataType" = "DataTypeParam"
    AND td."IsDeleted" = FALSE
    ORDER BY td."UnixTimestamp" DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- PERFORMANCE OPTIMIZATION HINTS
-- ============================================================================

-- Consider creating additional partial indexes for frequently queried conditions
-- Example partial indexes for better performance on active/non-deleted records:

-- CREATE INDEX "IdxDevicesActiveConnected" ON "Devices"("DeviceId") WHERE "IsDeleted" = FALSE AND "IsConnected" = TRUE;
-- CREATE INDEX "IdxTelemetryDataRecent" ON "TelemetryData"("DeviceId", "UnixTimestamp" DESC) WHERE "IsDeleted" = FALSE AND "UnixTimestamp" > (EXTRACT(EPOCH FROM NOW() - INTERVAL '30 days'))::BIGINT;
-- CREATE INDEX "IdxAlarmsRecentCritical" ON "Alarms"("DeviceId", "UnixTimestamp" DESC) WHERE "IsDeleted" = FALSE AND "AlarmType" = 'C';

-- ============================================================================
-- CLEANUP AND MAINTENANCE PROCEDURES
-- ============================================================================

-- Procedure to clean up old telemetry data (older than specified days)
CREATE OR REPLACE FUNCTION "CleanupOldTelemetryData"("DaysToKeep" INTEGER DEFAULT 90)
RETURNS VOID AS $$
DECLARE
    "CutoffTimestamp" BIGINT;
    "DeletedRows" INTEGER;
BEGIN
    "CutoffTimestamp" := (EXTRACT(EPOCH FROM NOW() - ("DaysToKeep" || ' days')::INTERVAL))::BIGINT;
    
    UPDATE "TelemetryData" 
    SET "IsDeleted" = TRUE 
    WHERE "UnixTimestamp" < "CutoffTimestamp" 
    AND "IsDeleted" = FALSE;
    
    GET DIAGNOSTICS "DeletedRows" = ROW_COUNT;
    RAISE NOTICE 'Marked % telemetry records as deleted (older than % days)', "DeletedRows", "DaysToKeep";
END;
$$ LANGUAGE plpgsql;

-- Procedure to update device connection status based on latest telemetry
CREATE OR REPLACE FUNCTION "UpdateDeviceConnectionStatus"()
RETURNS VOID AS $$
DECLARE
    "ThresholdTimestamp" BIGINT;
    "UpdatedRows" INTEGER;
BEGIN
    -- Consider devices disconnected if no telemetry in last 5 minutes
    "ThresholdTimestamp" := (EXTRACT(EPOCH FROM NOW() - INTERVAL '5 minutes'))::BIGINT;
    
    -- Mark devices as disconnected if no recent telemetry
    UPDATE "Devices" 
    SET "IsConnected" = FALSE,
        "UpdatedAt" = CURRENT_TIMESTAMP
    WHERE "IsConnected" = TRUE 
    AND "IsDeleted" = FALSE
    AND "DeviceId" NOT IN (
        SELECT DISTINCT "DeviceId" 
        FROM "TelemetryData" 
        WHERE "UnixTimestamp" > "ThresholdTimestamp" 
        AND "IsDeleted" = FALSE
    );
    
    GET DIAGNOSTICS "UpdatedRows" = ROW_COUNT;
    RAISE NOTICE 'Updated connection status for % devices', "UpdatedRows";
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SAMPLE DATA INSERTION FUNCTIONS (FOR TESTING)
-- ============================================================================

-- Function to create sample enterprise with hierarchy
CREATE OR REPLACE FUNCTION "CreateSampleEnterpriseData"()
RETURNS VARCHAR(64) AS $$
DECLARE
    "SampleEnterpriseId" VARCHAR(64);
    "SampleClusterId" VARCHAR(64);
    "SampleSiteId" VARCHAR(64);
    "SampleLevelId" VARCHAR(64);
BEGIN
    -- Generate IDs
    "SampleEnterpriseId" := 'ENT_' || EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT;
    "SampleClusterId" := 'CLU_' || EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT;
    "SampleSiteId" := 'SIT_' || EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT;
    "SampleLevelId" := 'LEV_' || EXTRACT(EPOCH FROM NOW())::BIGINT::TEXT;
    
    -- Insert sample enterprise
    INSERT INTO "Enterprises" (
        "EnterpriseId", "EnterpriseName", "Description", 
        "ContactEmail", "IsDeleted", "IsSystem"
    ) VALUES (
        "SampleEnterpriseId", 'Sample Enterprise', 'Test enterprise for development',
        'test@example.com', FALSE, FALSE
    );
    
    -- Insert sample cluster
    INSERT INTO "Clusters" (
        "ClusterId", "ClusterName", "Description", "EnterpriseId", "IsDeleted", "IsSystem"
    ) VALUES (
        "SampleClusterId", 'Main Cluster', 'Primary cluster', 
        "SampleEnterpriseId", FALSE, FALSE
    );
    
    -- Insert sample site
    INSERT INTO "Sites" (
        "SiteId", "ClusterId", "SiteName", "Description", "SiteType", "IsDeleted", "IsSystem"
    ) VALUES (
        "SampleSiteId", "SampleClusterId", 'Headquarters', 'Main office building', 
        'I', FALSE, FALSE
    );
    
    -- Insert sample level
    INSERT INTO "Levels" (
        "LevelId", "SiteId", "LevelName", "Description", "LevelNumber", "IsDeleted", "IsSystem"
    ) VALUES (
        "SampleLevelId", "SampleSiteId", 'Ground Floor', 'Ground floor of building', 
        0, FALSE, FALSE
    );
    
    RETURN "SampleEnterpriseId";
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- COMMENTS AND DOCUMENTATION
-- ============================================================================

COMMENT ON DATABASE "IotPlatform" IS 'IoT Platform Database - Pascal Case Version';

COMMENT ON TABLE "Enterprises" IS 'Master table for enterprise/organization management';
COMMENT ON TABLE "Users" IS 'User accounts with enterprise association';
COMMENT ON TABLE "Devices" IS 'IoT devices and sensors registry';
COMMENT ON TABLE "TelemetryData" IS 'Time-series data from IoT devices (partitioned by timestamp)';
COMMENT ON TABLE "Alarms" IS 'Alert and alarm events from devices';
COMMENT ON TABLE "Assets" IS 'Physical assets that devices are attached to';

-- Column comments for critical tables
COMMENT ON COLUMN "TelemetryData"."UnixTimestamp" IS 'Unix timestamp for time-series partitioning';
COMMENT ON COLUMN "Devices"."IsConnected" IS 'Real-time connection status of device';
COMMENT ON COLUMN "Devices"."IsConfigured" IS 'Whether device has been properly configured';
COMMENT ON COLUMN "Alarms"."AlarmType" IS 'C=Critical, W=Warning, I=Info';

-- ============================================================================
-- NOTES ON CASE SENSITIVITY IN POSTGRESQL
-- ============================================================================

-- IMPORTANT: PostgreSQL converts all unquoted identifiers to lowercase
-- To preserve PascalCase, ALL identifiers must be quoted with double quotes
-- 
-- Examples:
-- - Table name: "Enterprises" (not Enterprises)
-- - Column name: "EnterpriseId" (not EnterpriseId) 
-- - Index name: "IdxEnterprisesIsDeleted" (not IdxEnterprisesIsDeleted)
-- - Function name: "UpdateUpdatedAtColumn" (not UpdateUpdatedAtColumn)
--
-- When querying, you must also use quotes:
-- SELECT "EnterpriseId", "EnterpriseName" FROM "Enterprises" WHERE "IsDeleted" = FALSE;

-- ============================================================================
-- END OF SCHEMA DEFINITION
-- ============================================================================
