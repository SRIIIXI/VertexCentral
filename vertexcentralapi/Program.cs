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
using System.Data.Common;
using Npgsql;
using Microsoft.AspNetCore.Http.Features;
using Microsoft.AspNetCore.Hosting.Server.Features;

public class Program
{
    static private DataInterface? dataInterface = null;
    static private AlarmRepository? alarmRepository = null;      
    static  private ApplicationRepository? applicationRepository = null;
    static private ApplicationPermissionRepository? applicationPermissionRepository = null;
    static private AreaRepository? areaRepository = null;
    static private AssetRepository? assetRepository = null;
    static private AssetToDeviceMappingRepository? assetToDeviceMappingRepository = null;
    static private ClusterRepository? clusterRepository = null;
    static private DeviceAttributeRepository? deviceAttributeRepository = null;
    static private DeviceRepository? deviceRepository = null;
    static private DeviceHierarchyRepository? deviceHierarchyRepository = null;
    static private DevicePermissionRepository? devicePermissionRepository = null;
    static private EnterpriseRepository? enterpriseRepository = null;
    static private FeatureRepository? featureRepository = null;
    static private LevelRepository? levelRepository = null;
    static private SessionLogRepository? loginSessionRepository = null;
    static private NotificationRepository? notificationRepository = null;
    static private RoleRepository? roleRepository = null;
    static private RuleRepository? ruleRepository = null;
    static private SiteRepository? siteRepository = null;
    static private TelemetryRepository? telemetryRepository = null;
    static private UserRepository? userRepository = null;
    static private UserToRoleMappingRepository? userToRoleMappingRepository = null;
    static private ZoneRepository? zoneRepository = null; 

    public static void Main(string[] args)
    {
        Microsoft.AspNetCore.Hosting.IWebHostBuilder hostBuilder = Microsoft.AspNetCore.WebHost.CreateDefaultBuilder(args);

        hostBuilder.ConfigureServices(services =>
        {
            services.AddCors(); // ✅ Required for UseCors to work
        });

        WebHostConfiguration.Configure(hostBuilder);

        Microsoft.AspNetCore.Hosting.IWebHost host = hostBuilder.Build();

        // Open the database connection
        string connectionString = "Host=localhost;Username=vertexcentral;Password=vertexcentral@1974#0311;Database=VertexCentral";

        dataInterface = new DataInterface(connectionString);

        if (dataInterface.OpenConnection())
        {
            Console.WriteLine("Database connection established.");
        }
        else
        {
            Console.WriteLine("Failed to establish database connection.");
            return; // Exit if the database connection cannot be established
        }

        if(!dataInterface.LoadTableNames())
        {
            Console.WriteLine("Failed to load table names from the database.");
            dataInterface.CloseConnection();
            return; // Exit if table names cannot be loaded
        }

        Initialize();

        host.Start();

        IServerAddressesFeature addresses = host.ServerFeatures.Get<Microsoft.AspNetCore.Hosting.Server.Features.IServerAddressesFeature>();
        if (addresses != null && addresses.Addresses.Any())
        {
            foreach (String address in addresses.Addresses)
            {
                Console.WriteLine($"Listening on: {address}");
            }
        }

        Console.WriteLine("Web service is running. Press Ctrl+C to shut down.");
        host.WaitForShutdown();
    }

    private static void Initialize()
    {
        if (dataInterface == null)
        {
            Console.WriteLine("DataInterface is not initialized.");
            return;
        }

        alarmRepository = new AlarmRepository();
        applicationRepository = new ApplicationRepository();
        applicationPermissionRepository = new ApplicationPermissionRepository();
        areaRepository = new AreaRepository();
        assetRepository = new AssetRepository();
        assetToDeviceMappingRepository = new AssetToDeviceMappingRepository();
        clusterRepository = new ClusterRepository();
        deviceAttributeRepository = new DeviceAttributeRepository();
        deviceRepository = new DeviceRepository();
        deviceHierarchyRepository = new DeviceHierarchyRepository();
        devicePermissionRepository = new DevicePermissionRepository();
        enterpriseRepository = new EnterpriseRepository();
        featureRepository = new FeatureRepository();
        levelRepository = new LevelRepository();
        loginSessionRepository = new SessionLogRepository();
        notificationRepository = new NotificationRepository();
        roleRepository = new RoleRepository();
        ruleRepository = new RuleRepository();
        siteRepository = new SiteRepository();
        telemetryRepository = new TelemetryRepository();
        userRepository = new UserRepository();
        userToRoleMappingRepository = new UserToRoleMappingRepository();
        zoneRepository = new ZoneRepository();

        alarmRepository.Initialize(dataInterface);
        applicationRepository.Initialize(dataInterface);
        applicationPermissionRepository.Initialize(dataInterface);
        areaRepository.Initialize(dataInterface);
        assetRepository.Initialize(dataInterface);
        assetToDeviceMappingRepository.Initialize(dataInterface);
        clusterRepository.Initialize(dataInterface);
        deviceAttributeRepository.Initialize(dataInterface);
        deviceRepository.Initialize(dataInterface);
        deviceHierarchyRepository.Initialize(dataInterface);
        devicePermissionRepository.Initialize(dataInterface);
        enterpriseRepository.Initialize(dataInterface);
        featureRepository.Initialize(dataInterface);
        levelRepository.Initialize(dataInterface);
        loginSessionRepository.Initialize(dataInterface);
        notificationRepository.Initialize(dataInterface);
        roleRepository.Initialize(dataInterface);
        ruleRepository.Initialize(dataInterface);
        siteRepository.Initialize(dataInterface);
        telemetryRepository.Initialize(dataInterface);
        userRepository.Initialize(dataInterface);
        userToRoleMappingRepository.Initialize(dataInterface);
        zoneRepository.Initialize(dataInterface);

        SessionLogHandler.Initialize(loginSessionRepository, dataInterface);
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

        app.UseCors(policy =>
            policy.SetIsOriginAllowed(origin =>
            {
                Console.WriteLine($"Origin: {origin}");
                return origin.StartsWith("http://localhost") ||
                    origin.StartsWith("http://127.0.0.1") ||
                    origin.StartsWith("http://192.168.");
            })
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowAnyOrigin());

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

        endpoints.MapGet("/api/v1/sessionlog", SessionLogHandler.GetAll);
        endpoints.MapGet("/api/v1/sessionlog/{id}", SessionLogHandler.Get);

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

