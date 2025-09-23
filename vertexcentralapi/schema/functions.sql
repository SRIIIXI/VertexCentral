-- ============================================================================
-- CREATE NOTIFICATION FUNCTIONS FOR pg_notify
-- ============================================================================

-- Generic notification function that sends structured JSON payload
CREATE OR REPLACE FUNCTION "SendDataChangeNotification"(
    "TableName" VARCHAR(64),
    "Operation" VARCHAR(10), -- INSERT, UPDATE, DELETE
    "RecordId" VARCHAR(64),
    "UserId" VARCHAR(64) DEFAULT NULL,
    "AdditionalData" JSONB DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    "NotificationPayload" JSONB;
BEGIN
    -- Build notification payload
    "NotificationPayload" := jsonb_build_object(
        'table', "TableName",
        'operation', "Operation",
        'recordId', "RecordId",
        'userId', "UserId",
        'timestamp', EXTRACT(EPOCH FROM NOW())::BIGINT,
        'data', "AdditionalData"
    );
    
    -- Send notification on channel 'data_changes'
    PERFORM pg_notify('data_changes', "NotificationPayload"::TEXT);
    
    -- Also send on table-specific channel
    PERFORM pg_notify('table_' || LOWER("TableName"), "NotificationPayload"::TEXT);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- CREATE FUNCTIONS AND TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES AND NOTIFICATIONS
-- ============================================================================

-- Function to update the "UpdatedAt" column
CREATE OR REPLACE FUNCTION "UpdateUpdatedAtColumn"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."UpdatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER FUNCTIONS FOR NOTIFICATIONS
-- ============================================================================

-- Generic trigger function for INSERT notifications
CREATE OR REPLACE FUNCTION "NotifyInsertTrigger"()
RETURNS TRIGGER AS $$
DECLARE
    "RecordId" VARCHAR(64);
    "TableName" VARCHAR(64);
BEGIN
    "TableName" := TG_TABLE_NAME;
    
    -- Extract primary key value dynamically
    CASE "TableName"
        WHEN 'Enterprises' THEN "RecordId" := NEW."EnterpriseId";
        WHEN 'Users' THEN "RecordId" := NEW."UserId";
        WHEN 'Countries' THEN "RecordId" := NEW."CountryId";
        WHEN 'Sites' THEN "RecordId" := NEW."SiteId";
        WHEN 'Areas' THEN "RecordId" := NEW."AreaId";
        WHEN 'Levels' THEN "RecordId" := NEW."LevelId";
        WHEN 'Zones' THEN "RecordId" := NEW."ZoneId";
        WHEN 'Devices' THEN "RecordId" := NEW."DeviceId";
        WHEN 'Assets' THEN "RecordId" := NEW."AssetId";
        WHEN 'AssetDeviceMappings' THEN "RecordId" := NEW."AssetDeviceMappingId";
        WHEN 'DeviceHierarchies' THEN "RecordId" := NEW."DeviceHierarchyId";
        WHEN 'DevicePermissions' THEN "RecordId" := NEW."DevicePermissionId";
        WHEN 'DeviceAttributes' THEN "RecordId" := NEW."DeviceAttributeId";
        WHEN 'TelemetryControl' THEN "RecordId" := NEW."TelemetryControlId";
        WHEN 'FirmwareControl' THEN "RecordId" := NEW."FirmwareControlId";
        WHEN 'FirmwareDeployments' THEN "RecordId" := NEW."FirmwareDeploymentId";
        WHEN 'FirmwareCompatibility' THEN "RecordId" := NEW."FirmwareCompatibilityId";
        WHEN 'Applications' THEN "RecordId" := NEW."ApplicationId";
        WHEN 'Features' THEN "RecordId" := NEW."FeatureId";
        WHEN 'Rules' THEN "RecordId" := NEW."RuleId";
        WHEN 'ApplicationPermissions' THEN "RecordId" := NEW."ApplicationPermissionId";
        WHEN 'Roles' THEN "RecordId" := NEW."RoleId";
        WHEN 'UserRoleMappings' THEN "RecordId" := NEW."UserRoleMappingId";
        WHEN 'SessionLogs' THEN "RecordId" := NEW."SessionId";
        WHEN 'Alarms' THEN "RecordId" := NEW."AlarmId";
        WHEN 'Notifications' THEN "RecordId" := NEW."NotificationId";
        WHEN 'AssetDevices' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        WHEN 'RolePermissions' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        ELSE "RecordId" := 'UNKNOWN';
    END CASE;
    
    -- Send notification
    PERFORM "SendDataChangeNotification"("TableName", 'INSERT', "RecordId");
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generic trigger function for UPDATE notifications
CREATE OR REPLACE FUNCTION "NotifyUpdateTrigger"()
RETURNS TRIGGER AS $$
DECLARE
    "RecordId" VARCHAR(64);
    "TableName" VARCHAR(64);
    "ChangedFields" JSONB;
BEGIN
    "TableName" := TG_TABLE_NAME;
    
    -- Extract primary key value dynamically
    CASE "TableName"
        WHEN 'Enterprises' THEN "RecordId" := NEW."EnterpriseId";
        WHEN 'Users' THEN "RecordId" := NEW."UserId";
        WHEN 'Countries' THEN "RecordId" := NEW."CountryId";
        WHEN 'Sites' THEN "RecordId" := NEW."SiteId";
        WHEN 'Areas' THEN "RecordId" := NEW."AreaId";
        WHEN 'Levels' THEN "RecordId" := NEW."LevelId";
        WHEN 'Zones' THEN "RecordId" := NEW."ZoneId";
        WHEN 'Devices' THEN "RecordId" := NEW."DeviceId";
        WHEN 'Assets' THEN "RecordId" := NEW."AssetId";
        WHEN 'AssetDeviceMappings' THEN "RecordId" := NEW."AssetDeviceMappingId";
        WHEN 'DeviceHierarchies' THEN "RecordId" := NEW."DeviceHierarchyId";
        WHEN 'DevicePermissions' THEN "RecordId" := NEW."DevicePermissionId";
        WHEN 'DeviceAttributes' THEN "RecordId" := NEW."DeviceAttributeId";
        WHEN 'TelemetryControl' THEN "RecordId" := NEW."TelemetryControlId";
        WHEN 'Applications' THEN "RecordId" := NEW."ApplicationId";
        WHEN 'Features' THEN "RecordId" := NEW."FeatureId";
        WHEN 'Rules' THEN "RecordId" := NEW."RuleId";
        WHEN 'ApplicationPermissions' THEN "RecordId" := NEW."ApplicationPermissionId";
        WHEN 'Roles' THEN "RecordId" := NEW."RoleId";
        WHEN 'UserRoleMappings' THEN "RecordId" := NEW."UserRoleMappingId";
        WHEN 'SessionLogs' THEN "RecordId" := NEW."SessionId";
        WHEN 'Alarms' THEN "RecordId" := NEW."AlarmId";
        WHEN 'Notifications' THEN "RecordId" := NEW."NotificationId";
        WHEN 'AssetDevices' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        WHEN 'RolePermissions' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        ELSE "RecordId" := 'UNKNOWN';
    END CASE;
    
    -- Build changed fields JSON (simplified - can be enhanced to show specific field changes)
    "ChangedFields" := jsonb_build_object('hasChanges', true);
    
    -- Send notification
    PERFORM "SendDataChangeNotification"("TableName", 'UPDATE', "RecordId", NULL, "ChangedFields");
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generic trigger function for DELETE notifications
CREATE OR REPLACE FUNCTION "NotifyDeleteTrigger"()
RETURNS TRIGGER AS $$
DECLARE
    "RecordId" VARCHAR(64);
    "TableName" VARCHAR(64);
BEGIN
    "TableName" := TG_TABLE_NAME;
    
    -- Extract primary key value dynamically from OLD record
    CASE "TableName"
        WHEN 'Enterprises' THEN "RecordId" := OLD."EnterpriseId";
        WHEN 'Users' THEN "RecordId" := OLD."UserId";
        WHEN 'Countries' THEN "RecordId" := OLD."CountryId";
        WHEN 'Sites' THEN "RecordId" := OLD."SiteId";
        WHEN 'Areas' THEN "RecordId" := OLD."AreaId";
        WHEN 'Levels' THEN "RecordId" := OLD."LevelId";
        WHEN 'Zones' THEN "RecordId" := OLD."ZoneId";
        WHEN 'Devices' THEN "RecordId" := OLD."DeviceId";
        WHEN 'Assets' THEN "RecordId" := OLD."AssetId";
        WHEN 'AssetDeviceMappings' THEN "RecordId" := OLD."AssetDeviceMappingId";
        WHEN 'DeviceHierarchies' THEN "RecordId" := OLD."DeviceHierarchyId";
        WHEN 'DevicePermissions' THEN "RecordId" := OLD."DevicePermissionId";
        WHEN 'DeviceAttributes' THEN "RecordId" := OLD."DeviceAttributeId";
        WHEN 'TelemetryControl' THEN "RecordId" := OLD."TelemetryControlId";
        WHEN 'FirmwareControl' THEN "RecordId" := OLD."FirmwareControlId";
        WHEN 'FirmwareDeployments' THEN "RecordId" := OLD."FirmwareDeploymentId";
        WHEN 'FirmwareCompatibility' THEN "RecordId" := OLD."FirmwareCompatibilityId";
        WHEN 'Applications' THEN "RecordId" := OLD."ApplicationId";
        WHEN 'Features' THEN "RecordId" := OLD."FeatureId";
        WHEN 'Rules' THEN "RecordId" := OLD."RuleId";
        WHEN 'ApplicationPermissions' THEN "RecordId" := OLD."ApplicationPermissionId";
        WHEN 'Roles' THEN "RecordId" := OLD."RoleId";
        WHEN 'UserRoleMappings' THEN "RecordId" := OLD."UserRoleMappingId";
        WHEN 'SessionLogs' THEN "RecordId" := OLD."SessionId";
        WHEN 'Alarms' THEN "RecordId" := OLD."AlarmId";
        WHEN 'Notifications' THEN "RecordId" := OLD."NotificationId";
        WHEN 'AssetDevices' THEN "RecordId" := OLD."Id"::VARCHAR(64);
        WHEN 'RolePermissions' THEN "RecordId" := OLD."Id"::VARCHAR(64);
        ELSE "RecordId" := 'UNKNOWN';
    END CASE;
    
    -- Send notification
    PERFORM "SendDataChangeNotification"("TableName", 'DELETE', "RecordId");
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


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
) AS $$
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
$$ LANGUAGE plpgsql;

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
) AS $$
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
$$ LANGUAGE plpgsql;

-- Function to start firmware deployment
CREATE OR REPLACE FUNCTION "StartFirmwareDeployment"(
    "FirmwareControlIdParam" VARCHAR(64),
    "TargetTypeParam" "FirmwareTargetTypeEnum",
    "TargetIdParam" VARCHAR(64),
    "UserIdParam" VARCHAR(64),
    "DeploymentMethodParam" VARCHAR(32) DEFAULT 'OTA'
)
RETURNS VARCHAR(64) AS $$
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
$$ LANGUAGE plpgsql;

-- Function to update deployment progress
CREATE OR REPLACE FUNCTION "UpdateFirmwareDeploymentProgress"(
    "DeploymentIdParam" VARCHAR(64),
    "ProgressParam" INTEGER,
    "StatusParam" "FirmwareDeploymentStatusEnum" DEFAULT NULL,
    "ErrorCodeParam" VARCHAR(32) DEFAULT NULL,
    "ErrorMessageParam" TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
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
$$ LANGUAGE plpgsql;

-- Function to initiate firmware rollback
CREATE OR REPLACE FUNCTION "InitiateFirmwareRollback"(
    "FailedDeploymentIdParam" VARCHAR(64),
    "UserIdParam" VARCHAR(64)
)
RETURNS VARCHAR(64) AS $$
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
$$ LANGUAGE plpgsql;

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
) AS $$
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
$$ LANGUAGE plpgsql;

-- Function to get pending firmware deployments for retry
CREATE OR REPLACE FUNCTION "GetPendingFirmwareRetries"()
RETURNS TABLE(
    "FirmwareDeploymentId" VARCHAR(64),
    "TargetType" "FirmwareTargetTypeEnum",
    "TargetId" VARCHAR(64),
    "RetryCount" INTEGER,
    "NextRetryAt" TIMESTAMP WITH TIME ZONE
) AS $$
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
$$ LANGUAGE plpgsql;
-- Generic notification function that sends structured JSON payload
CREATE OR REPLACE FUNCTION "SendDataChangeNotification"(
    "TableName" VARCHAR(64),
    "Operation" VARCHAR(10), -- INSERT, UPDATE, DELETE
    "RecordId" VARCHAR(64),
    "UserId" VARCHAR(64) DEFAULT NULL,
    "AdditionalData" JSONB DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
    "NotificationPayload" JSONB;
BEGIN
    -- Build notification payload
    "NotificationPayload" := jsonb_build_object(
        'table', "TableName",
        'operation', "Operation",
        'recordId', "RecordId",
        'userId', "UserId",
        'timestamp', EXTRACT(EPOCH FROM NOW())::BIGINT,
        'data', "AdditionalData"
    );
    
    -- Send notification on channel 'data_changes'
    PERFORM pg_notify('data_changes', "NotificationPayload"::TEXT);
    
    -- Also send on table-specific channel
    PERFORM pg_notify('table_' || LOWER("TableName"), "NotificationPayload"::TEXT);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- CREATE FUNCTIONS AND TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES AND NOTIFICATIONS
-- ============================================================================

-- Function to update the "UpdatedAt" column
CREATE OR REPLACE FUNCTION "UpdateUpdatedAtColumn"()
RETURNS TRIGGER AS $$
BEGIN
    NEW."UpdatedAt" = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TRIGGER FUNCTIONS FOR NOTIFICATIONS
-- ============================================================================

-- Generic trigger function for INSERT notifications
CREATE OR REPLACE FUNCTION "NotifyInsertTrigger"()
RETURNS TRIGGER AS $$
DECLARE
    "RecordId" VARCHAR(64);
    "TableName" VARCHAR(64);
BEGIN
    "TableName" := TG_TABLE_NAME;
    
    -- Extract primary key value dynamically
    CASE "TableName"
        WHEN 'Enterprises' THEN "RecordId" := NEW."EnterpriseId";
        WHEN 'Users' THEN "RecordId" := NEW."UserId";
        WHEN 'Countries' THEN "RecordId" := NEW."CountryId";
        WHEN 'Sites' THEN "RecordId" := NEW."SiteId";
        WHEN 'Areas' THEN "RecordId" := NEW."AreaId";
        WHEN 'Levels' THEN "RecordId" := NEW."LevelId";
        WHEN 'Zones' THEN "RecordId" := NEW."ZoneId";
        WHEN 'Devices' THEN "RecordId" := NEW."DeviceId";
        WHEN 'Assets' THEN "RecordId" := NEW."AssetId";
        WHEN 'AssetDeviceMappings' THEN "RecordId" := NEW."AssetDeviceMappingId";
        WHEN 'DeviceHierarchies' THEN "RecordId" := NEW."DeviceHierarchyId";
        WHEN 'DevicePermissions' THEN "RecordId" := NEW."DevicePermissionId";
        WHEN 'DeviceAttributes' THEN "RecordId" := NEW."DeviceAttributeId";
        WHEN 'TelemetryControl' THEN "RecordId" := NEW."TelemetryControlId";
        WHEN 'FirmwareControl' THEN "RecordId" := NEW."FirmwareControlId";
        WHEN 'FirmwareDeployments' THEN "RecordId" := NEW."FirmwareDeploymentId";
        WHEN 'FirmwareCompatibility' THEN "RecordId" := NEW."FirmwareCompatibilityId";
        WHEN 'Applications' THEN "RecordId" := NEW."ApplicationId";
        WHEN 'Features' THEN "RecordId" := NEW."FeatureId";
        WHEN 'Rules' THEN "RecordId" := NEW."RuleId";
        WHEN 'ApplicationPermissions' THEN "RecordId" := NEW."ApplicationPermissionId";
        WHEN 'Roles' THEN "RecordId" := NEW."RoleId";
        WHEN 'UserRoleMappings' THEN "RecordId" := NEW."UserRoleMappingId";
        WHEN 'SessionLogs' THEN "RecordId" := NEW."SessionId";
        WHEN 'Alarms' THEN "RecordId" := NEW."AlarmId";
        WHEN 'Notifications' THEN "RecordId" := NEW."NotificationId";
        WHEN 'AssetDevices' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        WHEN 'RolePermissions' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        ELSE "RecordId" := 'UNKNOWN';
    END CASE;
    
    -- Send notification
    PERFORM "SendDataChangeNotification"("TableName", 'INSERT', "RecordId");
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generic trigger function for UPDATE notifications
CREATE OR REPLACE FUNCTION "NotifyUpdateTrigger"()
RETURNS TRIGGER AS $$
DECLARE
    "RecordId" VARCHAR(64);
    "TableName" VARCHAR(64);
    "ChangedFields" JSONB;
BEGIN
    "TableName" := TG_TABLE_NAME;
    
    -- Extract primary key value dynamically
    CASE "TableName"
        WHEN 'Enterprises' THEN "RecordId" := NEW."EnterpriseId";
        WHEN 'Users' THEN "RecordId" := NEW."UserId";
        WHEN 'Countries' THEN "RecordId" := NEW."CountryId";
        WHEN 'Sites' THEN "RecordId" := NEW."SiteId";
        WHEN 'Areas' THEN "RecordId" := NEW."AreaId";
        WHEN 'Levels' THEN "RecordId" := NEW."LevelId";
        WHEN 'Zones' THEN "RecordId" := NEW."ZoneId";
        WHEN 'Devices' THEN "RecordId" := NEW."DeviceId";
        WHEN 'Assets' THEN "RecordId" := NEW."AssetId";
        WHEN 'AssetDeviceMappings' THEN "RecordId" := NEW."AssetDeviceMappingId";
        WHEN 'DeviceHierarchies' THEN "RecordId" := NEW."DeviceHierarchyId";
        WHEN 'DevicePermissions' THEN "RecordId" := NEW."DevicePermissionId";
        WHEN 'DeviceAttributes' THEN "RecordId" := NEW."DeviceAttributeId";
        WHEN 'TelemetryControl' THEN "RecordId" := NEW."TelemetryControlId";
        WHEN 'Applications' THEN "RecordId" := NEW."ApplicationId";
        WHEN 'Features' THEN "RecordId" := NEW."FeatureId";
        WHEN 'Rules' THEN "RecordId" := NEW."RuleId";
        WHEN 'ApplicationPermissions' THEN "RecordId" := NEW."ApplicationPermissionId";
        WHEN 'Roles' THEN "RecordId" := NEW."RoleId";
        WHEN 'UserRoleMappings' THEN "RecordId" := NEW."UserRoleMappingId";
        WHEN 'SessionLogs' THEN "RecordId" := NEW."SessionId";
        WHEN 'Alarms' THEN "RecordId" := NEW."AlarmId";
        WHEN 'Notifications' THEN "RecordId" := NEW."NotificationId";
        WHEN 'AssetDevices' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        WHEN 'RolePermissions' THEN "RecordId" := NEW."Id"::VARCHAR(64);
        ELSE "RecordId" := 'UNKNOWN';
    END CASE;
    
    -- Build changed fields JSON (simplified - can be enhanced to show specific field changes)
    "ChangedFields" := jsonb_build_object('hasChanges', true);
    
    -- Send notification
    PERFORM "SendDataChangeNotification"("TableName", 'UPDATE', "RecordId", NULL, "ChangedFields");
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generic trigger function for DELETE notifications
CREATE OR REPLACE FUNCTION "NotifyDeleteTrigger"()
RETURNS TRIGGER AS $$
DECLARE
    "RecordId" VARCHAR(64);
    "TableName" VARCHAR(64);
BEGIN
    "TableName" := TG_TABLE_NAME;
    
    -- Extract primary key value dynamically from OLD record
    CASE "TableName"
        WHEN 'Enterprises' THEN "RecordId" := OLD."EnterpriseId";
        WHEN 'Users' THEN "RecordId" := OLD."UserId";
        WHEN 'Countries' THEN "RecordId" := OLD."CountryId";
        WHEN 'Sites' THEN "RecordId" := OLD."SiteId";
        WHEN 'Areas' THEN "RecordId" := OLD."AreaId";
        WHEN 'Levels' THEN "RecordId" := OLD."LevelId";
        WHEN 'Zones' THEN "RecordId" := OLD."ZoneId";
        WHEN 'Devices' THEN "RecordId" := OLD."DeviceId";
        WHEN 'Assets' THEN "RecordId" := OLD."AssetId";
        WHEN 'AssetDeviceMappings' THEN "RecordId" := OLD."AssetDeviceMappingId";
        WHEN 'DeviceHierarchies' THEN "RecordId" := OLD."DeviceHierarchyId";
        WHEN 'DevicePermissions' THEN "RecordId" := OLD."DevicePermissionId";
        WHEN 'DeviceAttributes' THEN "RecordId" := OLD."DeviceAttributeId";
        WHEN 'TelemetryControl' THEN "RecordId" := OLD."TelemetryControlId";
        WHEN 'FirmwareControl' THEN "RecordId" := OLD."FirmwareControlId";
        WHEN 'FirmwareDeployments' THEN "RecordId" := OLD."FirmwareDeploymentId";
        WHEN 'FirmwareCompatibility' THEN "RecordId" := OLD."FirmwareCompatibilityId";
        WHEN 'Applications' THEN "RecordId" := OLD."ApplicationId";
        WHEN 'Features' THEN "RecordId" := OLD."FeatureId";
        WHEN 'Rules' THEN "RecordId" := OLD."RuleId";
        WHEN 'ApplicationPermissions' THEN "RecordId" := OLD."ApplicationPermissionId";
        WHEN 'Roles' THEN "RecordId" := OLD."RoleId";
        WHEN 'UserRoleMappings' THEN "RecordId" := OLD."UserRoleMappingId";
        WHEN 'SessionLogs' THEN "RecordId" := OLD."SessionId";
        WHEN 'Alarms' THEN "RecordId" := OLD."AlarmId";
        WHEN 'Notifications' THEN "RecordId" := OLD."NotificationId";
        WHEN 'AssetDevices' THEN "RecordId" := OLD."Id"::VARCHAR(64);
        WHEN 'RolePermissions' THEN "RecordId" := OLD."Id"::VARCHAR(64);
        ELSE "RecordId" := 'UNKNOWN';
    END CASE;
    
    -- Send notification
    PERFORM "SendDataChangeNotification"("TableName", 'DELETE', "RecordId");
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- TELEMETRY CONTROL MANAGEMENT FUNCTIONS
-- ============================================================================

-- Function to get device telemetry file count
CREATE OR REPLACE FUNCTION "GetDeviceTelemetryFileCount"("DeviceIdParam" VARCHAR(64))
RETURNS INTEGER AS $$
DECLARE
    "FileCount" INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO "FileCount"
    FROM "TelemetryControl"
    WHERE "DeviceId" = "DeviceIdParam"
    AND "IsDeleted" = FALSE;
    
    RETURN COALESCE("FileCount", 0);
END;
$$ LANGUAGE plpgsql;

-- Function to get telemetry files for a device within time range
CREATE OR REPLACE FUNCTION "GetDeviceTelemetryFilesInRange"(
    "DeviceIdParam" VARCHAR(64),
    "StartTimestamp" BIGINT,
    "EndTimestamp" BIGINT
)
RETURNS TABLE(
    "TelemetryControlId" VARCHAR(64),
    "FilePath" VARCHAR(512),
    "FileName" VARCHAR(256),
    "FileStatus" "TelemetryFileStatusEnum",
    "RecordCount" BIGINT,
    "MinTimestamp" BIGINT,
    "MaxTimestamp" BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc."TelemetryControlId",
        tc."FilePath",
        tc."FileName",
        tc."FileStatus",
        tc."RecordCount",
        tc."MinTimestamp",
        tc."MaxTimestamp"
    FROM "TelemetryControl" tc
    WHERE tc."DeviceId" = "DeviceIdParam"
    AND tc."IsDeleted" = FALSE
    AND (
        (tc."MinTimestamp" <= "EndTimestamp" AND tc."MaxTimestamp" >= "StartTimestamp")
        OR (tc."MinTimestamp" IS NULL OR tc."MaxTimestamp" IS NULL) -- Handle null timestamps
    )
    ORDER BY tc."Year", tc."Month", tc."Hour";
END;
$$ LANGUAGE plpgsql;

-- Function to close active telemetry file
CREATE OR REPLACE FUNCTION "CloseTelemetryFile"(
    "TelemetryControlIdParam" VARCHAR(64),
    "FinalRecordCount" BIGINT,
    "FinalFileSize" BIGINT,
    "FinalMaxTimestamp" BIGINT,
    "ChecksumValue" VARCHAR(64)
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE "TelemetryControl"
    SET 
        "FileStatus" = 'CLOSED',
        "RecordCount" = "FinalRecordCount",
        "FileSizeBytes" = "FinalFileSize",
        "MaxTimestamp" = "FinalMaxTimestamp",
        "LastRecordTimestamp" = "FinalMaxTimestamp",
        "FileClosedAt" = CURRENT_TIMESTAMP,
        "Checksum" = "ChecksumValue",
        "UpdatedAt" = CURRENT_TIMESTAMP
    WHERE "TelemetryControlId" = "TelemetryControlIdParam"
    AND "FileStatus" = 'ACTIVE'
    AND "IsDeleted" = FALSE;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Function to archive telemetry files older than specified days
CREATE OR REPLACE FUNCTION "ArchiveOldTelemetryFiles"("DaysOld" INTEGER DEFAULT 30)
RETURNS INTEGER AS $$
DECLARE
    "ArchivedCount" INTEGER;
    "CutoffTimestamp" BIGINT;
BEGIN
    "CutoffTimestamp" := (EXTRACT(EPOCH FROM NOW() - ("DaysOld" || ' days')::INTERVAL))::BIGINT;
    
    UPDATE "TelemetryControl"
    SET 
        "FileStatus" = 'ARCHIVED',
        "UpdatedAt" = CURRENT_TIMESTAMP
    WHERE "FileStatus" = 'CLOSED'
    AND "MaxTimestamp" < "CutoffTimestamp"
    AND "IsDeleted" = FALSE;
    
    GET DIAGNOSTICS "ArchivedCount" = ROW_COUNT;
    RETURN "ArchivedCount";
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- UPDATED UTILITY FUNCTIONS (Removed telemetry table references)
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

-- Function to get latest telemetry file for a device
CREATE OR REPLACE FUNCTION "GetLatestTelemetryFile"("DeviceIdParam" VARCHAR(64))
RETURNS TABLE(
    "TelemetryControlId" VARCHAR(64),
    "FilePath" VARCHAR(512),
    "FileName" VARCHAR(256),
    "FileStatus" "TelemetryFileStatusEnum",
    "RecordCount" BIGINT,
    "MaxTimestamp" BIGINT,
    "LastModified" TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        tc."TelemetryControlId",
        tc."FilePath",
        tc."FileName",
        tc."FileStatus",
        tc."RecordCount",
        tc."MaxTimestamp",
        tc."FileLastModified"
    FROM "TelemetryControl" tc
    WHERE tc."DeviceId" = "DeviceIdParam"
    AND tc."IsDeleted" = FALSE
    ORDER BY tc."MaxTimestamp" DESC NULLS LAST
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- CLEANUP AND MAINTENANCE PROCEDURES (Updated)
-- ============================================================================

-- Procedure to update device connection status based on latest telemetry files
CREATE OR REPLACE FUNCTION "UpdateDeviceConnectionStatus"()
RETURNS VOID AS $$
DECLARE
    "ThresholdTimestamp" BIGINT;
    "UpdatedRows" INTEGER;
BEGIN
    -- Consider devices disconnected if no telemetry files in last 5 minutes
    "ThresholdTimestamp" := (EXTRACT(EPOCH FROM NOW() - INTERVAL '5 minutes'))::BIGINT;
    
    -- Mark devices as disconnected if no recent telemetry
    UPDATE "Devices" 
    SET "IsConnected" = FALSE,
        "UpdatedAt" = CURRENT_TIMESTAMP
    WHERE "IsConnected" = TRUE 
    AND "IsDeleted" = FALSE
    AND "DeviceId" NOT IN (
        SELECT DISTINCT tc."DeviceId" 
        FROM "TelemetryControl" tc
        WHERE tc."MaxTimestamp" > "ThresholdTimestamp" 
        AND tc."IsDeleted" = FALSE
    );
    
    GET DIAGNOSTICS "UpdatedRows" = ROW_COUNT;
    RAISE NOTICE 'Updated connection status for % devices', "UpdatedRows";
END;
$$ LANGUAGE plpgsql;

-- Procedure to clean up old telemetry control records (soft delete)
CREATE OR REPLACE FUNCTION "CleanupOldTelemetryControlRecords"("DaysToKeep" INTEGER DEFAULT 365)
RETURNS VOID AS $$
DECLARE
    "CutoffTimestamp" BIGINT;
    "DeletedRows" INTEGER;
BEGIN
    "CutoffTimestamp" := (EXTRACT(EPOCH FROM NOW() - ("DaysToKeep" || ' days')::INTERVAL))::BIGINT;
    
    UPDATE "TelemetryControl" 
    SET "IsDeleted" = TRUE,
        "UpdatedAt" = CURRENT_TIMESTAMP
    WHERE "MaxTimestamp" < "CutoffTimestamp" 
    AND "FileStatus" = 'ARCHIVED'
    AND "IsDeleted" = FALSE;
    
    GET DIAGNOSTICS "DeletedRows" = ROW_COUNT;
    RAISE NOTICE 'Marked % telemetry control records as deleted (older than % days)', "DeletedRows", "DaysToKeep";
END;
$$ LANGUAGE plpgsql;

