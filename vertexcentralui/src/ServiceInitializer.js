
import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import logo from './logo.svg';
import './ServiceInitializer.css';

function ServiceInitializer() 
{
  console.log("Running on port:", window.location.port);
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/main-window');
    }, 2500);
    return () => clearTimeout(timer);
  }, [navigate]);
  
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
      </header>
    </div>
  );
}

export default ServiceInitializer;
