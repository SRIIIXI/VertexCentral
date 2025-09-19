using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class UserToRoleMapping
    {
        [Required]
        [StringLength(64)]
        public string UserRoleMappingId { get; set; } = string.Empty;

        [StringLength(64)]
        public string UserId { get; set; } = string.Empty;

        [StringLength(64)]
        public string RoleId { get; set; } = string.Empty;

        public ulong UnixTimestampCreated { get; set; }

        public ulong UnixTimestampUpdated { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
        public bool IsDeleted { get; set; }
    }
}