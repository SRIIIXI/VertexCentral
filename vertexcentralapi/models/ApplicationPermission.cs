using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class ApplicationPermission
    {
        [Required]
        [StringLength(64)]
        public string ApplicationPermissionId { get; set; } = string.Empty;

        [StringLength(64)]
        public string ApplicationId { get; set; } = string.Empty;

        [StringLength(64)]
        public string UserId { get; set; } = string.Empty;

        public PermissionType PermissionType { get; set; }

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}