using System;
using System.Data;
using System.Data.Common;
using Npgsql;

public class DataInterface
{
    private DbConnection? dataConnection = null;
    private String? connectionString = null;

    private List<String> tableNames = new List<String>();

    public DataInterface()
    {
        tableNames.Clear();
    }

    public DataInterface(String iConnectionString)
    {
        connectionString = iConnectionString;
        tableNames.Clear();
    }

    public Boolean OpenConnection()
    {
        tableNames.Clear();
        try
        {
            dataConnection = new NpgsqlConnection(connectionString);
            dataConnection.Open();
            Console.WriteLine($"Connection to edgelite database opened successfully!");
            Console.WriteLine($"Connection object type: {dataConnection.GetType().Name}");
            LoadTableNames();
            return true;
        }
        catch (Exception ex)
        {
            Console.WriteLine($"An error occurred: {ex.Message}");
        }
        finally
        {
            if (dataConnection != null && dataConnection.State == System.Data.ConnectionState.Open)
            {
                dataConnection.Close();
                Console.WriteLine("Connection closed.");
            }
            dataConnection?.Dispose();
        }
        return false;
    }
    public void CloseConnection()
    {
        if (dataConnection != null)
        {
            if (dataConnection.State == ConnectionState.Open)
            {
                dataConnection.Close();
                Console.WriteLine("Connection closed.");
            }
            dataConnection.Dispose();
            dataConnection = null;
        }
    }

    void LoadTableNames()
    {
        tableNames.Clear();
        if (dataConnection == null || dataConnection.State != ConnectionState.Open)
            throw new InvalidOperationException("Data connection is not open.");

        using (var command = dataConnection.CreateCommand())
        {
            command.CommandText = "SELECT table_name FROM information_schema.tables WHERE table_schema='public'";
            using (var reader = command.ExecuteReader())
            {
                while (reader.Read())
                {
                    tableNames.Add(reader.GetString(0));
                }
            }
        }
    }

    Boolean CreateTable(String tableName, String createTableSql)
    {
        if (String.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("Table name cannot be null or whitespace.", nameof(tableName));
        if (String.IsNullOrWhiteSpace(createTableSql))
            throw new ArgumentException("Create table SQL cannot be null or whitespace.", nameof(createTableSql));

        try
        {
            using (var command = dataConnection.CreateCommand())
            {
                command.CommandText = $"SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=@tableName";
                var param = command.CreateParameter();
                param.ParameterName = "@tableName";
                param.Value = tableName;
                command.Parameters.Add(param);

                var count = Convert.ToInt32(command.ExecuteScalar());
                if (count == 0)
                {
                    command.CommandText = createTableSql;
                    command.Parameters.Clear();
                    command.ExecuteNonQuery();
                    return true; // Table created
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error creating table {tableName}: {ex.Message}");
            return false; // Error occurred
        }

        return false; // Table already exists
    }

    Boolean DropTable(String tableName)
    {
        if (String.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("Table name cannot be null or whitespace.", nameof(tableName));

        try
        {
            using (var command = dataConnection.CreateCommand())
            {
                command.CommandText = $"DROP TABLE IF EXISTS {tableName}";
                command.ExecuteNonQuery();
                return true; // Table dropped or did not exist
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error dropping table {tableName}: {ex.Message}");
            return false; // Error occurred
        }
    }

    Boolean ClearTable(String tableName)
    {
        if (String.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("Table name cannot be null or whitespace.", nameof(tableName));

        try
        {
            using (var command = dataConnection.CreateCommand())
            {
                command.CommandText = $"DELETE FROM {tableName}";
                command.ExecuteNonQuery();
                return true; // Table cleared
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error clearing table {tableName}: {ex.Message}");
            return false; // Error occurred
        }
    }

    Boolean TableExists(String tableName)
    {
        if (String.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("Table name cannot be null or whitespace.", nameof(tableName));

        try
        {
            using (var command = dataConnection.CreateCommand())
            {
                command.CommandText = $"SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=@tableName";
                var param = command.CreateParameter();
                param.ParameterName = "@tableName";
                param.Value = tableName;
                command.Parameters.Add(param);

                var count = Convert.ToInt32(command.ExecuteScalar());
                return count > 0; // Table exists if count > 0
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error checking existence of table {tableName}: {ex.Message}");
            return false; // Error occurred
        }
    }

    Boolean IsTableEmpty(String tableName)
    {
        if (String.IsNullOrWhiteSpace(tableName))
            throw new ArgumentException("Table name cannot be null or whitespace.", nameof(tableName));

        try
        {
            using (var command = dataConnection.CreateCommand())
            {
                command.CommandText = $"SELECT COUNT(*) FROM {tableName}";
                var count = Convert.ToInt32(command.ExecuteScalar());
                return count == 0; // Table is empty if count == 0
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error checking if table {tableName} is empty: {ex.Message}");
            return false; // Error occurred
        }
    }
}