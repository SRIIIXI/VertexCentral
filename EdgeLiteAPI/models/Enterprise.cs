using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using EdgeLiteAPI.Models;

namespace EdgeLiteAPI.Models
{
    public class Enterprise
    {
        [Required]
        [StringLength(64)]
        public string EnterpriseId { get; set; } = string.Empty;

        [Required]
        [StringLength(64)]
        public string EnterpriseName { get; set; } = string.Empty;

        [StringLength(255)]
        public string Description { get; set; } = string.Empty;

        [Phone]
        [StringLength(31)]
        public string ContactMo { get; set; } = string.Empty;

        [EmailAddress]
        [StringLength(256)]
        public string ContactEmail { get; set; } = string.Empty;

        [StringLength(64)]
        public string ContactFirstName { get; set; } = string.Empty;

        [StringLength(64)]
        public string ContactLastName { get; set; } = string.Empty;

        public ulong UnixTimestampCreated { get; set; }

        [StringLength(1024)]
        public string WhitelabelText { get; set; } = string.Empty;

        [StringLength(256)]
        public string AddressLine1 { get; set; } = string.Empty;

        [StringLength(256)]
        public string AddressLine2 { get; set; } = string.Empty;

        [StringLength(32)]
        public string AddressCity { get; set; } = string.Empty;

        [StringLength(32)]
        public string AddressState { get; set; } = string.Empty;

        [StringLength(32)]
        public string AddressCountry { get; set; } = string.Empty;

        [StringLength(16)]
        public string AddressPinCode { get; set; } = string.Empty;

        public bool IsActive { get; set; }

        public bool IsSystem { get; set; }
    }
}