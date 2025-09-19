import React, { useState, useEffect } from 'react';
import TopBar from './TopBar';
import PaginationBar from './PaginationBar';
import './Listing.css';

function SessionLogs() {
  const [logs, setLogs] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    async function fetchLogs() {
      const response = await fetch('https://localhost:5001/api/v1/sessionlog');
      const data = await response.json();
      console.log("Logs length:", logs.length);
      setLogs(data);
    }
    fetchLogs();
  }, []);

  const paginatedLogs = logs.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  function getDuration(start, end) {
  const startTime = new Date(start);
  const endTime = new Date(end);
  const diffMs = endTime - startTime;
  const diffHrs = Math.floor(diffMs / (1000 * 60 * 60));
  const diffMin = Math.floor((diffMs / (1000 * 60)) % 60);
  return `${diffHrs}h ${diffMin}m`;
}


  return (
    <div className="SessionLogs">
      <TopBar
        entity="Session Log"
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        onSearchSubmit={() => console.log('Search:', searchTerm)}
        showAdd={false}
        showDelete={false}
        showImport={false}
        showExport={true}
      />

      <table className="ListingTable">
        <thead>
          <tr>
            <th>User</th>
            <th>IP Address</th>
            <th>Login Time</th>
            <th>Logout Time</th>
            <th>Session Duration</th>
          </tr>
        </thead>
        <tbody>
          {paginatedLogs.map((log, index) => (
            <tr key={index}>
              <td>{log.UserId}</td>
              <td>{log.IpAddress}</td>
              <td>{new Date(log.TimestampLoggedIn).toLocaleString()}</td>
              <td>{new Date(log.TimestampLoggedOut).toLocaleString()}</td>
              <td>{getDuration(log.TimestampLoggedIn, log.TimestampLoggedOut)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <PaginationBar
        currentPage={currentPage}
        totalItems={logs.length}
        itemsPerPage={itemsPerPage}
        onPageChange={setCurrentPage}
      />
    </div>
  );
}

export default SessionLogs;
