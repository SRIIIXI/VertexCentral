import React, { useState } from 'react';
import Header from './Header';
import SideBar from './SideBar';
import DashboardSA from './DashboardSA';
import Devices from './Devices';
import Rules from './Rules';
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
      case 'Rules':
        return <Rules />;
      // Add other cases as needed
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
