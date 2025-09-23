import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

import './SideBar.css';

function SideBar({ activeItem, setActiveItem }) {

  const navigate = useNavigate();

  const handleClick = (label) => {
    setActiveItem(label);
    console.log(label)
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
        {['Enterprises', 'Clusters', 'Sites', 'Zones', 'Devices', 'Assets', 'Firmwares'].map(label => (
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
        {['Applications', 'Features','Rules'].map(label => (
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
        {['Settings','Session Logs'].map(label => (
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
            onClick={() => navigate('/login')}
          >
            {label}
          </li>
        ))}

      </ul>
    </div>
  );
}

export default SideBar;
