
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;

public class DeviceHierarchyRepository : RepositoryBase
{
    public DeviceHierarchyRepository() : base("DeviceHierarchies")
    {
    }
    
    public void Initialize(DataInterface? dataInterface)
    {
        selfReference = this;
        selfReference.connection = dataInterface;
    }
    public override String GetInsertSQL()
    {
        return "";
    }
    
    public override String GetUpdateSQL()
    {
        return "";
    }
}