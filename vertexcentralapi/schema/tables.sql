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
-- SITES TABLE
-- ============================================================================
CREATE TABLE "Sites" (
    "SiteId" VARCHAR(64) PRIMARY KEY,
    "ClusterId" VARCHAR(64) NOT NULL,
    "SiteName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "CountryId" VARCHAR(8) NOT NULL,
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
    "IpAddress" VARCHAR(64) NOT NULL,
   "TimestampLoggedIn" TIMESTAMP WITH TIME ZONE,
    "TimestampLoggedOut" TIMESTAMP WITH TIME ZONE,
    "Location" "CoordinateType",
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "TimestampCreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("UserId") REFERENCES "Users"("UserId") ON DELETE CASCADE
);

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
-- TELEMETRY_CONTROL TABLE (Tracks Parquet files and statistics)
-- ============================================================================
CREATE TABLE "TelemetryControl" (
    "TelemetryControlId" VARCHAR(64) PRIMARY KEY,
    "DeviceId" VARCHAR(64) NOT NULL,
    "EnterpriseId" VARCHAR(64) NOT NULL,
    "SiteId" VARCHAR(64) NOT NULL,
    "Year" INTEGER NOT NULL,
    "Month" INTEGER NOT NULL,
    "Hour" INTEGER NOT NULL,
    "FilePath" VARCHAR(512) NOT NULL, -- enterprise/site/device/year/month/hour
    "FileName" VARCHAR(256) NOT NULL,
    "FileStatus" "TelemetryFileStatusEnum" NOT NULL DEFAULT 'ACTIVE',
    "FileSizeBytes" BIGINT DEFAULT 0,
    "RecordCount" BIGINT DEFAULT 0,
    "DataTypes" VARCHAR(64)[], -- Array of data types in this file
    "MinTimestamp" BIGINT,
    "MaxTimestamp" BIGINT,
    "FirstRecordTimestamp" BIGINT,
    "LastRecordTimestamp" BIGINT,
    "FileCreatedAt" TIMESTAMP WITH TIME ZONE,
    "FileLastModified" TIMESTAMP WITH TIME ZONE,
    "FileClosedAt" TIMESTAMP WITH TIME ZONE,
    "Checksum" VARCHAR(64), -- For file integrity
    "CompressionRatio" DOUBLE PRECISION,
    "IsDeleted" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE,
    FOREIGN KEY ("EnterpriseId") REFERENCES "Enterprises"("EnterpriseId") ON DELETE CASCADE,
    FOREIGN KEY ("SiteId") REFERENCES "Sites"("SiteId") ON DELETE CASCADE,
    CONSTRAINT "ValidMonth" CHECK ("Month" >= 1 AND "Month" <= 12),
    CONSTRAINT "ValidHour" CHECK ("Hour" >= 0 AND "Hour" <= 23),
    CONSTRAINT "ValidYear" CHECK ("Year" >= 2020 AND "Year" <= 2100)
);

CREATE TABLE "FirmwareControl" (
    "FirmwareControlId" VARCHAR(64) PRIMARY KEY,
    "Manufacturer" VARCHAR(64) NOT NULL,
    "Model" VARCHAR(64) NOT NULL,
    "Version" VARCHAR(64) NOT NULL,
    "TargetType" "FirmwareTargetTypeEnum" NOT NULL, -- DEVICE or ASSET
    "FilePath" VARCHAR(512) NOT NULL, -- firmware/manufacturer/model/version/
    "FileName" VARCHAR(256) NOT NULL,
    "FileType" VARCHAR(16) NOT NULL, -- hex, deb, pkg, bin, img, tar.gz
    "FileStatus" "FirmwareFileStatusEnum" NOT NULL DEFAULT 'UPLOADED',
    "FileSizeBytes" BIGINT DEFAULT 0,
    "Checksum" VARCHAR(128) NOT NULL, -- Critical for firmware integrity (SHA256)
    "ChecksumAlgorithm" VARCHAR(16) DEFAULT 'SHA256',
    "ReleaseNotes" TEXT,
    "ReleaseDate" TIMESTAMP WITH TIME ZONE,
    "MinHardwareVersion" VARCHAR(64),
    "MaxHardwareVersion" VARCHAR(64),
    "SupportedDeviceTypes" "DeviceTypeEnum"[], -- Array of supported device types
    "SupportedDeviceSubTypes" "DeviceSubTypeEnum"[], -- Array of supported device subtypes
    "IsSecurityUpdate" BOOLEAN DEFAULT FALSE,
    "IsCriticalUpdate" BOOLEAN DEFAULT FALSE,
    "RequiredBootloaderVersion" VARCHAR(64),
    "MemoryRequirements" JSONB, -- JSON for memory specs: {"flash": "256KB", "ram": "64KB"}
    "DependsOnFirmwareIds" VARCHAR(64)[], -- Array of firmware IDs this depends on
    "ReplacesVersion" VARCHAR(64), -- Version this firmware replaces
    "UploadedBy" VARCHAR(64), -- UserId who uploaded this firmware
    "ApprovedBy" VARCHAR(64), -- UserId who approved for deployment
    "FileCreatedAt" TIMESTAMP WITH TIME ZONE,
    "FileLastModified" TIMESTAMP WITH TIME ZONE,
    "ApprovedAt" TIMESTAMP WITH TIME ZONE,
    "IsDeleted" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("UploadedBy") REFERENCES "Users"("UserId") ON DELETE SET NULL,
    FOREIGN KEY ("ApprovedBy") REFERENCES "Users"("UserId") ON DELETE SET NULL,
    CONSTRAINT "ValidFileType" CHECK ("FileType" IN ('hex', 'deb', 'pkg', 'bin', 'img', 'tar.gz', 'zip', 'elf'))
);

-- ============================================================================
-- FIRMWARE_DEPLOYMENTS TABLE (Tracks firmware deployment history)
-- ============================================================================
CREATE TABLE "FirmwareDeployments" (
    "FirmwareDeploymentId" VARCHAR(64) PRIMARY KEY,
    "FirmwareControlId" VARCHAR(64) NOT NULL,
    "TargetType" "FirmwareTargetTypeEnum" NOT NULL,
    "TargetId" VARCHAR(64) NOT NULL, -- DeviceId or AssetId
    "DeploymentStatus" "FirmwareDeploymentStatusEnum" NOT NULL DEFAULT 'PENDING',
    "PreviousFirmwareVersion" VARCHAR(64), -- For rollback purposes
    "DeploymentStarted" TIMESTAMP WITH TIME ZONE,
    "DeploymentCompleted" TIMESTAMP WITH TIME ZONE,
    "DeploymentProgress" INTEGER DEFAULT 0, -- Percentage 0-100
    "ErrorCode" VARCHAR(32),
    "ErrorMessage" TEXT,
    "DeploymentLog" TEXT,
    "InitiatedBy" VARCHAR(64), -- UserId who started deployment
    "DeploymentMethod" VARCHAR(32), -- OTA, USB, TFTP, HTTP, etc.
    "RetryCount" INTEGER DEFAULT 0,
    "MaxRetries" INTEGER DEFAULT 3,
    "NextRetryAt" TIMESTAMP WITH TIME ZONE,
    "IsRollback" BOOLEAN DEFAULT FALSE,
    "ParentDeploymentId" VARCHAR(64), -- Reference to original deployment if this is a rollback
    "IsDeleted" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("FirmwareControlId") REFERENCES "FirmwareControl"("FirmwareControlId") ON DELETE CASCADE,
    FOREIGN KEY ("InitiatedBy") REFERENCES "Users"("UserId") ON DELETE SET NULL,
    FOREIGN KEY ("ParentDeploymentId") REFERENCES "FirmwareDeployments"("FirmwareDeploymentId") ON DELETE SET NULL,
    CONSTRAINT "ValidProgress" CHECK ("DeploymentProgress" >= 0 AND "DeploymentProgress" <= 100),
    CONSTRAINT "ValidRetryCount" CHECK ("RetryCount" >= 0 AND "RetryCount" <= "MaxRetries")
);

-- ============================================================================
-- FIRMWARE_COMPATIBILITY TABLE (Define which firmware works with which devices/assets)
-- ============================================================================
CREATE TABLE "FirmwareCompatibility" (
    "FirmwareCompatibilityId" VARCHAR(64) PRIMARY KEY,
    "FirmwareControlId" VARCHAR(64) NOT NULL,
    "TargetType" "FirmwareTargetTypeEnum" NOT NULL,
    "TargetId" VARCHAR(64) NOT NULL, -- Specific DeviceId or AssetId, or NULL for model-wide compatibility
    "Manufacturer" VARCHAR(64),
    "Model" VARCHAR(64),
    "HardwareVersion" VARCHAR(64),
    "IsCompatible" BOOLEAN DEFAULT TRUE,
    "IncompatibilityReason" TEXT,
    "TestedBy" VARCHAR(64), -- UserId who verified compatibility
    "TestedAt" TIMESTAMP WITH TIME ZONE,
    "IsDeleted" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("FirmwareControlId") REFERENCES "FirmwareControl"("FirmwareControlId") ON DELETE CASCADE,
    FOREIGN KEY ("TestedBy") REFERENCES "Users"("UserId") ON DELETE SET NULL
);

-- Add firmware version tracking to existing tables
ALTER TABLE "Devices" ADD COLUMN "CurrentFirmwareVersion" VARCHAR(64);
ALTER TABLE "Devices" ADD COLUMN "CurrentFirmwareControlId" VARCHAR(64);
ALTER TABLE "Devices" ADD COLUMN "LastFirmwareUpdateAt" TIMESTAMP WITH TIME ZONE;
ALTER TABLE "Assets" ADD COLUMN "CurrentFirmwareVersion" VARCHAR(64);
ALTER TABLE "Assets" ADD COLUMN "CurrentFirmwareControlId" VARCHAR(64);
ALTER TABLE "Assets" ADD COLUMN "LastFirmwareUpdateAt" TIMESTAMP WITH TIME ZONE;

CREATE TABLE "Countries" (
    "CountryId" VARCHAR(8) PRIMARY KEY, -- ISO 3166-1 alpha-3
    "CountryName" VARCHAR(64) NOT NULL,
    "Capital" VARCHAR(64),
    "IsoCode2" VARCHAR(2), -- ISO 3166-1 alpha-2
    "IsoCode3" VARCHAR(3), -- ISO 3166-1 alpha-3
    "IsdCode" VARCHAR(8),
    "Currency" VARCHAR(8),
    "GeoClusters" VARCHAR(256), -- 'APAC;ASEAN' or 'EMEA;EU;BENELUX'
    "IsDeleted" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT TRUE
);
