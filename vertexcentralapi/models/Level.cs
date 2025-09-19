using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Level
    {
        [Required]
        [StringLength(64)]
        public string LevelId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string LevelName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public uint LevelNumber { get; set; }

        public Area Bounds { get; set; } = new Area();

        public Zone[] Zones { get; set; } = new Zone[ModelConstants.MaxZones];

        public uint ZonesCount { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}