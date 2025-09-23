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
CREATE TYPE "FirmwareType" AS ENUM ('B', 'C', 'D', 'M'); -- Application binary, Comfiguration, Data, Machine Learning Model
CREATE TYPE "FirmwareFileStatusEnum" AS ENUM ('UPLOADED', 'VERIFIED', 'APPROVED', 'DEPLOYED', 'DEPRECATED', 'CORRUPTED');
CREATE TYPE "FirmwareTargetTypeEnum" AS ENUM ('DEVICE', 'ASSET');
CREATE TYPE "FirmwareDeploymentStatusEnum" AS ENUM ('PENDING', 'IN_PROGRESS', 'SUCCESS', 'FAILED', 'ROLLED_BACK');

-- Create composite type for coordinates
CREATE TYPE "CoordinateType" AS (
    "Latitude" DOUBLE PRECISION,
    "Longitude" DOUBLE PRECISION,
    "Altitude" DOUBLE PRECISION
);
