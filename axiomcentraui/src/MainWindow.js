import React from 'react';
import Header from './Header';
import Sidebar from './SideBar';
import DashboardSA from './DashboardSA'; // For now, hardcoded

import './MainWindow.css';

function MainWindow() {
  return (
    <div className="MainWindow">
      {/* Top header bar */}
      <Header />

      {/* Main content area: Sidebar + Dashboard */}
      <div className="MainBody">
        <Sidebar />
        <div className="DashboardFrame">
          <DashboardSA />
        </div>
      </div>
    </div>
  );
}

export default MainWindow;
