import React, { useState } from 'react';
import Header from './Header';
import SideBar from './SideBar';

import DashboardSA from './DashboardSA';
import DashboardTA from './DashboardTA';
import DashboardGuest from './DashboardGuest';
import DashboardAgent from './DashboardAgent';

import Devices from './Devices';
import Enterprises from './Enterprises';
import Clusters from './Clusters';
import Sites from './Sites';
import Zones from './Zones';
import Assets from './Assets';  

import Applications from './Applications';
import Features from './Features';
import Rules from './Rules';

import Roles from './Roles';
import Users from './Users';
import Permissions from './Permissions';

import Settings from './Settings';  
import SessionLogs from './SessionLogs';
// ...import other modules

import './MainWindow.css';

function MainWindow() {
  const [activeItem, setActiveItem] = useState('Overview');

  console.log(activeItem)

  const renderContent = () => {
    switch (activeItem) {
      case 'Overview':
        return <DashboardSA />;

      case 'Devices':
        return <Devices />;
      case 'Enterprises':
        return <Enterprises />;
      case 'Clusters':
        return <Clusters />;
      case 'Sites':
        return <Sites />;
      case 'Zones':
        return <Zones />;
      case 'Assets':
        return <Assets />;

      case 'Applications':
        return <Applications />;
      case 'Features':
        return <Features />;
      case 'Rules':
        return <Rules />;

      case 'Roles':
        return <Roles />;
      case 'Users':
        return <Users />;
      case 'Permissions':
        return <Permissions />;
        
      case 'Settings':
        return <Settings />;
      case 'Session Logs':
        return <SessionLogs />;

      // ...handle other cases
      default:
        return <div style={{ padding: '1rem' }}>Coming Soon: {activeItem}</div>;
    }
  };

  return (
    <div className="MainWindow">
      <Header />
      <div className="MainBody">
        <SideBar activeItem={activeItem} setActiveItem={setActiveItem} />
        <div className="DashboardFrame">
          {renderContent()}
        </div>
      </div>
    </div>
  );
}

export default MainWindow;
