import React from 'react';
import './Header.css';
import axiomLogo from './logo.svg'; // Replace with your actual logo path

function Header() {
  return (
    <div className="Header">
      <div className="Header-left">
        <img src={axiomLogo} alt="Axiom Logo" className="Header-logo" />
        <span className="Header-title">Vertex Central</span>
      </div>
      <div className="Header-right">
        <span className="User-name">System Admin</span>
        <span className="User-role">Role: SA</span>
      </div>
    </div>
  );
}

export default Header;

