-- ============================================================================
-- FIRMWARE MANAGEMENT FUNCTIONS
-- ============================================================================

-- Function to get compatible firmware for a device
CREATE OR REPLACE FUNCTION "GetCompatibleFirmware"(
    "DeviceIdParam" VARCHAR(64)
)
RETURNS TABLE(
    "FirmwareControlId" VARCHAR(64),
    "Version" VARCHAR(64),
    "FileStatus" "FirmwareFileStatusEnum",
    "IsSecurityUpdate" BOOLEAN,
    "IsCriticalUpdate" BOOLEAN,
    "ReleaseDate" TIMESTAMP WITH TIME ZONE
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        fc."FirmwareControlId",
        fc."Version",
        fc."FileStatus",
        fc."IsSecurityUpdate",
        fc."IsCriticalUpdate",
        fc."ReleaseDate"
    FROM "FirmwareControl" fc
    JOIN "Devices" d ON fc."Manufacturer" = d."Manufacturer" AND fc."Model" = d."Model"
    LEFT JOIN "FirmwareCompatibility" fcomp ON fc."FirmwareControlId" = fcomp."FirmwareControlId" 
        AND fcomp."TargetType" = 'DEVICE' 
        AND (fcomp."TargetId" = "DeviceIdParam" OR fcomp."TargetId" IS NULL)
    WHERE d."DeviceId" = "DeviceIdParam"
    AND fc."TargetType" = 'DEVICE'
    AND fc."IsDeleted" = FALSE
    AND fc."FileStatus" IN ('VERIFIED', 'APPROVED')
    AND (fcomp."IsCompatible" IS NULL OR fcomp."IsCompatible" = TRUE)
    ORDER BY fc."ReleaseDate" DESC;
END;
$ LANGUAGE plpgsql;

-- Function to get compatible firmware for an asset
CREATE OR REPLACE FUNCTION "GetCompatibleFirmwareForAsset"(
    "AssetIdParam" VARCHAR(64)
)
RETURNS TABLE(
    "FirmwareControlId" VARCHAR(64),
    "Version" VARCHAR(64),
    "FileStatus" "FirmwareFileStatusEnum",
    "IsSecurityUpdate" BOOLEAN,
    "IsCriticalUpdate" BOOLEAN,
    "ReleaseDate" TIMESTAMP WITH TIME ZONE
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        fc."FirmwareControlId",
        fc."Version",
        fc."FileStatus",
        fc."IsSecurityUpdate",
        fc."IsCriticalUpdate",
        fc."ReleaseDate"
    FROM "FirmwareControl" fc
    JOIN "Assets" a ON fc."Manufacturer" = a."Manufacturer" AND fc."Model" = a."Model"
    LEFT JOIN "FirmwareCompatibility" fcomp ON fc."FirmwareControlId" = fcomp."FirmwareControlId" 
        AND fcomp."TargetType" = 'ASSET' 
        AND (fcomp."TargetId" = "AssetIdParam" OR fcomp."TargetId" IS NULL)
    WHERE a."AssetId" = "AssetIdParam"
    AND fc."TargetType" = 'ASSET'
    AND fc."IsDeleted" = FALSE
    AND fc."FileStatus" IN ('VERIFIED', 'APPROVED')
    AND (fcomp."IsCompatible" IS NULL OR fcomp."IsCompatible" = TRUE)
    ORDER BY fc."ReleaseDate" DESC;
END;
$ LANGUAGE plpgsql;

-- Function to start firmware deployment
CREATE OR REPLACE FUNCTION "StartFirmwareDeployment"(
    "FirmwareControlIdParam" VARCHAR(64),
    "TargetTypeParam" "FirmwareTargetTypeEnum",
    "TargetIdParam" VARCHAR(64),
    "UserIdParam" VARCHAR(64),
    "DeploymentMethodParam" VARCHAR(32) DEFAULT 'OTA'
)
RETURNS VARCHAR(64) AS $
DECLARE
    "DeploymentId" VARCHAR(64);
    "PreviousVersion" VARCHAR(64);
    "CurrentTimestamp" BIGINT;
BEGIN
    "CurrentTimestamp" := EXTRACT(EPOCH FROM NOW())::BIGINT;
    "DeploymentId" := 'FWDEP_' || "CurrentTimestamp"::TEXT;
    
    -- Get current firmware version for rollback
    IF "TargetTypeParam" = 'DEVICE' THEN
        SELECT "CurrentFirmwareVersion" INTO "PreviousVersion"
        FROM "Devices" WHERE "DeviceId" = "TargetIdParam";
    ELSE
        SELECT "CurrentFirmwareVersion" INTO "PreviousVersion"
        FROM "Assets" WHERE "AssetId" = "TargetIdParam";
    END IF;
    
    -- Insert deployment record
    INSERT INTO "FirmwareDeployments" (
        "FirmwareDeploymentId", "FirmwareControlId", "TargetType", "TargetId",
        "DeploymentStatus", "PreviousFirmwareVersion", "DeploymentStarted",
        "InitiatedBy", "DeploymentMethod", "IsDeleted", "IsSystem"
    ) VALUES (
        "DeploymentId", "FirmwareControlIdParam", "TargetTypeParam", "TargetIdParam",
        'PENDING', "PreviousVersion", CURRENT_TIMESTAMP,
        "UserIdParam", "DeploymentMethodParam", FALSE, FALSE
    );
    
    RETURN "DeploymentId";
END;
$ LANGUAGE plpgsql;

-- Function to update deployment progress
CREATE OR REPLACE FUNCTION "UpdateFirmwareDeploymentProgress"(
    "DeploymentIdParam" VARCHAR(64),
    "ProgressParam" INTEGER,
    "StatusParam" "FirmwareDeploymentStatusEnum" DEFAULT NULL,
    "ErrorCodeParam" VARCHAR(32) DEFAULT NULL,
    "ErrorMessageParam" TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $
DECLARE
    "CurrentStatus" "FirmwareDeploymentStatusEnum";
    "TargetTypeValue" "FirmwareTargetTypeEnum";
    "TargetIdValue" VARCHAR(64);
    "FirmwareVersion" VARCHAR(64);
    "FirmwareControlIdValue" VARCHAR(64);
BEGIN
    -- Get current deployment info
    SELECT "DeploymentStatus", "TargetType", "TargetId", "FirmwareControlId" 
    INTO "CurrentStatus", "TargetTypeValue", "TargetIdValue", "FirmwareControlIdValue"
    FROM "FirmwareDeployments" 
    WHERE "FirmwareDeploymentId" = "DeploymentIdParam";
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Update deployment record
    UPDATE "FirmwareDeployments"
    SET 
        "DeploymentProgress" = "ProgressParam",
        "DeploymentStatus" = COALESCE("StatusParam", "DeploymentStatus"),
        "ErrorCode" = "ErrorCodeParam",
        "ErrorMessage" = "ErrorMessageParam",
        "DeploymentCompleted" = CASE 
            WHEN COALESCE("StatusParam", "DeploymentStatus") IN ('SUCCESS', 'FAILED') THEN CURRENT_TIMESTAMP
            ELSE "DeploymentCompleted"
        END,
        "UpdatedAt" = CURRENT_TIMESTAMP
    WHERE "FirmwareDeploymentId" = "DeploymentIdParam";
    
    -- If deployment successful, update target firmware version
    IF COALESCE("StatusParam", "CurrentStatus") = 'SUCCESS' AND "ProgressParam" = 100 THEN
        -- Get firmware version
        SELECT "Version" INTO "FirmwareVersion" 
        FROM "FirmwareControl" 
        WHERE "FirmwareControlId" = "FirmwareControlIdValue";
        
        -- Update target's current firmware
        IF "TargetTypeValue" = 'DEVICE' THEN
            UPDATE "Devices" 
            SET "CurrentFirmwareVersion" = "FirmwareVersion",
                "CurrentFirmwareControlId" = "FirmwareControlIdValue",
                "LastFirmwareUpdateAt" = CURRENT_TIMESTAMP,
                "UpdatedAt" = CURRENT_TIMESTAMP
            WHERE "DeviceId" = "TargetIdValue";
        ELSE
            UPDATE "Assets" 
            SET "CurrentFirmwareVersion" = "FirmwareVersion",
                "CurrentFirmwareControlId" = "FirmwareControlIdValue",
                "LastFirmwareUpdateAt" = CURRENT_TIMESTAMP,
                "UpdatedAt" = CURRENT_TIMESTAMP
            WHERE "AssetId" = "TargetIdValue";
        END IF;
    END IF;
    
    RETURN FOUND;
END;
$ LANGUAGE plpgsql;

-- Function to initiate firmware rollback
CREATE OR REPLACE FUNCTION "InitiateFirmwareRollback"(
    "FailedDeploymentIdParam" VARCHAR(64),
    "UserIdParam" VARCHAR(64)
)
RETURNS VARCHAR(64) AS $
DECLARE
    "RollbackDeploymentId" VARCHAR(64);
    "TargetTypeValue" "FirmwareTargetTypeEnum";
    "TargetIdValue" VARCHAR(64);
    "PreviousVersion" VARCHAR(64);
    "PreviousFirmwareControlId" VARCHAR(64);
    "CurrentTimestamp" BIGINT;
BEGIN
    "CurrentTimestamp" := EXTRACT(EPOCH FROM NOW())::BIGINT;
    "RollbackDeploymentId" := 'FWROLL_' || "CurrentTimestamp"::TEXT;
    
    -- Get failed deployment info
    SELECT "TargetType", "TargetId", "PreviousFirmwareVersion"
    INTO "TargetTypeValue", "TargetIdValue", "PreviousVersion"
    FROM "FirmwareDeployments"
    WHERE "FirmwareDeploymentId" = "FailedDeploymentIdParam";
    
    IF NOT FOUND OR "PreviousVersion" IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Find previous firmware control ID
    SELECT fc."FirmwareControlId" INTO "PreviousFirmwareControlId"
    FROM "FirmwareControl" fc
    WHERE fc."Version" = "PreviousVersion"
    AND fc."TargetType" = "TargetTypeValue"
    AND fc."IsDeleted" = FALSE
    LIMIT 1;
    
    IF "PreviousFirmwareControlId" IS NULL THEN
        RETURN NULL;
    END IF;
    
    -- Create rollback deployment
    INSERT INTO "FirmwareDeployments" (
        "FirmwareDeploymentId", "FirmwareControlId", "TargetType", "TargetId",
        "DeploymentStatus", "PreviousFirmwareVersion", "DeploymentStarted",
        "InitiatedBy", "DeploymentMethod", "IsRollback", "ParentDeploymentId",
        "IsDeleted", "IsSystem"
    ) VALUES (
        "RollbackDeploymentId", "PreviousFirmwareControlId", "TargetTypeValue", "TargetIdValue",
        'PENDING', NULL, CURRENT_TIMESTAMP,
        "UserIdParam", 'ROLLBACK', TRUE, "FailedDeploymentIdParam",
        FALSE, FALSE
    );
    
    RETURN "RollbackDeploymentId";
END;
$ LANGUAGE plpgsql;

-- Function to get firmware deployment history for target
CREATE OR REPLACE FUNCTION "GetFirmwareDeploymentHistory"(
    "TargetTypeParam" "FirmwareTargetTypeEnum",
    "TargetIdParam" VARCHAR(64),
    "LimitParam" INTEGER DEFAULT 10
)
RETURNS TABLE(
    "FirmwareDeploymentId" VARCHAR(64),
    "Version" VARCHAR(64),
    "DeploymentStatus" "FirmwareDeploymentStatusEnum",
    "DeploymentStarted" TIMESTAMP WITH TIME ZONE,
    "DeploymentCompleted" TIMESTAMP WITH TIME ZONE,
    "InitiatedBy" VARCHAR(64),
    "IsRollback" BOOLEAN,
    "DeploymentProgress" INTEGER
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        fd."FirmwareDeploymentId",
        fc."Version",
        fd."DeploymentStatus",
        fd."DeploymentStarted",
        fd."DeploymentCompleted",
        fd."InitiatedBy",
        fd."IsRollback",
        fd."DeploymentProgress"
    FROM "FirmwareDeployments" fd
    JOIN "FirmwareControl" fc ON fd."FirmwareControlId" = fc."FirmwareControlId"
    WHERE fd."TargetType" = "TargetTypeParam"
    AND fd."TargetId" = "TargetIdParam"
    AND fd."IsDeleted" = FALSE
    ORDER BY fd."DeploymentStarted" DESC
    LIMIT "LimitParam";
END;
$ LANGUAGE plpgsql;

-- Function to get pending firmware deployments for retry
CREATE OR REPLACE FUNCTION "GetPendingFirmwareRetries"()
RETURNS TABLE(
    "FirmwareDeploymentId" VARCHAR(64),
    "TargetType" "FirmwareTargetTypeEnum",
    "TargetId" VARCHAR(64),
    "RetryCount" INTEGER,
    "NextRetryAt" TIMESTAMP WITH TIME ZONE
) AS $
BEGIN
    RETURN QUERY
    SELECT 
        fd."FirmwareDeploymentId",
        fd."TargetType",
        fd."TargetId",
        fd."RetryCount",
        fd."NextRetryAt"
    FROM "FirmwareDeployments" fd
    WHERE fd."DeploymentStatus" = 'FAILED'
    AND fd."NextRetryAt" IS NOT NULL
    AND fd."NextRetryAt" <= CURRENT_TIMESTAMP
    AND fd."RetryCount" < fd."MaxRetries"
    AND fd."IsDeleted" = FALSE
    ORDER BY fd."NextRetryAt";
END;
$ LANGUAGE plpgsql;
        -- IoT Data Model - PostgreSQL Schema Creation Script (Pascal Case with Double Quotes)
-- Updated: Telemetry moved to Parquet files with control table and complete notification triggers

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
CREATE TYPE "TelemetryFileStatusEnum" AS ENUM ('ACTIVE', 'CLOSED', 'ARCHIVED', 'CORRUPTED', 'DELETED');
CREATE TYPE "FirmwareFileStatusEnum" AS ENUM ('UPLOADED', 'VERIFIED', 'APPROVED', 'DEPLOYED', 'DEPRECATED', 'CORRUPTED');
CREATE TYPE "FirmwareTargetTypeEnum" AS ENUM ('DEVICE', 'ASSET');
CREATE TYPE "FirmwareDeploymentStatusEnum" AS ENUM ('PENDING', 'IN_PROGRESS', 'SUCCESS', 'FAILED', 'ROLLED_BACK');

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
-- COUNTRIES TABLE (Reference data with geo-clustering)
-- ============================================================================
CREATE TABLE "Countries" (
    "CountryId" VARCHAR(8) PRIMARY KEY, -- ISO 3166-1 alpha-3
    "CountryName" VARCHAR(64) NOT NULL,
    "Capital" VARCHAR(64),
    "IsoCode2" VARCHAR(2), -- ISO 3166-1 alpha-2  
    "IsoCode3" VARCHAR(3), -- ISO 3166-1 alpha-3
    "IsdCode" VARCHAR(8),
    "Currency" VARCHAR(8),
    "GeoClusters" VARCHAR(256) DEFAULT 'WTO', -- Multiple affiliations: 'APAC;ASEAN' or 'EMEA;EU;BENELUX'
    "IsDeleted" BOOLEAN DEFAULT FALSE,
    "IsSystem" BOOLEAN DEFAULT TRUE,
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
    "EnterpriseId" VARCHAR(64) NOT NULL,
    "CountryId" VARCHAR(8), -- Link to Countries table instead of Clusters
    "SiteName" VARCHAR(64) NOT NULL,
    "Description" VARCHAR(256),
    "SiteType" "SiteTypeEnum" NOT NULL,
    "SiteLevelCount" INTEGER DEFAULT 0,
    "IsMasterSite" BOOLEAN DEFAULT FALSE,
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("EnterpriseId") REFERENCES "Enterprises"("EnterpriseId") ON DELETE CASCADE,
    FOREIGN KEY ("CountryId") REFERENCES "Countries"("CountryId") ON DELETE SET NULL
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
-- FIRMWARE_CONTROL TABLE (Tracks firmware files for devices and assets)
-- ============================================================================
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
    "RelatedTelemetryFileIds" VARCHAR(64)[], -- References to TelemetryControl records
    "IsDeleted" BOOLEAN DEFAULT TRUE,
    "IsSystem" BOOLEAN DEFAULT FALSE,
    "CreatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    "UpdatedAt" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("DeviceId") REFERENCES "Devices"("DeviceId") ON DELETE CASCADE
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

-- Countries indexes
CREATE INDEX "IdxCountriesIsDeleted" ON "Countries"("IsDeleted");
CREATE INDEX "IdxCountriesIsoCode2" ON "Countries"("IsoCode2");
CREATE INDEX "IdxCountriesIsoCode3" ON "Countries"("IsoCode3");
CREATE INDEX "IdxCountriesGeoClusters" ON "Countries" USING gin(string_to_array("GeoClusters", ';'));

-- User indexes
CREATE INDEX "IdxUsersEnterpriseId" ON "Users"("EnterpriseId");
CREATE INDEX "IdxUsersIsDeleted" ON "Users"("IsDeleted");
CREATE INDEX "IdxUsersEmail" ON "Users"("Email");
CREATE INDEX "IdxUsersCreatedAt" ON "Users"("CreatedAt");

-- Site indexes (updated to remove cluster references)
CREATE INDEX "IdxSitesEnterpriseId" ON "Sites"("EnterpriseId");
CREATE INDEX "IdxSitesCountryId" ON "Sites"("CountryId");
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

-- Telemetry Control indexes (Critical for file management)
CREATE INDEX "IdxTelemetryControlDeviceId" ON "TelemetryControl"("DeviceId");
CREATE INDEX "IdxTelemetryControlEnterpriseId" ON "TelemetryControl"("EnterpriseId");
CREATE INDEX "IdxTelemetryControlSiteId" ON "TelemetryControl"("SiteId");
CREATE INDEX "IdxTelemetryControlYearMonth" ON "TelemetryControl"("Year", "Month");
CREATE INDEX "IdxTelemetryControlYearMonthHour" ON "TelemetryControl"("Year", "Month", "Hour");
CREATE INDEX "IdxTelemetryControlFileStatus" ON "TelemetryControl"("FileStatus");
CREATE INDEX "IdxTelemetryControlFilePath" ON "TelemetryControl"("FilePath");
CREATE INDEX "IdxTelemetryControlDeviceTimeRange" ON "TelemetryControl"("DeviceId", "MinTimestamp", "MaxTimestamp");
CREATE INDEX "IdxTelemetryControlIsDeleted" ON "TelemetryControl"("IsDeleted");
CREATE INDEX "IdxTelemetryControlUniqueFile" ON "TelemetryControl"("DeviceId", "Year", "Month", "Hour") WHERE "IsDeleted" = FALSE;

-- Firmware Control indexes (Critical for firmware management)
CREATE INDEX "IdxFirmwareControlManufacturer" ON "FirmwareControl"("Manufacturer");
CREATE INDEX "IdxFirmwareControlModel" ON "FirmwareControl"("Manufacturer", "Model");
CREATE INDEX "IdxFirmwareControlVersion" ON "FirmwareControl"("Manufacturer", "Model", "Version");
CREATE INDEX "IdxFirmwareControlTargetType" ON "FirmwareControl"("TargetType");
CREATE INDEX "IdxFirmwareControlFileStatus" ON "FirmwareControl"("FileStatus");
CREATE INDEX "IdxFirmwareControlIsDeleted" ON "FirmwareControl"("IsDeleted");
CREATE INDEX "IdxFirmwareControlSecurity" ON "FirmwareControl"("IsSecurityUpdate", "IsCriticalUpdate");
CREATE INDEX "IdxFirmwareControlApproval" ON "FirmwareControl"("FileStatus", "ApprovedAt");
CREATE INDEX "IdxFirmwareControlChecksum" ON "FirmwareControl"("Checksum");

-- Firmware Deployments indexes
CREATE INDEX "IdxFirmwareDeploymentsTarget" ON "FirmwareDeployments"("TargetType", "TargetId");
CREATE INDEX "IdxFirmwareDeploymentsFirmware" ON "FirmwareDeployments"("FirmwareControlId");
CREATE INDEX "IdxFirmwareDeploymentsStatus" ON "FirmwareDeployments"("DeploymentStatus");
CREATE INDEX "IdxFirmwareDeploymentsRetry" ON "FirmwareDeployments"("DeploymentStatus", "NextRetryAt") WHERE "DeploymentStatus" = 'FAILED' AND "NextRetryAt" IS NOT NULL;
CREATE INDEX "IdxFirmwareDeploymentsIsDeleted" ON "FirmwareDeployments"("IsDeleted");
CREATE INDEX "IdxFirmwareDeploymentsProgress" ON "FirmwareDeployments"("DeploymentStatus", "DeploymentProgress");

-- Firmware Compatibility indexes
CREATE INDEX "IdxFirmwareCompatibilityTarget" ON "FirmwareCompatibility"("TargetType", "TargetId");
CREATE INDEX "IdxFirmwareCompatibilityFirmware" ON "FirmwareCompatibility"("FirmwareControlId");
CREATE INDEX "IdxFirmwareCompatibilityModel" ON "FirmwareCompatibility"("Manufacturer", "Model");
CREATE INDEX "IdxFirmwareCompatibilityIsDeleted" ON "FirmwareCompatibility"("IsDeleted");

-- Device firmware tracking indexes
CREATE INDEX "IdxDevicesCurrentFirmware" ON "Devices"("CurrentFirmwareControlId") WHERE "CurrentFirmwareControlId" IS NOT NULL;
CREATE INDEX "IdxDevicesFirmwareVersion" ON "Devices"("CurrentFirmwareVersion") WHERE "CurrentFirmwareVersion" IS NOT NULL;

-- Asset firmware tracking indexes
CREATE INDEX "IdxAssetsCurrentFirmware" ON "Assets"("CurrentFirmwareControlId") WHERE "CurrentFirmwareControlId" IS NOT NULL;
CREATE INDEX "IdxAssetsFirmwareVersion" ON "Assets"("CurrentFirmwareVersion") WHERE "CurrentFirmwareVersion" IS NOT NULL;

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
-- CREATE ALL TRIGGERS FOR CHANGE NOTIFICATIONS AND TIMESTAMP UPDATES
-- ============================================================================

-- Enterprises triggers
CREATE TRIGGER "UpdateEnterprisesUpdatedAt" BEFORE UPDATE ON "Enterprises" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyEnterprisesInsert" AFTER INSERT ON "Enterprises" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyEnterprisesUpdate" AFTER UPDATE ON "Enterprises" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyEnterprisesDelete" AFTER DELETE ON "Enterprises" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Users triggers
CREATE TRIGGER "UpdateUsersUpdatedAt" BEFORE UPDATE ON "Users" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyUsersInsert" AFTER INSERT ON "Users" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyUsersUpdate" AFTER UPDATE ON "Users" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyUsersDelete" AFTER DELETE ON "Users" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Countries triggers
CREATE TRIGGER "UpdateCountriesUpdatedAt" BEFORE UPDATE ON "Countries" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyCountriesInsert" AFTER INSERT ON "Countries" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyCountriesUpdate" AFTER UPDATE ON "Countries" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyCountriesDelete" AFTER DELETE ON "Countries" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Sites triggers
CREATE TRIGGER "UpdateSitesUpdatedAt" BEFORE UPDATE ON "Sites" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifySitesInsert" AFTER INSERT ON "Sites" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifySitesUpdate" AFTER UPDATE ON "Sites" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifySitesDelete" AFTER DELETE ON "Sites" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Areas triggers
CREATE TRIGGER "UpdateAreasUpdatedAt" BEFORE UPDATE ON "Areas" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyAreasInsert" AFTER INSERT ON "Areas" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyAreasUpdate" AFTER UPDATE ON "Areas" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyAreasDelete" AFTER DELETE ON "Areas" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Levels triggers
CREATE TRIGGER "UpdateLevelsUpdatedAt" BEFORE UPDATE ON "Levels" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyLevelsInsert" AFTER INSERT ON "Levels" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyLevelsUpdate" AFTER UPDATE ON "Levels" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyLevelsDelete" AFTER DELETE ON "Levels" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Zones triggers
CREATE TRIGGER "UpdateZonesUpdatedAt" BEFORE UPDATE ON "Zones" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyZonesInsert" AFTER INSERT ON "Zones" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyZonesUpdate" AFTER UPDATE ON "Zones" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyZonesDelete" AFTER DELETE ON "Zones" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Devices triggers
CREATE TRIGGER "UpdateDevicesUpdatedAt" BEFORE UPDATE ON "Devices" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyDevicesInsert" AFTER INSERT ON "Devices" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyDevicesUpdate" AFTER UPDATE ON "Devices" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyDevicesDelete" AFTER DELETE ON "Devices" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Assets triggers
CREATE TRIGGER "UpdateAssetsUpdatedAt" BEFORE UPDATE ON "Assets" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyAssetsInsert" AFTER INSERT ON "Assets" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyAssetsUpdate" AFTER UPDATE ON "Assets" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyAssetsDelete" AFTER DELETE ON "Assets" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- AssetDeviceMappings triggers
CREATE TRIGGER "UpdateAssetDeviceMappingsUpdatedAt" BEFORE UPDATE ON "AssetDeviceMappings" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyAssetDeviceMappingsInsert" AFTER INSERT ON "AssetDeviceMappings" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyAssetDeviceMappingsUpdate" AFTER UPDATE ON "AssetDeviceMappings" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyAssetDeviceMappingsDelete" AFTER DELETE ON "AssetDeviceMappings" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- AssetDevices triggers
CREATE TRIGGER "NotifyAssetDevicesInsert" AFTER INSERT ON "AssetDevices" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyAssetDevicesDelete" AFTER DELETE ON "AssetDevices" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- DeviceHierarchies triggers
CREATE TRIGGER "UpdateDeviceHierarchiesUpdatedAt" BEFORE UPDATE ON "DeviceHierarchies" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyDeviceHierarchiesInsert" AFTER INSERT ON "DeviceHierarchies" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyDeviceHierarchiesUpdate" AFTER UPDATE ON "DeviceHierarchies" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyDeviceHierarchiesDelete" AFTER DELETE ON "DeviceHierarchies" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- DevicePermissions triggers
CREATE TRIGGER "UpdateDevicePermissionsUpdatedAt" BEFORE UPDATE ON "DevicePermissions" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyDevicePermissionsInsert" AFTER INSERT ON "DevicePermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyDevicePermissionsUpdate" AFTER UPDATE ON "DevicePermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyDevicePermissionsDelete" AFTER DELETE ON "DevicePermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- DeviceAttributes triggers
CREATE TRIGGER "UpdateDeviceAttributesUpdatedAt" BEFORE UPDATE ON "DeviceAttributes" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyDeviceAttributesInsert" AFTER INSERT ON "DeviceAttributes" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyDeviceAttributesUpdate" AFTER UPDATE ON "DeviceAttributes" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyDeviceAttributesDelete" AFTER DELETE ON "DeviceAttributes" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- TelemetryControl triggers
CREATE TRIGGER "UpdateTelemetryControlUpdatedAt" BEFORE UPDATE ON "TelemetryControl" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyTelemetryControlInsert" AFTER INSERT ON "TelemetryControl" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyTelemetryControlUpdate" AFTER UPDATE ON "TelemetryControl" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyTelemetryControlDelete" AFTER DELETE ON "TelemetryControl" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- FirmwareControl triggers
CREATE TRIGGER "UpdateFirmwareControlUpdatedAt" BEFORE UPDATE ON "FirmwareControl" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyFirmwareControlInsert" AFTER INSERT ON "FirmwareControl" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyFirmwareControlUpdate" AFTER UPDATE ON "FirmwareControl" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyFirmwareControlDelete" AFTER DELETE ON "FirmwareControl" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- FirmwareDeployments triggers
CREATE TRIGGER "UpdateFirmwareDeploymentsUpdatedAt" BEFORE UPDATE ON "FirmwareDeployments" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyFirmwareDeploymentsInsert" AFTER INSERT ON "FirmwareDeployments" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyFirmwareDeploymentsUpdate" AFTER UPDATE ON "FirmwareDeployments" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyFirmwareDeploymentsDelete" AFTER DELETE ON "FirmwareDeployments" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- FirmwareCompatibility triggers
CREATE TRIGGER "UpdateFirmwareCompatibilityUpdatedAt" BEFORE UPDATE ON "FirmwareCompatibility" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyFirmwareCompatibilityInsert" AFTER INSERT ON "FirmwareCompatibility" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyFirmwareCompatibilityUpdate" AFTER UPDATE ON "FirmwareCompatibility" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyFirmwareCompatibilityDelete" AFTER DELETE ON "FirmwareCompatibility" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Applications triggers
CREATE TRIGGER "UpdateApplicationsUpdatedAt" BEFORE UPDATE ON "Applications" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyApplicationsInsert" AFTER INSERT ON "Applications" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyApplicationsUpdate" AFTER UPDATE ON "Applications" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyApplicationsDelete" AFTER DELETE ON "Applications" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Features triggers
CREATE TRIGGER "UpdateFeaturesUpdatedAt" BEFORE UPDATE ON "Features" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyFeaturesInsert" AFTER INSERT ON "Features" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyFeaturesUpdate" AFTER UPDATE ON "Features" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyFeaturesDelete" AFTER DELETE ON "Features" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Rules triggers
CREATE TRIGGER "UpdateRulesUpdatedAt" BEFORE UPDATE ON "Rules" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyRulesInsert" AFTER INSERT ON "Rules" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyRulesUpdate" AFTER UPDATE ON "Rules" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyRulesDelete" AFTER DELETE ON "Rules" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- ApplicationPermissions triggers
CREATE TRIGGER "UpdateApplicationPermissionsUpdatedAt" BEFORE UPDATE ON "ApplicationPermissions" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyApplicationPermissionsInsert" AFTER INSERT ON "ApplicationPermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyApplicationPermissionsUpdate" AFTER UPDATE ON "ApplicationPermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyApplicationPermissionsDelete" AFTER DELETE ON "ApplicationPermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Roles triggers
CREATE TRIGGER "UpdateRolesUpdatedAt" BEFORE UPDATE ON "Roles" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyRolesInsert" AFTER INSERT ON "Roles" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyRolesUpdate" AFTER UPDATE ON "Roles" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyRolesDelete" AFTER DELETE ON "Roles" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- RolePermissions triggers
CREATE TRIGGER "NotifyRolePermissionsInsert" AFTER INSERT ON "RolePermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyRolePermissionsDelete" AFTER DELETE ON "RolePermissions" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- UserRoleMappings triggers
CREATE TRIGGER "UpdateUserRoleMappingsUpdatedAt" BEFORE UPDATE ON "UserRoleMappings" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyUserRoleMappingsInsert" AFTER INSERT ON "UserRoleMappings" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyUserRoleMappingsUpdate" AFTER UPDATE ON "UserRoleMappings" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyUserRoleMappingsDelete" AFTER DELETE ON "UserRoleMappings" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- SessionLogs triggers (no UpdatedAt trigger as this table doesn't have UpdatedAt column)
CREATE TRIGGER "NotifySessionLogsInsert" AFTER INSERT ON "SessionLogs" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifySessionLogsDelete" AFTER DELETE ON "SessionLogs" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Alarms triggers
CREATE TRIGGER "UpdateAlarmsUpdatedAt" BEFORE UPDATE ON "Alarms" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyAlarmsInsert" AFTER INSERT ON "Alarms" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyAlarmsUpdate" AFTER UPDATE ON "Alarms" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyAlarmsDelete" AFTER DELETE ON "Alarms" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

-- Notifications triggers
CREATE TRIGGER "UpdateNotificationsUpdatedAt" BEFORE UPDATE ON "Notifications" FOR EACH ROW EXECUTE FUNCTION "UpdateUpdatedAtColumn"();
CREATE TRIGGER "NotifyNotificationsInsert" AFTER INSERT ON "Notifications" FOR EACH ROW EXECUTE FUNCTION "NotifyInsertTrigger"();
CREATE TRIGGER "NotifyNotificationsUpdate" AFTER UPDATE ON "Notifications" FOR EACH ROW EXECUTE FUNCTION "NotifyUpdateTrigger"();
CREATE TRIGGER "NotifyNotificationsDelete" AFTER DELETE ON "Notifications" FOR EACH ROW EXECUTE FUNCTION "NotifyDeleteTrigger"();

