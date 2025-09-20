using System;
using System.IO;
using System.Text;
using System.Runtime.CompilerServices;

public enum LogLevel
{
    Debug,
    Info,
    Warning,
    Error,
    Critical
}

public static class Logger
{
    private static readonly object _lock = new object();
    private static string _logFilePath = "application.log";
    private static bool _logToConsole = true;

    public static void Initialize(bool logToConsole = true)
    {
        _logToConsole = logToConsole;

        if (Environment.OSVersion.Platform == PlatformID.Unix || Environment.OSVersion.Platform == PlatformID.MacOSX)
        {
            if (Environment.UserName == "root")
            {
                _logFilePath = "/var/log/vertexcentralapi.log";
            }
            else
            {
                string homeDir = Environment.GetEnvironmentVariable("HOME") ?? ".";
                string sharedDir = Path.Combine(homeDir, ".shared", "vertexcentralapi");
                if (!Directory.Exists(sharedDir))
                {
                    Directory.CreateDirectory(sharedDir);
                }
                _logFilePath = Path.Combine(sharedDir, "vertexcentralapi.log");
            }
        }
        else
        {
            _logFilePath = "vertexcentralapi.log";
        }
    }

    private static void ArchiveLogFile()
    {
        const long maxLogFileSize = 10 * 1024 * 1024;
        try
        {
            if (File.Exists(_logFilePath))
            {
                FileInfo logFileInfo = new FileInfo(_logFilePath);
                if (logFileInfo.Length > maxLogFileSize)
                {
                    string archiveFilePath = _logFilePath + "." + DateTime.Now.ToString("yyyyMMddHHmmss") + ".bak";
                    File.Move(_logFilePath, archiveFilePath);
                    File.WriteAllText(_logFilePath, $"Log file archived to {archiveFilePath} at {DateTime.Now}\n", Encoding.UTF8);
                }
            }
        }
        catch (Exception ex)
        {
            if (_logToConsole)
            {
                Console.WriteLine($"Failed to check or archive log file: {ex.Message}");
            }
        }
    }

    public static void Log(
        string message,
        LogLevel level,
        string source = "",
        int lineNumber = 0,
        string memberName = "")
    {
        ArchiveLogFile();

        string fileName = string.IsNullOrEmpty(source) ? "unknown" : Path.GetFileName(source);
        string logEntry = $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} [{level}] [{fileName}:{lineNumber} {memberName}] {message}";

        lock (_lock)
        {
            if (_logToConsole)
            {
                Console.WriteLine(logEntry);
            }

            try
            {
                File.AppendAllText(_logFilePath, logEntry + Environment.NewLine, Encoding.UTF8);
            }
            catch (Exception ex)
            {
                if (_logToConsole)
                {
                    Console.WriteLine($"Failed to write to log file: {ex.Message}");
                }
            }
        }
    }

    public static void Debug(
        string message,
        [CallerFilePath] string source = "",
        [CallerLineNumber] int lineNumber = 0,
        [CallerMemberName] string memberName = "")
        => Log(message, LogLevel.Debug, source, lineNumber, memberName);

    public static void Info(
        string message,
        [CallerFilePath] string source = "",
        [CallerLineNumber] int lineNumber = 0,
        [CallerMemberName] string memberName = "")
        => Log(message, LogLevel.Info, source, lineNumber, memberName);

    public static void Warning(
        string message,
        [CallerFilePath] string source = "",
        [CallerLineNumber] int lineNumber = 0,
        [CallerMemberName] string memberName = "")
        => Log(message, LogLevel.Warning, source, lineNumber, memberName);

    public static void Error(
        string message,
        [CallerFilePath] string source = "",
        [CallerLineNumber] int lineNumber = 0,
        [CallerMemberName] string memberName = "")
        => Log(message, LogLevel.Error, source, lineNumber, memberName);

    public static void Critical(
        string message,
        [CallerFilePath] string source = "",
        [CallerLineNumber] int lineNumber = 0,
        [CallerMemberName] string memberName = "")
        => Log(message, LogLevel.Critical, source, lineNumber, memberName);
}