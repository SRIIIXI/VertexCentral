using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Zone
    {
        [Required]
        [StringLength(64)]
        public string ZoneId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string ZoneName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public Coordinate[] ZonePoints { get; set; } = new Coordinate[ModelConstants.MaxPolygonPoints];

        public uint ZonePointsCount { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
        public bool IsDeleted { get; set; }
    }
}