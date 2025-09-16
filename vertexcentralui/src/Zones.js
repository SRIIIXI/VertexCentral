import React, { useState } from 'react';
import './Listing.css';
import ZoneForm from './ZoneForm';
import PaginationBar from './PaginationBar';
import TopBar from './TopBar';
import SlidePanel from './SlidePanel';

function Zones() {
  const [selectedZoneIds, setSelectedZoneIds] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');

  const [isPanelOpen, setPanelOpen] = useState(false);
  const [panelMode, setPanelMode] = useState('add'); // or 'edit'
  const [selectedZone, setSelectedZone] = useState(null);

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;

  const [zones, setZones] = useState([
    {
      id: 'Z001',
      name: 'Billing Counter',
      site: 'Site A',
      cluster: 'Cluster 1',
      access: 'Restricted',
    },
    {
      id: 'Z002',
      name: 'Operation Theatre',
      site: 'Site B',
      cluster: 'Cluster 2',
      access: 'Forbidden',
    },
    {
      id: 'Z003',
      name: 'Boiler Room',
      site: 'Site C',
      cluster: 'Cluster 1',
      access: 'Monitored',
    },
     {
      id: 'Z004',
      name: 'Billing Counter',
      site: 'Site A',
      cluster: 'Cluster 1',
      access: 'Restricted',
    },
    {
      id: 'Z005',
      name: 'Operation Theatre',
      site: 'Site B',
      cluster: 'Cluster 2',
      access: 'Forbidden',
    },
    {
      id: 'Z006',
      name: 'Boiler Room',
      site: 'Site C',
      cluster: 'Cluster 1',
      access: 'Monitored',
    }, 
  ]);

  const toggleSelectAll = (e) => {
    if (e.target.checked) {
      setSelectedZoneIds(zones.map((z) => z.id));
    } else {
      setSelectedZoneIds([]);
    }
  };

  const toggleSelectRow = (id) => {
    setSelectedZoneIds((prev) =>
      prev.includes(id) ? prev.filter((zid) => zid !== id) : [...prev, id]
    );
  };

  const handleSearch = () => {
    console.log('Searching for:', searchTerm);
    // TODO: Filter zones based on searchTerm
  };

    const paginatedZones = zones.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

    function handleBulkDelete() {
    const confirmed = window.confirm(`Delete ${selectedZoneIds.length} selected zones?`);
    if (!confirmed) return;

    const remaining = zones.filter(zone => !selectedZoneIds.includes(zone.id));
    setZones(remaining);
    setSelectedZoneIds([]);
  }
  
  return (
    <div className="Zones">

    <TopBar
      entity="Zone"
      searchTerm={searchTerm}
      onSearchChange={setSearchTerm}
      onSearchSubmit={() => console.log('Search:', searchTerm)}
      onAdd={() => {
        setPanelMode('add');
        setSelectedZone(null);
        setPanelOpen(true);
      }}
      onDelete={handleBulkDelete}
      showAdd={true}
      showDelete={true}
      showExport={false}
      showImport={false}

    />

      <table className="ListingTable">
        <thead>
          <tr>
            <th>
              <input
                type="checkbox"
                checked={selectedZoneIds.length === zones.length}
                onChange={toggleSelectAll}
              />
            </th>
            <th>Zone ID</th>
            <th>Zone Name</th>
            <th>Site</th>
            <th>Cluster</th>
            <th>Access Level</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>

          {paginatedZones.map((zone) => (
          <tr key={zone.id}>
            <td>
              <input
                type="checkbox"
                checked={selectedZoneIds.includes(zone.id)}
                onChange={() => toggleSelectRow(zone.id)}
              />
            </td>
            <td>{zone.id}</td>
            <td>{zone.name}</td>
            <td>{zone.site}</td>
            <td>{zone.cluster}</td>
            <td>{zone.access}</td>
            <td>
              <button
                className="IconButton"
                onClick={() => {
                  setPanelMode('edit');
                  setSelectedZone(zone);
                  setPanelOpen(true);
                }}
              >
                ✏️
              </button>
              <button className="IconButton">🗑️</button>
            </td>
          </tr>
          ))}
          
        </tbody>
      </table>

    <PaginationBar
      currentPage={currentPage}
      totalItems={zones.length}
      itemsPerPage={itemsPerPage}
      onPageChange={setCurrentPage}
    />

    {isPanelOpen && (
      <SlidePanel onClose={() => {
        setPanelOpen(false);
        setSelectedZone(null);
      }}>
        <ZoneForm
          mode={panelMode}
          data={selectedZone}
          onSave={(newZone) => {
            console.log('Saved zone:', newZone);
            setPanelOpen(false);
            setSelectedZone(null);
          }}
          onCancel={() => {
            setPanelOpen(false);
            setSelectedZone(null);
          }}
        />
      </SlidePanel>
    )}


    </div>
  );
}

export default Zones;