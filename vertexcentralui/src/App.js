
import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import logo from './logo.svg';
import './App.css';

function App() 
{
  console.log("Running on port:", window.location.port);
  const navigate = useNavigate();

  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/login');
    }, 1000);
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

export default App;
