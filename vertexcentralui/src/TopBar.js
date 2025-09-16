import React from 'react';
import './Listing.css';

function TopBar({
  entity,
  searchTerm,
  onSearchChange,
  onSearchSubmit,
  onAdd,
  onDelete,
  showAdd = true,
  showDelete = true,
  showImport = false,
  showExport = false,
}) {
  return (
    <div className="TopBar">
      <div className="SearchGroup">
        <input
          type="text"
          className="SearchInput"
          placeholder={`Search ${entity}s...`}
          value={searchTerm}
          onChange={(e) => onSearchChange(e.target.value)}
        />
        <button className="SearchButton" onClick={onSearchSubmit}>🔍</button>
      </div>

      <div className="ActionGroup">
        {showImport && <button className="ActionButton">Import</button>}
        {showExport && <button className="ActionButton">Export</button>}
        {showAdd && <button className="ActionButton" onClick={onAdd}>Add {entity}</button>}
        {showDelete && <button className="ActionButton" onClick={onDelete}>Delete</button>}
      </div>
    </div>
  );
}



export default TopBar;

