using System;
using System.ComponentModel.DataAnnotations;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    // User
    public class User
    {
        [Required]
        [StringLength(64)]
        public string UserId { get; set; } = string.Empty;

        [StringLength(64)]
        public string EnterpriseId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string UserName { get; set; } = string.Empty;

        [EmailAddress]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        [Phone]
        [StringLength(31)]
        public string ContactMo { get; set; } = string.Empty;

        [StringLength(64)]
        public string FirstName { get; set; } = string.Empty;

        [StringLength(64)]
        public string LastName { get; set; } = string.Empty;

        [StringLength(256)]
        public string PasswordHash { get; set; } = string.Empty;

        [StringLength(256)]
        public string PasswordSalt { get; set; } = string.Empty;

        public ulong UnixTimestampLastLogin { get; set; }

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}