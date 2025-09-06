using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Site
    {
        [Required]
        [StringLength(64)]
        public string SiteId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string SiteName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        public SiteType SiteType { get; set; }

        public uint SiteLevelCount { get; set; }

        public Level[] Levels { get; set; } = new Level[ModelConstants.MaxLevels];

        public bool IsMasterSite { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}