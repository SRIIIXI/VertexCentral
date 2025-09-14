import React, { useState } from 'react';
import './SideBar.css';

function SideBar() {
  const [activeItem, setActiveItem] = useState('Overview');

  const handleClick = (label) => {
    setActiveItem(label);
  };

  return (
    <div className="Sidebar">
      <ul className="Sidebar-menu">
        {/* Default Dashboard */}
        <li
          className={`Sidebar-item ${activeItem === 'Overview' ? 'active' : ''}`}
          onClick={() => handleClick('Overview')}
        >
          Overview
        </li>

        <hr className="Sidebar-separator" />

        {/* Infrastructure */}
        {['Enterprises', 'Clusters', 'Sites', 'Zones', 'Devices', 'Assets'].map(label => (
          <li
            key={label}
            className={`Sidebar-item ${activeItem === label ? 'active' : ''}`}
            onClick={() => handleClick(label)}
          >
            {label}
          </li>
        ))}

        <hr className="Sidebar-separator" />

        {/* Logic */}
        {['Applications', 'Rules'].map(label => (
          <li
            key={label}
            className={`Sidebar-item ${activeItem === label ? 'active' : ''}`}
            onClick={() => handleClick(label)}
          >
            {label}
          </li>
        ))}

        <hr className="Sidebar-separator" />

        {/* Governance */}
        {['Users', 'Roles', 'Permissions'].map(label => (
          <li
            key={label}
            className={`Sidebar-item ${activeItem === label ? 'active' : ''}`}
            onClick={() => handleClick(label)}
          >
            {label}
          </li>
        ))}

        <hr className="Sidebar-separator" />

        {/* Settings */}
        {['Settings'].map(label => (
          <li
            key={label}
            className={`Sidebar-item ${activeItem === label ? 'active' : ''}`}
            onClick={() => handleClick(label)}
          >
            {label}
          </li>
        ))}

        <hr className="Sidebar-separator" />

        {/* Session */}
        {['Logout'].map(label => (
          <li
            key={label}
            className={`Sidebar-item ${activeItem === label ? 'active' : ''}`}
            onClick={() => handleClick(label)}
          >
            {label}
          </li>
        ))}

      </ul>
    </div>
  );
}

export default SideBar;
