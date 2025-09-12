using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using EdgeLiteAPI.Models;

public class Program
{
    public static void Main(string[] args)
    {
        Microsoft.AspNetCore.Hosting.IWebHostBuilder hostBuilder = Microsoft.AspNetCore.WebHost.CreateDefaultBuilder(args);
        WebHostConfiguration.Configure(hostBuilder);

        Microsoft.AspNetCore.Hosting.IWebHost host = hostBuilder.Build();
        host.Start();
        Console.WriteLine("Web service is running. Press Ctrl+C to shut down.");
        host.WaitForShutdown();
    }
}

public class WebHostConfiguration
{
    public static void Configure(IWebHostBuilder builder)
    {
        builder.Configure(RoutingConfiguration.Configure);
    }
}

public class RoutingConfiguration
{
    public static void Configure(IApplicationBuilder app)
    {
        app.UseRouting();
        app.UseEndpoints(ConfigureEndpoints);
    }

    private static void ConfigureEndpoints(IEndpointRouteBuilder endpoints)
    {
        ConfigureGetEndpoints(endpoints);
        ConfigurePutEndpoints(endpoints);
        ConfigurePostEndpoints(endpoints);
        ConfigureDeleteEndpoints(endpoints);
    }

    private static void ConfigureGetEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapGet("/", RootHandler.GetRoot);

        endpoints.MapGet("/api/v1/alarm", AlarmHandler.GetAll);
        endpoints.MapGet("/api/v1/alarm/{id}", AlarmHandler.Get);

        endpoints.MapGet("/api/v1/application", ApplicationHandler.GetAll);
        endpoints.MapGet("/api/v1/application/{id}", ApplicationHandler.Get);

        endpoints.MapGet("/api/v1/applicationpermission", ApplicationPermissionHandler.GetAll);
        endpoints.MapGet("/api/v1/applicationpermission/{id}", ApplicationPermissionHandler.Get);

        endpoints.MapGet("/api/v1/area", AreaHandler.GetAll);
        endpoints.MapGet("/api/v1/area/{id}", AreaHandler.Get);

        endpoints.MapGet("/api/v1/asset", AssetHandler.GetAll);
        endpoints.MapGet("/api/v1/asset/{id}", AssetHandler.Get);

        endpoints.MapGet("/api/v1/assettodevicemapping", AssetToDeviceMappingHandler.GetAll);
        endpoints.MapGet("/api/v1/assettodevicemapping/{id}", AssetToDeviceMappingHandler.Get);

        endpoints.MapGet("/api/v1/cluster", ClusterHandler.GetAll);
        endpoints.MapGet("/api/v1/cluster/{id}", ClusterHandler.Get);

        endpoints.MapGet("/api/v1/deviceattribute", DeviceAttributeHandler.GetAll);
        endpoints.MapGet("/api/v1/deviceattribute/{id}", DeviceAttributeHandler.Get);

        endpoints.MapGet("/api/v1/device", DeviceHandler.GetAll);
        endpoints.MapGet("/api/v1/device/{id}", DeviceHandler.Get);

        endpoints.MapGet("/api/v1/devicehierarchy", DeviceHierarchyHandler.GetAll);
        endpoints.MapGet("/api/v1/devicehierarchy/{id}", DeviceHierarchyHandler.Get);

        endpoints.MapGet("/api/v1/devicepermission", DevicePermissionHandler.GetAll);
        endpoints.MapGet("/api/v1/devicepermission/{id}", DevicePermissionHandler.Get);

        endpoints.MapGet("/api/v1/enterprise", EnterpriseHandler.GetAll);
        endpoints.MapGet("/api/v1/enterprise/{id}", EnterpriseHandler.Get);

        endpoints.MapGet("/api/v1/feature", FeatureHandler.GetAll);
        endpoints.MapGet("/api/v1/feature/{id}", FeatureHandler.Get);

        endpoints.MapGet("/api/v1/level", LevelHandler.GetAll);
        endpoints.MapGet("/api/v1/level/{id}", LevelHandler.Get);

        endpoints.MapGet("/api/v1/loginsession", LoginSessionHandler.GetAll);
        endpoints.MapGet("/api/v1/loginsession/{id}", LoginSessionHandler.Get);

        endpoints.MapGet("/api/v1/notification", NotificationHandler.GetAll);
        endpoints.MapGet("/api/v1/notification/{id}", NotificationHandler.Get);

        endpoints.MapGet("/api/v1/role", RoleHandler.GetAll);
        endpoints.MapGet("/api/v1/role/{id}", RoleHandler.Get);

        endpoints.MapGet("/api/v1/rule", RuleHandler.GetAll);
        endpoints.MapGet("/api/v1/rule/{id}", RuleHandler.Get);

        endpoints.MapGet("/api/v1/site", SiteHandler.GetAll);
        endpoints.MapGet("/api/v1/site/{id}", SiteHandler.Get);

        endpoints.MapGet("/api/v1/telemetry", TelemetryHandler.GetAll);
        endpoints.MapGet("/api/v1/telemetry/{id}", TelemetryHandler.Get);

        endpoints.MapGet("/api/v1/user", UserHandler.GetAll);
        endpoints.MapGet("/api/v1/user/{id}", UserHandler.Get);

        endpoints.MapGet("/api/v1/usertorolemapping", UserToRoleMappingHandler.GetAll);
        endpoints.MapGet("/api/v1/usertorolemapping/{id}", UserToRoleMappingHandler.Get);

        endpoints.MapGet("/api/v1/zone", ZoneHandler.GetAll);
        endpoints.MapGet("/api/v1/zone/{id}", ZoneHandler.Get);
    }

    private static void ConfigurePutEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPut("/api/v1/application/{id}", ApplicationHandler.Put);
        endpoints.MapPut("/api/v1/applicationpermission/{id}", ApplicationPermissionHandler.Put);
        endpoints.MapPut("/api/v1/area/{id}", AreaHandler.Put);
        endpoints.MapPut("/api/v1/asset/{id}", AssetHandler.Put);
        endpoints.MapPut("/api/v1/assettodevicemapping/{id}", AssetToDeviceMappingHandler.Put);
        endpoints.MapPut("/api/v1/cluster/{id}", ClusterHandler.Put);
        endpoints.MapPut("/api/v1/deviceattribute/{id}", DeviceAttributeHandler.Put);
        endpoints.MapPut("/api/v1/device/{id}", DeviceHandler.Put);
        endpoints.MapPut("/api/v1/devicehierarchy/{id}", DeviceHierarchyHandler.Put);
        endpoints.MapPut("/api/v1/devicepermission/{id}", DevicePermissionHandler.Put);
        endpoints.MapPut("/api/v1/enterprise/{id}", EnterpriseHandler.Put);
        endpoints.MapPut("/api/v1/feature/{id}", FeatureHandler.Put);
        endpoints.MapPut("/api/v1/level/{id}", LevelHandler.Put);
        endpoints.MapPut("/api/v1/role/{id}", RoleHandler.Put);
        endpoints.MapPut("/api/v1/rule/{id}", RuleHandler.Put);
        endpoints.MapPut("/api/v1/site/{id}", SiteHandler.Put);
        endpoints.MapPut("/api/v1/user/{id}", UserHandler.Put);
        endpoints.MapPut("/api/v1/usertorolemapping/{id}", UserToRoleMappingHandler.Put);
        endpoints.MapPut("/api/v1/zone/{id}", ZoneHandler.Put);
    }

    private static void ConfigurePostEndpoints(IEndpointRouteBuilder endpoints)
    {
        endpoints.MapPost("/api/v1/application", ApplicationHandler.Post);
        endpoints.MapPost("/api/v1/applicationpermission", ApplicationPermissionHandler.Post);
        endpoints.MapPost("/api/v1/area", AreaHandler.Post);
        endpoints.MapPost("/api/v1/asset", AssetHandler.Post);
        endpoints.MapPost("/api/v1/assettodevicemapping", AssetToDeviceMappingHandler.Post);
        endpoints.MapPost("/api/v1/cluster", ClusterHandler.Post);
        endpoints.MapPost("/api/v1/deviceattribute", DeviceAttributeHandler.Post);
        endpoints.MapPost("/api/v1/device", DeviceHandler.Post);
        endpoints.MapPost("/api/v1/devicehierarchy", DeviceHierarchyHandler.Post);
        endpoints.MapPost("/api/v1/devicepermission", DevicePermissionHandler.Post);
        endpoints.MapPost("/api/v1/enterprise", EnterpriseHandler.Post);
        endpoints.MapPost("/api/v1/feature", FeatureHandler.Post);
        endpoints.MapPost("/api/v1/level", LevelHandler.Post);
        endpoints.MapPost("/api/v1/role", RoleHandler.Post);
        endpoints.MapPost("/api/v1/rule", RuleHandler.Post);
        endpoints.MapPost("/api/v1/site", SiteHandler.Post);
        endpoints.MapPost("/api/v1/user", UserHandler.Post);
        endpoints.MapPost("/api/v1/usertorolemapping", UserToRoleMappingHandler.Post);
        endpoints.MapPost("/api/v1/zone", ZoneHandler.Post);
    }

    private static void ConfigureDeleteEndpoints(IEndpointRouteBuilder endpoints)
    {      
        endpoints.MapDelete("/api/v1/application/{id}", ApplicationHandler.Delete);
        endpoints.MapDelete("/api/v1/applicationpermission/{id}", ApplicationPermissionHandler.Delete);
        endpoints.MapDelete("/api/v1/area/{id}", AreaHandler.Delete);
        endpoints.MapDelete("/api/v1/asset/{id}", AssetHandler.Delete);
        endpoints.MapDelete("/api/v1/assettodevicemapping/{id}", AssetToDeviceMappingHandler.Delete);
        endpoints.MapDelete("/api/v1/cluster/{id}", ClusterHandler.Delete);
        endpoints.MapDelete("/api/v1/deviceattribute/{id}", DeviceAttributeHandler.Delete);
        endpoints.MapDelete("/api/v1/device/{id}", DeviceHandler.Delete);
        endpoints.MapDelete("/api/v1/devicehierarchy/{id}", DeviceHierarchyHandler.Delete);
        endpoints.MapDelete("/api/v1/devicepermission/{id}", DevicePermissionHandler.Delete);
        endpoints.MapDelete("/api/v1/enterprise/{id}", EnterpriseHandler.Delete);
        endpoints.MapDelete("/api/v1/feature/{id}", FeatureHandler.Delete);
        endpoints.MapDelete("/api/v1/level/{id}", LevelHandler.Delete);
        endpoints.MapDelete("/api/v1/role/{id}", RoleHandler.Delete);
        endpoints.MapDelete("/api/v1/rule/{id}", RuleHandler.Delete);
        endpoints.MapDelete("/api/v1/site/{id}", SiteHandler.Delete);
        endpoints.MapDelete("/api/v1/user/{id}", UserHandler.Delete);
        endpoints.MapDelete("/api/v1/usertorolemapping/{id}", UserToRoleMappingHandler.Delete);
        endpoints.MapDelete("/api/v1/zone/{id}", ZoneHandler.Delete);

    }
}

