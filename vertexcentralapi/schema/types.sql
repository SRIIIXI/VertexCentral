-- Create custom data types for enums
CREATE TYPE "SiteTypeEnum" AS ENUM ('I', 'O'); -- Indoor, Outdoor
CREATE TYPE "AlarmTypeEnum" AS ENUM ('C', 'W', 'I'); -- Critical, Warning, Info
CREATE TYPE "NotificationTypeEnum" AS ENUM ('A', 'T', 'E'); -- Alarm, Telemetry, Event
CREATE TYPE "TelemetryDataTypeEnum" AS ENUM ('S', 'N', 'B', 'L'); -- String, Number, Boolean, Location
CREATE TYPE "PermissionTypeEnum" AS ENUM ('R', 'W', 'E', 'D', 'A'); -- 'READ', 'WRITE', 'EXECUTE', 'DELETE', 'ADMIN'
CREATE TYPE "DeviceTypeEnum" AS ENUM ('SENSOR', 'ACTUATOR', 'CONTROLLER', 'GATEWAY', 'VIRTUAL', 'OTHER'); -- 'SENSOR', 'ACTUATOR', 'CONTROLLER', 'GATEWAY', 'VIRTUAL', 'OTHER'
CREATE TYPE "DeviceSubTypeEnum" AS ENUM ('TEMPERATURE_SENSOR', 'HUMIDITY_SENSOR', 'PRESSURE_SENSOR', 'LIGHT_SENSOR', 'MOTION_SENSOR', 'OTHER');
CREATE TYPE "InventoryLifeCycleEnum" AS ENUM ('N', 'I', 'D', 'R', 'L'); -- 'NEW', 'IN_USE', 'DECOMMISSIONED', 'RETIRED', 'LOST'
CREATE TYPE "DeviceAttributeTypeEnum" AS ENUM ('S', 'N', 'B', 'L'); -- String, Number, Boolean, Location
CREATE TYPE "RuleTypeEnum" AS ENUM ('A', 'C', 'E'); -- Automation, Condition, Event
CREATE TYPE "TelemetryFileStatusEnum" AS ENUM ('A', 'C', 'A', 'R', 'D'); -- 'ACTIVE', 'CLOSED', 'ARCHIVED', 'CORRUPTED', 'DELETED'
CREATE TYPE "FirmwareType" AS ENUM ('B', 'C', 'D', 'M'); -- Application binary, Comfiguration, Data, Machine Learning Model
CREATE TYPE "FirmwareFileStatusEnum" AS ENUM ('U', 'V', 'A', 'D', 'E', 'R'); -- 'UPLOADED', 'VERIFIED', 'APPROVED', 'DEPLOYED', 'DEPRECATED', 'CORRUPTED'
CREATE TYPE "FirmwareTargetTypeEnum" AS ENUM ('D', 'A'); -- 'DEVICE', 'ASSET'
CREATE TYPE "FirmwareDeploymentStatusEnum" AS ENUM ('P', 'I', 'S', 'F', 'K'); -- 'PENDING', 'IN_PROGRESS', 'SUCCESS', 'FAILED', 'ROLLED_BACK'
CREATE TYPE "RoleTypeEnum" AS ENUM ('S', 'E', 'A', 'D', 'G', 'F'); -- System Admin, Enterprise Admin, Agent, Data Analyst, Guest, Field Device 

-- Create composite type for coordinates
CREATE TYPE "CoordinateType" AS (
    "Latitude" DOUBLE PRECISION,
    "Longitude" DOUBLE PRECISION,
    "Altitude" DOUBLE PRECISION
);
