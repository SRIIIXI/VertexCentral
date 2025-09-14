using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Area
    {
        [Required]
        [StringLength(64)]
        public string AreaId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string AreaName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public Coordinate[] AreaPoints { get; set; } = new Coordinate[ModelConstants.MaxPolygonPoints];

        public uint AreaPointsCount { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}