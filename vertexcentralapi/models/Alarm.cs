using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Alarm
    {
        [Required]
        [StringLength(64)]
        public string AlarmId { get; set; } = string.Empty;

        [StringLength(64)]
        public string DeviceId { get; set; } = string.Empty;

        public ulong UnixTimestamp { get; set; }

        public AlarmType AlarmType { get; set; }

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public Telemetry[]? RelatedTelemetry { get; set; }

        public uint RelatedTelemetryCount { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}