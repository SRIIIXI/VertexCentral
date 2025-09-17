
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;

public class ZoneRepository : RepositoryBase
{
    public ZoneRepository() : base("Zones")
    {
    }
    
    public void Initialize(DataInterface? dataInterface)
    {
        selfReference = this;
        selfReference.connection = dataInterface;
    }
}