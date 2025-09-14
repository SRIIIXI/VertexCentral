using System;
using System.Data;
using System.Data.Common;

public class DataInterface
{
    private string connectionString;
    public DataInterface()
    {

    }

    public DataInterface(String iconnectionString)
    {
        connectionString = iconnectionString;
    }

    public Boolean OpenConnection()
    {
        return false;
    }

    public void CloseConnection()
    {
        
    }
}