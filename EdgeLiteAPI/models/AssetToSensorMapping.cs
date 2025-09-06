using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class AssetToSensorMapping
    {
        [Required]
        [StringLength(64)]
        public string AssetSensorMappingId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string AssetId { get; set; } = string.Empty;

        public Device[] SensorList { get; set; } = new Device[ModelConstants.MaxSensorsPerAsset];

        public uint SensorCount { get; set; }

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}