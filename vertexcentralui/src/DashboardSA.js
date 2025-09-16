import React, { useEffect, useState } from 'react';
import './Dashboard.css';

function DashboardSA() {
  const [stats, setStats] = useState({
    activeSessions: 0,
    failedLogins: 0,
    zoneCount: 0,
    deviceCount: 0,
    apiLatency: 0,
    dbStatus: 'Unknown',
  });

  // useEffect(() => {
  //   async function fetchStats() {
  //     // Replace with real API call
  //     const response = await fetch('/api/admin-dashboard');
  //     const data = await response.json();
  //     setStats(data);
  //   }
  //   fetchStats();
  // }, []);

    useEffect(() => {
    // Simulate delayed fetch
    const timer = setTimeout(() => {
      setStats({
        activeSessions: 12,
        failedLogins: 3,
        zoneCount: 8,
        deviceCount: 42,
        apiLatency: 87,
        dbStatus: 'Connected',
      });
    }, 500);
    return () => clearTimeout(timer);
  }, []);

  return (
    <div className="DashboardSA">
      <h2 className="DashboardTitle">System Admin Dashboard</h2>
      <div className="DashboardGrid">
        <DashboardTile label="Active Sessions" value={stats.activeSessions} />
        <DashboardTile label="Failed Logins (24h)" value={stats.failedLogins} />
        <DashboardTile label="Zones" value={stats.zoneCount} />
        <DashboardTile label="Devices" value={stats.deviceCount} />
        <DashboardTile label="API Latency" value={`${stats.apiLatency} ms`} />
        <DashboardTile label="DB Status" value={stats.dbStatus} />
      </div>
    </div>
  );
}

function DashboardTile({ label, value }) {
  return (
    <div className="DashboardTile">
      <div className="TileLabel">{label}</div>
      <div className="TileValue">{value}</div>
    </div>
  );
}

export default DashboardSA;
