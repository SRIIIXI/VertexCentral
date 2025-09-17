using System;
using System.Data;
using System.Data.Common;

public abstract class RepositoryBase
{
    public DataInterface? connection = null;
    public RepositoryBase? selfReference = null;
    private String tableName = String.Empty;
    private String id = String.Empty;
    private Int32 pageSize = 10;
    private Int32 pageNumber = 1;

    public RepositoryBase(String tableName)
    {
        this.tableName = tableName;
    }

    public String TableName
    {
        get { return tableName; }
    }

    public String Id
    {
        get { return id; }
        set { id = value; }
    }
    public Int32 PageSize
    {
        get { return pageSize; }
        set { pageSize = value; }
    }
    public Int32 PageNumber
    {
        get { return pageNumber; }
        set { pageNumber = value; }
    }
}