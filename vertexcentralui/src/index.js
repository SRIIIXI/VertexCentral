import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import reportWebVitals from './reportWebVitals';
import './index.css';

import App from './App';
import Login from './Login';
import ServiceInitializer from './ServiceInitializer';
import MainWindow from './MainWindow';
import ForgotPassword from './ForgotPassword';
import SideBar from './SideBar';
import Header from './Header';
import PaginationBar from './PaginationBar';
import TopBar from './TopBar';
import SlidePanel from './SlidePanel';

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
import Firmwares from './Firmwares';

import DeviceForm from './DeviceForm';
import EnterpriseForm from './EnterpriseForm';
import ClusterForm from './ClusterForm';
import SiteForm from './SiteForm';
import ZoneForm from './ZoneForm';
import AssetForm from './AssetForm';  

import Applications from './Applications'
import Features from './Features';
import Rules from './Rules';

import Roles from './Roles';
import Users from './Users';
import Permissions from './Permissions';

import Settings from './Settings';  
import SessionLogs from './SessionLogs';


// ...import other modules

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<App />} />
      <Route path="/login" element={<Login />} />
      <Route path="/service-initializer" element={<ServiceInitializer/>}/>
      <Route path="/main-window" element={<MainWindow />} />
      <Route path="/forgot-password" element={<ForgotPassword />} />
      <Route path="/side-bar" element={<SideBar />} />
      <Route path="/header" element={<Header />} />
      <Route path="/pagination-bar" element={<PaginationBar />} /> 
      <Route path="/top-bar" element={<TopBar />} />
      <Route path="/slide-panel" element={<SlidePanel />} />

      <Route path="/dashboard-sa" element={<DashboardSA />} />
      <Route path="/dashboard-ta" element={<DashboardTA />} />
      <Route path="/dashboard-guest" element={<DashboardGuest />} />
      <Route path="/dashboard-agent" element={<DashboardAgent />} />

      <Route path="/devices" element={<Devices />} />
      <Route path="/enterprises" element={<Enterprises />} />
      <Route path="/clusters" element={<Clusters />} />
      <Route path="/sites" element={<Sites />} />
      <Route path="/zones" element={<Zones />} />
      <Route path="/assets" element={<Assets />} />
      <Route path="/firmwares" element={<Firmwares />} />

      <Route path="/zone-form" element={<ZoneForm />} />


      <Route path="/applications" element={<Applications />} />
      <Route path="/features" element={<Features />} />
      <Route path="/rules" element={<Rules />} />

      <Route path="/roles" element={<Roles />} />
      <Route path="/users" element={<Users />} />
      <Route path="/permissions" element={<Permissions />} />

      <Route path="/settings" element={<Settings />} />
      <Route path="/session-logs" element={<SessionLogs />} />
      {/* Add other routes as needed */}
    </Routes>
  </BrowserRouter>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
