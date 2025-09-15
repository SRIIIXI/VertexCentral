import React, { useState } from 'react';
import './Listing.css';
import ZoneForm from './ZoneForm';

function Zones() {
  const [selectedZoneIds, setSelectedZoneIds] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');

  const [isPanelOpen, setPanelOpen] = useState(false);
  const [panelMode, setPanelMode] = useState('add'); // or 'edit'
  const [selectedZone, setSelectedZone] = useState(null);

  const [zones] = useState([
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

  return (
    <div className="Zones">
      <div className="TopBar">
        <div className="TopBar-left">
          <input
            type="text"
            placeholder="Search zones..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="SearchInput"
          />
          <button className="TopBarButton" onClick={handleSearch}>Search</button>
        </div>

        <div className="TopBar-right">
          <button className="TopBarButton"
                        onClick={() => {
              setPanelMode('add');
              setSelectedZone(null);
              setPanelOpen(true);
              console.log('Add Zone Cliked');
            }}
          >Add</button>

          <button
            className="TopBarButton"
            disabled={selectedZoneIds.length === 0}
          >
            Delete
          </button>
          <button className="TopBarButton">Import</button>
          <button className="TopBarButton">Export</button>
        </div>
      </div>

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
          {zones.map((zone) => (
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
                <button className="IconButton"
                onClick={() => {
                setPanelMode('edit');
                setSelectedZone(zone);
                setPanelOpen(true);
                }}
                >✏️</button>
                <button className="IconButton">🗑️</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      <div className="PaginationBar">Pagination controls here</div>

    {isPanelOpen && (
      <div className="SlidePanel">
        <ZoneForm
          mode={panelMode}
          data={selectedZone}
          onSave={(newZone) => {
            console.log('Saved zone:', newZone);
            setPanelOpen(false);
            setSelectedZone(null); // optional: reset after save
          }}
          onCancel={() => {
            setSelectedZone(null); // ✅ this line
            setPanelOpen(false);   // ✅ and this line
          }}        
      />
      </div>
    )}

    </div>
  );
}

export default Zones;