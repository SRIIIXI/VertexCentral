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
      const response = await fetch('/api/session-logs');
      const data = await response.json();
      setLogs(data);
    }
    fetchLogs();
  }, []);

  const paginatedLogs = logs.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

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
              <td>{log.user}</td>
              <td>{log.ip}</td>
              <td>{log.loginTime}</td>
              <td>{log.logoutTime}</td>
              <td>{log.duration}</td>
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
