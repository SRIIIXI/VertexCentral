using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Cluster
    {
        [Required]
        [StringLength(64)]
        public string ClusterId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string ClusterName { get; set; } = string.Empty;

        [StringLength(256)]
        public string Description { get; set; } = string.Empty;

        [StringLength(64)]
        public string EnterpriseId { get; set; } = string.Empty;

        public uint ClusterCount { get; set; }

        public Site[] Sites { get; set; } = new Site[ModelConstants.MaxSites];

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }

        public bool IsDeleted { get; set; }
    }
}