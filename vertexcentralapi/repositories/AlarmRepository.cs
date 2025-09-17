
using System;
using System.Threading.Tasks;
using Microsoft.Extensions;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;

public class AlarmRepository : RepositoryBase
{
    public AlarmRepository() : base("Alarms")
    {
    }
    public void Initialize(DataInterface? dataInterface)
    {
        selfReference = this;
        selfReference.connection = dataInterface;
    }

    public override String GetInsertSQL()
    {
        return "INSERT INTO Alarms (Id, Name, Severity) VALUES (@Id, @Name, @Severity)";
    }
    public override String GetUpdateSQL()
    {
        return "UPDATE Alarms SET Name = @Name, Severity = @Severity WHERE Id = @Id";
    }
}