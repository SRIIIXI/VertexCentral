using System;
using System.Data;
using System.Data.Common;

public interface HandlerBase
{
    public static abstract void Initialize(RepositoryBase repository, DataInterface idataInterface);
}